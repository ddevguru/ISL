# Sign Detection Project – Extended Documentation

## 1. Project Overview (recap)
*See **PROJECT_OVERVIEW_DOC.md** for the high‑level summary and architecture diagram.*

---

## 2. Detailed Backend Structure
### 2.1 Core Packages & Files
- **`app.py`** – Flask application factory, registers blueprints (`auth`, `detection`, `translation`, `user`, `utility`).
- **`config.py`** – Central configuration (environment variables, DB URLs, CORS settings).
- **`auth.py`** – JWT authentication utilities (`login`, `register`, token refresh).
- **`sign_detector.py`** –
  - `extract_landmarks(image: np.ndarray) -> List[float]` – Uses MediaPipe Hands to output a flattened list of 21×3 (x, y, z) landmarks.
  - `load_model()` – Lazy‑loads the RandomForest `.pkl` (or Keras `.h5` if configured).
  - `predict_sign(landmarks: List[float]) -> Tuple[str, float]` – Returns `(sign_label, confidence)`.
- **`video_processor.py`** – Wraps `ISLSignDetector` for per‑frame processing; also handles optional frame throttling.

### 2.2 API Blueprints & Endpoints
| Blueprint | Route | Method | Description |
|-----------|-------|--------|-------------|
| **auth** | `/api/v1/login` | POST | Returns JWT after validating email/password.
|  | `/api/v1/register` | POST | Creates a new user; stores hashed password.
| **detection** | `/api/v1/detect-frame` | POST | Main inference endpoint (see `API_INTEGRATION_GUIDE.md`).
|  | `/api/v1/batch-detect` | POST | Accepts an array of base64 frames; returns predictions for each.
| **translation** | `/api/v1/translate` | POST | Maps sign label to textual description using `isl_signs_database.py`.
| **user** | `/api/v1/profile` | GET | Returns user profile data.
|  | `/api/v1/practice-history` | GET | Returns a list of past practice sessions with timestamps and scores.
| **utility** | `/api/v1/health` | GET | Simple health‑check used by Render.
|  | `/api/v1/models` | GET | Lists the model files currently loaded on the server.
|  | `/api/v1/reload-model` | POST (admin) | Forces a reload of the model from disk – useful after a new model upload.

All routes (except `/health` and `/login`) require the `Authorization: Bearer <JWT>` header.

---

## 3. Model Training Pipeline
1. **Data Preparation** – `dataset_loader.py` reads raw hand‑landmark CSV files from `datasets/` and splits them into train/val.
2. **Feature Scaling** – `StandardScaler` is fitted on training landmarks and saved as `models/landmark_normalizer.pkl`.
3. **RandomForest Training** – `model_trainer.py`:
   ```python
   from sklearn.ensemble import RandomForestClassifier
   clf = RandomForestClassifier(n_estimators=200, max_depth=15, random_state=42)
   clf.fit(X_train, y_train)
   joblib.dump(clf, 'models/ISL_Detection_V1.pkl')
   ```
4. **Keras Lite Model** – `train_complete_model.py` builds a small Conv1D network, trains for 30 epochs, and exports `models/ISL_Detection_V1.h5`.
5. **Versioning** – Each model file is accompanied by a small JSON manifest (`models/manifest.json`) that records training date, data checksum, and accuracy metrics.
6. **Deployment** – After training, copy the `.pkl`/`.h5` into the Render `instance/models/` directory and run `touch .ready` to signal the backend to reload.

---

## 4. Deployment & Operations (Render)
- **`render.yaml`** – Defines a **web service** with Docker build, environment variables, and auto‑deploy on push.
- **Dockerfile** (simplified):
  ```Dockerfile
  FROM python:3.11-slim
  WORKDIR /app
  COPY . /app
  RUN pip install -r requirements.txt
  CMD gunicorn --bind 0.0.0.0:$PORT wsgi:app
  ```
- **Procfile** – `web: gunicorn wsgi:app`.
- **Environment Variables** (set in Render console):
  - `MODEL_PATH=models/ISL_Detection_V1.pkl`
  - `REDIS_URL` (optional cache)
  - `DATABASE_URL` (PostgreSQL)
- **Health Checks** – Render pings `/api/v1/health` every 30 s; a non‑200 response restarts the container.
- **Logs** – Accessible via Render dashboard; also streamed to `stdout` for `gunicorn`.

---

## 5. Flutter Front‑End – Complete Page Inventory
| Dart File | UI Purpose |
|-----------|-----------|
| `lib/features/books/books_screens.dart` | Sign glossary with video demos.
| `lib/features/practice/practice_screens_enhanced.dart` | Live practice with real‑time detection overlay.
| `lib/features/subscriptions/subscriptions_screen.dart` | Subscription management (free vs premium).
| `lib/features/streaks/streaks_screen.dart` | Shows user’s daily practice streak.
| `lib/features/analytics/analytics_screen.dart` | Visualizes practice statistics (confidence heat‑map).
| `lib/core/services/sign_detection_service.dart` | HTTP client wrapper for `/detect-frame`.
| `lib/core/services/auth_service.dart` | Handles login, token storage, and refresh.
| `lib/ui/widgets/sign_overlay.dart` | Paints MediaPipe landmarks on camera preview.
| `lib/ui/widgets/confidence_bar.dart` | Animated bar reflecting prediction confidence.
| `lib/ui/widgets/custom_drawer.dart` | Navigation drawer with links to all feature screens.

### Navigation Flow (simplified)
```
HomeScreen → Drawer →
  • PracticeScreen (live detection)
  • BooksScreen (learn signs)
  • StreaksScreen (track progress)
  • SubscriptionScreen (upgrade)
  • AnalyticsScreen (view stats)
```
All screens use a shared `AppScaffold` that injects the JWT token into the `SignDetectionService`.

---

## 6. Important Configuration Files
- **`backend/.env.example`** – Template for environment variables.
- **`backend/requirements.txt`** – Core Python deps (`flask`, `mediapipe`, `scikit-learn`, `gunicorn`, `flask-jwt-extended`).
- **`pubspec.yaml`** – Flutter dependencies (`http`, `shared_preferences`, `camera`, `provider`).
- **`render.yaml`** – Render service definition.
- **`docker-compose.yml`** – Local development stack (Flask + PostgreSQL + Redis).

---

## 7. Gotchas & Tips for Contributors
1. **Large Model Files** – Git LFS may reject >100 MB. Store models in a private cloud bucket and download via `SETUP.sh` when container starts.
2. **MediaPipe CPU vs GPU** – The Render environment uses CPU only; keep `mediapipe` version <=0.10.35 to avoid GPU‑only binaries.
3. **Testing Locally** – Run `docker-compose up` to spin up Flask, PostgreSQL, and Redis. Use `http://localhost:5000/api/v1/health` to verify.
4. **Flutter Hot‑Reload** – When editing detection UI, keep the camera stream alive by calling `controller.startImageStream` only once and re‑using the same `SignDetectionService` instance.
5. **Model Versioning** – Increment the `manifest.json` `version` field after each training run; the backend will automatically pick the newest file when `MODEL_PATH` changes.

---

## 8. Frequently Asked Questions (FAQ)
| Question | Answer |
|----------|--------|
| *Why does detection sometimes return `null`?* | The confidence threshold (`min_confidence`) filters low‑confidence predictions. Lower the threshold or ensure the hand is fully within the camera view.
| *Can I add a new sign?* | Yes. Add landmark data to `datasets/`, retrain using `train_complete_model.py`, and upload the new model file.
| *How do I enable caching?* | Set `REDIS_URL` in the `.env`; the backend will cache the last 100 predictions per user ID.
| *Is there a Web version?* | Not yet. The API is platform‑agnostic, so a React web client can be built using the same endpoints.

---

*Prepared on 2026‑08‑24. For any missing details, refer to the source code docstrings or open an issue in the repository.*
