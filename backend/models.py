from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
import uuid

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(80))
    last_name = db.Column(db.String(80))
    profile_picture = db.Column(db.String(255))
    bio = db.Column(db.Text)
    phone_number = db.Column(db.String(20))
    country = db.Column(db.String(100))
    language_preference = db.Column(db.String(10), default='en')
    is_online = db.Column(db.Boolean, default=False)
    last_seen = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)

    history = db.relationship('UserHistory', backref='user', lazy=True, cascade='all, delete-orphan')
    saved_signs = db.relationship('SavedSign', backref='user', lazy=True, cascade='all, delete-orphan')
    call_requests_sent = db.relationship('CallRequest', foreign_keys='CallRequest.caller_id', backref='caller', lazy=True)
    call_requests_received = db.relationship('CallRequest', foreign_keys='CallRequest.receiver_id', backref='receiver', lazy=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'profile_picture': self.profile_picture,
            'bio': self.bio,
            'phone_number': self.phone_number,
            'country': self.country,
            'language_preference': self.language_preference,
            'is_online': self.is_online,
            'last_seen': self.last_seen.isoformat() if self.last_seen else None,
            'created_at': self.created_at.isoformat(),
            'is_active': self.is_active
        }


class Sign(db.Model):
    __tablename__ = 'signs'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(255), nullable=False, unique=True)
    english_translation = db.Column(db.String(255), nullable=False)
    hindi_translation = db.Column(db.String(255))
    description = db.Column(db.Text)
    video_path = db.Column(db.String(255))
    image_path = db.Column(db.String(255))
    keypoints_data = db.Column(db.JSON)
    category = db.Column(db.String(100))
    difficulty_level = db.Column(db.String(20))
    dataset_source = db.Column(db.String(255))
    confidence_score = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    history_entries = db.relationship('UserHistory', backref='sign', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'english_translation': self.english_translation,
            'hindi_translation': self.hindi_translation,
            'description': self.description,
            'video_path': self.video_path,
            'image_path': self.image_path,
            'category': self.category,
            'difficulty_level': self.difficulty_level,
            'dataset_source': self.dataset_source,
            'confidence_score': self.confidence_score,
            'created_at': self.created_at.isoformat()
        }


class UserHistory(db.Model):
    __tablename__ = 'user_history'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    sign_id = db.Column(db.String(36), db.ForeignKey('signs.id'), nullable=False)
    detected_text = db.Column(db.String(255))
    confidence = db.Column(db.Float)
    video_frame_path = db.Column(db.String(255))
    detection_timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    detection_type = db.Column(db.String(50))
    source = db.Column(db.String(100))
    is_correct = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'sign_id': self.sign_id,
            'sign_name': self.sign.name if self.sign else None,
            'detected_text': self.detected_text,
            'confidence': self.confidence,
            'detection_timestamp': self.detection_timestamp.isoformat(),
            'detection_type': self.detection_type,
            'source': self.source,
            'is_correct': self.is_correct
        }


class SavedSign(db.Model):
    __tablename__ = 'saved_signs'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    sign_id = db.Column(db.String(36), db.ForeignKey('signs.id'), nullable=False)
    saved_at = db.Column(db.DateTime, default=datetime.utcnow)
    notes = db.Column(db.Text)

    sign = db.relationship('Sign', backref='saved_by_users')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'sign_id': self.sign_id,
            'sign': self.sign.to_dict() if self.sign else None,
            'saved_at': self.saved_at.isoformat(),
            'notes': self.notes
        }


class VideoSession(db.Model):
    __tablename__ = 'video_sessions'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    session_type = db.Column(db.String(50))
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    ended_at = db.Column(db.DateTime)
    duration = db.Column(db.Integer)
    video_file_path = db.Column(db.String(255))
    status = db.Column(db.String(50))

    user = db.relationship('User', backref='video_sessions')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'session_type': self.session_type,
            'started_at': self.started_at.isoformat(),
            'ended_at': self.ended_at.isoformat() if self.ended_at else None,
            'duration': self.duration,
            'status': self.status
        }


class SignLanguageModel(db.Model):
    __tablename__ = 'sign_language_models'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    model_name = db.Column(db.String(255), nullable=False, unique=True)
    model_type = db.Column(db.String(100))
    file_path = db.Column(db.String(255))
    accuracy = db.Column(db.Float)
    dataset_used = db.Column(db.String(255))
    version = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)

    def to_dict(self):
        return {
            'id': self.id,
            'model_name': self.model_name,
            'model_type': self.model_type,
            'accuracy': self.accuracy,
            'dataset_used': self.dataset_used,
            'version': self.version,
            'created_at': self.created_at.isoformat(),
            'is_active': self.is_active
        }


class SignLearningProgress(db.Model):
    __tablename__ = 'sign_learning_progress'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    sign_id = db.Column(db.String(36), db.ForeignKey('signs.id'), nullable=False)
    times_practiced = db.Column(db.Integer, default=0)
    times_detected_correctly = db.Column(db.Integer, default=0)
    accuracy = db.Column(db.Float, default=0.0)
    last_practiced = db.Column(db.DateTime)
    mastered = db.Column(db.Boolean, default=False)

    user = db.relationship('User', backref='learning_progress')
    sign = db.relationship('Sign', backref='learning_progress')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'sign_id': self.sign_id,
            'sign_name': self.sign.name if self.sign else None,
            'times_practiced': self.times_practiced,
            'times_detected_correctly': self.times_detected_correctly,
            'accuracy': self.accuracy,
            'last_practiced': self.last_practiced.isoformat() if self.last_practiced else None,
            'mastered': self.mastered
        }


class CallRequest(db.Model):
    __tablename__ = 'call_requests'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    caller_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    receiver_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    status = db.Column(db.String(50), default='pending')
    call_type = db.Column(db.String(50), default='video')
    started_at = db.Column(db.DateTime)
    ended_at = db.Column(db.DateTime)
    duration = db.Column(db.Integer)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'caller_id': self.caller_id,
            'caller_name': self.caller.first_name if self.caller else None,
            'receiver_id': self.receiver_id,
            'receiver_name': self.receiver.first_name if self.receiver else None,
            'status': self.status,
            'call_type': self.call_type,
            'started_at': self.started_at.isoformat() if self.started_at else None,
            'ended_at': self.ended_at.isoformat() if self.ended_at else None,
            'duration': self.duration,
            'created_at': self.created_at.isoformat()
        }
