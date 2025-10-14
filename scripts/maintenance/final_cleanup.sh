#!/bin/bash
# Zero World - Final Cleanup Script
# Removes unnecessary files, optimizes repository

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Zero World - Final Cleanup 🧹         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

PROJECT_ROOT="/home/z/zero_world"
cd "$PROJECT_ROOT"

# Get initial size
INITIAL_SIZE=$(du -sh . | cut -f1)
echo -e "${BLUE}📊 Initial project size: ${YELLOW}${INITIAL_SIZE}${NC}"
echo ""

# 1. Clean Flutter build artifacts
echo -e "${GREEN}🧹 Cleaning Flutter build artifacts...${NC}"
if [ -d "frontend/zero_world" ]; then
    cd frontend/zero_world
    flutter clean > /dev/null 2>&1 || true
    cd "$PROJECT_ROOT"
    echo "   ✅ Flutter build cache cleared"
fi

# 2. Remove Python cache files
echo -e "${GREEN}🐍 Removing Python cache files...${NC}"
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true
find . -type f -name "*.pyd" -delete 2>/dev/null || true
echo "   ✅ Python cache files removed"

# 3. Remove temporary files
echo -e "${GREEN}🗑️  Removing temporary files...${NC}"
find . -type f -name "*.tmp" -delete 2>/dev/null || true
find . -type f -name "*.temp" -delete 2>/dev/null || true
find . -type f -name "*.bak" -delete 2>/dev/null || true
find . -type f -name "*.backup" -delete 2>/dev/null || true
find . -type f -name "*~" -delete 2>/dev/null || true
echo "   ✅ Temporary files removed"

# 4. Remove OS-specific files
echo -e "${GREEN}💻 Removing OS-specific files...${NC}"
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "Thumbs.db" -delete 2>/dev/null || true
find . -name "desktop.ini" -delete 2>/dev/null || true
echo "   ✅ OS-specific files removed"

# 5. Remove log files
echo -e "${GREEN}📝 Removing log files...${NC}"
find . -type f -name "*.log" -delete 2>/dev/null || true
find . -type d -name "logs" -exec rm -rf {} + 2>/dev/null || true
echo "   ✅ Log files removed"

# 6. Clean node_modules if exists
if [ -d "node_modules" ]; then
    echo -e "${GREEN}📦 Removing node_modules...${NC}"
    rm -rf node_modules
    echo "   ✅ node_modules removed"
fi

# 7. Remove empty directories
echo -e "${GREEN}📁 Removing empty directories...${NC}"
find . -type d -empty -delete 2>/dev/null || true
echo "   ✅ Empty directories removed"

# 8. Optimize git repository
echo -e "${GREEN}🔧 Optimizing git repository...${NC}"
git gc --quiet 2>/dev/null || true
echo "   ✅ Git repository optimized"

# 9. Remove duplicate documentation
echo -e "${GREEN}📚 Checking for duplicate documentation...${NC}"
# Keep only essential docs, archive others
if [ -f "CLEANUP_SUMMARY.md" ] && [ -d "docs/archive" ]; then
    mv CLEANUP_SUMMARY.md docs/archive/ 2>/dev/null || true
fi
if [ -f "CLEANUP_COMPLETE.md" ] && [ -d "docs/archive" ]; then
    mv CLEANUP_COMPLETE.md docs/archive/ 2>/dev/null || true
fi
echo "   ✅ Documentation organized"

# Get final size
FINAL_SIZE=$(du -sh . | cut -f1)

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Cleanup Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📊 Results:${NC}"
echo -e "   Initial size: ${YELLOW}${INITIAL_SIZE}${NC}"
echo -e "   Final size:   ${GREEN}${FINAL_SIZE}${NC}"
echo ""

# Show what's left
echo -e "${BLUE}📁 Project structure:${NC}"
echo ""
tree -L 2 -I 'node_modules|build|.dart_tool|.git' . || ls -la

echo ""
echo -e "${GREEN}✨ Repository is now clean and optimized!${NC}"
