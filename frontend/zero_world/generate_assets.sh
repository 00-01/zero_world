#!/bin/bash

# Zero World Asset Generation Script
# This script regenerates all icons from the master logo file

MASTER_LOGO="assets/images/zn_logo.png"
WEB_DIR="web"

echo "🎨 Zero World Asset Generator"
echo "================================"
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ Error: ImageMagick is not installed"
    echo "Install with: sudo apt-get install imagemagick"
    exit 1
fi

# Check if master logo exists
if [ ! -f "$MASTER_LOGO" ]; then
    echo "❌ Error: Master logo not found at $MASTER_LOGO"
    exit 1
fi

echo "✓ Master logo found: $MASTER_LOGO"
echo ""

# Create directories if they don't exist
mkdir -p "$WEB_DIR/assets/images"
mkdir -p "$WEB_DIR/icons"

# Copy full-size logo to web assets
echo "📦 Copying full-size logo to web assets..."
cp "$MASTER_LOGO" "$WEB_DIR/assets/images/zn_logo.png"
echo "✓ Created: $WEB_DIR/assets/images/zn_logo.png"

# Generate favicon
echo ""
echo "🖼️  Generating favicon (16x16)..."
convert "$MASTER_LOGO" -resize 16x16 "$WEB_DIR/favicon.png"
echo "✓ Created: $WEB_DIR/favicon.png"

# Generate standard icons
echo ""
echo "📱 Generating PWA icons..."
convert "$MASTER_LOGO" -resize 192x192 "$WEB_DIR/icons/Icon-192.png"
echo "✓ Created: $WEB_DIR/icons/Icon-192.png (192x192)"

convert "$MASTER_LOGO" -resize 512x512 "$WEB_DIR/icons/Icon-512.png"
echo "✓ Created: $WEB_DIR/icons/Icon-512.png (512x512)"

# Generate maskable icons (with transparent background for Android adaptive icons)
echo ""
echo "🎭 Generating maskable icons..."
convert "$MASTER_LOGO" -resize 192x192 -gravity center \
  -background transparent -extent 192x192 \
  "$WEB_DIR/icons/Icon-maskable-192.png"
echo "✓ Created: $WEB_DIR/icons/Icon-maskable-192.png (192x192)"

convert "$MASTER_LOGO" -resize 512x512 -gravity center \
  -background transparent -extent 512x512 \
  "$WEB_DIR/icons/Icon-maskable-512.png"
echo "✓ Created: $WEB_DIR/icons/Icon-maskable-512.png (512x512)"

echo ""
echo "================================"
echo "✨ All assets generated successfully!"
echo ""
echo "📊 File sizes:"
ls -lh "$WEB_DIR/favicon.png" "$WEB_DIR/icons/Icon-"*.png "$WEB_DIR/assets/images/zn_logo.png" | awk '{print "  " $9 " - " $5}'

echo ""
echo "📝 Next steps:"
echo "  1. Run: flutter build web --release"
echo "  2. Run: docker-compose build frontend"
echo "  3. Run: docker-compose down && docker-compose up -d"
echo ""
