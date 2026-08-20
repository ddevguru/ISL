# Render Deployment Checklist

## Pre-Deployment (Local Computer)

### Step 1: Train Model Locally ✅
```bash
cd backend

# Install training dependencies
pip install -r requirements-train.txt

# Train the model (creates models/ directory)
python model_trainer.py
```

Output should show:
```
✓ Training data shape: (2000, 30, 1662)
✓ Model compiled successfully
✓ Model trained successfully
✓ Model saved to models/sign_model.h5
✓ Labels saved to models/sign_labels.json
```

### Step 2: Verify Model Files
```bash
# Check model files exist
ls -la models/
# Should show:
# - sign_model.h5 (45MB)
# - sign_labels.json
# - sign_mappings.json
```

### Step 3: Test Locally
```bash
python app.py
# Visit: http://localhost:5000/health
# Should return: {"status": "healthy", "database": "connected"}
```

### Step 4: Commit Everything
```bash
git add models/sign_model.h5
git add models/sign_labels.json
git add models/sign_mappings.json
git add backend/requirements.txt
git add backend/requirements-train.txt
git add Procfile
git add runtime.txt

git commit -m "Add trained LSTM model and optimized deployment config"
git push origin main
```

---

## Render Deployment

### Step 5: Clear Render Cache
1. Go to Render Dashboard
2. Select your service (sign-detection-api)
3. Click **Settings** → **Danger Zone**
4. Click **"Clear Build Cache"**

### Step 6: Manual Redeploy
1. Click **"Redeploy"** button
2. Watch build logs:

**Build should show:**
```
==> Using Python version 3.11.7
==> Installing Python version 3.11.7...
==> Running build command 'pip install -r backend/requirements.txt'...
...
Successfully installed Flask==2.3.3 ...
==> Build successful 🎉
```

### Step 7: Release Command
Release should show:
```
==> Running release command 'python backend/init_db.py'...
[1/3] Creating database tables...
✓ Database tables created successfully
[2/3] Loading sign language dataset...
✓ 134 signs loaded
...
Database initialization completed successfully!
==> Release command finished
```

### Step 8: Verify Deployment
Once deployed (green status), test:

```bash
# Health check
curl https://your-service.onrender.com/health

# Expected response:
# {"status": "healthy", "database": "connected"}

# Get all signs
curl https://your-service.onrender.com/api/translation/signs

# Register user
curl -X POST https://your-service.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123!"
  }'
```

---

## Troubleshooting

### Build Fails: "Python version not found"
**Solution:**
- [ ] Delete `backend/runtime.txt` (if it exists)
- [ ] Verify root-level `runtime.txt` exists
- [ ] Check content: `python-3.11.7`
- [ ] Redeploy

### Build Fails: "Cannot find module"
**Solution:**
- [ ] Verify all files in `models/` are committed
- [ ] Check `requirements.txt` is in `backend/` folder
- [ ] Run locally: `python backend/app.py`
- [ ] Push working version to GitHub

### Build Fails: "setuptools.build_meta"
**Solution:**
- [ ] Clear build cache (Settings → Danger Zone)
- [ ] Verify you're NOT using Python 3.14.3
- [ ] Check runtime.txt is at ROOT, not backend/
- [ ] Redeploy

### API Returns "Database connection error"
**Solution:**
- [ ] Check DATABASE_URL in environment variables
- [ ] Use PostgreSQL INTERNAL URL (not external)
- [ ] Format: `postgresql://user:pass@host/dbname`
- [ ] Verify database is running on Render

### Model Not Loading
**Solution:**
- [ ] Check persistent disk mounted correctly
- [ ] Verify models/ files exist in Render filesystem
- [ ] Check logs: `cat /opt/render/project/backend/models/sign_model.h5`
- [ ] If missing, manually upload via SFTP

### 502 Bad Gateway Error
**Solution:**
- [ ] Check logs for crash on startup
- [ ] Verify DATABASE_URL format
- [ ] Check if port 10000 is being used
- [ ] Restart service: Settings → Restart

---

## File Structure After Deployment

**Local (before push):**
```
sign_detection/
├── runtime.txt                    ← Python 3.11
├── Procfile                       ← Deployment config
├── backend/
│   ├── requirements.txt           ← Production deps (no ML)
│   ├── requirements-train.txt     ← Training deps only
│   ├── app.py
│   ├── models/
│   │   ├── sign_model.h5          ← Trained LSTM
│   │   ├── sign_labels.json       ← Translations
│   │   └── sign_mappings.json     ← Metadata
│   └── ...
└── ...
```

**Render Server:**
```
/opt/render/project/
├── runtime.txt                    ← Specifies Python 3.11
├── Procfile                       ← Runs: gunicorn + init_db
├── backend/
│   ├── app.py                     ← Running Flask app
│   ├── models/
│   │   ├── sign_model.h5          ← Persisted on disk
│   │   ├── sign_labels.json
│   │   └── sign_mappings.json
│   └── ...
└── ...
```

---

## Performance After Deploy

Expected metrics:
- ✅ Startup time: 30-60 seconds
- ✅ API response: <100ms
- ✅ Sign translation: <50ms
- ✅ Database query: <10ms
- ✅ Health check: Should work immediately

---

## What Happens on Deploy

1. **Build Phase:**
   - Clone repo from GitHub
   - Read `runtime.txt` → Install Python 3.11.7
   - Run build command → Install dependencies
   - Create virtual environment

2. **Release Phase:**
   - Read `Procfile` release command
   - Run: `python backend/init_db.py`
   - Initialize PostgreSQL database
   - Load 134 signs into database

3. **Runtime Phase:**
   - Read `Procfile` web command
   - Start Gunicorn with 4 workers
   - Listen on port 10000
   - Serve Flask app

---

## After Deployment

### Monitor Performance
- View logs: Dashboard → "Live tail"
- Check for errors: Search for "ERROR"
- Monitor memory: Settings → Metrics

### Test All Endpoints
```bash
# 1. Health
curl https://api.onrender.com/health

# 2. Register
curl -X POST https://api.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user","email":"user@test.com","password":"Pass123"}'

# 3. Login
curl -X POST https://api.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user","password":"Pass123"}'

# 4. Get Signs
curl https://api.onrender.com/api/translation/signs

# 5. Translate (requires token)
curl -X POST https://api.onrender.com/api/translation/translate \
  -H "Authorization: Bearer TOKEN" \
  -d '{"signs":["Hello","Please"],"language":"english"}'

# 6. Paragraph (requires token) ← MAIN FEATURE
curl -X POST https://api.onrender.com/api/translation/paragraph \
  -H "Authorization: Bearer TOKEN" \
  -d '{"detections":[{"sign":"Hello","confidence":0.95}]}'
```

### Connect Frontend
Update your app config:
```dart
// Flutter
const String API_BASE_URL = 'https://your-service.onrender.com/api';

// React
const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://your-service.onrender.com/api';
```

---

## Success Indicators ✅

- [ ] Render shows "Deployed" with green checkmark
- [ ] Logs show no errors
- [ ] Health endpoint works
- [ ] Can register users
- [ ] Can translate signs
- [ ] Can build paragraphs
- [ ] Database queries work

---

**You're Live! 🎉**

Your sign language detection API is now running on Render with:
- ✅ LSTM sign detection
- ✅ English/Hindi translations
- ✅ Paragraph building
- ✅ User authentication
- ✅ PostgreSQL database
- ✅ Persistent model storage
