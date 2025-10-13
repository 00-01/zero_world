#!/bin/bash

# Zero World Mobile Release Build Script
# Builds both Android and iOS release versions

set -e

echo "======================================"
echo "Zero World Mobile Release Builder"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to Flutter project
cd "$(dirname "$0")/../frontend/zero_world" || exit 1

echo -e "${BLUE}📱 Building Zero World Mobile Apps...${NC}"
echo ""

# Check Flutter version
echo -e "${BLUE}Checking Flutter version...${NC}"
flutter --version
echo ""

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get
echo ""

# Build Android
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📦 Building Android Release (AAB)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if flutter build appbundle --release; then
    echo ""
    echo -e "${GREEN}✅ Android AAB built successfully!${NC}"
    echo -e "${GREEN}📁 Location: build/app/outputs/bundle/release/app-release.aab${NC}"
    
    # Get file size
    AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
    echo -e "${GREEN}📊 Size: ${AAB_SIZE}${NC}"
else
    echo -e "${RED}❌ Android AAB build failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📦 Building Android APK (for testing)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if flutter build apk --release; then
    echo ""
    echo -e "${GREEN}✅ Android APK built successfully!${NC}"
    echo -e "${GREEN}📁 Location: build/app/outputs/flutter-apk/app-release.apk${NC}"
    
    # Get file size
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo -e "${GREEN}📊 Size: ${APK_SIZE}${NC}"
else
    echo -e "${RED}❌ Android APK build failed${NC}"
fi

echo ""

# Check if running on macOS for iOS build
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📱 Building iOS Release (IPA)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if flutter build ipa --release; then
        echo ""
        echo -e "${GREEN}✅ iOS IPA built successfully!${NC}"
        echo -e "${GREEN}📁 Location: build/ios/ipa/zero_world.ipa${NC}"
        
        # Get file size
        IPA_SIZE=$(du -h build/ios/ipa/*.ipa | cut -f1)
        echo -e "${GREEN}📊 Size: ${IPA_SIZE}${NC}"
    else
        echo -e "${RED}❌ iOS IPA build failed${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  iOS builds require macOS${NC}"
    echo -e "${YELLOW}   Transfer the project to a Mac to build iOS version${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Build Summary${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✅ Android AAB: ${NC}build/app/outputs/bundle/release/app-release.aab"
echo -e "${GREEN}✅ Android APK: ${NC}build/app/outputs/flutter-apk/app-release.apk"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}✅ iOS IPA: ${NC}build/ios/ipa/zero_world.ipa"
else
    echo -e "${YELLOW}⏸️  iOS IPA: ${NC}Build on macOS"
fi

echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo ""
echo -e "  ${BLUE}For Google Play Store:${NC}"
echo -e "  1. Go to https://play.google.com/console"
echo -e "  2. Upload: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo -e "  ${BLUE}For Apple App Store:${NC}"
echo -e "  1. Open build/ios/ipa in Finder"
echo -e "  2. Use Transporter app to upload IPA"
echo -e "  3. Or use Xcode → Product → Archive → Distribute"
echo ""
echo -e "  ${BLUE}For Testing:${NC}"
echo -e "  • Android: adb install build/app/outputs/flutter-apk/app-release.apk"
echo -e "  • iOS: Use TestFlight or Xcode"
echo ""
echo -e "${GREEN}🎉 Build complete!${NC}"
echo ""
