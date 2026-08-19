@echo off
REM Setup Script for Sign Language Detection Backend

cls
echo.
echo ====================================================
echo Sign Language Detection Backend - Setup
echo ====================================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Please install Python 3.8+ from python.org
    pause
    exit /b 1
)

echo [1/5] Creating virtual environment...
python -m venv venv
if errorlevel 1 goto error

echo [2/5] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 goto error

echo [3/5] Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 goto error

echo [4/5] Initializing database...
python init_db.py
if errorlevel 1 goto error

echo [5/5] Loading signs...
python load_signs.py
if errorlevel 1 goto error

cls
echo.
echo ====================================================
echo SUCCESS! Setup Complete!
echo ====================================================
echo.
echo Next: Run the backend with:
echo   python app.py
echo.
echo Backend will be available at:
echo   http://localhost:5000 (Computer)
echo   http://192.168.0.132:5000 (Mobile WiFi)
echo.
echo ====================================================
pause
exit /b 0

:error
echo.
echo ERROR! Setup failed!
echo.
pause
exit /b 1
