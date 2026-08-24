"""ISL Sign Detection Service using MediaPipe + TensorFlow"""
import cv2
import numpy as np
import mediapipe as mp
import tensorflow as tf
from tensorflow import keras
import pickle
import json
from pathlib import Path
from typing import Dict, Optional
import base64
from io import BytesIO
from PIL import Image

class ISLSignDetector:
    def __init__(self, model_name="ISL_Detection_V1"):
        self.model_name = model_name
        self.models_dir = Path('models')
        
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.7
        )
        
        self.model = None
        self.label_encoder = None
        self.metadata = None
        self.landmarks_size = 42
        self._load_model()

    def _load_model(self):
        # Try TensorFlow model first
        model_path_tf = self.models_dir / f"{self.model_name}.h5"
        # Try sklearn model
        model_path_sk = self.models_dir / f"{self.model_name}.pkl"
        encoder_path = self.models_dir / f"{self.model_name}_encoder.pkl"
        metadata_path = self.models_dir / f"{self.model_name}_metadata.json"

        try:
            # Try TensorFlow model
            if model_path_tf.exists():
                self.model = keras.models.load_model(str(model_path_tf))
                print(f"✅ Loaded TensorFlow model")
            # Try sklearn model
            elif model_path_sk.exists():
                with open(model_path_sk, 'rb') as f:
                    self.model = pickle.load(f)
                print(f"✅ Loaded sklearn model")
            else:
                print(f"⚠️ Model not found: {model_path_tf} or {model_path_sk}")
                return False

            if encoder_path.exists():
                with open(encoder_path, 'rb') as f:
                    self.label_encoder = pickle.load(f)
            if metadata_path.exists():
                with open(metadata_path, 'r') as f:
                    self.metadata = json.load(f)
            return True
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            return False

    def extract_landmarks(self, frame: np.ndarray) -> Optional[np.ndarray]:
        try:
            results = self.hands.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if results.multi_hand_landmarks:
                landmarks = []
                for hand_landmarks in results.multi_hand_landmarks:
                    for landmark in hand_landmarks.landmark:
                        landmarks.extend([landmark.x, landmark.y])
                if len(landmarks) == self.landmarks_size:
                    landmarks.extend([0] * self.landmarks_size)
                return np.array(landmarks[:self.landmarks_size * 2])
            return None
        except Exception as e:
            print(f"❌ Error: {e}")
            return None

    def predict_sign(self, landmarks: np.ndarray) -> Dict:
        if self.model is None:
            return {'success': False, 'error': 'Model not loaded', 'sign': None, 'confidence': 0}

        try:
            landmarks = np.array(landmarks).reshape(1, -1)

            # Check if it's sklearn model (has predict_proba) or TensorFlow
            if hasattr(self.model, 'predict_proba'):
                # sklearn model
                proba = self.model.predict_proba(landmarks)[0]
                confidence = float(np.max(proba))
                idx = np.argmax(proba)
            else:
                # TensorFlow model
                predictions = self.model.predict(landmarks, verbose=0)
                idx = np.argmax(predictions[0])
                confidence = float(predictions[0][idx])

            sign = self.label_encoder.inverse_transform([idx])[0]
            return {'success': True, 'sign': sign, 'confidence': confidence}
        except Exception as e:
            return {'success': False, 'error': str(e), 'sign': None, 'confidence': 0}

    def detect_from_image(self, image_data: str) -> Dict:
        try:
            image_bytes = base64.b64decode(image_data)
            image = Image.open(BytesIO(image_bytes))
            frame = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
            landmarks = self.extract_landmarks(frame)
            if landmarks is None:
                return {'success': False, 'error': 'No hands detected', 'sign': None}
            return self.predict_sign(landmarks)
        except Exception as e:
            return {'success': False, 'error': str(e), 'sign': None}

    def process_video_frame(self, frame: np.ndarray, min_confidence: float = 0.5) -> tuple:
        """Process a video frame and return (sign, confidence, annotated_frame)"""
        try:
            landmarks = self.extract_landmarks(frame)
            if landmarks is None:
                return None, 0.0, frame

            result = self.predict_sign(landmarks)
            if result['success']:
                sign = result['sign']
                confidence = result['confidence']
                if confidence >= min_confidence:
                    return sign, confidence, frame
            return None, 0.0, frame
        except Exception as e:
            print(f"Error processing frame: {e}")
            return None, 0.0, frame

def get_detector():
    global detector
    if detector is None:
        detector = ISLSignDetector()
    return detector

detector = None
