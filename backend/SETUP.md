# Sign Language Detection Backend - Setup Guide

## Prerequisites

- Python 3.8+
- PostgreSQL 12+
- Redis (optional, for caching)
- Virtual Environment

## Installation

### 1. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Database Setup

#### Create PostgreSQL Database

```bash
psql -U postgres
CREATE DATABASE sign_detection;
\q
```

#### Set Environment Variables

Copy `.env.example` to `.env` and update:

```bash
cp .env.example .env
```

Update the `.env` file with your configuration:
```
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/sign_detection
SECRET_KEY=your-random-secret-key
JWT_SECRET_KEY=your-random-jwt-secret
```

#### Initialize Database

```bash
python
from app import create_app, db
app = create_app()
with app.app_context():
    db.create_all()
    print("Database initialized successfully!")
exit()
```

### 4. Load Dataset

```bash
python
from app import create_app
from dataset_loader import DatasetLoader
app = create_app()
with app.app_context():
    loader = DatasetLoader()
    count, message = loader.insert_signs_into_db()
    print(f"{count} signs loaded: {message}")
exit()
```

## Running the Application

### Development Server

```bash
python app.py
```

The API will be available at `http://localhost:5000`

### Production Server (using Gunicorn)

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:create_app()
```

## API Documentation

### Authentication Endpoints

#### Sign Up
```
POST /api/auth/signup
Content-Type: application/json

{
  "username": "user123",
  "email": "user@example.com",
  "password": "SecurePass123",
  "first_name": "John",
  "last_name": "Doe"
}

Response:
{
  "message": "User created successfully",
  "user": {...},
  "access_token": "jwt_token_here"
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username_or_email": "user123",
  "password": "SecurePass123"
}

Response:
{
  "message": "Login successful",
  "user": {...},
  "access_token": "jwt_token_here"
}
```

#### Get Profile
```
GET /api/auth/profile
Authorization: Bearer {access_token}

Response:
{
  "user": {...}
}
```

#### Update Profile
```
PUT /api/auth/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "first_name": "John",
  "last_name": "Doe",
  "email": "newemail@example.com"
}
```

#### Change Password
```
POST /api/auth/change-password
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "old_password": "OldPass123",
  "new_password": "NewPass123"
}
```

### Detection Endpoints

#### Get All Signs
```
GET /api/detection/signs?page=1&per_page=20&category=Greetings&search=hello
```

#### Get Sign by ID
```
GET /api/detection/signs/{sign_id}
```

#### Get Signs by Category
```
GET /api/detection/signs/category/{category}?page=1&per_page=20
```

#### Detect from Frame
```
POST /api/detection/detect-frame
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "frame": "base64_encoded_image_data",
  "min_confidence": 0.5
}

Response:
{
  "sign": "Hello",
  "confidence": 0.95,
  "timestamp": "2024-01-15T10:30:45.123456"
}
```

#### Detect from Video
```
POST /api/detection/detect-video
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

(file: video.mp4)

Response:
{
  "message": "Video processed successfully",
  "total_frames": 300,
  "fps": 30,
  "duration": 10.0,
  "detections_found": 5,
  "detections": [
    {
      "frame": 0,
      "timestamp": 0.0,
      "sign": "Hello",
      "confidence": 0.95
    }
  ],
  "output_video": "uploads/videos/detected_xyz.mp4"
}
```

#### Get User History
```
GET /api/detection/history?page=1&per_page=20&days=30
Authorization: Bearer {access_token}

Response:
{
  "history": [...],
  "total": 50,
  "pages": 3,
  "current_page": 1,
  "days": 30
}
```

#### Get History Statistics
```
GET /api/detection/history/stats?days=30
Authorization: Bearer {access_token}

Response:
{
  "total_detections": 50,
  "unique_signs": 15,
  "average_confidence": 0.87,
  "top_signs": [
    {"sign": "Hello", "count": 10}
  ],
  "period_days": 30
}
```

#### Save Sign
```
POST /api/detection/save-sign/{sign_id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "notes": "Personal notes about this sign"
}
```

#### Get Saved Signs
```
GET /api/detection/saved-signs?page=1&per_page=20
Authorization: Bearer {access_token}
```

#### Unsave Sign
```
DELETE /api/detection/unsave-sign/{sign_id}
Authorization: Bearer {access_token}
```

### Utility Endpoints

#### Load Dataset
```
POST /api/utils/dataset/load
```

#### Get Dataset Statistics
```
GET /api/utils/dataset/stats
```

#### Get Learning Progress
```
GET /api/utils/learning-progress?page=1&per_page=20
Authorization: Bearer {access_token}
```

#### Get Progress Summary
```
GET /api/utils/learning-progress/summary
Authorization: Bearer {access_token}

Response:
{
  "total_practiced": 100,
  "total_mastered": 15,
  "average_accuracy": 85.5,
  "recent": [...]
}
```

#### Update Learning Progress
```
PUT /api/utils/learning-progress/{sign_id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "times_practiced": 1,
  "times_detected_correctly": 1,
  "mastered": false
}
```

#### Create Video Session
```
POST /api/utils/video-sessions
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "session_type": "live"
}

Response:
{
  "message": "Video session created",
  "session": {...}
}
```

#### End Video Session
```
PUT /api/utils/video-sessions/{session_id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "status": "completed"
}
```

#### Get Video Sessions
```
GET /api/utils/video-sessions?page=1&per_page=20
Authorization: Bearer {access_token}
```

#### Get Categories
```
GET /api/utils/categories

Response:
{
  "categories": ["Greetings", "Emotions", "Actions", ...]
}
```

#### Health Check
```
GET /api/utils/health
GET /health
```

## Database Schema

### Users Table
- id (UUID, Primary Key)
- username (String, Unique)
- email (String, Unique)
- password_hash (String)
- first_name (String)
- last_name (String)
- profile_picture (String)
- created_at (DateTime)
- updated_at (DateTime)
- is_active (Boolean)

### Signs Table
- id (UUID, Primary Key)
- name (String, Unique)
- english_translation (String)
- hindi_translation (String)
- description (Text)
- video_path (String)
- image_path (String)
- keypoints_data (JSON)
- category (String)
- difficulty_level (String)
- dataset_source (String)
- confidence_score (Float)
- created_at (DateTime)
- updated_at (DateTime)

### UserHistory Table
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key)
- sign_id (UUID, Foreign Key)
- detected_text (String)
- confidence (Float)
- video_frame_path (String)
- detection_timestamp (DateTime)
- detection_type (String)
- source (String)
- is_correct (Boolean)

### SavedSigns Table
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key)
- sign_id (UUID, Foreign Key)
- saved_at (DateTime)
- notes (Text)

### VideoSessions Table
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key)
- session_type (String)
- started_at (DateTime)
- ended_at (DateTime)
- duration (Integer)
- video_file_path (String)
- status (String)

### SignLearningProgress Table
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key)
- sign_id (UUID, Foreign Key)
- times_practiced (Integer)
- times_detected_correctly (Integer)
- accuracy (Float)
- last_practiced (DateTime)
- mastered (Boolean)

### SignLanguageModels Table
- id (UUID, Primary Key)
- model_name (String, Unique)
- model_type (String)
- file_path (String)
- accuracy (Float)
- dataset_used (String)
- version (String)
- created_at (DateTime)
- updated_at (DateTime)
- is_active (Boolean)

## Features

### 1. User Authentication
- Secure signup and login with JWT tokens
- Password validation and hashing
- Profile management
- Password change functionality

### 2. Sign Detection
- Real-time sign detection using MediaPipe
- Support for video file processing
- Frame-by-frame detection
- Confidence scoring

### 3. User History Tracking
- Track all detected signs per user
- Statistics on detection patterns
- Confidence metrics
- Time-based filtering

### 4. Learning Progress
- Track practice sessions per sign
- Calculate accuracy rates
- Mark mastered signs
- View learning progress summary

### 5. Video Session Management
- Create and manage video sessions
- Track session duration
- Store video files

### 6. Large Sign Language Dataset
- 30+ predefined signs with translations
- English and Hindi translations
- Category-based organization
- Difficulty levels
- Expandable dataset structure

## Testing

### API Testing with cURL

```bash
# Signup
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123",
    "first_name": "Test"
  }'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username_or_email": "testuser",
    "password": "TestPass123"
  }'

# Get signs (with JWT token)
curl -X GET http://localhost:5000/api/detection/signs \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Health check
curl -X GET http://localhost:5000/health
```

## Troubleshooting

### Database Connection Error
- Ensure PostgreSQL is running
- Check DATABASE_URL in .env file
- Verify database exists: `psql -U postgres -l`

### JWT Token Error
- Ensure JWT_SECRET_KEY is set in .env
- Token should be passed in Authorization header as: `Bearer {token}`

### MediaPipe Error
- Reinstall: `pip install --upgrade mediapipe`
- Ensure camera/video permissions are granted

### CORS Issues
- Update CORS_ORIGINS in .env
- Or modify CORS configuration in app.py

## Performance Tips

1. Use pagination for large result sets
2. Index frequently searched columns in database
3. Cache sign categories and common queries with Redis
4. Use video compression for upload/storage
5. Implement rate limiting for API endpoints

## Security Recommendations

1. Always use HTTPS in production
2. Keep SECRET_KEY and JWT_SECRET_KEY secure
3. Use strong database passwords
4. Implement rate limiting
5. Validate all user inputs
6. Use environment variables for sensitive data
7. Implement CORS properly for production

## Future Enhancements

1. Real-time translation to multiple languages
2. Computer vision improvements using CNN models
3. Support for continuous sign language streaming
4. Mobile app integration
5. Collaborative learning features
6. Advanced analytics dashboard
7. Multi-language support for UI
8. Gesture recognition for more complex signs
