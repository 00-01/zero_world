#!/bin/bash

# Zero World - Project Organization Script
# Organizes docs and scripts directories, removes unnecessary files

set -e

echo "🗂️  Zero World - Project Organization"
echo "======================================"
echo ""

PROJECT_ROOT="/home/z/zero_world"
cd "$PROJECT_ROOT"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ====================
# 1. ORGANIZE DOCS
# ====================
echo -e "${BLUE}📚 Organizing Documentation...${NC}"

# Create organized structure
mkdir -p docs/{testing,deployment,mobile,legal,archive,guides}

# Move testing docs
echo "  → Moving testing documentation..."
[ -f "docs/ANDROID_EMULATOR_TESTING.md" ] && mv docs/ANDROID_EMULATOR_TESTING.md docs/testing/ 2>/dev/null || true
[ -f "TESTING_GUIDE.md" ] && mv TESTING_GUIDE.md docs/testing/ 2>/dev/null || true

# Move platform setup docs to guides
echo "  → Moving setup guides..."
[ -f "CROSS_PLATFORM_SETUP.md" ] && mv CROSS_PLATFORM_SETUP.md docs/guides/ 2>/dev/null || true
[ -f "WEB_PLATFORM_FIX.md" ] && mv WEB_PLATFORM_FIX.md docs/guides/ 2>/dev/null || true

# Move status/summary docs to archive
echo "  → Archiving summary documents..."
[ -f "WEB_APP_STATUS.md" ] && mv WEB_APP_STATUS.md docs/archive/ 2>/dev/null || true
[ -f "FINAL_CLEANUP_SUMMARY.md" ] && mv FINAL_CLEANUP_SUMMARY.md docs/archive/ 2>/dev/null || true
[ -f "GIT_PUSH_SUMMARY.md" ] && mv GIT_PUSH_SUMMARY.md docs/archive/ 2>/dev/null || true

# Clean up redundant docs
echo "  → Removing redundant documentation..."
rm -f docs/FULL_DOCUMENTATION.md 2>/dev/null || true

echo -e "${GREEN}✅ Documentation organized${NC}"
echo ""

# ====================
# 2. ORGANIZE SCRIPTS
# ====================
echo -e "${BLUE}🛠️  Organizing Scripts...${NC}"

# Create script categories
mkdir -p scripts/{build,test,deploy,maintenance}

# Move build scripts
echo "  → Organizing build scripts..."
[ -f "scripts/build_mobile_release.sh" ] && mv scripts/build_mobile_release.sh scripts/build/ 2>/dev/null || true

# Move test scripts
echo "  → Organizing test scripts..."
[ -f "scripts/test_android.sh" ] && mv scripts/test_android.sh scripts/test/ 2>/dev/null || true
[ -f "scripts/test_android_emulator.sh" ] && mv scripts/test_android_emulator.sh scripts/test/ 2>/dev/null || true
[ -f "scripts/test_all_platforms.sh" ] && mv scripts/test_all_platforms.sh scripts/test/ 2>/dev/null || true

# Move deployment scripts
echo "  → Organizing deployment scripts..."
[ -f "scripts/setup_letsencrypt.sh" ] && mv scripts/setup_letsencrypt.sh scripts/deploy/ 2>/dev/null || true
[ -f "scripts/certify_app.sh" ] && mv scripts/certify_app.sh scripts/deploy/ 2>/dev/null || true
[ -f "scripts/certify_now.sh" ] && mv scripts/certify_now.sh scripts/deploy/ 2>/dev/null || true
[ -f "scripts/quick_certify.sh" ] && mv scripts/quick_certify.sh scripts/deploy/ 2>/dev/null || true

# Move maintenance scripts
echo "  → Organizing maintenance scripts..."
[ -f "scripts/final_cleanup.sh" ] && mv scripts/final_cleanup.sh scripts/maintenance/ 2>/dev/null || true
[ -f "scripts/cleanup_all.sh" ] && mv scripts/cleanup_all.sh scripts/maintenance/ 2>/dev/null || true

# Remove redundant/archived scripts
echo "  → Removing redundant scripts..."
rm -f scripts/archived_scripts.sh 2>/dev/null || true
rm -f scripts/organize_docs.sh 2>/dev/null || true

echo -e "${GREEN}✅ Scripts organized${NC}"
echo ""

# ====================
# 3. CREATE INDEX FILES
# ====================
echo -e "${BLUE}📋 Creating index files...${NC}"

# Create docs README
cat > docs/README.md << 'EOF'
# Zero World Documentation

## 📚 Documentation Structure

### 📖 Guides
- **CROSS_PLATFORM_SETUP.md** - Multi-platform configuration guide
- **WEB_PLATFORM_FIX.md** - Web platform troubleshooting

### 🧪 Testing
- **TESTING_GUIDE.md** - Comprehensive testing instructions
- **ANDROID_EMULATOR_TESTING.md** - Android emulator setup and testing

### 🚀 Deployment
- **ARCHITECTURE.md** - System architecture overview
- **GET_CERTIFIED.md** - SSL/TLS certificate setup
- **HTTPS_QUICKSTART.md** - Quick HTTPS setup guide
- **HTTPS_SETUP_GUIDE.md** - Detailed HTTPS configuration

### 📱 Mobile
- **MOBILE_APP_DEPLOYMENT.md** - Mobile app deployment guide
- **APP_STORE_QUICKSTART.md** - App store submission guide

### ⚖️ Legal
- **PRIVACY_POLICY.md** - Privacy policy
- **TERMS_OF_SERVICE.md** - Terms of service

### 📦 Archive
Historical documentation and summaries

---

**Main Documentation:** [../README.md](../README.md)  
**Quick Start:** [../QUICKSTART.md](../QUICKSTART.md)
EOF

# Create scripts README
cat > scripts/README.md << 'EOF'
# Zero World Scripts

## 🛠️ Script Categories

### 🏗️ Build Scripts (`build/`)
- **build_mobile_release.sh** - Build production mobile app releases

### 🧪 Test Scripts (`test/`)
- **test_android.sh** - Test Android app
- **test_android_emulator.sh** - Test with Android emulator
- **test_all_platforms.sh** - Cross-platform testing

### 🚀 Deploy Scripts (`deploy/`)
- **setup_letsencrypt.sh** - Setup Let's Encrypt SSL
- **certify_app.sh** - Certificate management (full)
- **certify_now.sh** - Quick certificate renewal
- **quick_certify.sh** - Quick certificate setup

### 🧹 Maintenance Scripts (`maintenance/`)
- **final_cleanup.sh** - Comprehensive project cleanup
- **cleanup_all.sh** - Full cleanup automation

---

## 📝 Usage

Make scripts executable:
```bash
chmod +x scripts/**/*.sh
```

Run a script:
```bash
./scripts/category/script_name.sh
```
EOF

echo -e "${GREEN}✅ Index files created${NC}"
echo ""

# ====================
# 4. SUMMARY
# ====================
echo -e "${BLUE}📊 Organization Summary${NC}"
echo "======================================"

# Count files in each category
docs_guides=$(find docs/guides -type f 2>/dev/null | wc -l)
docs_testing=$(find docs/testing -type f 2>/dev/null | wc -l)
docs_deployment=$(find docs/deployment -type f 2>/dev/null | wc -l)
docs_mobile=$(find docs/mobile -type f 2>/dev/null | wc -l)
docs_legal=$(find docs/legal -type f 2>/dev/null | wc -l)
docs_archive=$(find docs/archive -type f 2>/dev/null | wc -l)

scripts_build=$(find scripts/build -type f 2>/dev/null | wc -l)
scripts_test=$(find scripts/test -type f 2>/dev/null | wc -l)
scripts_deploy=$(find scripts/deploy -type f 2>/dev/null | wc -l)
scripts_maintenance=$(find scripts/maintenance -type f 2>/dev/null | wc -l)

echo ""
echo "📚 Documentation:"
echo "  ├── Guides:      $docs_guides files"
echo "  ├── Testing:     $docs_testing files"
echo "  ├── Deployment:  $docs_deployment files"
echo "  ├── Mobile:      $docs_mobile files"
echo "  ├── Legal:       $docs_legal files"
echo "  └── Archive:     $docs_archive files"
echo ""
echo "🛠️  Scripts:"
echo "  ├── Build:       $scripts_build files"
echo "  ├── Test:        $scripts_test files"
echo "  ├── Deploy:      $scripts_deploy files"
echo "  └── Maintenance: $scripts_maintenance files"
echo ""

echo -e "${GREEN}✅ Project organization complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review organized structure: tree docs/ scripts/"
echo "  2. Update README.md links if needed"
echo "  3. Commit changes: git add -A && git commit -m 'Organize docs and scripts'"
