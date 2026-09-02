# Sign Detection Project – Comprehensive Overview

---

## Table of Contents
1. [Project Summary](#project-summary)
2. [Backend Architecture](#backend-architecture)
3. [Machine‑Learning Models](#machine‑learning-models)
4. [REST API Endpoints](#rest-api-endpoints)
5. [Flutter Front‑End Integration](#flutter-front‑end-integration)
   - 5.1 [Authentication Flow](#authentication-flow)
   - 5.2 [Detecting a Sign (Sample Code)](#detecting-a-sign-sample-code)
   - 5.3 [Training & Practice Screens](#training‑practice-screens)
6. [Deployment Stack](#deployment-stack)
7. [Important Files & Directories](#important-files‑directories)
8. [Visual Architecture Diagram](#visual-architecture-diagram)
---

## Project Summary
The **sign_detection** repository implements a hand‑gesture based sign language recognition system. It consists of:
- A **Flask** backend that receives frames from a client, extracts hand landmarks via **MediaPipe**, and classifies the gesture with a **Scikit‑Learn RandomForest** model (and optionally a lightweight Keras model).
- A collection of **Python utilities** for data loading, model training, and database interaction.
- Deployment configuration for **Render** (Docker, Procfile, nginx). 
- Integration points for a **Flutter** mobile application (found in the sibling `indraprastha` repo) that streams camera frames to the backend.

---

## Backend Architecture
```
[Flutter App] <--REST (JSON)--> [Flask API]
                              |
          ├── MediaPipe (hand landmark extraction)
          ├── RandomForest classifier (models/ISL_Detection_V1.pkl)
          └── Keras lite model (models/ISL_Detection_V1.h5) – optional fallback
```
Key modules:
- **app.py** – Flask entry point, registers blueprints.
- **sign_detector.py** – Core logic: `extract_landmarks` → `predict_sign`.
- **video_processor.py** – Handles frame‑by‑frame processing for live streams.
- **detection_routes.py** – `/detect-frame` endpoint that receives a base‑64 image, runs the detector and returns `{ sign, confidence, landmarks }`.
- **model_trainer.py / train_complete_model.py** – Scripts for training the RandomForest/Keras models.

---

## Machine‑Learning Models
| Model File | Type | Purpose | Size |
|------------|------|---------|------|
| `models/ISL_Detection_V1.pkl` | Scikit‑Learn RandomForest | Primary classifier for 26 ASL signs | ~45 MB |
| `models/ISL_Detection_V1.h5` | TensorFlow/Keras | Lightweight fallback for mobile‑first scenarios | ~12 MB |
| `models/landmark_normalizer.pkl` | Scikit‑Learn StandardScaler | Normalizes MediaPipe landmarks before classification | < 1 MB |

Both models were trained on the **ISL** dataset (see `SIGN_LANGUAGE_DATASET.md`). The RandomForest model provides the best accuracy, while the Keras model offers faster inference on CPU‑constrained environments.

---

## REST API Endpoints
| Method | URL | Description | Request Body | Response |
|--------|-----|-------------|--------------|----------|
| **POST** | `/api/v1/detect-frame` | Detect a sign from a single camera frame. | `{ "frame": "<base64‑png>", "min_confidence": 0.6 }` | `{ "sign": "A", "confidence": 0.93, "landmarks": [...] }` |
| **GET** | `/api/v1/models` | List available model versions. | – | `{ "available": ["v1"] }` |
| **POST** | `/api/v1/train` | Trigger a quick training run (admin only). | `{ "type": "random_forest" }` | `{ "status": "started", "job_id": "abc123" }` |
| **GET** | `/api/v1/health` | Health‑check used by Render. | – | `{ "status": "ok" }` |

All routes are protected with JWT authentication (`auth.py`). The detection endpoint expects a **PNG** image encoded in base‑64; the backend decodes it, runs MediaPipe, and returns the prediction.

---

## Flutter Front‑End Integration
The Flutter side lives in the `indraprastha/lib` package. The following key files are used for sign detection:
- `lib/core/services/sign_detection_service.dart` – Handles HTTP calls to `/detect-frame`.
- `lib/ui/screens/practice_screen.dart` – Captures camera frames, sends them, and displays live feedback.
- `lib/ui/widgets/sign_overlay.dart` – Renders landmarks on the camera preview.

### 5.1 Authentication Flow
```dart
Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt') ?? '';
}
```
All API calls include the header: `Authorization: Bearer <token>`.

### 5.2 Detecting a Sign (Sample Code)
```dart
Future<SignResult> detectSign(Uint8List pngBytes) async {
  final token = await _getToken();
  final response = await http.post(
    Uri.parse('${Env.apiBaseUrl}/api/v1/detect-frame'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'frame': base64Encode(pngBytes),
      'min_confidence': 0.6,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Detection failed: ${response.body}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return SignResult(
    sign: data['sign'] as String,
    confidence: (data['confidence'] as num).toDouble(),
    landmarks: List<double>.from(data['landmarks'] ?? []),
  );
}
```
`SignResult` is a simple model:
```dart
class SignResult {
  final String sign;
  final double confidence;
  final List<double> landmarks;
  SignResult({required this.sign, required this.confidence, required this.landmarks});
}
```
The UI updates in real‑time, showing the predicted sign and a confidence bar.

### 5.3 Training & Practice Screens
- **PracticeScreen** – Guides the user through a sequence of target signs, validates the prediction against the target, and provides haptic feedback.
- **TrainingScreen** – Allows a user to record new gestures, which are sent to `/api/v1/train` for optional model fine‑tuning (admin‑only).

---

## Deployment Stack
| Component | Technology | Notes |
|-----------|------------|-------|
| **Web Server** | Render (Docker) + Nginx | `render.yaml` defines the service, `Dockerfile` builds the image. |
| **Python Runtime** | 3.11 | Dependencies listed in `requirements.txt`. |
| **Database** | PostgreSQL (managed by Render) | Used by `isl_signs_database.py` for storing user data and practice logs. |
| **Cache** | Redis (optional) | Can be enabled for frequent landmark normalisation. |
| **Static Files** | Served via Nginx | `/uploads` folder stores user‑uploaded reference images. |

---

## Important Files & Directories
- **backend/** – Core Flask application.
- **backend/models/** – Pre‑trained model files.
- **backend/sign_detector.py** – Landmark extraction & classification logic.
- **backend/detection_routes.py** – API entry point for detection.
- **backend/video_processor.py** – Real‑time frame handling.
- **backend/requirements.txt** – Python dependencies (MediaPipe, scikit‑learn, Flask‑JWT, etc.).
- **backend/PROJECT_OVERVIEW.md** – Human‑readable description (this file).
- **frontend (Flutter)** – Located in the sibling `indraprastha/lib` directory; see `sign_detection_service.dart` and UI screens as mentioned above.

---

## Visual Architecture Diagram
![Architecture Diagram](file:///C:/Users/deepa/.gemini/antigravity-ide/brain/5ef63b0c-5487-41cc-8011-e16e45e389b8/project_overview_diagram_1787562851452.png)

---

*This document provides a high‑level overview for developers, testers, and new contributors. For deeper technical details, refer to the individual module docstrings and the API specification in `API_INTEGRATION_GUIDE.md`.*
