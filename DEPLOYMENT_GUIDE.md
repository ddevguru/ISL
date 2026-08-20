# Sign Language Detection - Deployment Guide

## Complete Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (Flutter/Web)                    │
│                  (Separate Repository)                       │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP/REST API
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    API Gateway                               │
│              (Render/Heroku/Railway)                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼────┐        ┌───▼────┐        ┌───▼────┐
    │  Auth   │        │Detection│        │Trans-  │
    │ Routes  │        │ Routes  │        │lation  │
    │ (JWT)   │        │(ML/CV)  │        │Routes  │
    └────┬────┘        └────┬────┘        └────┬───┘
         │                  │                  │
    ┌────▼──────────────────▼──────────────────▼────┐
    │          SQLAlchemy ORM Layer                  │
    └────┬──────────────────────────────────────────┘
         │
    ┌────▼──────────────────────────────────────────┐
    │  PostgreSQL Database                          │
    │  - Users & Authentication                     │
    │  - Signs & Translations                       │
    │  - Detection History                          │
    │  - Learning Progress                          │
    └───────────────────────────────────────────────┘

    ┌──────────────────────────────────────────────┐
    │  ML Components (Render Instance)             │
    │  - MediaPipe (Keypoint Extraction)           │
    │  - LSTM Model (Sign Classification)          │
    │  - Translation Service                       │
    └──────────────────────────────────────────────┘
```

## Prerequisites

- Python 3.11+
- PostgreSQL (or use Render's PostgreSQL)
- Git
- Render.com account

## Local Setup

### 1. Clone and Install

```bash
cd backend
python -m venv venv

# On Windows
venv\Scripts\activate

# On Mac/Linux
source venv/bin/activate

pip install -r requirements.txt
```

### 2. Configure Environment

Create `.env` file:

```env
FLASK_ENV=development
FLASK_APP=app.py
PORT=5000

# Security
SECRET_KEY=your-dev-secret-key-here
JWT_SECRET_KEY=your-dev-jwt-key-here

# Database (Local PostgreSQL)
DATABASE_URL=postgresql://postgres:password@localhost:5432/sign_detection

# Redis (Optional, for caching)
REDIS_URL=redis://localhost:6379/0

# Upload Settings
UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=524288000

# Model & Dataset Paths
MEDIAPIPE_MODEL_PATH=models
SIGN_LANGUAGE_DATASET_PATH=datasets

CORS_ORIGINS=http://localhost:3000,http://localhost:5000,*
```

### 3. Initialize Database

```bash
python init_db.py
```

### 4. Train Model

```bash
python model_trainer.py
```

This will:
- Generate synthetic training data
- Build LSTM model
- Save `models/sign_model.h5`
- Save `models/sign_labels.json`
- Save `models/sign_mappings.json`

### 5. Run Locally

```bash
python app.py
```

API will be available at: `http://localhost:5000`

## Deployment to Render

### Step 1: Prepare Repository

Ensure your GitHub repository has this structure:

```
sign_detection/
├── backend/
│   ├── app.py
│   ├── models.py
│   ├── config.py
│   ├── requirements.txt
│   ├── Procfile
│   ├── runtime.txt
│   ├── model_trainer.py
│   ├── init_db.py
│   ├── sign_detector.py
│   ├── translation_service.py
│   ├── detection_routes.py
│   ├── translation_routes.py
│   └── .env.example
├── DEPLOYMENT_GUIDE.md
└── .gitignore
```

### Step 2: Create Render PostgreSQL Database

1. Go to https://render.com
2. Create a new PostgreSQL Database:
   - Name: `sign-detection-db`
   - PostgreSQL Version: 15
   - Region: Choose closest to you
3. Note the **Internal Database URL** and **External Database URL**

### Step 3: Deploy Backend Service

1. Go to Render Dashboard
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Configure:

   **Service Details:**
   - Name: `sign-detection-api`
   - Environment: `Python 3.11`
   - Region: Same as database
   - Build Command: `pip install -r backend/requirements.txt`
   - Start Command: `cd backend && gunicorn app:app --timeout 120 --workers 4`

   **Environment Variables:**
   ```
   FLASK_ENV=production
   FLASK_APP=app.py
   PORT=10000
   
   # Use Internal Database URL from PostgreSQL service
   DATABASE_URL=postgresql://user:password@hostname/database
   
   SECRET_KEY=<generate-strong-random-key>
   JWT_SECRET_KEY=<generate-strong-random-key>
   
   REDIS_URL=redis://localhost:6379/0
   
   UPLOAD_FOLDER=uploads
   MAX_CONTENT_LENGTH=524288000
   
   MEDIAPIPE_MODEL_PATH=models
   SIGN_LANGUAGE_DATASET_PATH=datasets
   
   CORS_ORIGINS=*
   ```

5. Click "Create Web Service"

### Step 4: Configure Persistent Disk (for models)

1. In Render dashboard, go to your service settings
2. Add a Disk:
   - Name: `models-disk`
   - Mount Path: `/opt/render/project/backend/models`
   - Size: 5GB

3. Another disk for datasets:
   - Name: `datasets-disk`
   - Mount Path: `/opt/render/project/backend/datasets`
   - Size: 10GB

### Step 5: Deploy Frontend (Separate)

If using Flutter Web:
1. Build: `flutter build web`
2. Deploy to Render Static Site or similar

API Endpoint Configuration:
```dart
const String API_BASE_URL = 'https://sign-detection-api.onrender.com/api';
```

## Database Schema

### Tables

**users**
```sql
- id (UUID, PRIMARY KEY)
- username (VARCHAR, UNIQUE)
- email (VARCHAR, UNIQUE)
- password_hash (VARCHAR)
- created_at (TIMESTAMP)
- is_active (BOOLEAN)
```

**signs**
```sql
- id (UUID, PRIMARY KEY)
- name (VARCHAR, UNIQUE)
- english_translation (VARCHAR)
- hindi_translation (VARCHAR)
- description (TEXT)
- category (VARCHAR)
- difficulty_level (VARCHAR)
- dataset_source (VARCHAR)
- confidence_score (FLOAT)
- created_at (TIMESTAMP)
```

**user_history**
```sql
- id (UUID, PRIMARY KEY)
- user_id (FK → users)
- sign_id (FK → signs)
- detected_text (VARCHAR)
- confidence (FLOAT)
- detection_type (VARCHAR)
- source (VARCHAR)
- detection_timestamp (TIMESTAMP)
```

**video_sessions**
```sql
- id (UUID, PRIMARY KEY)
- user_id (FK → users)
- session_type (VARCHAR)
- started_at (TIMESTAMP)
- ended_at (TIMESTAMP)
- duration (INTEGER)
- status (VARCHAR)
```

## API Endpoints

### Authentication
```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/refresh
GET    /api/auth/profile
```

### Detection
```
GET    /api/detection/signs
POST   /api/detection/detect-frame
POST   /api/detection/detect-video
GET    /api/detection/history
```

### Translation
```
GET    /api/translation/signs
GET    /api/translation/sign/<name>
POST   /api/translation/translate
POST   /api/translation/paragraph
GET    /api/translation/search
POST   /api/translation/fuzzy-match
POST   /api/translation/batch-detect
```

## Monitoring & Debugging

### View Logs

```bash
# On Render
render logs --service sign-detection-api --tail
```

### Check Database Connection

```bash
# SSH into Render service
render shell --service sign-detection-api

# Test database
python -c "from models import db; from app import create_app; app = create_app(); print(db.engine.url)"
```

### Health Check

```bash
curl https://sign-detection-api.onrender.com/health
```

## Performance Optimization

### 1. Model Caching
Models are loaded once at startup, not per request.

### 2. Database Indexing
```sql
CREATE INDEX idx_user_id ON user_history(user_id);
CREATE INDEX idx_sign_id ON user_history(sign_id);
CREATE INDEX idx_detection_timestamp ON user_history(detection_timestamp);
```

### 3. Keypoint Compression
The LSTM model uses compressed keypoints to reduce inference time.

### 4. Batch Processing
Use `/api/translation/batch-detect` for processing multiple frames at once.

## Troubleshooting

### Model Not Loading
```
Error: No module named 'tensorflow'
Solution: pip install -r requirements.txt --no-cache-dir
```

### Database Connection Failed
```
Error: could not connect to server
Solution: Check DATABASE_URL in environment variables
         Ensure PostgreSQL service is running
```

### Out of Memory on Render
```
Error: MemoryError
Solution: Reduce batch size in model_trainer.py
          Use smaller model variant
          Increase Render instance size
```

### Slow Predictions
```
Solutions:
1. Reduce LSTM layers (32 → 16)
2. Increase instance memory on Render
3. Use GPU instance (if available)
4. Implement model quantization
```

## Security Checklist

- [ ] Change all SECRET_KEY values in production
- [ ] Use strong JWT_SECRET_KEY (min 32 chars)
- [ ] Enable HTTPS (automatic on Render)
- [ ] Configure CORS_ORIGINS properly (not "*" in production)
- [ ] Use PostgreSQL with encrypted passwords
- [ ] Enable database backups on Render
- [ ] Regularly update dependencies
- [ ] Monitor logs for suspicious activity

## Scaling Strategy

1. **Database**: PostgreSQL can handle 1M+ records
2. **API**: Render auto-scales with instance count
3. **Models**: Store on persistent disk, load once
4. **Caching**: Add Redis for repeated predictions
5. **CDN**: Use Render's built-in CDN for static files

## Cost Estimation (Render.com)

| Component | Cost | Notes |
|-----------|------|-------|
| Web Service | $7-25/month | Auto-scales |
| PostgreSQL | $15-85/month | 10GB-100GB storage |
| Disk Storage | $0.30/GB/month | Models & datasets |
| **Total** | **~$30-120/month** | Production-grade |

## Next Steps

1. Push code to GitHub
2. Connect GitHub to Render
3. Set environment variables
4. Deploy and test
5. Monitor logs
6. Set up database backups
7. Configure custom domain (optional)

## Support & Documentation

- Render Docs: https://render.com/docs
- Flask Docs: https://flask.palletsprojects.com
- MediaPipe: https://mediapipe.dev
- TensorFlow/Keras: https://keras.io

---

**Happy Deploying! 🚀**
