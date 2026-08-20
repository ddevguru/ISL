"""Learning Module for ISL Practice"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Sign, SignLearningProgress
from datetime import datetime

learning_bp = Blueprint('learning', __name__, url_prefix='/api/learning')

@learning_bp.route('/signs', methods=['GET'])
@jwt_required()
def get_signs_for_learning():
    user_id = get_jwt_identity()
    category = request.args.get('category')
    difficulty = request.args.get('difficulty', 'Easy')
    
    query = Sign.query.filter_by(difficulty_level=difficulty)
    if category:
        query = query.filter_by(category=category)
    
    signs = query.all()
    return jsonify({'signs': [s.to_dict() for s in signs]}), 200

@learning_bp.route('/progress/<sign_id>', methods=['POST'])
@jwt_required()
def update_learning_progress(sign_id):
    user_id = get_jwt_identity()
    data = request.get_json()
    
    progress = SignLearningProgress.query.filter_by(
        user_id=user_id,
        sign_id=sign_id
    ).first()
    
    if not progress:
        progress = SignLearningProgress(user_id=user_id, sign_id=sign_id)
        db.session.add(progress)
    
    progress.times_practiced += 1
    if data.get('correct'):
        progress.times_detected_correctly += 1
    
    accuracy = (progress.times_detected_correctly / progress.times_practiced) * 100
    progress.accuracy = accuracy
    progress.last_practiced = datetime.utcnow()
    
    if accuracy >= 85:
        progress.mastered = True
    
    db.session.commit()
    
    return jsonify(progress.to_dict()), 200

@learning_bp.route('/progress', methods=['GET'])
@jwt_required()
def get_learning_progress():
    user_id = get_jwt_identity()
    limit = request.args.get('limit', 50, type=int)
    
    progress = SignLearningProgress.query.filter_by(user_id=user_id).limit(limit).all()
    
    mastered = sum(1 for p in progress if p.mastered)
    total_practice = sum(p.times_practiced for p in progress)
    
    return jsonify({
        'progress': [p.to_dict() for p in progress],
        'stats': {
            'total_signs_practiced': len(progress),
            'mastered_signs': mastered,
            'total_practice_sessions': total_practice
        }
    }), 200

@learning_bp.route('/categories', methods=['GET'])
def get_categories():
    signs = Sign.query.all()
    categories = list(set(s.category for s in signs if s.category))
    return jsonify({'categories': categories}), 200
