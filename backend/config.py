import os
from datetime import timedelta

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-prod')

    SQLALCHEMY_DATABASE_URI = os.getenv(
        'DATABASE_URL',
        'sqlite:///sign_detection.db'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False

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
    # Use SQLite for local development
    SQLALCHEMY_DATABASE_URI = 'sqlite:///sign_detection.db'


class ProductionConfig(Config):
    DEBUG = False
    # Use PostgreSQL for production
    SQLALCHEMY_DATABASE_URI = os.getenv(
        'DATABASE_URL',
        'postgresql://postgres:password@localhost:5432/sign_detection'
    )


class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'


config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
