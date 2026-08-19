import cv2
import numpy as np
import os
from pathlib import Path

class SignDetector:
    def __init__(self, model_path=None):
        self.mp_holistic = None
        self.mp_drawing = None
        self.holistic = None
        self._initialized = False

        self.model = None
        if model_path and os.path.exists(model_path):
            try:
                from tensorflow.keras.models import load_model
                self.model = load_model(model_path)
            except Exception as e:
                print(f"Error loading model: {e}")

        self.sign_labels = self._load_sign_labels()
        self.keypoints_history = []
        self.history_length = 30

    def _initialize_mediapipe(self):
        """Lazy initialization of MediaPipe"""
        if self._initialized:
            return

        try:
            import mediapipe as mp
            self.mp_holistic = mp.solutions.holistic
            self.mp_drawing = mp.solutions.drawing_utils
            self.holistic = self.mp_holistic.Holistic(
                static_image_mode=False,
                model_complexity=1,
                smooth_landmarks=True,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5
            )
            self._initialized = True
        except Exception as e:
            print(f"Warning: MediaPipe initialization failed: {e}")
            print("Sign detection will use keypoint extraction only")

    def _load_sign_labels(self):
        return {
            0: 'Hello', 1: 'Thank You', 2: 'Yes', 3: 'No', 4: 'Water',
            5: 'Food', 6: 'Good', 7: 'Bad', 8: 'Help', 9: 'Please'
        }

    def extract_keypoints(self, frame):
        try:
            self._initialize_mediapipe()

            if not self._initialized or self.holistic is None:
                return None, None

            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = self.holistic.process(frame_rgb)

            keypoints = []

            if results.pose_landmarks:
                for landmark in results.pose_landmarks.landmark:
                    keypoints.extend([landmark.x, landmark.y, landmark.z, landmark.visibility])

            if results.left_hand_landmarks:
                for landmark in results.left_hand_landmarks.landmark:
                    keypoints.extend([landmark.x, landmark.y, landmark.z])
            else:
                keypoints.extend([0] * (21 * 3))

            if results.right_hand_landmarks:
                for landmark in results.right_hand_landmarks.landmark:
                    keypoints.extend([landmark.x, landmark.y, landmark.z])
            else:
                keypoints.extend([0] * (21 * 3))

            if results.face_landmarks:
                for landmark in results.face_landmarks.landmark:
                    keypoints.extend([landmark.x, landmark.y, landmark.z])

            return np.array(keypoints, dtype=np.float32), results

        except Exception as e:
            print(f"Error extracting keypoints: {e}")
            return None, None

    def detect_sign(self, frame):
        try:
            keypoints, results = self.extract_keypoints(frame)

            if keypoints is None:
                return None, 0.0, frame

            self.keypoints_history.append(keypoints)
            if len(self.keypoints_history) > self.history_length:
                self.keypoints_history.pop(0)

            confidence = 0.0
            predicted_label = None

            if self.model and len(self.keypoints_history) >= 5:
                sequence = np.array(self.keypoints_history[-5:])
                try:
                    prediction = self.model.predict(np.expand_dims(sequence, axis=0), verbose=0)
                    predicted_idx = np.argmax(prediction[0])
                    confidence = float(prediction[0][predicted_idx])
                    predicted_label = self.sign_labels.get(predicted_idx, f'Sign_{predicted_idx}')
                except Exception as e:
                    print(f"Prediction error: {e}")

            frame_with_landmarks = self._draw_landmarks(frame, results)

            return predicted_label, confidence, frame_with_landmarks

        except Exception as e:
            print(f"Error in sign detection: {e}")
            return None, 0.0, frame

    def _draw_landmarks(self, frame, results):
        try:
            h, w, c = frame.shape
            frame_copy = frame.copy()

            if results.pose_landmarks:
                self.mp_drawing.draw_landmarks(
                    frame_copy,
                    results.pose_landmarks,
                    self.mp_holistic.POSE_CONNECTIONS,
                    self.mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                    self.mp_drawing.DrawingSpec(color=(255, 0, 0), thickness=2)
                )

            if results.left_hand_landmarks:
                self.mp_drawing.draw_landmarks(
                    frame_copy,
                    results.left_hand_landmarks,
                    self.mp_holistic.HAND_CONNECTIONS,
                    self.mp_drawing.DrawingSpec(color=(0, 255, 255), thickness=2, circle_radius=2),
                    self.mp_drawing.DrawingSpec(color=(255, 255, 0), thickness=2)
                )

            if results.right_hand_landmarks:
                self.mp_drawing.draw_landmarks(
                    frame_copy,
                    results.right_hand_landmarks,
                    self.mp_holistic.HAND_CONNECTIONS,
                    self.mp_drawing.DrawingSpec(color=(255, 0, 255), thickness=2, circle_radius=2),
                    self.mp_drawing.DrawingSpec(color=(0, 255, 255), thickness=2)
                )

            return frame_copy

        except Exception as e:
            print(f"Error drawing landmarks: {e}")
            return frame

    def process_video_frame(self, frame, min_confidence=0.5):
        sign, confidence, annotated_frame = self.detect_sign(frame)

        if confidence < min_confidence:
            return None, 0.0, annotated_frame

        return sign, confidence, annotated_frame

    def reset_history(self):
        self.keypoints_history = []

    def __del__(self):
        self.holistic.close()
