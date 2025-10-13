# Mobile App Deployment Guide
## Publishing Zero World to Google Play Store & Apple App Store

---

## 📱 Overview

Your Zero World app is built with **Flutter**, which supports building native apps for both Android and iOS from a single codebase. This guide covers the complete process for publishing to both app stores.

---

## 🏗️ Phase 1: Build Configuration

### Android (Google Play Store)

#### 1.1 Configure App Identity

Edit `frontend/zero_world/android/app/build.gradle`:

```gradle
android {
    namespace "com.zeroworld.app"  // Your package name
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.zeroworld.app"  // Unique app identifier
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1      // Increment for each release
        versionName "1.0.0"  // User-visible version
    }
}
```

#### 1.2 Create App Signing Key

```bash
cd frontend/zero_world
keytool -genkey -v -keystore ~/zero-world-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias zero-world-key
```

Create `android/key.properties`:
```properties
storePassword=<password-from-previous-step>
keyPassword=<password-from-previous-step>
keyAlias=zero-world-key
storeFile=/home/z/zero-world-release-key.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 1.3 Build Android App Bundle

```bash
cd frontend/zero_world
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Apple App Store)

#### 2.1 Requirements
- **Mac computer** (required for iOS builds)
- **Apple Developer Account** ($99/year)
- **Xcode** (latest version from Mac App Store)

#### 2.2 Configure App Identity

Edit `frontend/zero_world/ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.zeroworld.app</string>
<key>CFBundleName</key>
<string>Zero World</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

#### 2.3 Set Up in Xcode (on Mac)

```bash
cd frontend/zero_world
open ios/Runner.xcworkspace
```

In Xcode:
1. Select Runner → Signing & Capabilities
2. Select your Team (Apple Developer Account)
3. Set Bundle Identifier: `com.zeroworld.app`
4. Ensure "Automatically manage signing" is checked

#### 2.4 Build iOS App

```bash
cd frontend/zero_world
flutter build ipa --release
```

Output: `build/ios/ipa/zero_world.ipa`

---

## 📝 Phase 2: App Store Requirements

### Google Play Store

#### 3.1 Create Google Play Console Account
- Go to https://play.google.com/console
- Pay one-time $25 registration fee
- Complete account verification

#### 3.2 Required Assets

**App Icon**
- 512x512 PNG (32-bit with alpha)
- High-resolution icon

**Screenshots** (per device type)
- Phone: At least 2 screenshots (minimum 320px on short side)
- 7-inch Tablet: At least 2 screenshots
- 10-inch Tablet: At least 2 screenshots

**Feature Graphic**
- 1024x500 PNG or JPEG
- Showcases your app in Play Store

**Store Listing**
- App name: "Zero World"
- Short description (80 chars max)
- Full description (4000 chars max)
- Category: Social / Marketplace / Communication
- Content rating questionnaire
- Privacy policy URL (required)

#### 3.3 App Content

Create `frontend/zero_world/android/app/src/main/res/values/strings.xml`:
```xml
<resources>
    <string name="app_name">Zero World</string>
</resources>
```

#### 3.4 Privacy Policy
Required URL: `https://zn-01.com/privacy-policy`

Create privacy policy covering:
- Data collection practices
- How user data is used
- Third-party services
- User rights
- Contact information

### Apple App Store

#### 4.1 Create App Store Connect Account
- Go to https://appstoreconnect.apple.com
- Requires Apple Developer Program membership ($99/year)

#### 4.2 Required Assets

**App Icon**
- 1024x1024 PNG (no transparency)
- For App Store listing

**Screenshots** (per device size)
- iPhone 6.7": 1290x2796 (at least 3)
- iPhone 6.5": 1242x2688 (at least 3)
- iPhone 5.5": 1242x2208 (at least 3)
- iPad Pro 12.9": 2048x2732 (at least 3)

**App Preview Videos** (optional but recommended)
- 15-30 seconds
- Show key features

**Store Listing**
- App name: "Zero World"
- Subtitle (30 chars max)
- Description (4000 chars max)
- Keywords (100 chars, comma-separated)
- Category: Social Networking / Shopping / Business
- Content rating
- Privacy policy URL

#### 4.3 App Review Information
- Demo account credentials (if login required)
- Notes for reviewer
- Contact information

---

## 🚀 Phase 3: Submission Process

### Google Play Store Submission

```bash
# 1. Build release AAB
cd frontend/zero_world
flutter build appbundle --release

# 2. Test locally first
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

**In Google Play Console:**
1. Create new app
2. Upload AAB file (`app-release.aab`)
3. Complete store listing
4. Set up pricing & distribution
5. Complete content rating
6. Add privacy policy
7. Submit for review

**Review Time:** 1-7 days

### Apple App Store Submission

```bash
# 1. Build release IPA (on Mac)
cd frontend/zero_world
flutter build ipa --release

# 2. Upload to App Store Connect
open build/ios/ipa
# Use Transporter app or Xcode to upload
```

**In App Store Connect:**
1. Create new app
2. Upload IPA using Transporter or Xcode
3. Complete app information
4. Add screenshots and preview
5. Set pricing
6. Add privacy policy
7. Submit for review

**Review Time:** 24-48 hours (usually)

---

## 🔧 Phase 4: Configuration Changes

### Update API Endpoint

Edit `frontend/zero_world/lib/services/api_service.dart`:

```dart
class ApiService {
  // Use production API for mobile apps
  static const String baseUrl = 'https://zn-01.com/api';
  
  // For testing, use:
  // static const String baseUrl = 'https://test.zn-01.com/api';
}
```

### Configure Deep Links

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" 
          android:host="zn-01.com" />
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>zeroworld</string>
        </array>
    </dict>
</array>
```

### Add Internet Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

**iOS** - Already has network access by default

---

## 📊 Phase 5: Post-Launch

### Analytics & Monitoring

Add Firebase for both platforms:
```bash
cd frontend/zero_world
flutterfire configure
```

### Crash Reporting

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
  firebase_analytics: ^10.7.0
```

### Updates

**Android:**
- Increment `versionCode` and `versionName`
- Build new AAB
- Upload to Google Play Console

**iOS:**
- Increment `CFBundleVersion` and `CFBundleShortVersionString`
- Build new IPA
- Upload to App Store Connect

---

## 🎯 Quick Start Commands

### Build Both Platforms

```bash
cd frontend/zero_world

# Android Release
flutter build appbundle --release

# iOS Release (on Mac only)
flutter build ipa --release

# Test builds
flutter build apk --release  # Android APK for testing
flutter build ios --release  # iOS build for testing
```

### Test on Real Devices

```bash
# Android
flutter run --release -d <android-device-id>

# iOS (on Mac)
flutter run --release -d <ios-device-id>
```

---

## 📋 Pre-Launch Checklist

### Both Platforms
- [ ] App name finalized
- [ ] Package/Bundle ID registered
- [ ] App icons created (all sizes)
- [ ] Screenshots captured (all sizes)
- [ ] Privacy policy published
- [ ] API endpoints configured for production
- [ ] SSL certificates properly configured
- [ ] Terms of service created
- [ ] Support email/website configured
- [ ] Analytics integrated
- [ ] Crash reporting enabled

### Android Specific
- [ ] Signing key generated and secured
- [ ] `key.properties` configured
- [ ] Google Play Console account created
- [ ] Feature graphic created
- [ ] Content rating completed
- [ ] Target API level meets requirements (34+)

### iOS Specific
- [ ] Apple Developer account active
- [ ] Provisioning profiles configured
- [ ] App Store Connect app created
- [ ] TestFlight testing completed
- [ ] Export compliance information provided
- [ ] Xcode signing configured

---

## 💰 Cost Summary

| Item | Cost | Frequency |
|------|------|-----------|
| Google Play Developer Account | $25 | One-time |
| Apple Developer Program | $99 | Annual |
| Domain (zn-01.com) | ~$10-15 | Annual |
| SSL Certificate (Let's Encrypt) | Free | Auto-renew |
| Server Hosting | Varies | Monthly |

**Total Initial Investment:** $124 (+ hosting costs)
**Annual Renewal:** $99 (Apple) + $15 (domain) = ~$114/year

---

## 🆘 Support & Resources

### Official Documentation
- Flutter: https://docs.flutter.dev/deployment
- Google Play: https://developer.android.com/distribute
- Apple App Store: https://developer.apple.com/app-store/

### Community
- Flutter Dev Community: https://flutter.dev/community
- Stack Overflow: flutter tag
- Reddit: r/FlutterDev

### Tools
- App Icon Generator: https://appicon.co/
- Screenshot Generator: https://www.screely.com/
- Privacy Policy Generator: https://www.privacypolicygenerator.info/

---

## 🎓 Next Steps

1. **Week 1-2:** Set up developer accounts, create assets
2. **Week 3:** Build and test release versions locally
3. **Week 4:** Submit to stores and wait for approval
4. **Week 5+:** Monitor feedback, iterate, update

**Estimated Time to Launch:** 4-6 weeks (first submission)

---

*Last updated: October 13, 2025*
