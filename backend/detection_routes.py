from flask import Blueprint, request, jsonify, send_file
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, UserHistory, Sign, VideoSession, SavedSign
from video_processor import VideoProcessor
from datetime import datetime, timedelta
import os
import base64
import cv2
import numpy as np
from pathlib import Path

detection_bp = Blueprint('detection', __name__, url_prefix='/api/detection')

video_processor = VideoProcessor()

@detection_bp.route('/signs', methods=['GET'])
def get_all_signs():
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        category = request.args.get('category')
        search = request.args.get('search')

        query = Sign.query

        if category:
            query = query.filter_by(category=category)

        if search:
            query = query.filter(
                (Sign.name.ilike(f'%{search}%')) |
                (Sign.english_translation.ilike(f'%{search}%')) |
                (Sign.hindi_translation.ilike(f'%{search}%'))
            )

        paginated_signs = query.paginate(page=page, per_page=per_page)

        return jsonify({
            'signs': [sign.to_dict() for sign in paginated_signs.items],
            'total': paginated_signs.total,
            'pages': paginated_signs.pages,
            'current_page': page
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch signs: {str(e)}'}), 500

@detection_bp.route('/signs/<sign_id>', methods=['GET'])
def get_sign(sign_id):
    try:
        sign = Sign.query.get(sign_id)

        if not sign:
            return jsonify({'error': 'Sign not found'}), 404

        return jsonify({'sign': sign.to_dict()}), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch sign: {str(e)}'}), 500

@detection_bp.route('/signs/category/<category>', methods=['GET'])
def get_signs_by_category(category):
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)

        paginated_signs = Sign.query.filter_by(category=category).paginate(
            page=page, per_page=per_page
        )

        return jsonify({
            'signs': [sign.to_dict() for sign in paginated_signs.items],
            'total': paginated_signs.total,
            'pages': paginated_signs.pages,
            'current_page': page,
            'category': category
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch signs: {str(e)}'}), 500

@detection_bp.route('/detect-frame', methods=['POST'])
@jwt_required()
def detect_from_frame():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()

        if 'frame' not in data:
            return jsonify({'error': 'No frame provided'}), 400

        frame_data = data['frame']
        min_confidence = data.get('min_confidence', 0.5)

        if isinstance(frame_data, str):
            try:
                frame_bytes = base64.b64decode(frame_data)
                nparr = np.frombuffer(frame_bytes, np.uint8)
                frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            except Exception as e:
                return jsonify({'error': f'Invalid frame data: {str(e)}'}), 400
        else:
            return jsonify({'error': 'Frame must be base64 encoded'}), 400

        result = video_processor.process_camera_frame(frame, min_confidence)

        if result.get('sign'):
            sign = Sign.query.filter_by(name=result['sign']).first()

            history_entry = UserHistory(
                user_id=user_id,
                sign_id=sign.id if sign else None,
                detected_text=result['sign'],
                confidence=result['confidence'],
                detection_type='frame',
                source='camera'
            )

            db.session.add(history_entry)
            db.session.commit()

        return jsonify({
            'sign': result.get('sign'),
            'confidence': result.get('confidence'),
            'timestamp': result.get('timestamp')
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Detection failed: {str(e)}'}), 500

@detection_bp.route('/detect-video', methods=['POST'])
@jwt_required()
def detect_from_video():
    try:
        user_id = get_jwt_identity()

        if 'video' not in request.files:
            return jsonify({'error': 'No video file provided'}), 400

        video_file = request.files['video']

        if video_file.filename == '':
            return jsonify({'error': 'No selected video file'}), 400

        if not video_file.filename.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')):
            return jsonify({'error': 'Invalid video format'}), 400

        os.makedirs('uploads/videos', exist_ok=True)
        video_path = f"uploads/videos/{user_id}_{datetime.utcnow().timestamp()}.mp4"
        video_file.save(video_path)

        output_path = f"uploads/videos/detected_{user_id}_{datetime.utcnow().timestamp()}.mp4"

        result, error = video_processor.process_video_file(video_path, output_path)

        if error:
            return jsonify({'error': error}), 400

        for detection in result.get('detections', []):
            sign = Sign.query.filter_by(name=detection['sign']).first()

            history_entry = UserHistory(
                user_id=user_id,
                sign_id=sign.id if sign else None,
                detected_text=detection['sign'],
                confidence=detection['confidence'],
                detection_type='video',
                source='video_file'
            )

            db.session.add(history_entry)

        db.session.commit()

        return jsonify({
            'message': 'Video processed successfully',
            'total_frames': result['total_frames'],
            'fps': result['fps'],
            'duration': result['duration'],
            'detections_found': len(result['detections']),
            'detections': result['detections'][:50],
            'output_video': output_path
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Video processing failed: {str(e)}'}), 500

@detection_bp.route('/history', methods=['GET'])
@jwt_required()
def get_user_history():
    try:
        user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        days = request.args.get('days', 30, type=int)

        cutoff_date = datetime.utcnow() - timedelta(days=days)

        paginated_history = UserHistory.query.filter(
            UserHistory.user_id == user_id,
            UserHistory.detection_timestamp >= cutoff_date
        ).order_by(UserHistory.detection_timestamp.desc()).paginate(page=page, per_page=per_page)

        return jsonify({
            'history': [entry.to_dict() for entry in paginated_history.items],
            'total': paginated_history.total,
            'pages': paginated_history.pages,
            'current_page': page,
            'days': days
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch history: {str(e)}'}), 500

@detection_bp.route('/history/stats', methods=['GET'])
@jwt_required()
def get_history_stats():
    try:
        user_id = get_jwt_identity()
        days = request.args.get('days', 30, type=int)

        cutoff_date = datetime.utcnow() - timedelta(days=days)

        total_detections = UserHistory.query.filter(
            UserHistory.user_id == user_id,
            UserHistory.detection_timestamp >= cutoff_date
        ).count()

        unique_signs = db.session.query(db.func.count(db.func.distinct(UserHistory.sign_id))).filter(
            UserHistory.user_id == user_id,
            UserHistory.detection_timestamp >= cutoff_date
        ).scalar()

        avg_confidence = db.session.query(db.func.avg(UserHistory.confidence)).filter(
            UserHistory.user_id == user_id,
            UserHistory.detection_timestamp >= cutoff_date
        ).scalar() or 0

        top_signs = db.session.query(
            UserHistory.detected_text,
            db.func.count(UserHistory.id).label('count')
        ).filter(
            UserHistory.user_id == user_id,
            UserHistory.detection_timestamp >= cutoff_date
        ).group_by(UserHistory.detected_text).order_by(
            db.func.count(UserHistory.id).desc()
        ).limit(10).all()

        return jsonify({
            'total_detections': total_detections,
            'unique_signs': unique_signs,
            'average_confidence': float(avg_confidence),
            'top_signs': [{'sign': sign, 'count': count} for sign, count in top_signs],
            'period_days': days
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch stats: {str(e)}'}), 500

@detection_bp.route('/save-sign/<sign_id>', methods=['POST'])
@jwt_required()
def save_sign(sign_id):
    try:
        user_id = get_jwt_identity()

        sign = Sign.query.get(sign_id)
        if not sign:
            return jsonify({'error': 'Sign not found'}), 404

        existing = SavedSign.query.filter_by(user_id=user_id, sign_id=sign_id).first()
        if existing:
            return jsonify({'error': 'Sign already saved'}), 409

        data = request.get_json() or {}
        notes = data.get('notes', '')

        saved_sign = SavedSign(
            user_id=user_id,
            sign_id=sign_id,
            notes=notes
        )

        db.session.add(saved_sign)
        db.session.commit()

        return jsonify({
            'message': 'Sign saved successfully',
            'saved_sign': saved_sign.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to save sign: {str(e)}'}), 500

@detection_bp.route('/saved-signs', methods=['GET'])
@jwt_required()
def get_saved_signs():
    try:
        user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)

        paginated_saved = SavedSign.query.filter_by(user_id=user_id).paginate(
            page=page, per_page=per_page
        )

        return jsonify({
            'saved_signs': [saved.to_dict() for saved in paginated_saved.items],
            'total': paginated_saved.total,
            'pages': paginated_saved.pages,
            'current_page': page
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch saved signs: {str(e)}'}), 500

@detection_bp.route('/unsave-sign/<sign_id>', methods=['DELETE'])
@jwt_required()
def unsave_sign(sign_id):
    try:
        user_id = get_jwt_identity()

        saved_sign = SavedSign.query.filter_by(user_id=user_id, sign_id=sign_id).first()

        if not saved_sign:
            return jsonify({'error': 'Saved sign not found'}), 404

        db.session.delete(saved_sign)
        db.session.commit()

        return jsonify({'message': 'Sign removed from saved'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to remove sign: {str(e)}'}), 500
