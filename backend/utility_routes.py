from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, SignLearningProgress, VideoSession, Sign
from dataset_loader import DatasetLoader
from datetime import datetime

utils_bp = Blueprint('utils', __name__, url_prefix='/api/utils')
dataset_loader = DatasetLoader()

@utils_bp.route('/dataset/load', methods=['POST'])
def load_dataset():
    try:
        count, message = dataset_loader.insert_signs_into_db()
        return jsonify({
            'message': message,
            'signs_loaded': count
        }), 200
    except Exception as e:
        return jsonify({'error': f'Failed to load dataset: {str(e)}'}), 500

@utils_bp.route('/dataset/stats', methods=['GET'])
def get_dataset_stats():
    try:
        stats = dataset_loader.get_dataset_statistics()
        return jsonify(stats), 200
    except Exception as e:
        return jsonify({'error': f'Failed to fetch stats: {str(e)}'}), 500

@utils_bp.route('/learning-progress', methods=['GET'])
@jwt_required()
def get_learning_progress():
    try:
        user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)

        paginated_progress = SignLearningProgress.query.filter_by(
            user_id=user_id
        ).order_by(
            SignLearningProgress.accuracy.desc()
        ).paginate(page=page, per_page=per_page)

        return jsonify({
            'progress': [p.to_dict() for p in paginated_progress.items],
            'total': paginated_progress.total,
            'pages': paginated_progress.pages,
            'current_page': page
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch progress: {str(e)}'}), 500

@utils_bp.route('/learning-progress/summary', methods=['GET'])
@jwt_required()
def get_progress_summary():
    try:
        user_id = get_jwt_identity()

        total_practiced = db.session.query(
            db.func.sum(SignLearningProgress.times_practiced)
        ).filter(SignLearningProgress.user_id == user_id).scalar() or 0

        total_mastered = SignLearningProgress.query.filter(
            SignLearningProgress.user_id == user_id,
            SignLearningProgress.mastered == True
        ).count()

        avg_accuracy = db.session.query(
            db.func.avg(SignLearningProgress.accuracy)
        ).filter(SignLearningProgress.user_id == user_id).scalar() or 0

        recent_progress = SignLearningProgress.query.filter_by(
            user_id=user_id
        ).order_by(
            SignLearningProgress.last_practiced.desc()
        ).limit(5).all()

        return jsonify({
            'total_practiced': total_practiced,
            'total_mastered': total_mastered,
            'average_accuracy': float(avg_accuracy),
            'recent': [p.to_dict() for p in recent_progress]
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch summary: {str(e)}'}), 500

@utils_bp.route('/learning-progress/<sign_id>', methods=['PUT'])
@jwt_required()
def update_learning_progress(sign_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()

        sign = Sign.query.get(sign_id)
        if not sign:
            return jsonify({'error': 'Sign not found'}), 404

        progress = SignLearningProgress.query.filter_by(
            user_id=user_id,
            sign_id=sign_id
        ).first()

        if not progress:
            progress = SignLearningProgress(
                user_id=user_id,
                sign_id=sign_id
            )
            db.session.add(progress)

        if 'times_practiced' in data:
            progress.times_practiced += data['times_practiced']

        if 'times_detected_correctly' in data:
            progress.times_detected_correctly += data['times_detected_correctly']

            if progress.times_practiced > 0:
                progress.accuracy = (
                    progress.times_detected_correctly / progress.times_practiced
                ) * 100

        if 'mastered' in data:
            progress.mastered = data['mastered']

        progress.last_practiced = datetime.utcnow()

        db.session.commit()

        return jsonify({
            'message': 'Learning progress updated',
            'progress': progress.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to update progress: {str(e)}'}), 500

@utils_bp.route('/video-sessions', methods=['POST'])
@jwt_required()
def create_video_session():
    try:
        user_id = get_jwt_identity()
        data = request.get_json() or {}

        session = VideoSession(
            user_id=user_id,
            session_type=data.get('session_type', 'live'),
            status='active'
        )

        db.session.add(session)
        db.session.commit()

        return jsonify({
            'message': 'Video session created',
            'session': session.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to create session: {str(e)}'}), 500

@utils_bp.route('/video-sessions/<session_id>', methods=['PUT'])
@jwt_required()
def end_video_session(session_id):
    try:
        user_id = get_jwt_identity()

        session = VideoSession.query.filter_by(
            id=session_id,
            user_id=user_id
        ).first()

        if not session:
            return jsonify({'error': 'Session not found'}), 404

        data = request.get_json() or {}

        session.ended_at = datetime.utcnow()
        session.status = data.get('status', 'completed')

        if session.started_at and session.ended_at:
            duration = (session.ended_at - session.started_at).total_seconds()
            session.duration = int(duration)

        db.session.commit()

        return jsonify({
            'message': 'Video session ended',
            'session': session.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to end session: {str(e)}'}), 500

@utils_bp.route('/video-sessions', methods=['GET'])
@jwt_required()
def get_video_sessions():
    try:
        user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)

        paginated_sessions = VideoSession.query.filter_by(
            user_id=user_id
        ).order_by(VideoSession.started_at.desc()).paginate(page=page, per_page=per_page)

        return jsonify({
            'sessions': [s.to_dict() for s in paginated_sessions.items],
            'total': paginated_sessions.total,
            'pages': paginated_sessions.pages,
            'current_page': page
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch sessions: {str(e)}'}), 500

@utils_bp.route('/categories', methods=['GET'])
def get_categories():
    try:
        categories = db.session.query(Sign.category).distinct().all()
        return jsonify({
            'categories': [str(cat[0]) for cat in categories if cat[0] is not None]
        }), 200
    except Exception as e:
        return jsonify({'error': f'Failed to fetch categories: {str(e)}'}), 500

@utils_bp.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    }), 200
