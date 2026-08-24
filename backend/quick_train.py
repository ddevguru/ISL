#!/usr/bin/env python3
"""
Quick training script for ISL Sign Detection Model
Trains on 10 sample signs with synthetic data
Run this once to create the model
"""

import os
import sys
import numpy as np
from pathlib import Path
from sklearn.preprocessing import LabelEncoder
from tensorflow import keras
import pickle
import json

os.makedirs('models', exist_ok=True)

# Sample signs
SAMPLE_SIGNS = [
    'HELLO', 'THANK_YOU', 'YES', 'NO', 'HOME',
    'GOOD', 'BAD', 'HELP', 'LOVE', 'FRIEND'
]

landmarks_size = 42  # 21 landmarks * 2 (x, y)

print("🎯 Training ISL Sign Detection Model...")

# Create training data
X_train = []
y_train = []

for sign in SAMPLE_SIGNS:
    for _ in range(20):  # 20 samples per sign
        # Generate synthetic hand landmark data
        landmarks = np.random.randn(landmarks_size * 2) * 0.1 + np.random.rand(landmarks_size * 2) * 0.5
        X_train.append(landmarks)
        y_train.append(sign)

X_train = np.array(X_train)
y_train = np.array(y_train)

print(f"📊 Dataset size: {len(X_train)} samples")
print(f"🏷️ Classes: {len(SAMPLE_SIGNS)} signs")

# Encode labels
label_encoder = LabelEncoder()
y_encoded = label_encoder.fit_transform(y_train)

# Build model
print("🏗️ Building model...")
model = keras.Sequential([
    keras.layers.Input(shape=(landmarks_size * 2,)),

    keras.layers.Dense(256, activation='relu'),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.3),

    keras.layers.Dense(128, activation='relu'),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.3),

    keras.layers.Dense(64, activation='relu'),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.2),

    keras.layers.Dense(32, activation='relu'),
    keras.layers.Dropout(0.2),

    keras.layers.Dense(len(SAMPLE_SIGNS), activation='softmax')
])

model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Train model
print("🚀 Training model...")
model.fit(
    X_train, y_encoded,
    epochs=50,
    batch_size=8,
    verbose=1,
    validation_split=0.2
)

# Save model
model_path = 'models/ISL_Detection_V1.h5'
encoder_path = 'models/ISL_Detection_V1_encoder.pkl'
metadata_path = 'models/ISL_Detection_V1_metadata.json'

model.save(model_path)
print(f"✅ Model saved: {model_path}")

# Save label encoder
with open(encoder_path, 'wb') as f:
    pickle.dump(label_encoder, f)
print(f"✅ Encoder saved: {encoder_path}")

# Save metadata
metadata = {
    'signs': SAMPLE_SIGNS,
    'landmarks_size': landmarks_size,
    'model_version': 'V1'
}
with open(metadata_path, 'w') as f:
    json.dump(metadata, f, indent=2)
print(f"✅ Metadata saved: {metadata_path}")

print("\n✨ Model training complete!")
print(f"📝 Trained on {len(SAMPLE_SIGNS)} signs: {', '.join(SAMPLE_SIGNS)}")
