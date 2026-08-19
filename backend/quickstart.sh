#!/bin/bash

echo "=================================================="
echo "Sign Language Detection Backend - Quick Start"
echo "=================================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

echo "✓ Python found: $(python3 --version)"

# Check if PostgreSQL is running
echo ""
echo "Checking PostgreSQL connection..."
if ! psql -c "SELECT 1" &> /dev/null; then
    echo "⚠️  Warning: PostgreSQL is not running or credentials are incorrect."
    echo "   Make sure PostgreSQL is installed and running."
    echo "   Update DATABASE_URL in .env if needed."
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo ""
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

# Activate virtual environment
echo ""
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo ""
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
echo "✓ Dependencies installed"

# Setup environment file
if [ ! -f ".env" ]; then
    echo ""
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please update .env with your configuration"
    echo "   DATABASE_URL=postgresql://user:password@localhost:5432/sign_detection"
fi

# Initialize database
echo ""
echo "Initializing database..."
python init_db.py

# Start the server
echo ""
echo "=================================================="
echo "✓ Setup complete!"
echo "=================================================="
echo ""
echo "Starting Flask server..."
echo "API will be available at: http://localhost:5000"
echo "API Documentation: GET http://localhost:5000/api"
echo ""
echo "Press Ctrl+C to stop the server"
echo "=================================================="
echo ""

python app.py
