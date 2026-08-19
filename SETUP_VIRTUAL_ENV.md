# 🔧 Fix Virtual Environment Issue

The package is installed globally but NOT in your virtual environment. Let's fix this:

---

## 🚀 **COMPLETE FIX (Copy & Paste)**

### Step 1: Delete old virtual environment
```bash
cd C:\sign_detection\backend
rmdir /s /q venv
```

### Step 2: Create fresh virtual environment
```bash
python -m venv venv
```

### Step 3: Activate it (IMPORTANT!)
```bash
venv\Scripts\activate
```

**You should see this at the start of your prompt:**
```
(venv) C:\sign_detection\backend>
```

### Step 4: Upgrade pip
```bash
python -m pip install --upgrade pip
```

### Step 5: Install all requirements
```bash
pip install -r requirements.txt
```

**This will install ALL packages in the virtual environment**

### Step 6: Initialize database
```bash
python init_db.py
```

**Expected output:**
```
✓ Database tables created successfully
✓ Dataset loaded successfully
```

### Step 7: Load signs
```bash
python load_signs.py
```

**Expected output:**
```
✓ Loaded 100 signs from dataset
✓ 100 signs successfully added to database
```

### Step 8: Start backend
```bash
python app.py
```

**Expected output:**
```
✅ Server running on: http://0.0.0.0:5000
✅ Mobile access: http://192.168.0.132:5000
```

---

## ✅ **Complete Command Sequence**

Copy & paste this entire block:

```bash
cd C:\sign_detection\backend
rmdir /s /q venv
python -m venv venv
venv\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
python init_db.py
python load_signs.py
python app.py
```

---

## ⚠️ **Important Notes**

1. **ALWAYS activate venv first**
   ```bash
   venv\Scripts\activate
   ```
   You should see `(venv)` at the prompt start

2. **Install packages in activated venv**
   ```bash
   pip install package_name
   ```

3. **Run Python scripts in activated venv**
   ```bash
   python script.py
   ```

4. **If something fails, check venv is activated**
   - Prompt should show `(venv)`
   - If not, run: `venv\Scripts\activate`

---

## 🔍 **Verify Installation**

After all steps, verify everything is installed:

```bash
# Should be in venv (see (venv) at prompt)

# Check Flask
python -c "import flask; print(flask.__version__)"

# Check Flask-JWT-Extended  
python -c "import flask_jwt_extended; print('OK')"

# Check SQLAlchemy
python -c "import sqlalchemy; print(sqlalchemy.__version__)"

# Check MediaPipe
python -c "import mediapipe; print('OK')"

# Check TensorFlow
python -c "import tensorflow; print(tensorflow.__version__)"
```

All should show versions or "OK"

---

## 🆘 **If Still Getting Errors**

### Error: "ModuleNotFoundError: No module named..."

**Solution:**
```bash
# Make sure venv is activated (should see (venv) at prompt)
venv\Scripts\activate

# Install the missing module
pip install flask-jwt-extended flask-sqlalchemy flask-cors

# Try again
python init_db.py
```

### Error: "site-packages is not writeable"

**Solution:**
```bash
# Use --user flag
pip install --user flask-jwt-extended

# OR better: use activated venv
venv\Scripts\activate
pip install flask-jwt-extended
```

### Error: "Connection timeout" during pip install

**Solution:**
```bash
# Use different pip index
pip install -i https://pypi.org/simple/ -r requirements.txt

# OR retry with --retries
pip install --retries 5 -r requirements.txt
```

---

## 📋 **Step-by-Step Terminal Session**

Here's exactly what you should see:

```
PS C:\sign_detection\backend> rmdir /s /q venv
Removed directory

PS C:\sign_detection\backend> python -m venv venv
Created virtual environment

PS C:\sign_detection\backend> venv\Scripts\activate
(venv) PS C:\sign_detection\backend> 

(venv) PS C:\sign_detection\backend> python -m pip install --upgrade pip
Successfully installed pip-26.2.1

(venv) PS C:\sign_detection\backend> pip install -r requirements.txt
Successfully installed flask-2.3.3
Successfully installed flask-jwt-extended-4.5.2
... (more packages)

(venv) PS C:\sign_detection\backend> python init_db.py
✓ Database initialization completed!

(venv) PS C:\sign_detection\backend> python load_signs.py
✓ Dataset Loading Complete!

(venv) PS C:\sign_detection\backend> python app.py
============================================================
🚀 Sign Language Detection Backend
============================================================
✅ Server running on: http://0.0.0.0:5000
✅ Mobile access: http://192.168.0.132:5000
============================================================
```

---

## ✨ **Next Time You Start**

Just do this:

```bash
cd C:\sign_detection\backend
venv\Scripts\activate
python app.py
```

Backend will start!

---

**That's it! The virtual environment issue is now fixed!** 🎉
