import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._apiService) {
    // Defer session restoration to allow app to initialize first
    Future.microtask(() => _restoreSession());
  }

  static const _tokenKey = 'auth_token';

  final ApiService _apiService;

  User? _currentUser;
  String? _token;
  bool _isBusy = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<void> _restoreSession() async {
    try {
      _setBusy(true);
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      if (savedToken != null) {
        try {
          final profile = await _apiService.fetchProfile(savedToken);
          _token = savedToken;
          _currentUser = profile;
        } catch (error) {
          if (kDebugMode) {
            debugPrint('Failed to restore session: $error');
          }
          await prefs.remove(_tokenKey);
          _token = null;
          _currentUser = null;
        }
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to initialize auth: $error');
      }
      _token = null;
      _currentUser = null;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    _clearError();
    try {
      await _apiService.register(name: name, email: email, password: password);
      await login(email: email, password: password);
    } on ApiException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError('Registration failed: $error');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setBusy(true);
    _clearError();
    try {
      final token = await _apiService.login(email: email, password: password);
      final profile = await _apiService.fetchProfile(token);
      _token = token;
      _currentUser = profile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } on ApiException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError('Login failed: $error');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshProfile() async {
    final currentToken = _token;
    if (currentToken == null) return;
    try {
      final profile = await _apiService.fetchProfile(currentToken);
      _currentUser = profile;
      notifyListeners();
    } catch (error) {
      _setError('Could not refresh profile: $error');
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }

  void clearErrorMessage() {
    _clearError();
    notifyListeners();
  }

  void _setBusy(bool value) {
    if (_isBusy != value) {
      _isBusy = value;
      notifyListeners();
    }
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }
}
