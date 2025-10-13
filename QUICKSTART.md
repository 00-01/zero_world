# 🚀 Quick Start: Deploy & Test on All Devices

## Immediate Testing (Available Now)

### 1. Web Browser (Fastest - No Setup)
```bash
cd /home/z/zero_world/frontend/zero_world
flutter run -d chrome
# Opens app in Chrome browser
# Visit: http://localhost:XXXXX
```

### 2. Linux Desktop (Current System)
```bash
cd /home/z/zero_world/frontend/zero_world
flutter run -d linux
# Runs as native desktop app
```

### 3. Android Emulator
```bash
# Start available emulator
flutter emulators --launch Pixel_3a_API_34_extension_level_7_x86_64

# Run app
cd /home/z/zero_world/frontend/zero_world
flutter run
# Select emulator when prompted
```

---

## Automated Build & Test

### Test All Available Platforms
```bash
cd /home/z/zero_world
./scripts/test_all_platforms.sh
```

This will:
- ✅ Run unit tests
- ✅ Analyze code
- ✅ Build Web version
- ✅ Build Android APK
- ✅ Build Linux desktop
- ✅ Show available devices
- ✅ Option to run on Linux desktop

### Deploy All Platforms
```bash
cd /home/z/zero_world
./scripts/deploy_all.sh 1.0.0
```

This will:
- ✅ Build Web (production)
- ✅ Build Android APKs (arm64, arm32, x86_64)
- ✅ Build Android App Bundle (.aab for Play Store)
- ✅ Build Linux desktop binary
- ✅ Deploy Web to https://zn-01.com
- ✅ Generate checksums
- ✅ Create deployment log

---

## Platform-by-Platform Testing

### 🌐 Web
```bash
# Development
flutter run -d chrome

# Production build
flutter build web --release
# Open: build/web/index.html

# Deploy to production
cd /home/z/zero_world
cp -r frontend/zero_world/build/web/* nginx/www/
docker-compose up -d --build nginx
# Visit: https://zn-01.com
```

### 📱 Android

#### Option A: Emulator
```bash
# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch Pixel_3a_API_34_extension_level_7_x86_64

# Run app
flutter run
```

#### Option B: Physical Device
```bash
# Enable USB debugging on phone
# Connect via USB
adb devices

# Run app
flutter run
```

#### Option C: Build APK
```bash
# Build release APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 🐧 Linux Desktop
```bash
# Run directly
flutter run -d linux

# Build release binary
flutter build linux --release

# Run binary
./build/linux/x64/release/bundle/zero_world
```

### 🍎 iOS (Requires Mac)
```bash
# On Mac computer
flutter run -d <ios-device>

# Build for App Store
flutter build ios --release
open ios/Runner.xcworkspace
```

### 🪟 Windows (Requires Windows)
```bash
# On Windows computer
flutter run -d windows

# Build release
flutter build windows --release
```

### 🍏 macOS (Requires Mac)
```bash
# On Mac computer
flutter run -d macos

# Build release
flutter build macos --release
```

---

## Current Device Status

Run this to see what's available:
```bash
flutter devices
```

Expected output:
```
Found 2 connected devices:
  Linux (desktop) • linux  • linux-x64      • Ubuntu 22.04.5 LTS
  Chrome (web)    • chrome • web-javascript • Google Chrome 139
```

---

## Build Output Locations

After running builds, find files here:

```
zero_world/frontend/zero_world/
├── build/
│   ├── web/                    # 🌐 Web build
│   │   ├── index.html
│   │   └── main.dart.js
│   ├── app/outputs/flutter-apk/
│   │   ├── app-release.apk     # 📱 Android APK
│   │   └── app-*.apk           # Split APKs per architecture
│   ├── app/outputs/bundle/
│   │   └── app-release.aab     # 📦 Android App Bundle (Play Store)
│   └── linux/x64/release/bundle/
│       └── zero_world          # 🐧 Linux executable
└── builds/                     # After running deploy_all.sh
    ├── web-YYYYMMDD_HHMMSS/
    ├── android/
    ├── linux-YYYYMMDD_HHMMSS/
    ├── checksums-*.txt
    └── deployment-*.log
```

---

## Testing Matrix

| Platform | Status | Command | Output |
|----------|--------|---------|--------|
| **Web** | ✅ Ready | `flutter run -d chrome` | Browser |
| **Android Emulator** | ✅ Ready | `flutter run` | Emulator |
| **Android Device** | ⏳ Need device | `flutter run -d <device>` | Phone |
| **Linux** | ✅ Ready | `flutter run -d linux` | Desktop |
| **iOS** | ⏳ Need Mac | `flutter run -d ios` | iPhone |
| **Windows** | ⏳ Need Windows | `flutter run -d windows` | Desktop |
| **macOS** | ⏳ Need Mac | `flutter run -d macos` | Desktop |

---

## Performance Testing

### Web Performance
```bash
# Run Lighthouse audit
npm install -g lighthouse
lighthouse https://zn-01.com --view

# Target scores:
# - Performance: > 90
# - Accessibility: > 95
# - Best Practices: > 90
# - SEO: > 90
```

### Android Performance
```bash
# Profile mode (performance monitoring)
flutter run --profile

# Release mode (production performance)
flutter run --release

# Open DevTools for profiling
flutter pub global activate devtools
flutter pub global run devtools
```

### Desktop Performance
```bash
# Run with performance overlay
flutter run -d linux --release --enable-profiling
```

---

## Distribution

### Web (Production)
✅ **Currently deployed**: https://zn-01.com
- Nginx + Docker
- SSL/TLS enabled
- Auto-renewed certificates

### Android
- 📦 **Google Play Store**: Upload `app-release.aab`
- 📱 **Direct Install**: Share `app-release.apk`
- 🔗 **Website Download**: Host APK on zn-01.com

### iOS
- 🍎 **App Store**: Submit via Xcode
- 🧪 **TestFlight**: Beta testing platform
- 🔒 **Enterprise**: In-house distribution

### Linux
- 📦 **Snap Store**: `snapcraft upload`
- 📦 **Debian Package**: `.deb` file
- 🐧 **AppImage**: Portable executable
- ⬇️ **Direct Download**: `.tar.gz` archive

### Windows
- 🪟 **Microsoft Store**: Submit MSIX
- 📥 **Direct Download**: Installer `.exe`
- 📦 **Portable**: Zip archive

### macOS
- 🍏 **Mac App Store**: Submit via Xcode
- 📥 **Direct Download**: `.dmg` installer

---

## Quick Commands

```bash
# Test everything available
./scripts/test_all_platforms.sh

# Build and deploy all
./scripts/deploy_all.sh 1.0.0

# Just run on current system
cd frontend/zero_world && flutter run

# Check what devices are available
flutter devices

# See available emulators
flutter emulators

# Check Flutter setup
flutter doctor -v

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

---

## Troubleshooting

### App won't run
```bash
flutter clean
flutter pub get
flutter run
```

### Can't find devices
```bash
flutter doctor -v
adb devices
flutter emulators
```

### Build fails
```bash
flutter clean
flutter pub get
flutter build <platform> --release
```

### Backend not accessible
```bash
# Check backend is running
docker-compose ps

# Restart backend
docker-compose restart backend

# Check logs
docker-compose logs -f backend
```

---

## Next Steps

1. **✅ Test locally**: Run `./scripts/test_all_platforms.sh`
2. **✅ Deploy Web**: Already at https://zn-01.com
3. **📱 Test Android**: Install APK on device
4. **🏪 Submit to stores**: Google Play, App Store
5. **📊 Monitor**: Analytics, crash reports, user feedback

---

**Status**: ✅ Ready to test on Web, Android, and Linux  
**Production**: ✅ Web deployed at https://zn-01.com  
**Next**: Run `./scripts/test_all_platforms.sh`
