import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Authentication Service
/// Handles user login, signup, token management, and auth state
class AuthService {
  // Use relative path - nginx will proxy /api/ to backend
  // This works in both development and production
  static const String baseUrl = '/api';

  String? _accessToken;
  UserModel? _currentUser;

  String? get accessToken => _accessToken;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null;

  /// Initialize auth service - load saved token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');

    if (_accessToken != null) {
      // Validate token and load user data
      try {
        await getCurrentUser();
      } catch (e) {
        // Token invalid, clear it
        await logout();
      }
    }
  }

  /// Sign up new user
  Future<UserModel> signup({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
        'full_name': fullName,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _currentUser = UserModel.fromJson(data['user']);

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);

      return _currentUser!;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Signup failed');
    }
  }

  /// Login user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email, // OAuth2 uses 'username' field
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];

      // Get user data
      await getCurrentUser();

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);

      return _currentUser!;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  /// Get current user data
  Future<UserModel> getCurrentUser() async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = UserModel.fromJson(data);
      return _currentUser!;
    } else {
      throw Exception('Failed to get user data');
    }
  }

  /// Logout user
  Future<void> logout() async {
    _accessToken = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  /// Get authorization headers
  Map<String, String> getAuthHeaders() {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/auth/profile'),
      headers: getAuthHeaders(),
      body: jsonEncode({
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (address != null) 'address': address,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = UserModel.fromJson(data);
      return _currentUser!;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/change-password'),
      headers: getAuthHeaders(),
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to change password');
    }
  }
}
