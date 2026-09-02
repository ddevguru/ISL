import os
from datetime import timedelta

def _get_production_db_url():
    """Get production database URL with SSL configuration for Render"""
    db_url = os.getenv('DATABASE_URL', '')

    if not db_url:
        return 'sqlite:///sign_detection.db'

    # Fix URL scheme
    if db_url.startswith('postgres://'):
        db_url = db_url.replace('postgres://', 'postgresql://', 1)
    elif db_url.startswith('rediss://'):
        db_url = db_url.replace('rediss://', 'postgresql://', 1)

    # Remove existing SSL params
    if '?' in db_url:
        db_url = db_url.split('?')[0]

    return db_url


class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-prod')

    SQLALCHEMY_DATABASE_URI = os.getenv(
        'DATABASE_URL',
        'sqlite:///sign_detection.db'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ECHO = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'pool_recycle': 3600,
        'pool_pre_ping': True,
    }

    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'jwt-secret-key-change-in-prod')
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=30)

    UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')
    MAX_CONTENT_LENGTH = 500 * 1024 * 1024

    MEDIAPIPE_MODEL_PATH = os.path.join(os.getcwd(), 'models')

    REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/0')

    SIGN_LANGUAGE_DATASET_PATH = os.path.join(os.getcwd(), 'datasets')

    DEBUG = False
    TESTING = False


class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///sign_detection.db'


class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = _get_production_db_url()
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 5,
        'pool_recycle': 1800,
        'pool_pre_ping': True,
        'max_overflow': 10,
    }
    
    # Only add sslmode if we are actually using a PostgreSQL database
    if SQLALCHEMY_DATABASE_URI.startswith('postgresql://'):
        SQLALCHEMY_ENGINE_OPTIONS['connect_args'] = {
            'sslmode': 'allow',
        }


class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'


config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
