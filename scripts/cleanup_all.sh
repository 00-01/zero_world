#!/bin/bash

# Zero World - Complete Cleanup Script
# Removes unnecessary files, organizes structure, optimizes codebase

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}======================================"
echo "Zero World - Complete Cleanup"
echo -e "======================================${NC}"
echo ""

cd "$(dirname "$0")/.." || exit 1

# Calculate initial size
echo -e "${BLUE}📊 Calculating current size...${NC}"
INITIAL_SIZE=$(du -sh . | cut -f1)
echo -e "Current size: ${YELLOW}${INITIAL_SIZE}${NC}"
echo ""

# 1. Clean Flutter build artifacts
echo -e "${BLUE}🧹 Cleaning Flutter build artifacts...${NC}"
cd frontend/zero_world
if [ -d "build" ]; then
    rm -rf build/
    echo -e "${GREEN}✓ Removed build/ directory${NC}"
fi

if [ -d ".dart_tool" ]; then
    rm -rf .dart_tool/
    echo -e "${GREEN}✓ Removed .dart_tool/ directory${NC}"
fi

if [ -d "test/test_cache" ]; then
    rm -rf test/test_cache/
    echo -e "${GREEN}✓ Removed test_cache/ directory${NC}"
fi

# Clean iOS build artifacts
if [ -d "ios/build" ]; then
    rm -rf ios/build/
    echo -e "${GREEN}✓ Removed ios/build/ directory${NC}"
fi

if [ -d "ios/Pods" ]; then
    rm -rf ios/Pods/
    echo -e "${GREEN}✓ Removed ios/Pods/ directory${NC}"
fi

# Clean Android build artifacts
if [ -d "android/build" ]; then
    rm -rf android/build/
    echo -e "${GREEN}✓ Removed android/build/ directory${NC}"
fi

if [ -d "android/app/build" ]; then
    rm -rf android/app/build/
    echo -e "${GREEN}✓ Removed android/app/build/ directory${NC}"
fi

if [ -d "android/.gradle" ]; then
    rm -rf android/.gradle/
    echo -e "${GREEN}✓ Removed android/.gradle/ directory${NC}"
fi

cd ../..
echo ""

# 2. Clean Python cache
echo -e "${BLUE}🧹 Cleaning Python cache files...${NC}"
find backend -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find backend -type f -name "*.pyc" -delete 2>/dev/null || true
find backend -type f -name "*.pyo" -delete 2>/dev/null || true
find backend -type f -name "*.pyd" -delete 2>/dev/null || true
find backend -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
echo -e "${GREEN}✓ Removed Python cache files${NC}"
echo ""

# 3. Clean backup files
echo -e "${BLUE}🧹 Cleaning backup files...${NC}"
find . -type f -name "*.backup*" -delete 2>/dev/null || true
find . -type f -name "*~" -delete 2>/dev/null || true
find . -type f -name "*.bak" -delete 2>/dev/null || true
find nginx -type f -name "nginx.conf.backup-*" -delete 2>/dev/null || true
echo -e "${GREEN}✓ Removed backup files${NC}"
echo ""

# 4. Clean log files (keep recent ones)
echo -e "${BLUE}🧹 Cleaning old log files...${NC}"
find . -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
echo -e "${GREEN}✓ Removed old log files${NC}"
echo ""

# 5. Clean temporary files
echo -e "${BLUE}🧹 Cleaning temporary files...${NC}"
find . -type f -name ".DS_Store" -delete 2>/dev/null || true
find . -type f -name "Thumbs.db" -delete 2>/dev/null || true
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
echo -e "${GREEN}✓ Removed temporary files${NC}"
echo ""

# 6. Clean git cache
echo -e "${BLUE}🧹 Cleaning git cache...${NC}"
if [ -d ".git" ]; then
    git gc --quiet 2>/dev/null || true
    echo -e "${GREEN}✓ Cleaned git cache${NC}"
fi
echo ""

# 7. Organize documentation
echo -e "${BLUE}📚 Organizing documentation...${NC}"
./scripts/organize_docs.sh
echo ""

# 8. Remove empty directories
echo -e "${BLUE}🧹 Removing empty directories...${NC}"
find . -type d -empty -not -path "./.git/*" -delete 2>/dev/null || true
echo -e "${GREEN}✓ Removed empty directories${NC}"
echo ""

# Calculate final size
echo -e "${BLUE}📊 Calculating final size...${NC}"
FINAL_SIZE=$(du -sh . | cut -f1)
echo ""

# Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Cleanup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Size before:${NC} ${YELLOW}${INITIAL_SIZE}${NC}"
echo -e "${BLUE}Size after:${NC}  ${GREEN}${FINAL_SIZE}${NC}"
echo ""

echo -e "${BLUE}What was cleaned:${NC}"
echo "  ✓ Flutter build artifacts (build/, .dart_tool/)"
echo "  ✓ iOS build artifacts (Pods/, ios/build/)"
echo "  ✓ Android build artifacts (.gradle/, build/)"
echo "  ✓ Python cache files (__pycache__/, *.pyc)"
echo "  ✓ Backup files (*.backup*, *.bak)"
echo "  ✓ Old log files (older than 7 days)"
echo "  ✓ Temporary files (.DS_Store, Thumbs.db)"
echo "  ✓ Git cache (optimized)"
echo "  ✓ Documentation (organized)"
echo "  ✓ Empty directories"
echo ""

echo -e "${BLUE}📁 Updated project structure:${NC}"
echo "  zero_world/"
echo "    ├── README.md              - Main documentation"
echo "    ├── QUICKSTART.md          - Quick start guide"
echo "    ├── docs/"
echo "    │   ├── deployment/        - Deployment guides"
echo "    │   ├── mobile/            - Mobile app guides"
echo "    │   ├── legal/             - Legal documents"
echo "    │   └── archive/           - Historical docs"
echo "    ├── backend/               - FastAPI backend"
echo "    ├── frontend/              - Flutter frontend"
echo "    ├── nginx/                 - Nginx configuration"
echo "    └── scripts/               - Utility scripts"
echo ""

echo -e "${GREEN}🎉 Your codebase is now clean and organized!${NC}"
echo ""
