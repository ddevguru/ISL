#!/bin/bash
set -e

echo "Installing dependencies for backend..."
cd backend
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
echo "Build complete!"
