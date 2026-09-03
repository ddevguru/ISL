import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static String? authToken;

  static String _baseUrl = 'http://localhost:5000/api';

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static void useLocalNetwork(String ipAddress, {int port = 5000}) {
    _baseUrl = 'http://$ipAddress:$port/api';
  }

  static void useProduction(String domain, {int port = 443, bool https = true}) {
    final protocol = https ? 'https' : 'http';
    _baseUrl = '$protocol://$domain${port != 443 && port != 80 ? ':$port' : ''}/api';
  }

  static String get signDetectionUrl => '$baseUrl/detection';
  static String get authUrl => '$baseUrl/auth';
  static String get utilsUrl => '$baseUrl/utils';

  static String get signupEndpoint => '$authUrl/signup';
  static String get loginEndpoint => '$authUrl/login';
  static String get profileEndpoint => '$authUrl/profile';

  static String get signsEndpoint => '$signDetectionUrl/signs';
  static String get detectFrameEndpoint => '$signDetectionUrl/detect-frame';
  static String get detectVideoEndpoint => '$signDetectionUrl/detect-video';
  static String get historyEndpoint => '$signDetectionUrl/history';

  static String get learningProgressEndpoint => '$utilsUrl/learning-progress';
  static String get categoriesEndpoint => '$utilsUrl/categories';
  static String get datasetStatsEndpoint => '$utilsUrl/dataset/stats';

  static String get healthEndpoint {
    final baseParts = _baseUrl.split('/api');
    return '${baseParts[0]}/health';
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }
}

class ApiService {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String firstName,
  }) async {
    print('🔗 Connecting to: ${ApiConfig.signupEndpoint}');

    final response = await http.post(
      Uri.parse(ApiConfig.signupEndpoint),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
      }),
    );

    print('✅ Response: ${response.statusCode}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    print('🔗 Connecting to: ${ApiConfig.loginEndpoint}');

    final response = await http.post(
      Uri.parse(ApiConfig.loginEndpoint),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({
        'username_or_email': usernameOrEmail,
        'password': password,
      }),
    );

    print('✅ Response: ${response.statusCode}');
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getSigns() async {
    print('🔗 Connecting to: ${ApiConfig.signsEndpoint}');

    final response = await http.get(
      Uri.parse(ApiConfig.signsEndpoint),
      headers: ApiConfig.defaultHeaders,
    );

    print('✅ Response: ${response.statusCode}');
    final data = jsonDecode(response.body);
    return data['signs'] ?? [];
  }

  static Future<Map<String, dynamic>> detectFrame({
    required String frameBase64,
  }) async {
    print('🔗 Connecting to: ${ApiConfig.detectFrameEndpoint}');

    final response = await http.post(
      Uri.parse(ApiConfig.detectFrameEndpoint),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer ${ApiConfig.authToken}',
      },
      body: jsonEncode({
        'frame': frameBase64,
        'min_confidence': 0.5,
      }),
    ).timeout(ApiConfig.receiveTimeout);

    print('✅ Response: ${response.statusCode}');
    return jsonDecode(response.body);
  }

  static Future<bool> healthCheck() async {
    print('🔗 Health Check: ${ApiConfig.healthEndpoint}');

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.healthEndpoint),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.connectTimeout);

      print('✅ Health Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health Check Failed: $e');
      return false;
    }
  }
}
