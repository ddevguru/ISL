# 🎯 Sign Detection - Complete Deployment Guide (README)

> **TL;DR:** Everything is set up! Just use the `render.yaml` blueprint to deploy on Render in 5 minutes, then point your Flutter app to the backend URL. 🚀

---

## 📋 What's New (This Session)

### ✅ Backend Deployment Ready
- `render.yaml` - Deployment blueprint (PostgreSQL + Redis + Flask)
- `requirements.txt` - All Python dependencies
- `.env.example` - Environment variables template

### ✅ Flutter App Updated
- `api_config.dart` - Dynamic API URL configuration
- `live_sign_detection_screen.dart` - Camera + real-time detection UI
- Ready for camera package integration

### ✅ Documentation Complete
- Deployment guide (Artifact)
- Quick reference (DEPLOYMENT_SUMMARY.md)
- Setup scripts (SETUP.sh / SETUP.bat)
- Architecture blueprint (BLUEPRINT.txt)

---

## 🚀 Quick Start (Copy-Paste Ready)

### 1️⃣ Deploy Backend to Render (5 min)

```bash
# 1. Go to https://render.com
# 2. Click "+ New" → "PostgreSQL"
#    Name: sign-detection-db
# 3. Click "+ New" → "Redis"
#    Name: sign-detection-cache
# 4. Click "+ New" → "Web Service"
#    - Connect GitHub repo
#    - Root: backend
#    - Add env vars from below
# 5. Copy your backend URL
```

**Environment Variables to Set:**
```
FLASK_ENV=production
FLASK_APP=app.py
PORT=10000
DATABASE_URL=(from PostgreSQL dashboard)
REDIS_URL=(from Redis dashboard)
SECRET_KEY=(generate 32+ random chars)
JWT_SECRET_KEY=(generate 32+ random chars)
```

### 2️⃣ Update Flutter App (2 min)

In `sign_detection/lib/main.dart`:

```dart
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load cameras
  cameras = await availableCameras();
  
  // Configure backend URL (your Render URL)
  ApiConfig.useProduction('sign-detection-api-xxxxx.onrender.com');
  
  runApp(const MyApp());
}
```

### 3️⃣ Add Camera Dependencies (1 min)

In `sign_detection/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5
  http: ^1.1.0
  animate_do: ^3.3.4
```

Run: `flutter pub get`

### 4️⃣ Add Permissions

**Android** - `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** - `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses camera for sign language detection</string>
```

### 5️⃣ Add to Navigation

In your home screen:
```dart
ElevatedButton.icon(
  icon: const Icon(Icons.videocam),
  label: const Text('Live Detection'),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveSignDetectionScreen(cameras: cameras),
      ),
    );
  },
)
```

---

## 🧪 Testing

### Test Backend Health
```bash
# Replace URL with your Render URL
curl https://sign-detection-api-xxxxx.onrender.com/health
# Should return: {"status": "healthy", "database": "connected"}
```

### Test API
```bash
curl https://sign-detection-api-xxxxx.onrender.com/api
# Shows all available endpoints
```

### Test Flutter App

**Local Development:**
```bash
# Terminal 1: Start backend
cd backend
python app.py  # or use Render URL

# Terminal 2: Run app
cd sign_detection
flutter run
```

**Production:**
```bash
# Build APK
flutter build apk

# Build iOS
flutter build ios

# Install on device and test live detection!
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         RENDER CLOUD                    │
│  ┌────────┐  ┌────────┐  ┌────────┐   │
│  │ Flask  │→ │ PostgreSQL│ │ Redis  │  │
│  │ API    │  │   DB   │  │ Cache  │  │
│  └────────┘  └────────┘  └────────┘   │
│       ↑                                │
│       └────────────────────────────────┘
│              HTTPS API
│              ↑
├──────────────┼──────────────┐
│              │              │
┌──────────────┴──┐   ┌───────┴──────────┐
│ Flutter App    │   │ Local Backend    │
│ (Production)   │   │ (Development)    │
└────────────────┘   └──────────────────┘
```

---

## 📁 File Structure

```
sign_detection/
├── backend/
│   ├── render.yaml                ✅ NEW - Deploy blueprint
│   ├── requirements.txt            ✅ NEW - Python deps
│   ├── .env.example               ✅ NEW - Config template
│   ├── app.py                     (existing Flask app)
│   ├── models.py                  (existing)
│   └── ...
│
├── sign_detection/
│   ├── lib/
│   │   ├── main.dart              (update with API config)
│   │   ├── config/
│   │   │   └── api_config.dart    ✅ UPDATED - Dynamic URLs
│   │   └── features/
│   │       └── live_detection/
│   │           └── live_sign_detection_screen.dart  ✅ NEW
│   └── pubspec.yaml               (add camera package)
│
├── DEPLOYMENT_SUMMARY.md          ✅ NEW - Quick guide
├── BLUEPRINT.txt                  ✅ NEW - Architecture
├── README_DEPLOYMENT.md           ✅ NEW - This file
├── SETUP.sh                       ✅ NEW - Linux/Mac setup
└── SETUP.bat                      ✅ NEW - Windows setup
```

---

## 🔧 API Configuration Methods

### For Production (Render)
```dart
ApiConfig.useProduction('sign-detection-api-xxxxx.onrender.com');
```

### For Local Development
```dart
ApiConfig.useLocalNetwork('192.168.0.146', port: 5000);
```

### Custom URL
```dart
ApiConfig.setBaseUrl('https://custom-domain.com/api');
```

---

## 📊 API Endpoints

All endpoints are relative to `https://your-backend-url/api`

### Authentication
```
POST /auth/signup
POST /auth/login
GET  /auth/profile
```

### Detection (Main Feature)
```
POST /detection/detect-frame        # Send camera frame
GET  /detection/signs               # Get all signs
GET  /detection/history             # Get detection history
POST /detection/detect-video        # Process video file
```

### Utilities
```
GET  /utils/categories              # Get sign categories
GET  /utils/dataset/stats           # Dataset statistics
GET  /utils/learning-progress       # User progress
```

### Health
```
GET  /health                        # Health check
GET  /api                           # API info
```

---

## ⚙️ Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `FLASK_ENV` | Environment mode | `production` or `development` |
| `DATABASE_URL` | PostgreSQL connection | `postgresql://user:pass@host/db` |
| `REDIS_URL` | Redis cache connection | `redis://host:port` |
| `SECRET_KEY` | Session encryption | Random 32+ chars |
| `JWT_SECRET_KEY` | Token signing | Random 32+ chars |
| `PORT` | Server port | `10000` (Render) or `5000` (local) |

---

## 🐛 Troubleshooting

### Backend Won't Connect
**Error:** Connection refused
- **Local:** Make sure backend is running on correct IP
- **Remote:** Check Render service is "Live" (not "Building")
- **Fix:** Verify URL in ApiConfig matches your backend

### Camera Not Working
**Error:** Permission denied
- **Android:** Add permissions to AndroidManifest.xml
- **iOS:** Add NSCameraUsageDescription to Info.plist
- **Fix:** Request runtime permissions at app startup

### Detection Timeout
**Error:** Request timeout after 30 seconds
- **Fix:** Increase timeout or check backend logs
  ```dart
  static const Duration receiveTimeout = Duration(seconds: 60);
  ```

### Database Connection Failed
**Error:** psycopg2.OperationalError
- **Fix:** Copy full DATABASE_URL from Render PostgreSQL dashboard
- Paste exactly as shown in environment variables

---

## ✅ Deployment Checklist

- [ ] Backend files ready (render.yaml, requirements.txt)
- [ ] Render account created
- [ ] PostgreSQL database created and connected
- [ ] Redis cache created and connected
- [ ] Web service deployed (status: "Live")
- [ ] Backend URL copied
- [ ] Flutter main.dart updated with backend URL
- [ ] Camera package added to pubspec.yaml
- [ ] Permissions added (Android + iOS)
- [ ] App builds successfully: `flutter build apk`
- [ ] Local testing passes with local backend
- [ ] Production testing passes with Render backend
- [ ] Live detection screen working
- [ ] Ready for release! 🚀

---

## 🎯 Next Steps

1. **Read the detailed guide** (Artifact): "Sign Detection - Complete Deployment Guide"
2. **Run setup script**: `./SETUP.sh` (Linux/Mac) or `SETUP.bat` (Windows)
3. **Deploy backend**: Use render.yaml on render.com
4. **Update Flutter app**: Set API config to Render URL
5. **Add camera**: Install dependencies and permissions
6. **Test locally**: Run with local backend first
7. **Deploy app**: Build and install on real device
8. **Go live**: Monitor logs and enjoy live sign detection! 🎉

---

## 📚 Documentation

- **Complete Guide** (Artifact) - Full step-by-step instructions
- **DEPLOYMENT_SUMMARY.md** - Quick reference
- **BLUEPRINT.txt** - Architecture diagram
- **This file** - Quick start guide

---

## 💡 Pro Tips

✅ **Always test locally first** before deploying to production
✅ **Keep .env files secret** - Add to .gitignore
✅ **Monitor Render logs** for any deployment errors
✅ **Use strong keys** - Generate random SECRET_KEY and JWT_SECRET_KEY
✅ **Cache models** - Redis caches detection results for speed
✅ **Handle timeouts** - Large frames may take time to process

---

## 🆘 Need Help?

1. **Setup Issues?** Check SETUP.sh or SETUP.bat
2. **Deployment Issues?** See Complete Deployment Guide
3. **Connection Issues?** Run health check: `/health` endpoint
4. **Detection Issues?** Check Render backend logs
5. **Camera Issues?** Check AndroidManifest.xml and Info.plist

---

**Status:** ✅ Ready to Deploy
**Last Updated:** 2026-08-19
**Framework:** Flutter + Flask + Render

🚀 **Happy Deploying!**
