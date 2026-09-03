from flask import Flask, jsonify, request
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from config import config
import os
from pathlib import Path
from sqlalchemy import text
import logging
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

try:
    import matplotlib
    matplotlib.use('Agg')
except Exception:
    pass

import sys
if hasattr(sys.stdout, 'reconfigure'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass

from models import db, Sign
from auth import auth_bp
from detection_routes import detection_bp
from utility_routes import utils_bp
from translation_routes import translation_bp
from user_routes import user_bp
from call_signaling import call_bp
from learning_module import learning_bp

def create_app(config_name='development'):
    app = Flask(__name__)

    config_class = config.get(config_name, config['default'])
    app.config.from_object(config_class)

    db.init_app(app)
    JWTManager(app)
    CORS(app, resources={r"/api/*": {"origins": "*"}})

    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'videos'), exist_ok=True)
    os.makedirs(app.config['MEDIAPIPE_MODEL_PATH'], exist_ok=True)
    os.makedirs(app.config['SIGN_LANGUAGE_DATASET_PATH'], exist_ok=True)

    app.register_blueprint(auth_bp)
    app.register_blueprint(user_bp)
    app.register_blueprint(call_bp)
    app.register_blueprint(detection_bp)
    app.register_blueprint(utils_bp)
    app.register_blueprint(translation_bp)
    app.register_blueprint(learning_bp)

    @app.before_request
    def before_request():
        request.start_time = datetime.now()
        print(f"\n{'='*60}")
        print(f"📨 INCOMING REQUEST: {datetime.now()}")
        print(f"Method: {request.method}")
        print(f"Path: {request.path}")
        print(f"Remote Address: {request.remote_addr}")
        print(f"User Agent: {request.user_agent}")
        print(f"Content Type: {request.content_type}")
        if request.data:
            print(f"Body: {request.data[:500]}")
        print(f"{'='*60}\n")

    @app.after_request
    def after_request(response):
        if hasattr(request, 'start_time'):
            duration = (datetime.now() - request.start_time).total_seconds()
            print(f"\n{'='*60}")
            print(f"✅ RESPONSE: {datetime.now()}")
            print(f"Path: {request.path}")
            print(f"Status: {response.status_code}")
            print(f"Duration: {duration:.3f}s")
            print(f"Response Size: {len(response.data)} bytes")
            print(f"{'='*60}\n")
        return response

    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Endpoint not found'}), 404

    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api', methods=['GET'])
    def api_info():
        return jsonify({
            'name': 'Sign Language Detection API',
            'version': '1.0.0',
            'description': 'Backend API for real-time sign language detection and translation',
            'endpoints': {
                'authentication': '/api/auth',
                'detection': '/api/detection',
                'utilities': '/api/utils'
            }
        }), 200

    @app.route('/health', methods=['GET'])
    def health_check():
        try:
            db.session.execute(text('SELECT 1'))
            return jsonify({
                'status': 'healthy',
                'database': 'connected'
            }), 200
        except Exception as e:
            return jsonify({
                'status': 'unhealthy',
                'database': f'error: {str(e)}'
            }), 500

    def _run_migrations():
        """Run database migrations to add missing columns"""
        try:
            columns_to_check = [
                ('profile_picture', 'VARCHAR(255)'),
                ('bio', 'TEXT'),
                ('phone_number', 'VARCHAR(20)'),
                ('country', 'VARCHAR(100)'),
                ('language_preference', "VARCHAR(10) DEFAULT 'en'"),
                ('is_online', 'BOOLEAN DEFAULT FALSE'),
                ('last_seen', 'TIMESTAMP'),
                ('created_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'),
                ('updated_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'),
                ('is_active', 'BOOLEAN DEFAULT TRUE'),
            ]

            for col_name, col_type in columns_to_check:
                try:
                    query = f"ALTER TABLE users ADD COLUMN IF NOT EXISTS {col_name} {col_type}"
                    db.session.execute(text(query))
                    db.session.commit()
                except Exception:
                    db.session.rollback()
                    pass
        except Exception as e:
            print(f"Migration error: {e}")

    def _load_dataset_signs():
        """Load full ISL sign language dataset into database with keypoints and translations"""
        try:
            from dataset_loader import DatasetLoader
            loader = DatasetLoader()
            count, message = loader.insert_signs_into_db()
            print(f"✅ Full ISL dataset verified: {count} signs loaded/updated ({message})")
        except Exception as e:
            print(f"Error loading full ISL dataset: {e}")
            db.session.rollback()

    with app.app_context():
        db.create_all()
        _run_migrations()
        _load_dataset_signs()

    return app

app = create_app(os.getenv('FLASK_ENV', 'production'))

if __name__ == '__main__':
    host = os.getenv('HOST', '0.0.0.0')
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_ENV', 'development') == 'development'

    print("\n" + "="*60)
    print("🚀 Sign Language Detection Backend")
    print("="*60)
    print(f"✅ Server running on: http://{host}:{port}")
    print(f"✅ Local access: http://localhost:{port}")
    print(f"✅ Mobile access: http://192.168.0.132:{port}")
    print(f"✅ API Docs: http://192.168.0.132:{port}/api")
    print("="*60 + "\n")

    app.run(
        host=host,
        port=port,
        debug=debug,
        use_reloader=True,
        threaded=True
    )
