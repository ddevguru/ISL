@echo off

cls
echo ==================================================
echo Sign Language Detection Backend - Quick Start
echo ==================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed. Please install Python 3.8 or higher.
    pause
    exit /b 1
)

echo OK Python found:
python --version

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo.
    echo Creating virtual environment...
    python -m venv venv
    echo OK Virtual environment created
)

REM Activate virtual environment
echo.
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo.
echo Installing dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt
echo OK Dependencies installed

REM Setup environment file
if not exist ".env" (
    echo.
    echo Creating .env file from template...
    copy .env.example .env
    echo WARNING: Please update .env with your configuration
    echo    DATABASE_URL=postgresql://user:password@localhost:5432/sign_detection
)

REM Initialize database
echo.
echo Initializing database...
python init_db.py

REM Start the server
cls
echo ==================================================
echo OK Setup complete!
echo ==================================================
echo.
echo Starting Flask server...
echo API will be available at: http://localhost:5000
echo API Documentation: GET http://localhost:5000/api
echo.
echo Press Ctrl+C to stop the server
echo ==================================================
echo.

python app.py

pause
