#!/bin/bash

# Zero World Documentation Organization Script
# Consolidates and organizes all documentation files

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}======================================"
echo "Zero World - Documentation Cleanup"
echo -e "======================================${NC}"
echo ""

cd "$(dirname "$0")/.." || exit 1

# Create organized docs structure
echo -e "${BLUE}📁 Creating organized documentation structure...${NC}"

mkdir -p docs/{deployment,mobile,legal,guides}

# Move deployment docs
echo -e "${GREEN}Moving deployment documentation...${NC}"
[ -f "ARCHITECTURE.md" ] && mv "ARCHITECTURE.md" "docs/deployment/"
[ -f "HTTPS_QUICKSTART.md" ] && mv "HTTPS_QUICKSTART.md" "docs/deployment/"
[ -f "GET_CERTIFIED.md" ] && mv "GET_CERTIFIED.md" "docs/deployment/"
[ -f "docs/HTTPS_SETUP_GUIDE.md" ] && mv "docs/HTTPS_SETUP_GUIDE.md" "docs/deployment/"

# Move mobile app docs
echo -e "${GREEN}Moving mobile app documentation...${NC}"
[ -f "MOBILE_APP_DEPLOYMENT.md" ] && mv "MOBILE_APP_DEPLOYMENT.md" "docs/mobile/"
[ -f "APP_STORE_QUICKSTART.md" ] && mv "APP_STORE_QUICKSTART.md" "docs/mobile/"

# Move legal docs
echo -e "${GREEN}Moving legal documentation...${NC}"
[ -f "docs/PRIVACY_POLICY.md" ] && mv "docs/PRIVACY_POLICY.md" "docs/legal/"
[ -f "docs/TERMS_OF_SERVICE.md" ] && mv "docs/TERMS_OF_SERVICE.md" "docs/legal/"

# Move old cleanup summaries to archive
echo -e "${GREEN}Archiving old cleanup summaries...${NC}"
mkdir -p docs/archive
[ -f "CLEANUP_SUMMARY.md" ] && mv "CLEANUP_SUMMARY.md" "docs/archive/"
[ -f "CLEANUP_COMPLETE.md" ] && mv "CLEANUP_COMPLETE.md" "docs/archive/"

# Keep main docs at root
echo -e "${GREEN}Keeping essential docs at root...${NC}"
# README.md, QUICKSTART.md stay at root

echo ""
echo -e "${GREEN}✅ Documentation organized!${NC}"
echo ""
echo -e "${BLUE}New structure:${NC}"
echo "  docs/"
echo "    ├── deployment/     - Infrastructure & deployment guides"
echo "    ├── mobile/         - Mobile app publishing guides"
echo "    ├── legal/          - Privacy policy & terms of service"
echo "    ├── guides/         - Other guides"
echo "    └── archive/        - Historical documents"
echo ""
