from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
import base64
from sign_detector import get_detector
from models import db, UserHistory, Sign
from datetime import datetime
import logging

detection_bp = Blueprint('detection', __name__, url_prefix='/api/detection')

@detection_bp.route('/detect-frame', methods=['POST'])
@jwt_required()
def detect_frame():
    user_id = get_jwt_identity()
    print(f"\n{'='*60}")
    print(f"🎯 DETECT FRAME REQUEST: {user_id}")
    print(f"{'='*60}\n")
    
    try:
        data = request.get_json()
        if not data or 'frame' not in data:
            return jsonify({'error': 'Frame data required'}), 400

        frame_data = data['frame']
        print(f"✓ Frame received: {len(frame_data)} bytes")

        detector = get_detector()
        result = detector.detect_from_image(frame_data)

        if result['success']:
            sign_name = result['sign']
            confidence = result['confidence']
            
            print(f"✓ Detected: {sign_name} ({confidence:.2%})")

            # Log detection to database
            sign = Sign.query.filter_by(name=sign_name).first()
            if sign:
                history = UserHistory(
                    user_id=user_id,
                    sign_id=sign.id,
                    detected_text=sign_name,
                    confidence=confidence,
                    detection_type='frame',
                    source='app',
                    is_correct=True
                )
                db.session.add(history)
                db.session.commit()
                print(f"✓ Detection logged to database")

            result['sign_id'] = sign.id if sign else None
            result['translation'] = sign.english_translation if sign else sign_name
            
            print(f"✅ Detection complete: {sign_name}")
            print(f"{'='*60}\n")
            
            return jsonify(result), 200
        else:
            print(f"❌ Detection failed: {result.get('error')}")
            print(f"{'='*60}\n")
            return jsonify(result), 400

    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        print(f"{'='*60}\n")
        return jsonify({'error': f'Detection failed: {str(e)}'}), 500


@detection_bp.route('/signs', methods=['GET'])
@jwt_required()
def get_all_signs():
    print(f"\n{'='*60}")
    print(f"📋 GET ALL SIGNS")
    print(f"{'='*60}\n")
    
    try:
        category = request.args.get('category')
        difficulty = request.args.get('difficulty')

        query = Sign.query

        if category:
            query = query.filter_by(category=category)
        if difficulty:
            query = query.filter_by(difficulty_level=difficulty)

        signs = query.all()
        print(f"✓ Retrieved {len(signs)} signs")
        
        return jsonify({
            'signs': [sign.to_dict() for sign in signs],
            'total': len(signs)
        }), 200

    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        print(f"{'='*60}\n")
        return jsonify({'error': str(e)}), 500


@detection_bp.route('/model-info', methods=['GET'])
@jwt_required()
def get_model_info():
    detector = get_detector()
    info = detector.get_model_info()
    return jsonify(info), 200


@detection_bp.route('/detection-history', methods=['GET'])
@jwt_required()
def get_detection_history():
    user_id = get_jwt_identity()
    limit = request.args.get('limit', 20, type=int)

    history = UserHistory.query.filter_by(user_id=user_id).order_by(
        UserHistory.detection_timestamp.desc()
    ).limit(limit).all()

    return jsonify({
        'history': [h.to_dict() for h in history],
        'total': len(history)
    }), 200
