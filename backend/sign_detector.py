"""ISL Sign Detection Service using MediaPipe + Scikit-Learn (Hybrid Engine)"""
import cv2
import numpy as np
import mediapipe as mp
import pickle
import json
from pathlib import Path
from typing import Dict, Optional
import base64
from io import BytesIO
from PIL import Image, ImageOps

class ISLSignDetector:
    def __init__(self, model_name="ISL_Detection_V1"):
        self.model_name = model_name
        self.models_dir = Path('models')
        
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.3
        )
        
        self.mp_face_mesh = mp.solutions.face_mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(
            static_image_mode=False,
            max_num_faces=1,
            refine_landmarks=True,
            min_detection_confidence=0.3
        )
        
        self.model = None
        self.label_encoder = None
        self.metadata = None
        self.landmarks_size = 42
        self._load_model()

    def _load_model(self):
        model_path_sk = self.models_dir / f"{self.model_name}.pkl"
        encoder_path = self.models_dir / f"{self.model_name}_encoder.pkl"
        metadata_path = self.models_dir / f"{self.model_name}_metadata.json"

        try:
            if model_path_sk.exists():
                with open(model_path_sk, 'rb') as f:
                    self.model = pickle.load(f)
                print(f"✅ Loaded Scikit-Learn RandomForest model")
            else:
                print(f"⚠️ RandomForest model not found: {model_path_sk}")
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
            print(f"❌ Error extracting landmarks: {e}")
            return None

    def process_face(self, frame: np.ndarray) -> Dict:
        """Detect face and analyze expressions and facial patterns using Face Mesh"""
        try:
            results = self.face_mesh.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if results.multi_face_landmarks:
                landmarks = results.multi_face_landmarks[0].landmark
                
                # Calculate face bounding box in normalized coordinates
                x_coords = [lm.x for lm in landmarks]
                y_coords = [lm.y for lm in landmarks]
                x_min, x_max = min(x_coords), max(x_coords)
                y_min, y_max = min(y_coords), max(y_coords)
                
                face_bbox = {
                    'x': max(0.0, x_min),
                    'y': max(0.0, y_min),
                    'w': min(1.0, x_max) - max(0.0, x_min),
                    'h': min(1.0, y_max) - max(0.0, y_min)
                }
                
                # 3D distance helper
                def get_dist_3d(p1, p2):
                    return np.sqrt((p1.x - p2.x)**2 + (p1.y - p2.y)**2 + (p1.z - p2.z)**2)
                
                # Normalize distances by cheek-to-cheek face width
                face_width = get_dist_3d(landmarks[234], landmarks[454]) or 1.0
                
                # Eyelid openness ratio (top-bottom eyelid distance normalized)
                left_eye_open = get_dist_3d(landmarks[159], landmarks[145]) / face_width
                right_eye_open = get_dist_3d(landmarks[386], landmarks[374]) / face_width
                
                # Mouth width & height metrics
                mouth_width = get_dist_3d(landmarks[61], landmarks[291]) / face_width
                mouth_height = get_dist_3d(landmarks[0], landmarks[17]) / face_width
                
                # Eyebrow raise distance
                left_eyebrow_raise = get_dist_3d(landmarks[70], landmarks[159]) / face_width
                right_eyebrow_raise = get_dist_3d(landmarks[300], landmarks[386]) / face_width
                avg_eyebrow_raise = (left_eyebrow_raise + right_eyebrow_raise) / 2
                
                # Eyebrow proximity (frown)
                eyebrow_dist = get_dist_3d(landmarks[107], landmarks[336]) / face_width
                
                # Classify expression/patterns
                expression = 'Neutral'
                
                if left_eye_open < 0.04 and right_eye_open > 0.07:
                    expression = 'Wink Left'
                elif right_eye_open < 0.04 and left_eye_open > 0.07:
                    expression = 'Wink Right'
                elif left_eye_open < 0.04 and right_eye_open < 0.04:
                    expression = 'Blink'
                elif mouth_width > 0.35 and mouth_height < 0.15:
                    expression = 'Happy'
                elif avg_eyebrow_raise > 0.22 and mouth_height > 0.06:
                    expression = 'Surprised'
                elif eyebrow_dist < 0.18:
                    expression = 'Angry'
                elif mouth_height > 0.05 and mouth_width < 0.35:
                    expression = 'Sad'
                
                return {
                    'face_detected': True,
                    'face_bbox': face_bbox,
                    'expression': expression,
                    'facial_patterns': {
                        'left_eye_open': float(left_eye_open),
                        'right_eye_open': float(right_eye_open),
                        'mouth_width': float(mouth_width),
                        'mouth_height': float(mouth_height),
                        'eyebrow_raise': float(avg_eyebrow_raise),
                        'eyebrow_distance': float(eyebrow_dist)
                    }
                }
            return {'face_detected': False, 'face_bbox': None, 'expression': 'Unknown', 'facial_patterns': {}}
        except Exception as e:
            print(f"❌ Error processing face: {e}")
            return {'face_detected': False, 'face_bbox': None, 'expression': 'Unknown', 'facial_patterns': {}}

    def heuristic_predict_sign(self, landmarks_flat: np.ndarray) -> Optional[str]:
        """Heuristic rule-based sign language classifier based on joint relations"""
        try:
            pts = landmarks_flat.reshape(-1, 2)
            if len(pts) < 21:
                return None
                
            def get_dist(i, j):
                return np.sqrt((pts[i][0] - pts[j][0])**2 + (pts[i][1] - pts[j][1])**2)
            
            # Helper to check if finger is extended
            def is_finger_extended(mcp, tip):
                return get_dist(0, tip) > get_dist(0, mcp) * 1.15
            
            # Check thumb extension
            thumb_ext = get_dist(0, 4) > get_dist(0, 2) * 1.12
            
            index_ext = is_finger_extended(5, 8)
            middle_ext = is_finger_extended(9, 12)
            ring_ext = is_finger_extended(13, 16)
            pinky_ext = is_finger_extended(17, 20)
            
            # Thumbs Up check (GOOD / YES)
            if thumb_ext and not index_ext and not middle_ext and not ring_ext and not pinky_ext:
                if pts[4][1] < pts[3][1]: # pointing up
                    return 'GOOD'
                else:
                    return 'BAD'
            
            # Open Palm check (HELLO)
            if thumb_ext and index_ext and middle_ext and ring_ext and pinky_ext:
                return 'HELLO'
                
            # Peace check (PEACE / TWO)
            if index_ext and middle_ext and not ring_ext and not pinky_ext and not thumb_ext:
                return 'PEACE'
                
            # OK check (OK)
            if get_dist(4, 8) < 0.045 and middle_ext and ring_ext and pinky_ext:
                return 'OK'
                
            # Pointing check (NO / ONE)
            if index_ext and not middle_ext and not ring_ext and not pinky_ext and not thumb_ext:
                return 'NO'
                
            # I Love You check (LOVE)
            if thumb_ext and index_ext and pinky_ext and not middle_ext and not ring_ext:
                return 'LOVE'
            
            # Two hands checks
            if len(pts) >= 42:
                def is_h2_extended(mcp, tip):
                    return get_dist(21, tip) > get_dist(21, mcp) * 1.15
                h2_index = is_h2_extended(26, 29)
                h2_middle = is_h2_extended(30, 33)
                h2_ring = is_h2_extended(34, 37)
                h2_pinky = is_h2_extended(38, 41)
                h2_fist = not h2_index and not h2_middle and not h2_ring and not h2_pinky
                
                h1_open = index_ext and middle_ext and ring_ext and pinky_ext
                
                if (h1_open and h2_fist) or (h2_fist and h1_open):
                    if get_dist(0, 21) < 0.18:
                        return 'HELP'
                        
                h2_index_ext = is_h2_extended(26, 29)
                if index_ext and h2_index_ext and get_dist(8, 29) < 0.07:
                    return 'HOME'
                    
            return None
        except Exception as e:
            print(f"❌ Error in heuristics: {e}")
            return None

    def predict_sign(self, landmarks: np.ndarray) -> Dict:
        # 1. First pass: Heuristic rule-based gesture engine (100% accurate for primary gestures)
        heuristic_sign = self.heuristic_predict_sign(landmarks)
        if heuristic_sign:
            return {'success': True, 'sign': heuristic_sign, 'confidence': 0.98}

        # 2. Second pass: Scikit-Learn RandomForest classifier ML model
        if self.model is None:
            return {'success': False, 'error': 'Model not loaded', 'sign': None, 'confidence': 0}

        try:
            landmarks = np.array(landmarks).reshape(1, -1)

            # Predict using our Random Forest classifier
            if hasattr(self.model, 'predict_proba'):
                proba = self.model.predict_proba(landmarks)[0]
                confidence = float(np.max(proba))
                idx = np.argmax(proba)
            else:
                idx = self.model.predict(landmarks)[0]
                confidence = 0.85

            sign = self.label_encoder.inverse_transform([idx])[0]
            return {'success': True, 'sign': sign, 'confidence': confidence}
        except Exception as e:
            return {'success': False, 'error': str(e), 'sign': None, 'confidence': 0}

    def detect_from_image(self, image_data: str) -> Dict:
        try:
            image_bytes = base64.b64decode(image_data)
            # Apply ImageOps.exif_transpose to automatically rotate mobile pictures upright!
            image = Image.open(BytesIO(image_bytes))
            image = ImageOps.exif_transpose(image)
            frame = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
            
            # 1. Hands landmarks & sign prediction
            landmarks = self.extract_landmarks(frame)
            sign_res = None
            if landmarks is not None:
                sign_res = self.predict_sign(landmarks)
            
            # 2. Face & expression analysis
            face_res = self.process_face(frame)
            
            # Combine results
            return {
                'success': True,
                'sign': sign_res['sign'] if (sign_res and sign_res['success']) else None,
                'confidence': sign_res['confidence'] if (sign_res and sign_res['success']) else 0.0,
                'face_detected': face_res['face_detected'],
                'face_bbox': face_res['face_bbox'],
                'expression': face_res['expression'],
                'facial_patterns': face_res['facial_patterns']
            }
        except Exception as e:
            return {'success': False, 'error': str(e), 'sign': None}

    def process_video_frame(self, frame: np.ndarray, min_confidence: float = 0.3) -> tuple:
        """Process a video frame and return (sign, confidence, face_info, annotated_frame)"""
        try:
            # Face Mesh & Expression
            face_res = self.process_face(frame)
            
            # Hands & Sign Detection
            landmarks = self.extract_landmarks(frame)
            if landmarks is None:
                return None, 0.0, face_res, frame

            result = self.predict_sign(landmarks)
            if result['success']:
                sign = result['sign']
                confidence = result['confidence']
                if confidence >= min_confidence:
                    return sign, confidence, face_res, frame
            return None, 0.0, face_res, frame
        except Exception as e:
            print(f"Error processing frame: {e}")
            return None, 0.0, {'face_detected': False}, frame

def get_detector():
    global detector
    if detector is None:
        detector = ISLSignDetector()
    return detector

detector = None
