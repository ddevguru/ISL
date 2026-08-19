# API Testing Guide

## Quick Testing with cURL

### 1. Health Check
```bash
curl -X GET http://localhost:5000/health
```

### 2. Authentication

#### Sign Up
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123",
    "first_name": "Test",
    "last_name": "User"
  }'
```

Response:
```json
{
  "message": "User created successfully",
  "user": {
    "id": "uuid",
    "username": "testuser",
    "email": "test@example.com",
    "first_name": "Test",
    "last_name": "User",
    "created_at": "2024-01-15T10:30:45.123456",
    "is_active": true
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

Save the `access_token` for subsequent requests.

#### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username_or_email": "testuser",
    "password": "TestPass123"
  }'
```

### 3. Protected Endpoints (Replace TOKEN with your access_token)

#### Get Profile
```bash
curl -X GET http://localhost:5000/api/auth/profile \
  -H "Authorization: Bearer TOKEN"
```

#### Update Profile
```bash
curl -X PUT http://localhost:5000/api/auth/profile \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Updated",
    "last_name": "Name"
  }'
```

#### Change Password
```bash
curl -X POST http://localhost:5000/api/auth/change-password \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "old_password": "TestPass123",
    "new_password": "NewPass123"
  }'
```

### 4. Detection Endpoints

#### Load Dataset
```bash
curl -X POST http://localhost:5000/api/utils/dataset/load
```

#### Get All Signs
```bash
curl -X GET "http://localhost:5000/api/detection/signs?page=1&per_page=10"
```

#### Search Signs
```bash
curl -X GET "http://localhost:5000/api/detection/signs?search=hello"
```

#### Get Signs by Category
```bash
curl -X GET "http://localhost:5000/api/detection/signs?category=Greetings"
```

#### Get Single Sign
```bash
curl -X GET http://localhost:5000/api/detection/signs/{sign_id}
```

#### Get Categories
```bash
curl -X GET http://localhost:5000/api/utils/categories
```

#### Get Dataset Stats
```bash
curl -X GET http://localhost:5000/api/utils/dataset/stats
```

### 5. Detection with Frame Data

#### Create Test Frame Image (Python)
```python
import cv2
import base64

# Create a simple test image
img = cv2.imread('path/to/image.jpg')
_, buffer = cv2.imencode('.jpg', img)
frame_base64 = base64.b64encode(buffer).decode()

# Now use in API request
import requests

headers = {
    'Authorization': f'Bearer {access_token}',
    'Content-Type': 'application/json'
}

data = {
    'frame': frame_base64,
    'min_confidence': 0.5
}

response = requests.post(
    'http://localhost:5000/api/detection/detect-frame',
    json=data,
    headers=headers
)
print(response.json())
```

#### Using cURL with Base64 Image
```bash
# First, encode an image to base64
# On Linux/Mac
base64 -i image.jpg -o image_base64.txt

# On Windows (PowerShell)
$bytes = [System.IO.File]::ReadAllBytes('image.jpg')
$base64 = [Convert]::ToBase64String($bytes)

# Then use in request
curl -X POST http://localhost:5000/api/detection/detect-frame \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "frame": "$(cat image_base64.txt)",
  "min_confidence": 0.5
}
EOF
```

### 6. Video Upload

#### Upload Video File
```bash
curl -X POST http://localhost:5000/api/detection/detect-video \
  -H "Authorization: Bearer TOKEN" \
  -F "video=@/path/to/video.mp4"
```

Response includes detected signs and output video path.

### 7. User History

#### Get Detection History
```bash
curl -X GET "http://localhost:5000/api/detection/history?page=1&per_page=20" \
  -H "Authorization: Bearer TOKEN"
```

#### Get History with Date Filter
```bash
curl -X GET "http://localhost:5000/api/detection/history?days=7" \
  -H "Authorization: Bearer TOKEN"
```

#### Get History Statistics
```bash
curl -X GET "http://localhost:5000/api/detection/history/stats?days=30" \
  -H "Authorization: Bearer TOKEN"
```

### 8. Saved Signs

#### Save a Sign
```bash
curl -X POST http://localhost:5000/api/detection/save-sign/{sign_id} \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "notes": "This is my favorite sign"
  }'
```

#### Get Saved Signs
```bash
curl -X GET "http://localhost:5000/api/detection/saved-signs?page=1&per_page=20" \
  -H "Authorization: Bearer TOKEN"
```

#### Unsave a Sign
```bash
curl -X DELETE http://localhost:5000/api/detection/unsave-sign/{sign_id} \
  -H "Authorization: Bearer TOKEN"
```

### 9. Learning Progress

#### Get Learning Progress
```bash
curl -X GET "http://localhost:5000/api/utils/learning-progress?page=1&per_page=20" \
  -H "Authorization: Bearer TOKEN"
```

#### Get Progress Summary
```bash
curl -X GET http://localhost:5000/api/utils/learning-progress/summary \
  -H "Authorization: Bearer TOKEN"
```

#### Update Progress
```bash
curl -X PUT http://localhost:5000/api/utils/learning-progress/{sign_id} \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "times_practiced": 1,
    "times_detected_correctly": 1,
    "mastered": false
  }'
```

### 10. Video Sessions

#### Create Video Session
```bash
curl -X POST http://localhost:5000/api/utils/video-sessions \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session_type": "live"
  }'
```

#### End Video Session
```bash
curl -X PUT http://localhost:5000/api/utils/video-sessions/{session_id} \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed"
  }'
```

#### Get Video Sessions
```bash
curl -X GET "http://localhost:5000/api/utils/video-sessions?page=1&per_page=20" \
  -H "Authorization: Bearer TOKEN"
```

## Testing with Postman

### 1. Import Collection
Create a new Postman collection with the following requests:

### 2. Environment Variables
Set up Postman environment with:
```
base_url: http://localhost:5000
access_token: (will be auto-filled after login)
sign_id: (will be auto-filled after fetching signs)
```

### 3. Pre-request Scripts
For login endpoint:
```javascript
// Execute before sending request
// After login, token will be automatically saved
```

### 4. Tests
Add post-request tests to automatically capture tokens:
```javascript
// After login request
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.access_token);
    pm.environment.set("user_id", jsonData.user.id);
}
```

## Testing with Python Script

```python
import requests
import json

BASE_URL = "http://localhost:5000/api"

class SignDetectionTester:
    def __init__(self):
        self.token = None
        self.base_url = BASE_URL
        self.headers = {}

    def signup(self, username, email, password):
        url = f"{self.base_url}/auth/signup"
        data = {
            "username": username,
            "email": email,
            "password": password,
            "first_name": "Test",
            "last_name": "User"
        }
        response = requests.post(url, json=data)
        print(f"Signup: {response.status_code}")
        if response.status_code == 201:
            result = response.json()
            self.token = result['access_token']
            self.headers = {'Authorization': f'Bearer {self.token}'}
            print(f"Token: {self.token}")
        return response.json()

    def get_signs(self, page=1):
        url = f"{self.base_url}/detection/signs?page={page}&per_page=10"
        response = requests.get(url)
        print(f"Get Signs: {response.status_code}")
        return response.json()

    def load_dataset(self):
        url = f"{self.base_url}/utils/dataset/load"
        response = requests.post(url)
        print(f"Load Dataset: {response.status_code}")
        return response.json()

    def get_history(self):
        url = f"{self.base_url}/detection/history"
        response = requests.get(url, headers=self.headers)
        print(f"Get History: {response.status_code}")
        return response.json()

    def get_dataset_stats(self):
        url = f"{self.base_url}/utils/dataset/stats"
        response = requests.get(url)
        print(f"Get Stats: {response.status_code}")
        return response.json()

# Run tests
tester = SignDetectionTester()

print("\n1. Loading Dataset...")
print(json.dumps(tester.load_dataset(), indent=2))

print("\n2. Getting Signs...")
print(json.dumps(tester.get_signs(), indent=2))

print("\n3. Getting Dataset Stats...")
print(json.dumps(tester.get_dataset_stats(), indent=2))

print("\n4. Signing Up...")
print(json.dumps(tester.signup("testuser", "test@example.com", "TestPass123"), indent=2))

print("\n5. Getting History...")
print(json.dumps(tester.get_history(), indent=2))
```

## Error Handling

### Common Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 400 | Bad Request | Check request format |
| 401 | Unauthorized | Check token/authentication |
| 404 | Not Found | Check resource ID |
| 409 | Conflict | Resource already exists |
| 500 | Server Error | Check server logs |

### Error Response Format
```json
{
  "error": "Description of what went wrong"
}
```

## Performance Testing

### Load Testing with Apache Bench
```bash
ab -n 1000 -c 100 http://localhost:5000/health
```

### Stress Testing with wrk
```bash
wrk -t12 -c400 -d30s http://localhost:5000/api/detection/signs
```

## Debugging Tips

1. **Enable Flask Debug Mode**
   Set `FLASK_DEBUG=1` in .env

2. **Check Logs**
   Monitor stdout/stderr for error messages

3. **Database Queries**
   Add logging for SQL queries in development

4. **JWT Token Inspection**
   Decode JWT at https://jwt.io

5. **API Response Time**
   Use `time` command before curl requests

## Testing Checklist

- [ ] Health check passes
- [ ] User registration works
- [ ] Login returns valid token
- [ ] Profile endpoints work
- [ ] Dataset loads successfully
- [ ] Can fetch signs with filters
- [ ] Frame detection works
- [ ] Video processing works
- [ ] History tracking works
- [ ] Learning progress updates
- [ ] Video sessions create/end
- [ ] Saved signs functionality works

---

For more detailed API documentation, see [README.md](README.md)
