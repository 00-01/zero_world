# Comprehensive Cleanup Plan - October 15, 2025

## Current State Analysis

### Root Directory (44 files/folders)
- **Documentation overload**: 20+ MD files in root
- **Outdated super-app docs**: No longer relevant (pure chat now)
- **Enterprise docs**: Not applicable to current pure chat architecture
- **Unused infrastructure**: kubernetes/, monitoring/, docker-compose.enterprise.yml

## Cleanup Actions

### 1. Remove Outdated Documentation (Root Level)
Files to remove:
- AI_AGENT_ARCHITECTURE.md (outdated)
- COMPLETE_SERVICES_UPDATE.md (outdated)
- CROSS_PLATFORM_STATUS.md (outdated)
- CSP_ERROR_EXPLAINED.md (issue resolved)
- DEPLOYMENT_SUPER_APP.md (not a super app anymore)
- DIGITAL_IDENTITY_IMPLEMENTATION.md (feature removed)
- DIGITAL_IDENTITY_SYSTEM.md (feature removed)
- DIGITAL_IDENTITY_VISUAL.txt (feature removed)
- ENTERPRISE_ARCHITECTURE.md (not enterprise)
- ENTERPRISE_TRANSFORMATION_COMPLETE.md (outdated)
- IMPLEMENTATION_SUMMARY.md (outdated)
- MIGRATION_GUIDE.md (outdated)
- PLATFORM_SUMMARY.md (outdated)
- REBUILD_SUMMARY.md (outdated)
- SUPER_APP_OVERVIEW.md (not a super app)
- SUPER_APP_VISUAL.txt (not a super app)
- TODO_SUPER_APP.md (not applicable)

Keep:
- README.md (main documentation)
- QUICKSTART.md (useful)
- CLEANUP_REPORT.md (historical reference)
- FINAL_CLEANUP_SUMMARY.md (recent cleanup summary)
- CODE_STANDARDS.md (useful standards)
- UI_CUSTOMIZATION_GUIDE.md (useful for theme customization)
- LICENSE (legal requirement)

### 2. Remove Unused Infrastructure
- docker-compose.enterprise.yml (not using)
- kubernetes/ (not deploying to k8s)
- monitoring/ (no monitoring setup)

### 3. Consolidate Documentation
Move all docs to docs/ folder structure:
- Keep docs/ organized
- Remove duplicate docs in docs/archive/

### 4. Clean Build Artifacts
- frontend/zero_world/.dart_tool/ (keep, needed for development)
- frontend/zero_world/build/ (can be regenerated)

### 5. Organize Scripts
Review scripts/ directory for unused scripts

