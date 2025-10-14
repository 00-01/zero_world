import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String productionUrl = 'https://www.zn-01.com/api';
  static const String localhostUrl = 'http://localhost:8000';
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000';

  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (kReleaseMode) return productionUrl;
    if (kIsWeb) return productionUrl;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidEmulatorUrl;
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return localhostUrl;
    }
  }

  static String get wsUrl {
    final url = baseUrl;
    if (url.startsWith('https://'))
      return url.replaceFirst('https://', 'wss://');
    if (url.startsWith('http://')) return url.replaceFirst('http://', 'ws://');
    return url;
  }

  static bool get isLocal =>
      baseUrl.contains('localhost') || baseUrl.contains('10.0.2.2');

  static String get platformName {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

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
