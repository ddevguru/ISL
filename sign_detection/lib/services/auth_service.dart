import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  User? _currentUser;
  String? _accessToken;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  /// Initialize auth service - load token and user from local storage
  Future<void> initialize() async {
    print('🔄 Initializing AuthService...');
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');

      if (_accessToken != null) {
        await _fetchUserProfile();
        print('✓ AuthService initialized with existing token');
      } else {
        print('✓ AuthService initialized (no token)');
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error initializing AuthService: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Signup new user
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String firstName,
    String lastName = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('\n${'='*60}');
    print('📝 Signup: $email');
    print('${'='*60}\n');

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signupEndpoint),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      print('✓ Response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✓ Signup successful');

        _accessToken = data['access_token'];
        _currentUser = User.fromJson(data['user']);

        // Save token to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);

        print('✅ Signup complete');
        print('${'='*60}\n');

        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Signup failed';
        _error = error;
        print('❌ Signup failed: $error');
        print('${'='*60}\n');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      print('❌ Signup exception: $e');
      print('${'='*60}\n');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('\n${'='*60}');
    print('🔓 Login: $usernameOrEmail');
    print('${'='*60}\n');

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'username_or_email': usernameOrEmail,
          'password': password,
        }),
      );

      print('✓ Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✓ Login successful');

        _accessToken = data['access_token'];
        _currentUser = User.fromJson(data['user']);

        // Save token to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);

        // Set user as online
        await updateUserStatus(isOnline: true);

        print('✅ Login complete');
        print('${'='*60}\n');

        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login failed';
        _error = error;
        print('❌ Login failed: $error');
        print('${'='*60}\n');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      print('❌ Login exception: $e');
      print('${'='*60}\n');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch user profile from API
  Future<bool> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profileEndpoint),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['user']);
        print('✓ Profile fetched');
        return true;
      } else {
        print('❌ Failed to fetch profile');
        return false;
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? phoneNumber,
    String? country,
    String? languagePreference,
  }) async {
    if (!isAuthenticated) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (bio != null) data['bio'] = bio;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (country != null) data['country'] = country;
      if (languagePreference != null) data['language_preference'] = languagePreference;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/profile'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _currentUser = User.fromJson(responseData['user']);
        print('✓ Profile updated');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update profile';
        print('❌ Failed to update profile');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      print('❌ Error updating profile: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user online status
  Future<bool> updateUserStatus({required bool isOnline}) async {
    if (!isAuthenticated) return false;

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/status'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'is_online': isOnline}),
      );

      if (response.statusCode == 200) {
        _currentUser = _currentUser!.copyWith(isOnline: isOnline);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating status: $e');
      return false;
    }
  }

  /// Search for users
  Future<List<User>> searchUsers(String query) async {
    if (!isAuthenticated || query.length < 2) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/search?q=$query&limit=20'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = (data['users'] as List)
            .map((u) => User.fromJson(u))
            .toList();
        return users;
      }
      return [];
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// Get online users
  Future<List<User>> getOnlineUsers() async {
    if (!isAuthenticated) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/online-users'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = (data['users'] as List)
            .map((u) => User.fromJson(u))
            .toList();
        return users;
      }
      return [];
    } catch (e) {
      print('❌ Error getting online users: $e');
      return [];
    }
  }

  /// Logout
  Future<void> logout() async {
    print('🚪 Logging out...');

    // Set user as offline
    if (isAuthenticated) {
      await updateUserStatus(isOnline: false);
    }

    _currentUser = null;
    _accessToken = null;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    print('✓ Logout complete');
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
