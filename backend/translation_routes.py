from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from translation_service import TranslationService
from models import db, UserHistory, Sign
from datetime import datetime
import json

translation_bp = Blueprint('translation', __name__, url_prefix='/api/translation')

translation_service = TranslationService()

@translation_bp.route('/signs', methods=['GET'])
def get_all_signs():
    """Get all signs with translations"""
    try:
        language = request.args.get('language', 'english')
        signs = translation_service.get_all_signs()

        result = []
        for sign in signs:
            result.append({
                'id': sign['id'],
                'name': sign['english'],
                'english': sign['english'],
                'hindi': sign['hindi'],
                'variations': sign.get('variations', []),
                'translation': sign.get(language, sign['english'])
            })

        return jsonify({
            'signs': result,
            'total': len(result),
            'language': language
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch signs: {str(e)}'}), 500

@translation_bp.route('/sign/<sign_name>', methods=['GET'])
def get_sign_details(sign_name):
    """Get detailed information about a specific sign"""
    try:
        language = request.args.get('language', 'english')
        details = translation_service.get_sign_details(sign_name)

        if not details:
            return jsonify({'error': 'Sign not found'}), 404

        return jsonify({
            'sign': {
                'english': details.get('english'),
                'hindi': details.get('hindi'),
                'variations': details.get('variations', []),
                'translation': details.get(language, sign_name)
            }
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch sign details: {str(e)}'}), 500

@translation_bp.route('/translate', methods=['POST'])
@jwt_required()
def translate_signs():
    """Translate detected signs to target language"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()

        if not data or 'signs' not in data:
            return jsonify({'error': 'No signs provided'}), 400

        signs = data.get('signs', [])
        target_language = data.get('language', 'english')

        if not isinstance(signs, list):
            return jsonify({'error': 'Signs must be a list'}), 400

        translations = []
        for sign in signs:
            trans = translation_service.translate_sign(sign, target_language)
            translations.append({
                'original': sign,
                'translated': trans,
                'language': target_language
            })

        sentence = translation_service.build_sentence(signs, target_language)

        db.session.add(UserHistory(
            user_id=user_id,
            detected_text=sentence,
            confidence=0.0,
            detection_type='translation',
            source='api'
        ))
        db.session.commit()

        return jsonify({
            'signs': signs,
            'translations': translations,
            'sentence': sentence,
            'language': target_language
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Translation failed: {str(e)}'}), 500

@translation_bp.route('/paragraph', methods=['POST'])
@jwt_required()
def detect_paragraph():
    """Detect and convert multiple signs into a paragraph"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()

        if not data or 'detections' not in data:
            return jsonify({'error': 'No detections provided'}), 400

        detections = data.get('detections', [])
        if not isinstance(detections, list):
            return jsonify({'error': 'Detections must be a list'}), 400

        paragraph_data = translation_service.detect_paragraph_signs(detections)

        db.session.add(UserHistory(
            user_id=user_id,
            detected_text=paragraph_data['english_paragraph'],
            confidence=0.0,
            detection_type='paragraph',
            source='api'
        ))
        db.session.commit()

        return jsonify({
            'paragraph': {
                'english': paragraph_data['english_paragraph'],
                'hindi': paragraph_data['hindi_paragraph'],
                'signs': paragraph_data['signs'],
                'total_unique_signs': paragraph_data['total_signs'],
                'total_detections': paragraph_data['total_detections']
            }
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Paragraph detection failed: {str(e)}'}), 500

@translation_bp.route('/search', methods=['GET'])
def search_signs():
    """Search for signs matching a query"""
    try:
        query = request.args.get('q', '').strip()
        language = request.args.get('language', 'english')

        if not query:
            return jsonify({'error': 'Search query required'}), 400

        all_signs = translation_service.get_all_signs()
        results = []

        for sign in all_signs:
            if (query.lower() in sign['english'].lower() or
                query.lower() in sign['hindi'].lower() or
                any(query.lower() in var.lower() for var in sign.get('variations', []))):

                results.append({
                    'id': sign['id'],
                    'english': sign['english'],
                    'hindi': sign['hindi'],
                    'variations': sign.get('variations', []),
                    'translation': sign.get(language, sign['english'])
                })

        return jsonify({
            'query': query,
            'results': results,
            'total': len(results)
        }), 200

    except Exception as e:
        return jsonify({'error': f'Search failed: {str(e)}'}), 500

@translation_bp.route('/fuzzy-match', methods=['POST'])
def fuzzy_match():
    """Find closest matching sign for ambiguous input"""
    try:
        data = request.get_json()

        if not data or 'text' not in data:
            return jsonify({'error': 'No text provided'}), 400

        text = data.get('text', '').strip()
        language = data.get('language', 'english')

        if not text:
            return jsonify({'error': 'Text cannot be empty'}), 400

        matched_sign, confidence = translation_service.fuzzy_match_sign(text)

        if not matched_sign:
            return jsonify({
                'error': 'No matching sign found',
                'input': text,
                'confidence': 0.0
            }), 404

        details = translation_service.get_sign_details(matched_sign)

        return jsonify({
            'input': text,
            'matched_sign': matched_sign,
            'confidence': confidence,
            'sign_details': {
                'english': details.get('english'),
                'hindi': details.get('hindi'),
                'variations': details.get('variations', []),
                'translation': details.get(language, matched_sign)
            }
        }), 200

    except Exception as e:
        return jsonify({'error': f'Fuzzy match failed: {str(e)}'}), 500

@translation_bp.route('/validate', methods=['POST'])
def validate_sequence():
    """Validate a sequence of detected signs"""
    try:
        data = request.get_json()

        if not data or 'signs' not in data:
            return jsonify({'error': 'No signs provided'}), 400

        signs = data.get('signs', [])
        if not isinstance(signs, list):
            return jsonify({'error': 'Signs must be a list'}), 400

        analysis = translation_service.validate_sign_sequence(signs)

        return jsonify({
            'analysis': {
                'valid_signs': analysis['valid_signs'],
                'invalid_signs': analysis['invalid_signs'],
                'suggestions': analysis['suggestions'],
                'confidence': analysis['confidence'],
                'is_valid': len(analysis['invalid_signs']) == 0
            }
        }), 200

    except Exception as e:
        return jsonify({'error': f'Validation failed: {str(e)}'}), 500

@translation_bp.route('/batch-detect', methods=['POST'])
@jwt_required()
def batch_detect_signs():
    """Process multiple video frames and detect signs"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()

        if not data or 'frames' not in data:
            return jsonify({'error': 'No frames provided'}), 400

        frames_data = data.get('frames', [])
        if not isinstance(frames_data, list):
            return jsonify({'error': 'Frames must be a list'}), 400

        detected_signs = []
        for frame_data in frames_data:
            sign = frame_data.get('sign')
            confidence = frame_data.get('confidence', 0.0)

            if sign and confidence >= 0.5:
                detected_signs.append({
                    'sign': sign,
                    'confidence': confidence,
                    'timestamp': frame_data.get('timestamp')
                })

        paragraph = translation_service.detect_paragraph_signs(detected_signs)

        db.session.add(UserHistory(
            user_id=user_id,
            detected_text=paragraph['english_paragraph'],
            confidence=sum(d.get('confidence', 0) for d in detected_signs) / max(len(detected_signs), 1),
            detection_type='batch',
            source='batch_api'
        ))
        db.session.commit()

        return jsonify({
            'batch': {
                'total_frames': len(frames_data),
                'detected_signs': len(detected_signs),
                'paragraph': {
                    'english': paragraph['english_paragraph'],
                    'hindi': paragraph['hindi_paragraph'],
                    'unique_signs': paragraph['signs']
                }
            }
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Batch detection failed: {str(e)}'}), 500
