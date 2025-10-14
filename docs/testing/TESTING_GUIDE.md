# Zero World - Multi-Device Testing Guide

Complete guide for testing your Flutter app on all platforms.

## 🎯 Quick Reference

| Platform | Command | Notes |
|----------|---------|-------|
| **Android Emulator** | `./scripts/test_android.sh` | Headless mode (no GUI) |
| **Linux Desktop** | `flutter run -d linux` | Native Linux app |
| **Web (Chrome)** | `flutter run -d chrome` | Browser testing |
| **macOS** | Connect via network | Requires Flutter on Mac |
| **iOS Simulator** | Requires macOS | Not available on Linux |

---

## 📱 Android Emulator Testing

### Method 1: Automated Script (Recommended)

```bash
./scripts/test_android.sh
```

### Method 2: Manual Launch

```bash
# 1. Start emulator (headless mode - no display issues)
export QT_QPA_PLATFORM=offscreen
/home/z/Android/Sdk/emulator/emulator -avd Pixel_3a_API_34_extension_level_7_x86_64 -no-window -no-audio &

# 2. Wait for boot (20-30 seconds)
sleep 30

# 3. Verify device is ready
/home/z/Android/Sdk/platform-tools/adb devices

# 4. Run your app
cd frontend/zero_world
flutter run -d emulator-5554
```

### Troubleshooting

**Qt Platform Errors**
- Use headless mode: `-no-window -no-audio`
- Set environment: `export QT_QPA_PLATFORM=offscreen`

**Emulator Won't Start**
- Cold boot: Add `-no-snapshot-load` flag
- Check disk space: Emulator needs ~4GB
- GPU issues: Add `-gpu swiftshader_indirect`

**ADB Not Found**
```bash
# Add to ~/.zshrc
export ANDROID_HOME=/home/z/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

---

## 🖥️ Linux Desktop Testing

Test as a native Linux application:

```bash
cd frontend/zero_world

# Run on Linux
flutter run -d linux

# Build Linux release
flutter build linux --release

# Run the built app
./build/linux/x64/release/bundle/zero_world
```

**Features:**
- Native window management
- Direct localhost access (http://localhost:8000)
- Fastest hot reload
- Best for development

---

## 🌐 Web Browser Testing

Test in Chrome (production-like environment):

```bash
cd frontend/zero_world

# Run in Chrome
flutter run -d chrome

# Or with custom URL
flutter run -d chrome --web-hostname=0.0.0.0 --web-port=8080
```

**Test Different URLs:**
```bash
# Localhost
flutter run -d chrome --web-renderer html

# Your domain
# Open Chrome manually and navigate to:
# https://zn-01.com
```

**Browser Testing Checklist:**
- [ ] HTTPS certificate warning (expected with self-signed)
- [ ] Login/authentication flow
- [ ] API calls to backend
- [ ] WebSocket connections
- [ ] Responsive design (resize window)
- [ ] Mobile viewport (DevTools: Ctrl+Shift+M)

---

## 🍎 macOS Testing

Since you want to test on Mac, you have several options:

### Option 1: Network Testing (Web)

From your Mac:
1. Open Safari/Chrome
2. Navigate to: `https://zn-01.com`
3. Accept certificate warning
4. Test the web app

### Option 2: Flutter Development (Requires Setup)

On your Mac:
```bash
# 1. Install Flutter on Mac
# Follow: https://docs.flutter.io/get-started/install/macos

# 2. Clone your repo
git clone https://github.com/00-01/zero_world.git
cd zero_world/frontend/zero_world

# 3. Run on macOS desktop
flutter run -d macos

# 4. Or build macOS app
flutter build macos --release
```

### Option 3: SSH + X11 Forwarding

Run Linux app with display on Mac:
```bash
# On Mac, install XQuartz first
# Then SSH with X11:
ssh -X z@your-linux-ip

# On Linux, run:
cd /home/z/zero_world/frontend/zero_world
flutter run -d linux
```

---

## 📲 iOS Simulator Testing

**Note:** iOS development requires macOS. Cannot run on Linux.

On macOS:
```bash
# List simulators
xcrun simctl list devices

# Boot a simulator
open -a Simulator

# Run your app
cd zero_world/frontend/zero_world
flutter run -d ios
```

---

## 🔧 Testing Scripts

### Complete Android Test Script

Save as `scripts/test_android.sh`:

```bash
#!/bin/bash
set -e

echo "🤖 Starting Android Emulator (Headless Mode)..."

# Kill any existing emulators
pkill -f "emulator-5554" 2>/dev/null || true

# Start emulator
export QT_QPA_PLATFORM=offscreen
/home/z/Android/Sdk/emulator/emulator \
  -avd Pixel_3a_API_34_extension_level_7_x86_64 \
  -no-window \
  -no-audio \
  -no-snapshot-load \
  -gpu swiftshader_indirect &

EMULATOR_PID=$!

echo "⏳ Waiting for emulator to boot..."
sleep 5

# Wait for device to be online
for i in {1..60}; do
  DEVICE=$(/home/z/Android/Sdk/platform-tools/adb devices | grep "emulator-5554.*device" | wc -l)
  if [ "$DEVICE" -eq 1 ]; then
    echo "✅ Emulator is ready!"
    break
  fi
  echo -n "."
  sleep 2
done

echo ""
echo "📱 Connected devices:"
/home/z/Android/Sdk/platform-tools/adb devices -l

echo ""
echo "🚀 Launching Zero World app..."
cd /home/z/zero_world/frontend/zero_world
flutter run -d emulator-5554

# Cleanup on exit
echo ""
echo "🧹 Cleaning up..."
kill $EMULATOR_PID 2>/dev/null || true
```

### Multi-Platform Test Script

Save as `scripts/test_all_platforms.sh`:

```bash
#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Zero World - Multi-Platform Test Suite   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

cd "$(dirname "$0")/../frontend/zero_world"

echo -e "${YELLOW}Select test platform:${NC}"
echo "  1) Android Emulator (headless)"
echo "  2) Linux Desktop"
echo "  3) Chrome Web Browser"
echo "  4) All Available Devices"
echo "  5) List Devices Only"
echo ""
read -p "Choice [1-5]: " choice

case $choice in
  1)
    echo -e "${GREEN}🤖 Testing on Android Emulator${NC}"
    ../scripts/test_android.sh
    ;;
  2)
    echo -e "${GREEN}🖥️  Testing on Linux Desktop${NC}"
    flutter run -d linux
    ;;
  3)
    echo -e "${GREEN}🌐 Testing on Chrome${NC}"
    flutter run -d chrome --web-hostname=0.0.0.0 --web-port=8080
    ;;
  4)
    echo -e "${GREEN}🎯 Testing on all available devices${NC}"
    flutter devices
    echo ""
    read -p "Press Enter to start testing..."
    flutter run
    ;;
  5)
    echo -e "${GREEN}📱 Available devices:${NC}"
    flutter devices
    ;;
  *)
    echo -e "${YELLOW}Invalid choice${NC}"
    exit 1
    ;;
esac
```

---

## 🧪 Testing Checklist

### Core Functionality
- [ ] App launches successfully
- [ ] Backend connection works (http://10.0.2.2:8000 on Android, http://localhost:8000 on Linux/Mac)
- [ ] Login/authentication
- [ ] Navigation between screens
- [ ] Real-time updates (WebSockets)

### Platform-Specific Tests

**Android:**
- [ ] Permissions (camera, location, etc.)
- [ ] Back button behavior
- [ ] App lifecycle (background/foreground)
- [ ] Different screen sizes (tablet mode: `emulator -avd <name> -scale 0.5`)

**Linux Desktop:**
- [ ] Window resizing
- [ ] Keyboard shortcuts
- [ ] Native file picker
- [ ] Multi-window support

**Web:**
- [ ] CORS handling
- [ ] Browser back/forward
- [ ] Responsive breakpoints (mobile, tablet, desktop)
- [ ] HTTPS certificate
- [ ] Different browsers (Chrome, Firefox, Safari)

**macOS:**
- [ ] Native menu bar
- [ ] Keyboard shortcuts (Cmd vs Ctrl)
- [ ] Touch Bar support (if applicable)
- [ ] App notarization (for distribution)

---

## 🐛 Common Issues

### Issue: "No devices found"
```bash
# Check Flutter can see devices
flutter devices

# Enable USB debugging on physical device
# Or start emulator first
```

### Issue: "Connection refused" to backend
```bash
# Android emulator uses special IP for host machine
# Update API base URL:
# - Android: http://10.0.2.2:8000
# - iOS Simulator: http://localhost:8000
# - Linux/Mac: http://localhost:8000
# - Web: https://zn-01.com/api
```

### Issue: Hot reload not working
```bash
# Do full restart: Press 'R' in terminal
# Or restart app: Press 'q' then re-run
```

### Issue: Gradle build fails (Android)
```bash
cd frontend/zero_world/android
./gradlew clean
cd ../..
flutter clean
flutter pub get
flutter run
```

---

## 📊 Performance Testing

### Enable Performance Overlay
```bash
# Shows FPS, GPU usage, etc.
flutter run --profile -d <device>

# Then press 'P' in terminal
```

### Build Profiles
```bash
# Debug (default, slow, hot reload)
flutter run

# Profile (optimized, good for testing performance)
flutter run --profile

# Release (fully optimized, no debugging)
flutter run --release
```

### Measure App Size
```bash
# Android
flutter build apk --release --analyze-size
flutter build appbundle --release --analyze-size

# iOS
flutter build ios --release --analyze-size

# Linux
flutter build linux --release
du -sh build/linux/x64/release/bundle/

# Web
flutter build web --release
du -sh build/web/
```

---

## 🚀 Quick Commands

```bash
# Show all devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# List available emulators
flutter emulators

# Create new emulator
flutter emulators --create --name my_emulator

# Hot reload (during run)
# Press 'r' in terminal

# Hot restart (during run)
# Press 'R' in terminal

# Take screenshot
flutter screenshot

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 📱 Testing on Physical Devices

### Android Phone/Tablet
```bash
# 1. Enable Developer Options on phone
# Settings → About → Tap "Build Number" 7 times

# 2. Enable USB Debugging
# Settings → Developer Options → USB Debugging

# 3. Connect via USB

# 4. Verify connection
/home/z/Android/Sdk/platform-tools/adb devices

# 5. Run app
cd frontend/zero_world
flutter run
```

### Wireless Testing (Android)
```bash
# 1. Connect via USB first
# 2. Get device IP (Settings → About → Status)
# 3. Enable TCP/IP mode
/home/z/Android/Sdk/platform-tools/adb tcpip 5555

# 4. Connect wirelessly
/home/z/Android/Sdk/platform-tools/adb connect <device-ip>:5555

# 5. Disconnect USB, run app
flutter run
```

### iOS Device (Requires Mac)
```bash
# 1. Connect iPhone/iPad via USB
# 2. Trust computer on device
# 3. Run app
flutter run
```

---

## 🌍 Network Testing

Test your app from different devices on same network:

### Backend Access
```bash
# Find your Linux machine's IP
ip addr show | grep "inet " | grep -v 127.0.0.1

# Let's say it's 192.168.1.100
# Other devices can access:
# http://192.168.1.100:8000 (if ports open)
```

### Update API URLs for Network Testing
In `lib/services/api_service.dart` or config:
```dart
// For network testing
static const String baseUrl = 'http://192.168.1.100:8000';

// For production
static const String baseUrl = 'https://zn-01.com/api';

// For Android emulator
static const String baseUrl = 'http://10.0.2.2:8000';
```

---

## 📚 Additional Resources

- [Flutter Desktop Support](https://docs.flutter.dev/desktop)
- [Flutter Web Support](https://docs.flutter.dev/platform-integration/web)
- [Android Emulator Guide](https://developer.android.com/studio/run/emulator-commandline)
- [iOS Simulator Guide](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)

---

## 🎯 Next Steps

1. **Android Testing** (In Progress)
   - ✅ Emulator is running (headless mode)
   - ⏳ App is building (first build takes ~3-5 minutes)
   - Next: Test features, take screenshots

2. **Linux Desktop Testing**
   ```bash
   flutter run -d linux
   ```

3. **Web Testing**
   ```bash
   flutter run -d chrome
   # Or visit: https://zn-01.com
   ```

4. **macOS Testing**
   - Option A: Test web version on Mac browser
   - Option B: Install Flutter on Mac, run native app

5. **Create Test Report**
   - Document issues found on each platform
   - Screenshot differences
   - Performance metrics

---

*Last Updated: October 13, 2025*
*Current Status: Android emulator running, app building...*
