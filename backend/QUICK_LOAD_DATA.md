# Quick Start - Load 100+ Sign Language Data

Complete guide to load and use the comprehensive sign language dataset.

## 📊 What's Included

✅ **100+ Signs** with English & Hindi translations  
✅ **12 Categories** (Greetings, Emotions, Actions, etc.)  
✅ **3 Difficulty Levels** (Easy, Medium, Hard)  
✅ **Full Descriptions** for each sign  
✅ **Ready for Detection** - Signs searchable and filterable  

---

## 🚀 Load Data in 3 Steps

### Step 1: Start the Backend
```bash
cd backend

# Option A: Windows
quickstart.bat

# Option B: Linux/Mac
chmod +x quickstart.sh
./quickstart.sh

# Option C: Docker
docker-compose up -d
docker-compose exec api python init_db.py
```

### Step 2: Load All Signs
```bash
# Option A: Use the load script
python load_signs.py

# Option B: Use API endpoint
curl -X POST http://localhost:5000/api/utils/dataset/load

# Option C: Automatic during init
# (Already happens with init_db.py)
```

### Step 3: Verify Data is Loaded
```bash
# Check total signs
curl http://localhost:5000/api/utils/dataset/stats

# Response should show:
# {
#   "total_signs": 100+,
#   "categories": {...},
#   "difficulty_distribution": {...}
# }
```

---

## 📱 Use the Data via API

### 1. Browse All Signs
```bash
curl http://localhost:5000/api/detection/signs
```

Response (sample):
```json
{
  "signs": [
    {
      "id": "uuid",
      "name": "Hello",
      "english_translation": "Hello / Greetings",
      "hindi_translation": "नमस्ते",
      "category": "Greetings",
      "difficulty_level": "easy",
      "description": "Waving hand gesture to greet someone"
    }
  ],
  "total": 100,
  "pages": 5,
  "current_page": 1
}
```

### 2. Search for Specific Sign
```bash
# Search by name
curl "http://localhost:5000/api/detection/signs?search=hello"

# Search by translation
curl "http://localhost:5000/api/detection/signs?search=खुश"
```

### 3. Filter by Category
```bash
# List all categories
curl http://localhost:5000/api/utils/categories

# Get signs in Emotions category
curl "http://localhost:5000/api/detection/signs?category=Emotions"

# Get signs in Actions category
curl "http://localhost:5000/api/detection/signs?category=Actions"
```

### 4. Get Dataset Statistics
```bash
curl http://localhost:5000/api/utils/dataset/stats

# Response:
{
  "total_signs": 100,
  "categories": {
    "Greetings": 5,
    "Emotions": 8,
    "Actions": 21,
    ...
  },
  "difficulty_distribution": {
    "easy": 60,
    "medium": 35,
    "hard": 5
  }
}
```

### 5. Get Specific Sign Details
```bash
# First, get a sign ID from the browse response
curl http://localhost:5000/api/detection/signs/{sign_id}

# Response:
{
  "sign": {
    "id": "uuid",
    "name": "Happy",
    "english_translation": "Happy / Joy",
    "hindi_translation": "खुश",
    "description": "Hands move up along face with smile",
    "category": "Emotions",
    "difficulty_level": "easy",
    "confidence_score": 0.92,
    "created_at": "2024-01-15T10:30:45"
  }
}
```

---

## 🧪 Test Detection with Real Signs

### 1. Sign Up First
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123",
    "first_name": "Test"
  }'

# Save the access_token from response
TOKEN="your_access_token_here"
```

### 2. Detect from a Frame
```bash
# This will detect if you're making a sign in front of camera
curl -X POST http://localhost:5000/api/detection/detect-frame \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "frame": "base64_encoded_image",
    "min_confidence": 0.5
  }'
```

### 3. View Your Detection History
```bash
curl -X GET http://localhost:5000/api/detection/history \
  -H "Authorization: Bearer $TOKEN"

# Filter by recent (last 7 days)
curl -X GET "http://localhost:5000/api/detection/history?days=7" \
  -H "Authorization: Bearer $TOKEN"
```

### 4. Get Your Statistics
```bash
curl -X GET http://localhost:5000/api/detection/history/stats \
  -H "Authorization: Bearer $TOKEN"

# Response:
{
  "total_detections": 5,
  "unique_signs": 3,
  "average_confidence": 0.87,
  "top_signs": [
    {"sign": "Happy", "count": 2},
    {"sign": "Hello", "count": 2}
  ],
  "period_days": 30
}
```

---

## 📚 Complete Sign Categories

All 100+ signs organized by category:

### 🎉 **Greetings** (5 signs)
Hello, Goodbye, Welcome, Good Morning, Good Night

### ✅ **Responses** (5 signs)
Yes, No, Maybe, OK, Agree

### 😊 **Emotions** (8 signs)
Happy, Sad, Angry, Scared, Surprised, Love, Tired, Confused

### 🚶 **Actions** (21 signs)
Walk, Run, Jump, Sit, Stand, Sleep, Wake Up, Dance, Eat, Drink, Work, Play, Read, Write, Listen, Look, Help, Give, Take

### 🏠 **Objects** (10 signs)
Water, Food, House, Car, Phone, Book, School, Money, Clock, Doctor

### 💯 **Adjectives** (15 signs)
Good, Bad, Beautiful, Ugly, Big, Small, Hot, Cold, Strong, Weak, Fast, Slow, Clean, Dirty

### 👨‍👩‍👧‍👦 **Family** (10 signs)
Mother, Father, Sister, Brother, Baby, Grandfather, Grandmother, Husband, Wife, Friend

### 🙏 **Requests** (5 signs)
Please, Thank You, Sorry, Excuse Me, Help

### 📚 **Education** (5 signs)
Learn, Understand, Forget, Remember, Think

### ⏰ **Time** (6 signs)
Today, Tomorrow, Yesterday, Morning, Evening, Night

### 🔢 **Numbers** (6 signs)
One, Two, Three, Five, Ten

### 🏥 **Health** (4 signs)
Pain, Sick, Health, Hospital

**Total: 100+ Signs**

---

## 🎓 Test Scenarios

### Scenario 1: Browse Emotions
```bash
curl "http://localhost:5000/api/detection/signs?category=Emotions&per_page=10"
```

### Scenario 2: Learn Easy Signs
```bash
curl "http://localhost:5000/api/detection/signs?category=Greetings"
```

### Scenario 3: Challenge with Hard Signs
```bash
# Note: Filter by difficulty level in your app logic
curl "http://localhost:5000/api/detection/signs?search=grandfather"
```

### Scenario 4: Search Hindi Translation
```bash
# Search in your app with Hindi text
curl "http://localhost:5000/api/detection/signs?search=खुश"
```

---

## 💻 Python Example

```python
import requests
import json

BASE_URL = "http://localhost:5000/api"

# 1. Browse all signs
response = requests.get(f"{BASE_URL}/detection/signs")
signs = response.json()
print(f"Found {signs['total']} signs")

# 2. Get category options
response = requests.get(f"{BASE_URL}/utils/categories")
categories = response.json()['categories']
print(f"Categories: {categories}")

# 3. Get signs by category
response = requests.get(f"{BASE_URL}/detection/signs?category=Emotions")
emotion_signs = response.json()['signs']
print(f"Emotion signs: {len(emotion_signs)}")

# 4. Get stats
response = requests.get(f"{BASE_URL}/utils/dataset/stats")
stats = response.json()
print(json.dumps(stats, indent=2))
```

---

## 🔧 Database Check

### Check if data is loaded
```sql
-- Connect to PostgreSQL
psql -U postgres -d sign_detection

-- Check total signs
SELECT COUNT(*) FROM signs;
-- Should show: 100+

-- Check by category
SELECT category, COUNT(*) as count 
FROM signs 
GROUP BY category 
ORDER BY count DESC;

-- Check languages
SELECT COUNT(*) FROM signs WHERE hindi_translation IS NOT NULL;
-- Should show: 100
```

---

## ❓ Troubleshooting

### Signs not appearing?

**Check 1: Database connected?**
```bash
curl http://localhost:5000/health
```

**Check 2: Dataset loaded?**
```bash
curl http://localhost:5000/api/utils/dataset/stats
```

**Check 3: Run load script**
```bash
python load_signs.py
```

### API not responding?

```bash
# Make sure backend is running
ps aux | grep python  # Check if app.py is running

# Restart if needed
python app.py
```

### Database error?

```bash
# Check PostgreSQL
psql -U postgres -c "SELECT 1"

# Verify database exists
psql -U postgres -l | grep sign_detection

# Recreate if needed
python init_db.py
```

---

## 📊 What Happens When Data is Loaded

1. ✅ 100+ signs created in database
2. ✅ English translations added
3. ✅ Hindi translations added
4. ✅ Categories assigned
5. ✅ Difficulty levels set
6. ✅ Descriptions provided
7. ✅ Confidence scores initialized
8. ✅ Ready for detection & learning

---

## 🎯 Next Steps

1. **Browse the signs** - `GET /api/detection/signs`
2. **Create an account** - `POST /api/auth/signup`
3. **Test detection** - `POST /api/detection/detect-frame`
4. **Track progress** - `GET /api/utils/learning-progress`
5. **Build your app** - Integrate with frontend

---

## 📝 Notes

- All signs support both English and Hindi
- Each sign has a detailed description of the gesture
- Difficulty levels help users progress gradually
- 12 organized categories for easy browsing
- System is ready for real-time video detection
- Data can be expanded with more signs

---

## 🚀 Performance

Expected response times:
- Browse all signs: <200ms
- Search signs: <100ms
- Get statistics: <150ms
- Filter by category: <100ms

---

## 📞 Support

For issues:
1. Check README.md
2. See SIGN_LANGUAGE_DATASET.md for sign list
3. Review API_TESTING.md for more examples
4. Check logs: `tail -f app.log`

---

**Your sign language dataset is ready! 🎉**

Start using the API to detect signs in real-time.
