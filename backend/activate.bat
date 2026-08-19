@echo off
echo Activating virtual environment...
echo.
call venv\Scripts\activate.bat
echo [SUCCESS] Virtual environment activated!
echo.
echo You should see (venv) at the start of your prompt
echo.
echo Next, run: pip install -r requirements.txt
echo Then: python init_db.py
echo.
