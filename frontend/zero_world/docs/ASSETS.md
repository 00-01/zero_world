# Zero World Assets Organization

This document describes the asset organization for the Zero World application.

## Directory Structure

```
zero_world/
├── assets/
│   └── images/
│       └── zn_logo.png (838x838px, 173KB) - SOURCE LOGO
│
└── web/
    ├── favicon.png (16x16px, 2.3KB) - Browser tab icon
    ├── assets/
    │   └── images/
    │       └── zn_logo.png (838x838px, 173KB) - Full-size logo for web
    └── icons/
        ├── Icon-192.png (192x192px, 30KB) - PWA icon & apple-touch-icon
        ├── Icon-512.png (512x512px, 119KB) - PWA icon
        ├── Icon-maskable-192.png (192x192px) - PWA maskable icon
        └── Icon-maskable-512.png (512x512px) - PWA maskable icon
```

## Asset Sources

### Primary Logo
- **Source:** `assets/images/zn_logo.png`
- **Size:** 838x838 pixels
- **Format:** PNG with RGBA
- **Purpose:** Master logo file, source for all other icons

### Web Assets

#### Loading Screen & Error Pages
- **Location:** `web/assets/images/zn_logo.png`
- **Usage:** Referenced in `web/index.html` for loading and error screens
- **Display:** 120x120px (loading), 80x80px (error)
- **Styling:** Rounded corners (border-radius: 20px/16px), shadow effects

#### Browser Icons
- **Favicon:** `web/favicon.png` (16x16px)
  - Used for browser tab icon
  - Referenced in `<link rel="icon">` in index.html

#### PWA Icons
- **Icon-192.png:** App icon for PWA installation
  - Referenced in `<link rel="apple-touch-icon">` in index.html
  - Used in manifest.json for Android/iOS home screen
  
- **Icon-512.png:** High-res app icon for PWA
  - Used in manifest.json for app splash screens
  
- **Icon-maskable-*.png:** Adaptive icons for Android 13+
  - Allows system to apply custom shapes and backgrounds

## Usage Guidelines

### Adding New Image Assets
1. Place source images in `assets/images/`
2. Add to `pubspec.yaml` under `flutter > assets` if needed
3. For web-specific assets, copy to `web/assets/images/`
4. Rebuild with `flutter build web --release`

### Creating Icon Variants
Use ImageMagick to create icon sizes from the master logo:

```bash
# Create standard icon
convert assets/images/zn_logo.png -resize 192x192 web/icons/Icon-192.png

# Create maskable icon (with padding for Android adaptive icons)
convert assets/images/zn_logo.png -resize 192x192 -gravity center \
  -background transparent -extent 192x192 web/icons/Icon-maskable-192.png
```

### Referencing Assets in Code

#### In Flutter Dart Code
```dart
Image.asset('assets/images/zn_logo.png')
```

#### In Web HTML
```html
<!-- Full-size logo -->
<img src="assets/images/zn_logo.png" alt="Zero World">

<!-- Icons -->
<img src="icons/Icon-192.png" alt="Zero World">
```

## Asset Optimization

All icons are automatically generated from the master logo (`assets/images/zn_logo.png`) to ensure consistency across all platforms and sizes.

### Current Optimizations
- ✅ Tree-shaking enabled for fonts (99%+ reduction)
- ✅ PNG format with appropriate compression
- ✅ Multiple icon sizes for different display contexts
- ✅ Maskable icons for modern Android devices

### Future Considerations
- Consider WebP format for web assets (smaller file size, better compression)
- Add dark mode variant of logo if needed
- Add different logo variants (horizontal, icon-only, etc.) in separate files

## Deployment

After modifying assets:
1. Run `flutter build web --release` from `frontend/zero_world/`
2. Rebuild Docker container: `docker-compose build frontend`
3. Restart services: `docker-compose down && docker-compose up -d`

## Maintenance

- **Source Logo:** Update `assets/images/zn_logo.png` and regenerate all variants
- **Icon Review:** Check icons quarterly for quality and update if design changes
- **Size Monitoring:** Keep assets under 200KB each for fast loading

---
*Last Updated: October 8, 2025*
