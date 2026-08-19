import os
import numpy as np
from pathlib import Path
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
from tensorflow.keras import layers, models
from sign_detector import SignDetector

class SignLanguageModelTrainer:
    def __init__(self, model_save_path='models/sign_language_model.h5'):
        self.model_save_path = model_save_path
        self.detector = SignDetector()
        self.scaler = StandardScaler()

    def create_model(self, input_shape, num_classes):
        model = models.Sequential([
            layers.Input(shape=input_shape),

            layers.LSTM(128, activation='relu', return_sequences=True),
            layers.Dropout(0.2),

            layers.LSTM(64, activation='relu', return_sequences=False),
            layers.Dropout(0.2),

            layers.Dense(128, activation='relu'),
            layers.Dropout(0.3),

            layers.Dense(64, activation='relu'),
            layers.Dropout(0.2),

            layers.Dense(num_classes, activation='softmax')
        ])

        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )

        return model

    def generate_synthetic_training_data(self, num_samples=100, sequence_length=30):
        X = []
        y = []

        keypoint_size = 258

        for class_id in range(10):
            for sample in range(num_samples):
                sequence = np.random.randn(sequence_length, keypoint_size).astype(np.float32)
                X.append(sequence)
                y.append(class_id)

        X = np.array(X, dtype=np.float32)
        y = np.array(y, dtype=np.int32)

        return X, y

    def train_model(self, X=None, y=None, epochs=50, batch_size=32):
        if X is None or y is None:
            print("Generating synthetic training data...")
            X, y = self.generate_synthetic_training_data()

        print(f"Training data shape: {X.shape}")
        print(f"Labels shape: {y.shape}")

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )

        input_shape = (X_train.shape[1], X_train.shape[2])
        num_classes = len(np.unique(y))

        model = self.create_model(input_shape, num_classes)

        print(f"\nModel Summary:")
        model.summary()

        print(f"\nTraining model...")
        history = model.fit(
            X_train, y_train,
            epochs=epochs,
            batch_size=batch_size,
            validation_split=0.2,
            verbose=1
        )

        print(f"\nEvaluating model on test set...")
        test_loss, test_accuracy = model.evaluate(X_test, y_test)
        print(f"Test Accuracy: {test_accuracy:.4f}")

        os.makedirs(os.path.dirname(self.model_save_path), exist_ok=True)
        model.save(self.model_save_path)
        print(f"\nModel saved to: {self.model_save_path}")

        return model, history, test_accuracy

    def load_model(self):
        if os.path.exists(self.model_save_path):
            return tf.keras.models.load_model(self.model_save_path)
        else:
            print(f"Model not found at {self.model_save_path}")
            return None

if __name__ == '__main__':
    trainer = SignLanguageModelTrainer()

    print("=" * 50)
    print("Sign Language Detection Model Training")
    print("=" * 50)

    model, history, accuracy = trainer.train_model(epochs=50)

    print("\n" + "=" * 50)
    print(f"Training Complete! Test Accuracy: {accuracy:.4f}")
    print("=" * 50)
