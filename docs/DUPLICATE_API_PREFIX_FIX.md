# Duplicate /api/ Prefix Fix

## Issue
Browser console showed 404 errors:
```
POST https://www.zn-01.com/api/api/auth/login 404 (Not Found)
POST https://www.zn-01.com/api/api/auth/signup 404 (Not Found)
```

Notice the **duplicate `/api/api/`** in the URL path.

## Root Cause

In `AuthService`, the paths were constructed as:
```dart
static const String baseUrl = '/api';

// Then in methods:
Uri.parse('$baseUrl/api/auth/signup')  // Results in /api/api/auth/signup ❌
```

The baseUrl already included `/api`, and the paths also included `/api/`, causing duplication.

## Solution

Removed the `/api/` prefix from all path strings in `AuthService`:

### Before:
```dart
Uri.parse('$baseUrl/api/auth/signup')    → /api/api/auth/signup ❌
Uri.parse('$baseUrl/api/auth/login')     → /api/api/auth/login ❌
Uri.parse('$baseUrl/api/auth/me')        → /api/api/auth/me ❌
Uri.parse('$baseUrl/api/auth/profile')   → /api/api/auth/profile ❌
Uri.parse('$baseUrl/api/auth/change-password') → /api/api/auth/change-password ❌
```

### After:
```dart
Uri.parse('$baseUrl/auth/signup')        → /api/auth/signup ✓
Uri.parse('$baseUrl/auth/login')         → /api/auth/login ✓
Uri.parse('$baseUrl/auth/me')            → /api/auth/me ✓
Uri.parse('$baseUrl/auth/profile')       → /api/auth/profile ✓
Uri.parse('$baseUrl/auth/change-password') → /api/auth/change-password ✓
```

## Request Flow (After Fix)

1. **Frontend**: `POST /api/auth/login`
2. **Nginx**: Matches `/api/` location, rewrites to `/auth/login`
3. **Backend**: Receives `POST /auth/login`, router handles with `/auth` prefix ✓

## Files Changed

- `/home/z/zero_world/frontend/zero_world/lib/services/auth_service.dart`
  - Line 44: `/api/auth/signup` → `/auth/signup`
  - Line 76: `/api/auth/login` → `/auth/login`
  - Line 109: `/api/auth/me` → `/auth/me`
  - Line 155: `/api/auth/profile` → `/auth/profile`
  - Line 183: `/api/auth/change-password` → `/auth/change-password`

## Deployment Steps

1. Fixed auth_service.dart paths
2. Rebuilt Flutter: `flutter build web --release`
3. Rebuilt Docker image: `docker-compose build --no-cache frontend`
4. Restarted frontend container with new image
5. Restarted nginx to clear proxy cache
6. Committed: `53e1627`

## Verification

After deployment:
- Frontend container has latest build (timestamp 14:31 UTC)
- URLs are now `/api/auth/*` (single `/api/` prefix) ✓
- Backend should receive `/auth/*` (nginx strips `/api/`) ✓

## User Action Required

**Clear browser cache or do a hard refresh:**
- Chrome/Edge: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
- Firefox: `Ctrl+F5` (Windows/Linux) or `Cmd+Shift+R` (Mac)
- Safari: `Cmd+Option+R` (Mac)

This ensures the browser loads the new JavaScript files instead of using cached versions.

## Related Issues

- Initial CSP violations: Fixed by changing to relative paths (commit 005230e)
- Nginx rewrite rule: Added explicit rewrite (commit ebf6488)
- Duplicate prefix: This fix (commit 53e1627)

All three fixes work together to enable proper API routing from browser → nginx → backend.
