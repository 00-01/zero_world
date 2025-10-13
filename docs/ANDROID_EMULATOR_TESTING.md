# 📱 Testing Zero World on Android Emulator

**Guide for testing your Flutter app on virtual Android devices**

---

## 🚀 Quick Start

### Prerequisites
- ✅ Flutter installed (you have 3.35.2)
- ✅ Android Studio or Android SDK
- ⏳ Android Emulator setup (we'll do this)

### Fast Track (5 minutes)
```bash
cd /home/z/zero_world/frontend/zero_world

# 1. Check if emulator is available
flutter emulators

# 2. Launch an emulator
flutter emulators --launch <emulator_id>

# 3. Run your app
flutter run
```

---

## 📋 Step-by-Step Setup

### Step 1: Check Flutter Doctor

```bash
flutter doctor -v
```

This will show if Android toolchain is installed and configured.

**Expected output:**
```
✓ Flutter (Channel stable, 3.35.2)
✓ Android toolchain - develop for Android devices
✓ Android Studio (version X.X)
```

If Android toolchain is missing, you'll need to install Android Studio.

---

### Step 2: Install Android Studio (if needed)

#### On Linux:
```bash
# Download Android Studio
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.28/android-studio-2023.1.1.28-linux.tar.gz

# Extract
tar -xzf android-studio-*.tar.gz -C ~/

# Run Android Studio
~/android-studio/bin/studio.sh
```

During setup:
1. Choose "Standard" installation
2. Accept license agreements
3. Let it download SDK components

#### Alternative: Command Line Tools Only
```bash
# Install SDK command line tools
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk

# Download command line tools
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-*.zip
```

---

### Step 3: Configure Flutter for Android

```bash
# Set Android SDK path
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Add to ~/.zshrc for permanent setup
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc

# Accept Android licenses
flutter doctor --android-licenses
```

---

### Step 4: Create Virtual Device

#### Option A: Using Android Studio (Recommended)
1. Open Android Studio
2. Go to **Tools** → **Device Manager** (or AVD Manager)
3. Click **Create Virtual Device**
4. Choose device: **Pixel 5** or **Pixel 7** (recommended)
5. Select system image: **API 33** (Android 13) or **API 34** (Android 14)
6. Click **Download** if needed
7. Name it: "Pixel_5_API_33"
8. Click **Finish**

#### Option B: Using Command Line
```bash
# List available system images
sdkmanager --list | grep system-images

# Download system image (API 33 - Android 13)
sdkmanager "system-images;android-33;google_apis_playstore;x86_64"

# Create AVD
avdmanager create avd -n Pixel_5_API_33 \
  -k "system-images;android-33;google_apis_playstore;x86_64" \
  -d "pixel_5"
```

---

### Step 5: List Available Emulators

```bash
cd /home/z/zero_world/frontend/zero_world

# List all emulators
flutter emulators

# Should show something like:
# 2 available emulators:
#
# Pixel_5_API_33 • Pixel 5 API 33 • Google • android
# Pixel_7_API_34 • Pixel 7 API 34 • Google • android
```

---

### Step 6: Launch Emulator

#### Method 1: Using Flutter Command
```bash
# Launch specific emulator
flutter emulators --launch Pixel_5_API_33

# Or just launch any available
flutter emulators --launch $(flutter emulators | grep -o '^[^ ]*' | tail -1)
```

#### Method 2: Using Android Studio
1. Open Android Studio
2. Click **Device Manager** icon
3. Click ▶️ play button next to your device

#### Method 3: Direct Command
```bash
# Start emulator directly
emulator -avd Pixel_5_API_33 &
```

**Wait for emulator to fully boot** (30-60 seconds)

---

### Step 7: Run Your App

```bash
cd /home/z/zero_world/frontend/zero_world

# Check connected devices
flutter devices

# Should show:
# Android SDK built for x86 64 (mobile) • emulator-5554 • android-x64 • Android 13 (API 33)

# Run app in debug mode
flutter run

# Or specify device
flutter run -d emulator-5554

# For release build
flutter run --release
```

---

## 🎯 Complete Testing Script

Save this as `scripts/test_android.sh`:

```bash
#!/bin/bash

echo "🤖 Zero World - Android Emulator Test"
echo "======================================"
echo ""

cd /home/z/zero_world/frontend/zero_world

# Check Flutter setup
echo "📋 Checking Flutter setup..."
flutter doctor

echo ""
echo "📱 Available emulators:"
flutter emulators

echo ""
read -p "Enter emulator ID (or press Enter for default): " EMULATOR_ID

if [ -z "$EMULATOR_ID" ]; then
    EMULATOR_ID=$(flutter emulators | grep -o '^[^ ]*' | tail -1)
fi

echo ""
echo "🚀 Launching emulator: $EMULATOR_ID"
flutter emulators --launch "$EMULATOR_ID" &

echo ""
echo "⏳ Waiting for emulator to boot (30 seconds)..."
sleep 30

echo ""
echo "📱 Connected devices:"
flutter devices

echo ""
echo "🏃 Running Zero World app..."
flutter run

echo ""
echo "✅ Done!"
```

Make it executable:
```bash
chmod +x /home/z/zero_world/scripts/test_android.sh
```

---

## 🛠️ Troubleshooting

### Issue 1: No Android SDK Found

**Error:**
```
✗ Android toolchain - develop for Android devices
  ✗ Unable to locate Android SDK
```

**Solution:**
```bash
# Install Android Studio or command line tools
# Then set ANDROID_HOME
export ANDROID_HOME=$HOME/Android/Sdk
flutter doctor --android-licenses
```

### Issue 2: Emulator Won't Start

**Error:**
```
emulator: ERROR: x86_64 emulation currently requires hardware acceleration!
```

**Solution:**
```bash
# Check if KVM is enabled (Linux)
egrep -c '(vmx|svm)' /proc/cpuinfo
# If 0, virtualization is disabled in BIOS

# Enable KVM
sudo apt install qemu-kvm
sudo adduser $USER kvm
# Reboot
```

### Issue 3: Emulator is Slow

**Solution:**
```bash
# Use x86_64 images (faster)
# Enable hardware acceleration
# Allocate more RAM in AVD settings (4GB+)
# Use API 30-33 (not too new, not too old)
```

### Issue 4: Flutter Can't Find Emulator

**Solution:**
```bash
# Check ADB connection
adb devices

# Restart ADB
adb kill-server
adb start-server

# Check again
flutter devices
```

### Issue 5: App Won't Install

**Error:**
```
Error: ADB exited with exit code 1
```

**Solution:**
```bash
# Clean build
cd /home/z/zero_world/frontend/zero_world
flutter clean
flutter pub get

# Try again
flutter run
```

---

## 🎨 Emulator Recommendations

### For Development Testing:
- **Device:** Pixel 5 or Pixel 6
- **API Level:** 33 (Android 13) - Good balance
- **Architecture:** x86_64 (faster on Intel/AMD)
- **RAM:** 2-4 GB
- **Storage:** 8 GB

### For Production Testing:
- **Device:** Various (Pixel 5, Samsung Galaxy S21, etc.)
- **API Levels:** 
  - Min: API 21 (Android 5.0) - Your app's minimum
  - Target: API 33-34 (Android 13-14)
- **Screen sizes:** Phone and Tablet

---

## 🔧 Emulator Controls

### Keyboard Shortcuts:
- **Power:** Power button
- **Volume:** Ctrl + Up/Down
- **Back:** Backspace
- **Home:** Home key
- **Rotate:** Ctrl + Left/Right
- **Screenshot:** Ctrl + S

### Emulator Toolbar:
- 📱 Power button
- 🔊 Volume controls
- 🔄 Rotate screen
- 📸 Take screenshot
- ⚙️ Extended controls (GPS, Network, etc.)

---

## 📊 Performance Tips

### Speed Up Emulator:
1. **Use x86_64 images** (not ARM)
2. **Enable hardware acceleration**
3. **Allocate 4GB RAM** minimum
4. **Use SSD** for Android SDK
5. **Close other apps** when testing
6. **Use snapshot** (Quick Boot) feature

### Flutter Hot Reload:
```bash
# While app is running, press:
r  # Hot reload
R  # Hot restart
h  # Help
q  # Quit
```

---

## 📱 Testing Checklist

Once app is running, test:

- [ ] App launches without errors
- [ ] UI renders correctly
- [ ] Navigation works
- [ ] Images load
- [ ] Icons display properly
- [ ] Forms work
- [ ] API calls succeed
- [ ] Rotation works (portrait/landscape)
- [ ] Back button works
- [ ] Performance is acceptable

---

## 🚀 Next Steps After Testing

### Build Release APK:
```bash
cd /home/z/zero_world/frontend/zero_world

# Build release APK
flutter build apk --release

# Install on emulator
flutter install
```

### Build App Bundle (for Play Store):
```bash
# Build AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 📚 Useful Commands Reference

```bash
# Flutter commands
flutter devices                    # List devices
flutter emulators                  # List emulators
flutter emulators --launch <id>   # Launch emulator
flutter run                        # Run app
flutter run --release             # Release mode
flutter install                    # Install on device
flutter clean                      # Clean build

# ADB commands
adb devices                        # List connected devices
adb install app.apk               # Install APK
adb uninstall com.example.app     # Uninstall app
adb logcat                        # View logs
adb shell                         # Device shell

# Emulator commands
emulator -list-avds               # List virtual devices
emulator -avd <name>              # Start emulator
emulator -avd <name> -no-snapshot # Start without snapshot
```

---

## 🎯 Quick Command Summary

```bash
# The essentials:
cd /home/z/zero_world/frontend/zero_world
flutter emulators                          # 1. Check emulators
flutter emulators --launch Pixel_5_API_33 # 2. Launch one
flutter run                                # 3. Run your app!
```

---

## 💡 Pro Tips

1. **Use Hot Reload** - Make code changes and press `r` for instant updates
2. **Keep Emulator Running** - Don't close it between tests
3. **Use Snapshots** - Quick Boot saves emulator state
4. **Multiple Emulators** - Test on different devices/API levels
5. **Real Device Better** - For final testing, use real Android phone

---

## 📞 Need Help?

### Check Status:
```bash
flutter doctor -v                 # Detailed diagnostics
flutter devices                   # See connected devices
adb devices                      # See ADB connections
```

### Common Issues:
- **No emulators:** Create one in Android Studio
- **Emulator won't start:** Check KVM/virtualization
- **App won't run:** Try `flutter clean` then `flutter run`
- **Slow performance:** Use x86_64 images, enable acceleration

---

**Ready to test! 🚀**

Your Zero World app should run perfectly on the Android emulator. The Flutter framework handles all the platform-specific details automatically!
