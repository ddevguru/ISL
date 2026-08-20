# Backend API Integration Guide

## ✅ Setup Complete

Your backend API is now live at: **https://isl-u2qo.onrender.com**

The Flutter app has been configured to use this endpoint automatically.

## 📝 Configuration

The API configuration is in `lib/config/api_config.dart`:

```dart
static String _baseUrl = 'https://isl-u2qo.onrender.com/api';
```

All API endpoints are built on top of this base URL.

## 🔗 Available Endpoints

### Authentication
- **Login**: `POST /api/auth/login`
  ```dart
  ApiService.login(
    usernameOrEmail: 'user@example.com',
    password: 'password123'
  )
  ```

- **Signup**: `POST /api/auth/signup`
  ```dart
  ApiService.signup(
    username: 'username',
    email: 'user@example.com',
    password: 'password123',
    firstName: 'John'
  )
  ```

### Sign Detection
- **Get All Signs**: `GET /api/detection/signs`
  ```dart
  List<dynamic> signs = await ApiService.getSigns();
  ```

- **Detect Frame**: `POST /api/detection/detect-frame`
  ```dart
  Map<String, dynamic> result = await ApiService.detectFrame(
    frameBase64: base64EncodedImage
  );
  ```

### Health Check
- **Health Status**: `GET /health`
  ```dart
  bool isHealthy = await ApiService.healthCheck();
  ```

## 🔐 Authentication

After login, save the token and set it in ApiConfig:

```dart
// After successful login
ApiConfig.authToken = responseData['access_token'];

// The token will be automatically included in all subsequent requests
```

## 💻 Example Usage

### Login Flow
```dart
try {
  final response = await ApiService.login(
    usernameOrEmail: emailController.text,
    password: passwordController.text,
  );
  
  if (response['success'] != false) {
    ApiConfig.authToken = response['access_token'];
    // Navigate to home screen
  } else {
    // Show error message
  }
} catch (e) {
  print('Login error: $e');
}
```

### Using in Screens

The `ApiService` methods can be called directly in your screens:

```dart
@override
void initState() {
  super.initState();
  _loadSigns();
}

Future<void> _loadSigns() async {
  try {
    final signs = await ApiService.getSigns();
    setState(() {
      this.signs = signs;
    });
  } catch (e) {
    print('Error loading signs: $e');
  }
}
```

## 🧪 Testing the Connection

You can test the API connection using:

```dart
// In your app initialization
ApiService.healthCheck().then((isHealthy) {
  if (isHealthy) {
    print('✅ API is reachable');
  } else {
    print('❌ API is not reachable');
  }
});
```

## 🔄 Environment Switching

You can switch between different environments:

```dart
// Use production (default)
ApiConfig.useProduction('isl-u2qo.onrender.com');

// Use local network
ApiConfig.useLocalNetwork('192.168.0.146', port: 5000);

// Use custom URL
ApiConfig.setBaseUrl('https://your-custom-url.com/api');
```

## 📦 Dependencies

Make sure the `http` package is installed:

```yaml
dependencies:
  http: ^1.1.0
```

Run `flutter pub get` to install dependencies.

## 🚀 Next Steps

1. Run `flutter pub get` to install the http package
2. Test the API connection with a health check
3. Implement login/signup flows
4. Integrate sign detection in your screens

## 📋 API Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "message": "Detailed error message"
}
```

## ⚠️ Important Notes

- HTTPS is enabled for production API
- All requests include proper CORS headers
- JWT authentication is required for protected endpoints
- Request timeout is set to 30 seconds
- The API expects `Authorization: Bearer <token>` header for authenticated requests
