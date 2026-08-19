@echo off
REM Sign Detection - Quick Setup Script for Windows

echo.
echo 🚀 Sign Detection - Quick Setup
echo ================================
echo.

REM Check if .env exists
if not exist backend\.env (
    echo 📝 Creating .env from .env.example...
    copy backend\.env.example backend\.env
    echo ✅ .env created. Update with your database credentials.
) else (
    echo ✅ .env already exists
)

echo.
echo 📦 Installing dependencies...

REM Check if venv exists
if not exist backend\venv (
    echo Creating Python virtual environment...
    cd backend
    python -m venv venv
    cd ..
)

echo Installing Python packages...
call backend\venv\Scripts\activate.bat
pip install -r backend\requirements.txt

echo.
echo 📱 Installing Flutter dependencies...
cd sign_detection
call flutter pub get
cd ..

echo.
echo ✅ Setup Complete!
echo.
echo Next steps:
echo 1. Update backend\.env with your database credentials
echo 2. Start backend: cd backend ^& venv\Scripts\activate ^& python app.py
echo 3. Start app: cd sign_detection ^& flutter run
echo.
echo For Render deployment, see DEPLOYMENT_SUMMARY.md
echo.
pause
