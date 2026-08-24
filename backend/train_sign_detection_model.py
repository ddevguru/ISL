"""
ISL Sign Detection Model Training Script
Trains a Scikit-Learn RandomForestClassifier using MediaPipe hand landmarks
generated from templates mapped to 10 distinct core gesture classes.
"""

import os
import numpy as np
import pickle
import json
from pathlib import Path
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

# Add path so python can import app modules if run directly
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from dataset_loader import DatasetLoader

# Core gesture mapping for all 95 signs
SIGN_TO_CORE_GESTURE = {
    # Greetings
    'HELLO': 'HELLO', 'GOODBYE': 'HELLO', 'WELCOME': 'HELLO', 'GOOD MORNING': 'HELLO', 'GOOD NIGHT': 'HELLO',
    # Response
    'YES': 'GOOD', 'NO': 'NO', 'MAYBE': 'HELLO', 'OK': 'OK', 'AGREE': 'GOOD',
    # Emotions
    'HAPPY': 'HELLO', 'SAD': 'FIST', 'ANGRY': 'FIST', 'SCARED': 'FIST', 'SURPRISED': 'HELLO', 'LOVE': 'LOVE', 'TIRED': 'FIST', 'CONFUSED': 'FIST',
    # Actions
    'WALK': 'PEACE', 'RUN': 'PEACE', 'JUMP': 'PEACE', 'SIT': 'FIST', 'STAND': 'PEACE', 'SLEEP': 'HELLO', 'WAKE UP': 'HELLO', 'DANCE': 'PEACE',
    'EAT': 'FIST', 'DRINK': 'FIST', 'WORK': 'FIST', 'PLAY': 'HELLO', 'READ': 'HELLO', 'WRITE': 'NO', 'LISTEN': 'OK', 'LOOK': 'NO',
    'HELP': 'HELP', 'GIVE': 'HELLO', 'TAKE': 'FIST',
    # Objects
    'WATER': 'FIST', 'FOOD': 'FIST', 'HOUSE': 'HOME', 'CAR': 'FIST', 'PHONE': 'LOVE', 'BOOK': 'HELLO', 'SCHOOL': 'HOME', 'MONEY': 'FIST',
    'CLOCK': 'NO', 'DOCTOR': 'FIST',
    # Adjectives
    'GOOD': 'GOOD', 'BAD': 'BAD', 'BEAUTIFUL': 'LOVE', 'UGLY': 'BAD', 'BIG': 'HELLO', 'SMALL': 'FIST', 'HOT': 'HELLO', 'COLD': 'FIST',
    'STRONG': 'GOOD', 'WEAK': 'BAD', 'FAST': 'HELLO', 'SLOW': 'HELLO', 'CLEAN': 'HELLO', 'DIRTY': 'FIST',
    # Family
    'MOTHER': 'HELLO', 'FATHER': 'HELLO', 'SISTER': 'HELLO', 'BROTHER': 'HELLO', 'BABY': 'FIST', 'GRANDFATHER': 'HELLO', 'GRANDMUTHR': 'HELLO', 'GRANDMOTHER': 'HELLO',
    'HUSBAND': 'HELLO', 'WIFE': 'HELLO', 'FRIEND': 'LOVE',
    # Requests
    'PLEASE': 'HELLO', 'THANK YOU': 'HELLO', 'SORRY': 'FIST', 'EXCUSE ME': 'HELLO',
    # Education
    'LEARN': 'NO', 'UNDERSTAND': 'OK', 'FORGET': 'NO', 'REMEMBER': 'NO', 'THINK': 'NO',
    # Time & Numbers
    'TODAY': 'HELLO', 'TOMORROW': 'HELLO', 'YESTERDAY': 'HELLO', 'MORNING': 'HELLO', 'EVENING': 'HELLO', 'NIGHT': 'HELLO',
    'ONE': 'NO', 'TWO': 'PEACE', 'THREE': 'PEACE', 'FIVE': 'HELLO', 'TEN': 'HELLO',
    # Health
    'PAIN': 'FIST', 'SICK': 'FIST', 'HEALTH': 'GOOD', 'HOSPITAL': 'HOME'
}

class SignDetectionModelTrainer:
    def __init__(self, model_name="ISL_Detection_V1"):
        self.model_name = model_name
        self.models_dir = Path('models')
        self.models_dir.mkdir(exist_ok=True)
        self.label_encoder = LabelEncoder()
        self.model = None
        self.landmarks_size = 42  # 21 landmarks * 2 (x, y) for one hand

    def create_realistic_dataset(self):
        """Generate a realistic training dataset using templates from DatasetLoader with added variations"""
        print("📊 Generating training dataset from sign templates...")
        
        loader = DatasetLoader()
        dataset = loader.load_sign_language_dataset()
        
        X_data = []
        y_data = []
        
        # Retrieve visual landmarks coordinate templates and generate dataset
        for sign_data in dataset:
            name = sign_data['name']
            
            # Map sign name to core gesture label
            core_gesture = SIGN_TO_CORE_GESTURE.get(name.upper(), 'HELLO')
            
            # Retrieve the visual landmarks coordinate template
            points = loader.generate_hand_landmarks(name)
            
            # Flatten to 42 coordinate values (x, y for 21 joints)
            flat_points = []
            for p in points:
                flat_points.extend([p['x'], p['y']])
                
            # Pad with 42 zeros to represent the second hand (since our model expects size of 84)
            flat_points.extend([0.0] * 42)
            
            # Generate 150 variations per sign using Gaussian noise to teach the classifier variance
            for _ in range(150):
                # Standard deviation of 0.015 for realistic hand shake / position variance
                noise = np.random.normal(0, 0.015, 42)
                variant = np.array(flat_points)
                # Add noise only to the active hand landmarks (first 42 elements)
                variant[:42] = variant[:42] + noise
                
                X_data.append(variant)
                y_data.append(core_gesture)
                
        return np.array(X_data), np.array(y_data)

    def train(self, X_train, y_train, X_val=None, y_val=None):
        """Train a Random Forest classifier model."""
        print(f"\n{'='*60}")
        print(f"🎯 Training Scikit-Learn Model: {self.model_name}")
        print(f"{'='*60}")
        
        # Encode labels
        y_train_encoded = self.label_encoder.fit_transform(y_train)
        num_classes = len(self.label_encoder.classes_)
        
        print(f"✓ Training on {len(X_train)} samples with {num_classes} classes: {list(self.label_encoder.classes_)}")
        
        # Train Random Forest Classifier
        self.model = RandomForestClassifier(n_estimators=200, random_state=42, n_jobs=-1)
        self.model.fit(X_train, y_train_encoded)
        
        if X_val is not None and y_val is not None:
            y_val_encoded = self.label_encoder.transform(y_val)
            acc = self.model.score(X_val, y_val_encoded)
            print(f"✓ Validation Accuracy: {acc:.2%}")
        
        print("✓ Model training completed successfully")

    def save_model(self):
        """Save the trained model, encoder, and metadata."""
        if self.model is None:
            print("❌ No model to save. Train first!")
            return False

        model_path = self.models_dir / f"{self.model_name}.pkl"
        encoder_path = self.models_dir / f"{self.model_name}_encoder.pkl"
        metadata_path = self.models_dir / f"{self.model_name}_metadata.json"

        try:
            # Save classifier
            with open(model_path, 'wb') as f:
                pickle.dump(self.model, f)
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

            with open(metadata_path, 'w') as f:
                json.dump(metadata, f, indent=2)
            print(f"✓ Metadata saved to {metadata_path}")

            return True
        except Exception as e:
            print(f"❌ Error saving model: {e}")
            return False

    def predict(self, landmarks):
        """Predict sign from hand landmarks."""
        if self.model is None:
            print("❌ Model not loaded!")
            return None

        try:
            landmarks = np.array(landmarks).reshape(1, -1)
            predicted_class_idx = self.model.predict(landmarks)[0]
            proba = self.model.predict_proba(landmarks)[0]
            confidence = proba[predicted_class_idx]

            sign_name = self.label_encoder.inverse_transform([predicted_class_idx])[0]

            return {
                'sign': sign_name,
                'confidence': float(confidence),
                'all_predictions': {
                    self.label_encoder.inverse_transform([i])[0]: float(proba[i])
                    for i in range(len(proba))
                }
            }
        except Exception as e:
            print(f"❌ Prediction error: {e}")
            return None


def main():
    print("\n" + "="*60)
    print("🤟 ISL SIGN DETECTION MODEL TRAINER (RANDOM FOREST)")
    print("="*60 + "\n")

    trainer = SignDetectionModelTrainer(model_name="ISL_Detection_V1")

    X, y = trainer.create_realistic_dataset()

    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    print(f"✓ Training set: {len(X_train)} samples")
    print(f"✓ Validation set: {len(X_val)} samples")

    trainer.train(X_train, y_train, X_val, y_val)
    trainer.save_model()

    # Test prediction
    print(f"\n{'='*60}")
    print("🧪 Testing model prediction...")
    print(f"{'='*60}\n")

    test_landmarks = X_val[0]
    prediction = trainer.predict(test_landmarks)

    if prediction:
        print(f"✓ Predicted sign: {prediction['sign']}")
        print(f"✓ Confidence: {prediction['confidence']:.2%}")

    print(f"\n{'='*60}")
    print("✅ Training complete!")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
