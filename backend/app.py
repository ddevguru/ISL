from flask import Flask, jsonify
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from config import config
import os
from pathlib import Path

from models import db
from auth import auth_bp
from detection_routes import detection_bp
from utility_routes import utils_bp

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
    app.register_blueprint(detection_bp)
    app.register_blueprint(utils_bp)

    @app.before_request
    def before_request():
        pass

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
            db.session.execute('SELECT 1')
            return jsonify({
                'status': 'healthy',
                'database': 'connected'
            }), 200
        except Exception as e:
            return jsonify({
                'status': 'unhealthy',
                'database': f'error: {str(e)}'
            }), 500

    with app.app_context():
        db.create_all()

    return app

if __name__ == '__main__':
    app = create_app(os.getenv('FLASK_ENV', 'development'))

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
