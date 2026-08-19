#!/bin/bash

# Sign Detection - Quick Setup Script
# This script helps you set up the project quickly

echo "🚀 Sign Detection - Quick Setup"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f backend/.env ]; then
    echo -e "${BLUE}📝 Creating .env from .env.example...${NC}"
    cp backend/.env.example backend/.env
    echo -e "${GREEN}✅ .env created. Update with your database credentials.${NC}"
else
    echo -e "${GREEN}✅ .env already exists${NC}"
fi

echo ""
echo -e "${BLUE}📦 Installing dependencies...${NC}"

# Install Python dependencies
if [ -d backend/venv ]; then
    echo -e "${YELLOW}⚠️  Virtual environment already exists${NC}"
else
    echo -e "${BLUE}Creating Python virtual environment...${NC}"
    cd backend
    python -m venv venv
    source venv/bin/activate
    cd ..
fi

echo -e "${BLUE}Installing Python packages...${NC}"
source backend/venv/bin/activate
pip install -r backend/requirements.txt

echo ""
echo -e "${BLUE}📱 Installing Flutter dependencies...${NC}"
cd sign_detection
flutter pub get
cd ..

echo ""
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update backend/.env with your database credentials"
echo "2. Start backend: cd backend && source venv/bin/activate && python app.py"
echo "3. Start app: cd sign_detection && flutter run"
echo ""
echo -e "${BLUE}For Render deployment, see DEPLOYMENT_SUMMARY.md${NC}"
echo ""
