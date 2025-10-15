# 📱 Zero World - App Store Publishing Quick Guide

## What You Need

### For Both Stores
1. ✅ **Flutter app** (already built)
2. ✅ **Backend API** (running at zn-01.com)
3. ✅ **Privacy Policy** (docs/PRIVACY_POLICY.md)
4. ✅ **Terms of Service** (docs/TERMS_OF_SERVICE.md)
5. ⚠️ **App Icons** (create 512x512 and 1024x1024 versions)
6. ⚠️ **Screenshots** (capture from devices)
7. ⚠️ **Store descriptions** (write compelling copy)

### Google Play Store Only
- 💰 **$25** one-time developer registration fee
- 🔑 **App signing key** (generate with keytool)
- 📦 **AAB file** (Android App Bundle)

### Apple App Store Only
- 💰 **$99/year** Apple Developer Program
- 💻 **Mac computer** (required for iOS builds)
- 🍎 **Xcode** (latest version)
- 📱 **IPA file** (iOS app package)

---

## Step-by-Step Process

### Phase 1: Prepare Assets (Week 1-2)

#### 1. Create App Icons
- **For Android**: 512x512 PNG
- **For iOS**: 1024x1024 PNG (no transparency)
- Use online tools like https://appicon.co/

#### 2. Capture Screenshots
**Android (minimum):**
- Phone: 2+ screenshots
- 7" tablet: 2+ screenshots  
- 10" tablet: 2+ screenshots

**iOS (minimum):**
- iPhone 6.7": 3+ screenshots (1290x2796)
- iPhone 6.5": 3+ screenshots (1242x2688)
- iPad Pro: 3+ screenshots (2048x2732)

#### 3. Write Store Listings
- **App name**: Zero World
- **Short description** (80 chars): "Your all-in-one super app for life"
- **Full description** (4000 chars): Highlight all features
- **Keywords**: social, marketplace, chat, delivery, etc.

#### 4. Create Privacy Policy & Terms URLs
- Privacy: `https://zn-01.com/privacy-policy`
- Terms: `https://zn-01.com/terms-of-service`

*(Need to serve these from your web server)*

---

### Phase 2: Configure & Build (Week 2-3)

#### For Android

**1. Update App Configuration**
```bash
cd /home/z/zero_world/frontend/zero_world
```

Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.zeroworld.app"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
}
```

**2. Generate Signing Key**
```bash
keytool -genkey -v -keystore ~/zero-world-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias zero-world-key
```

**3. Configure Signing**
Create `android/key.properties`:
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=zero-world-key
storeFile=/home/z/zero-world-release-key.jks
```

**4. Build Release AAB**
```bash
./scripts/build_mobile_release.sh
# Or manually:
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### For iOS (on Mac)

**1. Open in Xcode**
```bash
cd /home/z/zero_world/frontend/zero_world
open ios/Runner.xcworkspace
```

**2. Configure Signing**
- Runner → Signing & Capabilities
- Select your Team
- Bundle ID: `com.zeroworld.app`
- Enable "Automatically manage signing"

**3. Build Release IPA**
```bash
flutter build ipa --release
```

Output: `build/ios/ipa/zero_world.ipa`

---

### Phase 3: Create Developer Accounts (Week 3)

#### Google Play Console
1. Go to https://play.google.com/console
2. Pay $25 registration fee
3. Complete identity verification
4. Wait for approval (1-2 days)

#### Apple Developer
1. Go to https://developer.apple.com
2. Enroll in Developer Program ($99/year)
3. Complete identity verification
4. Wait for approval (1-2 days)

---

### Phase 4: Submit Apps (Week 3-4)

#### Submit to Google Play

**In Play Console:**
1. Create New App
2. Complete Store Listing:
   - App name: Zero World
   - Description
   - Category: Social
   - Upload screenshots
   - Upload app icon
3. Upload Release:
   - Upload AAB file
   - Set version (1.0.0)
4. Content Rating:
   - Complete questionnaire
5. Pricing & Distribution:
   - Free app
   - Select countries
6. Privacy Policy:
   - Add URL: `https://zn-01.com/privacy-policy`
7. Submit for Review

**Review time:** 1-7 days

#### Submit to Apple App Store

**In App Store Connect:**
1. Create New App
2. App Information:
   - Name: Zero World
   - Bundle ID: com.zeroworld.app
   - Category: Social Networking
3. Upload Build:
   - Use Transporter app
   - Or Xcode → Product → Archive → Distribute
4. App Store Information:
   - Description
   - Keywords
   - Screenshots
   - App icon
5. Pricing & Availability:
   - Free
   - Select countries
6. App Review Information:
   - Demo account (if needed)
   - Notes for reviewer
7. Privacy Policy:
   - Add URL: `https://zn-01.com/privacy-policy`
8. Submit for Review

**Review time:** 24-48 hours (usually)

---

## Cost Breakdown

| Item | Cost | When |
|------|------|------|
| Google Play Developer | $25 | One-time |
| Apple Developer Program | $99 | Annual |
| **Total First Year** | **$124** | - |
| **Annual Renewal** | **$99** | Yearly |

---

## Timeline Estimate

- **Week 1-2**: Create assets, write descriptions
- **Week 3**: Build apps, create accounts
- **Week 4**: Submit to stores
- **Week 5**: Review process (Google: 1-7 days, Apple: 1-2 days)
- **Week 6**: Launch! 🎉

**Total:** 4-6 weeks from start to launch

---

## Quick Commands Reference

```bash
# Navigate to Flutter project
cd /home/z/zero_world/frontend/zero_world

# Build Android release
flutter build appbundle --release

# Build Android test APK
flutter build apk --release

# Install test APK on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Build iOS release (Mac only)
flutter build ipa --release

# Or use the automated script
cd /home/z/zero_world
./scripts/build_mobile_release.sh
```

---

## After Launch

### Monitor
- User reviews and ratings
- Crash reports (integrate Firebase Crashlytics)
- Analytics (user behavior, retention)

### Update Process
1. Increment version number
2. Build new release
3. Upload to stores
4. Write release notes
5. Submit update

---

## Important Notes

⚠️ **iOS builds require a Mac** - You cannot build iOS apps on Linux
- Transfer project to Mac for iOS development
- Or use CI/CD service like Codemagic

✅ **Android works everywhere** - Build on Linux, Mac, or Windows

🔒 **Keep signing keys safe** - Backup your keystore file securely
- If lost, you cannot update your app
- Store in multiple secure locations

📱 **Test on real devices** - Emulators don't catch all issues

🌍 **Start with select countries** - Easier to manage initially

---

## Need Help?

- **Full Guide**: [MOBILE_APP_DEPLOYMENT.md](MOBILE_APP_DEPLOYMENT.md)
- **Privacy Policy**: [docs/PRIVACY_POLICY.md](docs/PRIVACY_POLICY.md)
- **Terms of Service**: [docs/TERMS_OF_SERVICE.md](docs/TERMS_OF_SERVICE.md)
- **Build Script**: `scripts/build_mobile_release.sh`

---

**Ready to launch? Let's get Zero World on the app stores! 🚀**
