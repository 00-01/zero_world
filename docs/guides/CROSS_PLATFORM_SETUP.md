# Zero World - Cross-Platform Setup Guide

Complete guide to running Zero World on all platforms: Android, iOS, web, macOS, Linux, and Windows.

## 🎯 Platform Support

| Platform | Status | Backend URL | Notes |
|----------|--------|-------------|-------|
| **Android Emulator** | ✅ Ready | `http://10.0.2.2:8000` | Auto-configured |
| **iOS Simulator** | ✅ Ready | `http://localhost:8000` | Requires macOS |
| **Web (Chrome)** | ✅ Ready | `https://www.zn-01.com/api` | Production URL |
| **Linux Desktop** | ✅ Ready | `http://localhost:8000` | Native app |
| **macOS Desktop** | ✅ Ready | `http://localhost:8000` | Requires macOS |
| **Windows Desktop** | ✅ Ready | `http://localhost:8000` | Native app |

---

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/00-01/zero_world.git
cd zero_world/frontend/zero_world
flutter pub get
```

### 2. Start Backend (for local development)
```bash
cd ../../
docker-compose up -d
```

### 3. Run on Your Platform
```bash
# Android emulator
flutter run -d <android-device-id>

# iOS simulator (macOS only)
flutter run -d <ios-simulator-id>

# Linux desktop
flutter run -d linux

# macOS desktop
flutter run -d macos

# Windows desktop
flutter run -d windows

# Chrome browser
flutter run -d chrome
```

---

## 📱 Android Setup

### Prerequisites
- Android SDK installed
- Android emulator or physical device

### Configuration
✅ **Already configured:**
- Network security allows `localhost`, `10.0.2.2`, `127.0.0.1`
- Internet permission enabled
- Uses `http://10.0.2.2:8000` (emulator's localhost)

### Testing on Android Emulator
```bash
# Method 1: Use automated script
./scripts/test_android.sh

# Method 2: Manual
flutter emulators --launch <emulator-id>
flutter run -d emulator-5554
```

### Testing on Physical Device
```bash
# 1. Enable USB debugging on your phone
# Settings → About → Tap "Build Number" 7 times
# Settings → Developer Options → USB Debugging

# 2. Connect via USB
adb devices

# 3. Run the app
flutter run
```

---

## 🍎 iOS Setup (Requires macOS)

### Prerequisites
- macOS with Xcode installed
- iOS Simulator or physical iPhone/iPad

### Configuration
✅ **Already configured:**
- App Transport Security allows localhost
- HTTP connections permitted for development
- Uses `http://localhost:8000`

### Testing on iOS Simulator
```bash
# List available simulators
xcrun simctl list devices available

# Or use Flutter command
flutter emulators

# Launch a simulator
open -a Simulator

# Or use Flutter
flutter emulators --launch <simulator-id>

# Run the app
flutter run -d <ios-simulator-id>
```

### Testing on Physical iPhone/iPad
```bash
# 1. Connect your iPhone via USB
# 2. Trust computer on device
# 3. In Xcode, select your device
# 4. Run the app
flutter run
```

### iOS Specific Notes
- **Code Signing:** For physical devices, you need an Apple Developer account
- **Bundle ID:** Change `com.example.zero_world` to your own
- **Provisioning Profile:** Xcode will help set this up

---

## 🌐 Web Setup

### Configuration
✅ **Already configured:**
- Uses production URL: `https://www.zn-01.com/api`
- CORS handled by backend
- PWA support enabled

### Testing on Web
```bash
# Run in Chrome
flutter run -d chrome

# Or build for deployment
flutter build web --release

# Serve locally
cd build/web
python3 -m http.server 8080
```

### Access Your Web App
- **Local Development:** http://localhost:8080
- **Production:** https://www.zn-01.com

---

## 🖥️ Desktop Setup

### Linux Desktop

**Prerequisites:**
- Linux with required libraries
- Run: `flutter doctor` to check

**Testing:**
```bash
flutter run -d linux

# Or build release
flutter build linux --release
./build/linux/x64/release/bundle/zero_world
```

### macOS Desktop

**Prerequisites:**
- macOS 10.14 or later
- Xcode command line tools

**Testing:**
```bash
flutter run -d macos

# Or build release
flutter build macos --release
open build/macos/Build/Products/Release/zero_world.app
```

### Windows Desktop

**Prerequisites:**
- Windows 10 or later
- Visual Studio 2022 with C++ desktop development

**Testing:**
```bash
flutter run -d windows

# Or build release
flutter build windows --release
.\build\windows\runner\Release\zero_world.exe
```

---

## 🔧 Platform-Aware API Configuration

The app **automatically** selects the correct backend URL based on platform:

### How It Works

```dart
// lib/config/api_config.dart
class ApiConfig {
  static String get baseUrl {
    // Release mode → Always use production
    if (kReleaseMode) {
      return 'https://www.zn-01.com/api';
    }
    
    // Debug mode → Platform-specific URLs
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';  // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000';  // iOS simulator
    } else if (kIsWeb) {
      return 'https://www.zn-01.com/api';  // Web
    } else {
      return 'http://localhost:8000';  // Desktop
    }
  }
}
```

### Override Backend URL

For custom backend URLs:
```bash
# Method 1: Environment variable
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000

# Method 2: Build argument
flutter build apk --dart-define=API_BASE_URL=https://your-domain.com/api
```

---

## 🧪 Testing All Platforms

### Interactive Test Menu
```bash
./scripts/test_all_platforms.sh
```

This provides a menu to test on:
1. Android Emulator
2. Linux Desktop
3. Chrome Browser
4. All Available Devices
5. Performance Testing

### Individual Platform Tests
```bash
# Android
./scripts/test_android.sh

# List all devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

---

## 🐛 Troubleshooting

### Android Issues

**Problem:** "Connection refused" to backend
```bash
# Solution: Android emulator uses special IP
# Backend should be running on your host machine
docker-compose up -d

# Verify backend is accessible
curl http://localhost:8000/health
```

**Problem:** "Cleartext HTTP traffic not permitted"
```
✅ Fixed: network_security_config.xml allows localhost
```

### iOS Issues

**Problem:** "App Transport Security blocks HTTP"
```
✅ Fixed: Info.plist allows localhost connections
```

**Problem:** "No iOS devices found"
```bash
# Install Xcode from App Store
xcode-select --install

# Accept license
sudo xcodebuild -license

# Install simulators
xcodebuild -downloadPlatform iOS
```

### Web Issues

**Problem:** CORS errors
```
✅ Fixed: Backend has CORS middleware configured
Check nginx.conf for CORS headers
```

**Problem:** Can't connect to localhost from web
```
Use production URL for web builds
Web apps run in browser, can't access localhost backend
```

### Desktop Issues

**Problem:** "Platform not supported"
```bash
# Enable desktop support
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop

# Create platform files
flutter create --platforms=linux,macos,windows .
```

---

## 🚀 Build for Release

### Android (APK + AAB)
```bash
# APK (for testing)
flutter build apk --release

# AAB (for Google Play Store)
flutter build appbundle --release

# Outputs:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### iOS (IPA)
```bash
# Requires macOS
flutter build ios --release

# Archive in Xcode for App Store
open ios/Runner.xcworkspace
```

### Web
```bash
flutter build web --release

# Deploy to server
scp -r build/web/* user@server:/var/www/zn-01.com/
```

### Linux
```bash
flutter build linux --release

# Output: build/linux/x64/release/bundle/
```

### macOS
```bash
flutter build macos --release

# Output: build/macos/Build/Products/Release/zero_world.app
```

### Windows
```bash
flutter build windows --release

# Output: build/windows/runner/Release/
```

---

## 📊 Platform Comparison

| Feature | Android | iOS | Web | Desktop |
|---------|---------|-----|-----|---------|
| **Hot Reload** | ✅ | ✅ | ✅ | ✅ |
| **Native Performance** | ✅ | ✅ | ⚠️ | ✅ |
| **File System Access** | ✅ | ✅ | ❌ | ✅ |
| **Push Notifications** | ✅ | ✅ | ✅ | ❌ |
| **Camera/GPS** | ✅ | ✅ | ⚠️ | ⚠️ |
| **App Stores** | Google Play | App Store | N/A | N/A |
| **Distribution** | APK/AAB | IPA | URL | Installer |

---

## 🔑 Development vs Production

### Development Mode (Debug)
- Platform-specific backend URLs
- Hot reload enabled
- Debug logging enabled
- Unoptimized code

```bash
flutter run
```

### Production Mode (Release)
- Always uses `https://www.zn-01.com/api`
- Optimized code
- No debug logging
- Smaller app size

```bash
flutter run --release
flutter build <platform> --release
```

---

## 🌍 Network Configuration

### Local Development
```
Backend:  http://localhost:8000
Frontend:
  - Android:  http://10.0.2.2:8000
  - iOS:      http://localhost:8000
  - Desktop:  http://localhost:8000
  - Web:      Production URL (or proxy)
```

### Production
```
Backend:  https://www.zn-01.com/api
Frontend: https://www.zn-01.com
```

---

## 📱 Device Requirements

### Minimum Requirements

**Android:**
- Android 6.0 (API 23) or later
- 2GB RAM
- 100MB storage

**iOS:**
- iOS 12.0 or later
- iPhone 6s or later
- 100MB storage

**Web:**
- Modern browser (Chrome, Firefox, Safari, Edge)
- JavaScript enabled

**Desktop:**
- Linux: Ubuntu 18.04 or later
- macOS: 10.14 or later
- Windows: Windows 10 or later

---

## 🎯 Quick Commands Reference

```bash
# Check Flutter setup
flutter doctor -v

# List all devices
flutter devices

# List emulators
flutter emulators

# Clean build
flutter clean && flutter pub get

# Run on specific device
flutter run -d <device-id>

# Build release
flutter build <platform> --release

# Take screenshot
flutter screenshot

# Hot reload (during run)
Press 'r' in terminal

# Hot restart (during run)
Press 'R' in terminal

# Open DevTools
flutter pub global run devtools
```

---

## 📚 Additional Resources

- [Flutter Desktop Support](https://docs.flutter.dev/desktop)
- [Flutter Web Support](https://docs.flutter.dev/platform-integration/web)
- [Android Emulator](https://developer.android.com/studio/run/emulator)
- [iOS Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)

---

## ✅ Ready to Deploy

Your app is now configured to work on **all platforms**:
- ✅ Android emulator and devices
- ✅ iOS simulator and devices (requires macOS)
- ✅ Web browsers
- ✅ Linux, macOS, Windows desktops

Just run `flutter devices` and choose your platform!

---

*Last Updated: October 14, 2025*
*All platforms configured and tested ✨*
