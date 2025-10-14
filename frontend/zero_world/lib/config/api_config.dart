import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform-aware API configuration
/// Automatically selects the correct backend URL based on the platform
class ApiConfig {
  // Production domain
  static const String productionUrl = 'https://www.zn-01.com/api';
  
  // Development/local URLs for different platforms
  static const String localhostUrl = 'http://localhost:8000';
  
  // Android emulator uses special IP to access host machine's localhost
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000';
  
  // iOS simulator can use localhost directly
  static const String iosSimulatorUrl = 'http://localhost:8000';
  
  /// Get the appropriate base URL for the current platform
  static String get baseUrl {
    // Check for environment variable override first
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Use production URL for release builds
    if (kReleaseMode) {
      return productionUrl;
    }
    
    // Platform-specific URLs for development/debug mode
    if (kIsWeb) {
      // Web builds use the production URL (same domain)
      return productionUrl;
    } else if (Platform.isAndroid) {
      // Android emulator needs special IP to access host machine
      return androidEmulatorUrl;
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return iosSimulatorUrl;
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      // Desktop platforms use localhost
      return localhostUrl;
    }
    
    // Fallback to production
    return productionUrl;
  }
  
  /// Get WebSocket URL (converts http to ws, https to wss)
  static String get wsUrl {
    final url = baseUrl;
    if (url.startsWith('https://')) {
      return url.replaceFirst('https://', 'wss://');
    } else if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'ws://');
    }
    return url;
  }
  
  /// Check if we're using local development server
  static bool get isLocal => 
      baseUrl.contains('localhost') || baseUrl.contains('10.0.2.2');
  
  /// Get platform name for debugging
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }
  
  /// Print current configuration (useful for debugging)
  static void printConfig() {
    debugPrint('=== API Configuration ===');
    debugPrint('Platform: $platformName');
    debugPrint('Mode: ${kReleaseMode ? "Release" : "Debug"}');
    debugPrint('Base URL: $baseUrl');
    debugPrint('WebSocket URL: $wsUrl');
    debugPrint('Is Local: $isLocal');
    debugPrint('========================');
  }
}
