"""
ISL Sign Detection Model Training Script
Trains a TensorFlow model using MediaPipe hand landmarks
for recognizing Indian Sign Language signs.
"""

import os
import cv2
import numpy as np
import mediapipe as mp
import tensorflow as tf
from tensorflow import keras
from sklearn.preprocessing import LabelEncoder
from pathlib import Path
import pickle
import json

# MediaPipe setup
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=True, max_num_hands=2, min_detection_confidence=0.7)

class SignDetectionModelTrainer:
    def __init__(self, model_name="ISL_Detection_V1"):
        self.model_name = model_name
        self.models_dir = Path('models')
        self.models_dir.mkdir(exist_ok=True)
        self.label_encoder = LabelEncoder()
        self.model = None
        self.landmarks_size = 42  # 21 landmarks * 2 (x, y) for one hand

    def extract_hand_landmarks(self, image_path):
        """Extract hand landmarks from an image using MediaPipe."""
        try:
            image = cv2.imread(str(image_path))
            if image is None:
                return None

            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = hands.process(image_rgb)

            if results.multi_hand_landmarks:
                landmarks = []
                for hand_landmarks in results.multi_hand_landmarks:
                    for landmark in hand_landmarks.landmark:
                        landmarks.extend([landmark.x, landmark.y])

                # Pad with zeros if only one hand detected
                if len(landmarks) == self.landmarks_size:
                    landmarks.extend([0] * self.landmarks_size)

                return np.array(landmarks[:self.landmarks_size * 2])
            return None
        except Exception as e:
            print(f"Error processing {image_path}: {e}")
            return None

    def create_sample_dataset(self):
        """Create a sample dataset for demonstration."""
        print("📊 Creating sample ISL dataset...")

        sample_signs = {
            'HELLO': 10,
            'THANK_YOU': 10,
            'YES': 10,
            'NO': 10,
            'HOME': 10,
            'GOOD': 10,
            'BAD': 10,
            'HELP': 10,
            'LOVE': 10,
            'FRIEND': 10,
        }

        X_data = []
        y_data = []

        for sign, count in sample_signs.items():
            for i in range(count):
                # Generate synthetic data for demo
                landmarks = np.random.randn(self.landmarks_size * 2) * 0.1 + np.random.rand(self.landmarks_size * 2) * 0.5
                X_data.append(landmarks)
                y_data.append(sign)

        return np.array(X_data), np.array(y_data)

    def build_model(self, num_classes):
        """Build a neural network model for sign classification."""
        print(f"🏗️ Building model with {num_classes} classes...")

        model = keras.Sequential([
            keras.layers.Input(shape=(self.landmarks_size * 2,)),

            # Dense layers
            keras.layers.Dense(256, activation='relu', name='dense_1'),
            keras.layers.BatchNormalization(),
            keras.layers.Dropout(0.3),

            keras.layers.Dense(128, activation='relu', name='dense_2'),
            keras.layers.BatchNormalization(),
            keras.layers.Dropout(0.3),

            keras.layers.Dense(64, activation='relu', name='dense_3'),
            keras.layers.BatchNormalization(),
            keras.layers.Dropout(0.2),

            keras.layers.Dense(32, activation='relu', name='dense_4'),
            keras.layers.Dropout(0.2),

            # Output layer
            keras.layers.Dense(num_classes, activation='softmax', name='output'),
        ])

        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )

        print("✓ Model built successfully")
        return model

    def train(self, X_train, y_train, X_val=None, y_val=None, epochs=50, batch_size=32):
        """Train the sign detection model."""
        print(f"\n{'='*60}")
        print(f"🎯 Training ISL Sign Detection Model: {self.model_name}")
        print(f"{'='*60}")

        # Encode labels
        y_train_encoded = self.label_encoder.fit_transform(y_train)

        num_classes = len(np.unique(y_train_encoded))
        print(f"✓ Training on {len(X_train)} samples with {num_classes} classes")

        # Build model
        self.model = self.build_model(num_classes)

        # Prepare validation data
        if X_val is not None and y_val is not None:
            y_val_encoded = self.label_encoder.transform(y_val)
            validation_data = (X_val, y_val_encoded)
        else:
            validation_data = None
            print("⚠️ No validation data provided")

        # Train model
        print(f"\n📚 Training for {epochs} epochs...")
        history = self.model.fit(
            X_train, y_train_encoded,
            validation_data=validation_data,
            epochs=epochs,
            batch_size=batch_size,
            verbose=1,
            callbacks=[
                keras.callbacks.EarlyStopping(
                    monitor='val_loss' if validation_data else 'loss',
                    patience=10,
                    restore_best_weights=True
                ),
                keras.callbacks.ReduceLROnPlateau(
                    monitor='val_loss' if validation_data else 'loss',
                    factor=0.5,
                    patience=5,
                    min_lr=1e-6
                )
            ]
        )

        print("\n✅ Training completed")
        return history

    def save_model(self):
        """Save the trained model and label encoder."""
        if self.model is None:
            print("❌ No model to save. Train first!")
            return False

        model_path = self.models_dir / f"{self.model_name}.h5"
        encoder_path = self.models_dir / f"{self.model_name}_encoder.pkl"

        try:
            # Save model
            self.model.save(str(model_path))
            print(f"✓ Model saved to {model_path}")

            # Save label encoder
            with open(encoder_path, 'wb') as f:
                pickle.dump(self.label_encoder, f)
            print(f"✓ Label encoder saved to {encoder_path}")

            # Save metadata
            metadata = {
                'model_name': self.model_name,
                'landmarks_size': self.landmarks_size,
                'num_classes': len(self.label_encoder.classes_),
                'classes': list(self.label_encoder.classes_),
            }

            metadata_path = self.models_dir / f"{self.model_name}_metadata.json"
            with open(metadata_path, 'w') as f:
                json.dump(metadata, f, indent=2)
            print(f"✓ Metadata saved to {metadata_path}")

            return True
        except Exception as e:
            print(f"❌ Error saving model: {e}")
            return False

    def load_model(self):
        """Load a previously trained model."""
        model_path = self.models_dir / f"{self.model_name}.h5"
        encoder_path = self.models_dir / f"{self.model_name}_encoder.pkl"

        if not model_path.exists() or not encoder_path.exists():
            print(f"❌ Model files not found for {self.model_name}")
            return False

        try:
            self.model = keras.models.load_model(str(model_path))
            print(f"✓ Model loaded from {model_path}")

            with open(encoder_path, 'rb') as f:
                self.label_encoder = pickle.load(f)
            print(f"✓ Label encoder loaded from {encoder_path}")

            return True
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            return False

    def predict(self, landmarks):
        """Predict sign from hand landmarks."""
        if self.model is None:
            print("❌ Model not loaded!")
            return None

        try:
            # Reshape input
            landmarks = np.array(landmarks).reshape(1, -1)

            # Predict
            predictions = self.model.predict(landmarks, verbose=0)
            predicted_class_idx = np.argmax(predictions[0])
            confidence = predictions[0][predicted_class_idx]

            # Get sign name
            sign_name = self.label_encoder.inverse_transform([predicted_class_idx])[0]

            return {
                'sign': sign_name,
                'confidence': float(confidence),
                'all_predictions': {
                    self.label_encoder.inverse_transform([i])[0]: float(predictions[0][i])
                    for i in range(len(predictions[0]))
                }
            }
        except Exception as e:
            print(f"❌ Prediction error: {e}")
            return None


def main():
    """Main training function."""
    print("\n" + "="*60)
    print("🤟 ISL SIGN DETECTION MODEL TRAINER")
    print("="*60 + "\n")

    # Initialize trainer
    trainer = SignDetectionModelTrainer(model_name="ISL_Detection_V1")

    # Create sample dataset
    print("📊 Preparing dataset...")
    X_train, y_train = trainer.create_sample_dataset()

    # Split into train and validation
    from sklearn.model_selection import train_test_split
    X_train, X_val, y_train, y_val = train_test_split(
        X_train, y_train, test_size=0.2, random_state=42
    )

    print(f"✓ Training set: {len(X_train)} samples")
    print(f"✓ Validation set: {len(X_val)} samples")
    print(f"✓ Classes: {np.unique(y_train)}")

    # Train model
    history = trainer.train(
        X_train, y_train,
        X_val, y_val,
        epochs=50,
        batch_size=32
    )

    # Save model
    trainer.save_model()

    # Test prediction
    print(f"\n{'='*60}")
    print("🧪 Testing model...")
    print(f"{'='*60}\n")

    test_landmarks = X_val[0]
    prediction = trainer.predict(test_landmarks)

    if prediction:
        print(f"✓ Predicted sign: {prediction['sign']}")
        print(f"✓ Confidence: {prediction['confidence']:.2%}")
        print(f"✓ All predictions: {prediction['all_predictions']}")

    print(f"\n{'='*60}")
    print("✅ Training complete!")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
