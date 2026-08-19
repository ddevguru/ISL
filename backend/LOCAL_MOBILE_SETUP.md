# 🚀 Local Mobile Development Setup

**Your Network IP: 192.168.0.132**  
**WiFi Connected ✅**

---

## ✅ **STEP 1: Backend Setup (Computer)**

### 1.1 Open Command Prompt/PowerShell

```bash
cd C:\sign_detection\backend
```

### 1.2 Create Virtual Environment

```bash
python -m venv venv
venv\Scripts\activate
```

**Expected Output:**
```
(venv) C:\sign_detection\backend>
```

### 1.3 Install Dependencies

```bash
pip install -r requirements.txt
```

**Wait for installation to complete (~2-3 minutes)**

### 1.4 Initialize Database (First Time Only)

```bash
python init_db.py
```

**Expected Output:**
```
✓ Database tables created successfully
✓ 100+ signs loaded successfully
✓ Database initialization completed!
```

### 1.5 Load Sign Data

```bash
python load_signs.py
```

**Expected Output:**
```
✓ Loaded 100 signs from dataset
✓ 100 signs successfully added to database
✓ Dataset Loading Complete!
```

### 1.6 Start Backend Server

```bash
python app.py
```

**🎉 IMPORTANT - Copy This Output:**
```
============================================================
🚀 Sign Language Detection Backend
============================================================
✅ Server running on: http://0.0.0.0:5000
✅ Local access: http://localhost:5000
✅ Mobile access: http://192.168.0.132:5000
✅ API Docs: http://192.168.0.132:5000/api
============================================================
```

**✅ Backend is now running!**

---

## ✅ **STEP 2: Test Backend (From Computer)**

Open browser and test:

```
http://localhost:5000/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "database": "connected"
}
```

---

## ✅ **STEP 3: Mobile App Setup**

### 3.1 Configure Flutter App

**File:** `lib/config/api_config.dart`

Already configured with:
```dart
static const String baseUrl = 'http://192.168.0.132:5000/api';
```

### 3.2 Update pubspec.yaml (If needed)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.0
  dio: ^5.0.0
```

### 3.3 Start Flutter App

Open new terminal/command prompt:

```bash
cd C:\sign_detection\sign_detection
flutter pub get
flutter run
```

**Select device (Android/iOS simulator or physical phone on WiFi)**

---

## ✅ **STEP 4: Test Mobile App Connection**

### 4.1 From Mobile App

The app will automatically:
1. Check backend health
2. Load signs list
3. Test API connection

### 4.2 Manual Test (From Mobile Browser)

**On your mobile phone:**

```
Browser > URL Bar > http://192.168.0.132:5000/health
```

**Expected:**
```json
{"status": "healthy", "database": "connected"}
```

---

## 📱 **STEP 5: Test Sign Detection**

### From Mobile App:

1. **Signup:**
   ```
   Username: testuser
   Email: test@example.com
   Password: TestPass123
   ```

2. **Browse Signs:**
   ```
   Tap "Browse Signs"
   Should show 100+ signs
   ```

3. **Search:**
   ```
   Search for "Happy"
   Should find Happy sign
   ```

4. **Detect:**
   ```
   Tap Camera
   Make a gesture
   Should detect sign
   ```

---

## 🔧 **TROUBLESHOOTING**

### ❌ Problem: Mobile can't connect to backend

**Solution:**

```bash
# 1. Check both devices on same WiFi
# Phone WiFi: Same as computer

# 2. Check backend is running
# Computer Terminal should show:
# * Running on http://0.0.0.0:5000

# 3. Check IP address (should match)
# Your IP: 192.168.0.132

# 4. Ping test (from mobile browser)
# http://192.168.0.132:5000/health
```

### ❌ Problem: Database error

```bash
# Stop backend (Ctrl+C)
python init_db.py
python load_signs.py
python app.py
```

### ❌ Problem: Port 5000 already in use

```bash
# Change port in .env
PORT=5001

# Then run
python app.py
```

### ❌ Problem: Flutter can't find http package

```bash
cd C:\sign_detection\sign_detection
flutter pub get
```

---

## 📊 **Architecture Diagram**

```
┌──────────────────────────────────────────────────────┐
│              WiFi Network (192.168.0.x)              │
│              Same Router/Network                      │
└──────────────────────────────────────────────────────┘
         │                            │
         │                            │
    ┌────▼──────────┐          ┌──────▼──────────┐
    │ COMPUTER      │          │ MOBILE PHONE    │
    │               │          │                 │
    │ IP:           │          │ WiFi:           │
    │ 192.168.0.132 │◄────────►│ Same Network    │
    │               │          │                 │
    │ Backend:      │          │ Flutter App:    │
    │ PORT 5000     │          │ http://192.... │
    │ ✓ Running     │          │                 │
    │ ✓ Database OK │          │ ✓ Connected     │
    │ ✓ Signs Loaded│          │ ✓ Can Detect    │
    └───────────────┘          └─────────────────┘
```

---

## ✅ **Complete Checklist**

```
BACKEND SETUP:
□ Virtual environment created
□ Dependencies installed
□ Database initialized
□ Signs loaded (100+)
□ Backend running on 0.0.0.0:5000
□ Health check passed

NETWORK:
□ Computer IP: 192.168.0.132
□ WiFi connected
□ No firewall blocking port 5000
□ Same WiFi on mobile

MOBILE APP:
□ api_config.dart updated
□ pubspec.yaml dependencies OK
□ Flutter run successful
□ Backend connectivity confirmed
```

---

## 🎯 **Quick Reference**

### Backend URLs

```
Development (Computer):
http://localhost:5000

Mobile (WiFi):
http://192.168.0.132:5000

API Endpoints:
http://192.168.0.132:5000/api
```

### Key Endpoints

```
Health: GET http://192.168.0.132:5000/health
Signs: GET http://192.168.0.132:5000/api/detection/signs
Signup: POST http://192.168.0.132:5000/api/auth/signup
Login: POST http://192.168.0.132:5000/api/auth/login
Detect: POST http://192.168.0.132:5000/api/detection/detect-frame
```

### Ports

```
Backend API: 5000
Flutter Dev: 8080-8081 (varies)
PostgreSQL: 5432 (local only)
```

---

## 🚀 **START NOW**

### Terminal 1 (Backend - Keep Running)
```bash
cd C:\sign_detection\backend
venv\Scripts\activate
python app.py
```

### Terminal 2 (Mobile App)
```bash
cd C:\sign_detection\sign_detection
flutter run
```

**Both should run simultaneously!**

---

## 💡 **Pro Tips**

1. **Don't close backend terminal** - Keep it running while developing mobile app
2. **Use your IP address** - Never use localhost from mobile
3. **Same WiFi required** - Phone and computer must be on same network
4. **Check IP regularly** - IP can change if router restarts
5. **Mobile logs** - Check Flutter console for connection errors

---

## 📞 **Common Commands**

```bash
# Check IP again (if changed)
ipconfig

# Restart backend
# In backend terminal: Ctrl+C
python app.py

# Reload mobile app
# In mobile terminal: R (hot reload)

# Stop everything
# Ctrl+C in both terminals

# Reset database
python init_db.py
python load_signs.py
```

---

## ✨ **Success Indicators**

✅ Backend terminal shows "Running on http://0.0.0.0:5000"
✅ Mobile browser reaches http://192.168.0.132:5000/health
✅ Flutter app shows "Backend Connected"
✅ Mobile app loads signs from database
✅ Detection works with camera input

---

**Your local development environment is ready! 🎉**

Backend on computer ↔ Mobile app on phone = Both via WiFi

Let me know if you face any issues!
