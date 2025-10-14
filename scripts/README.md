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
