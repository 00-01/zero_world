# Content Security Policy (CSP) Fix Summary

## Problem

The Flutter web app was experiencing CSP violations when trying to connect to the backend API:

```
Fetch API cannot load http://backend:8000/api/auth/login. 
Refused to connect because it violates the document's Content Security Policy.
```

## Root Cause

The frontend services were configured with absolute URLs using Docker internal hostnames:
- `http://backend:8000` - Docker internal hostname
- `http://localhost:8000` - Localhost URLs

**Why this fails:**
1. **Browser security**: Browsers running the Flutter web app cannot resolve Docker internal hostnames like `backend`
2. **CSP restrictions**: The Content Security Policy blocks connections to unknown/unauthorized hosts
3. **Same-origin policy**: Browsers enforce same-origin policy for fetch requests

## Solution

Changed all API base URLs from absolute URLs to **relative paths** that go through the nginx reverse proxy:

### Frontend Changes

#### 1. AuthService (`lib/services/auth_service.dart`)
```dart
// BEFORE
static const String baseUrl = 'http://backend:8000';

// AFTER  
static const String baseUrl = '/api';
```

#### 2. ApiService (`lib/services/api_service.dart`)
```dart
// BEFORE
static const String _defaultBaseUrl = 'http://backend:8000';

// AFTER
static const String _defaultBaseUrl = '/api';
```

#### 3. ConciergeService initialization (`lib/main.dart`)
```dart
// BEFORE
ConciergeService(
  baseUrl: 'http://localhost:8000',
  authToken: auth.accessToken,
)

// AFTER
ConciergeService(
  baseUrl: '', // Empty - paths already include /api/concierge
  authToken: auth.accessToken,
)
```

### Backend Changes

#### 4. Concierge Router (`backend/app/routers/concierge.py`)
```python
# BEFORE
router = APIRouter(prefix="/api/concierge", tags=["AI Concierge"])

# AFTER
router = APIRouter(prefix="/concierge", tags=["AI Concierge"])
```

**Why?** Other routers (auth, listings, chat) already use prefix without `/api`, so this brings concierge in line with the rest. Nginx handles the `/api/` prefix stripping.

### Nginx Configuration Fix

#### 5. Explicit Rewrite Rule (`nginx/nginx.conf`)
```nginx
location /api/ {
    # Rewrite to strip /api prefix before proxying
    rewrite ^/api/(.*)$ /$1 break;
    proxy_pass http://backend;
    # ... headers ...
}
```

**Why?** The original `proxy_pass http://backend/;` with trailing slash should have stripped the prefix, but wasn't working reliably. The explicit `rewrite` rule ensures `/api/` is always stripped before proxying.

## Request Flow (After Fix)

### Example: User Login

1. **Browser request**: `POST /api/auth/login`
   - Relative path - goes to same origin (nginx)
   - No CSP violation ✓
   - No CORS issue ✓

2. **Nginx receives**: `/api/auth/login`
   - Matches `location /api/` block
   - Rewrites to: `/auth/login`
   - Proxies to: `http://backend/auth/login`

3. **Backend receives**: `POST /auth/login`
   - Matches auth router prefix `/auth`
   - Route handler processes request ✓

### Example: AI Concierge

1. **Browser request**: `POST /api/concierge/conversation/start`
2. **Nginx rewrites to**: `/concierge/conversation/start`
3. **Backend router**: `/concierge` prefix matches ✓

## Benefits

✅ **No CSP violations** - All requests use same-origin relative paths
✅ **No CORS issues** - Same-origin policy satisfied  
✅ **Works in production** - HTTPS, domain, all work seamlessly
✅ **Works locally** - No special localhost configuration needed
✅ **Consistent routing** - All routers follow same pattern

## Testing

After deployment, verify:

```bash
# Check containers are running
docker-compose ps

# Test auth endpoint
curl -X POST https://www.zn-01.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Test concierge endpoint  
curl -X POST https://www.zn-01.com/api/concierge/conversation/start \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"initial_message":"Hello"}'

# Check backend logs
docker logs zero_world_backend_1 --tail 50
```

Expected: No 404 errors, proper responses from API endpoints.

## Commits

- `005230e` - Fixed CSP violations and API routing  
- `ebf6488` - Added explicit nginx rewrite rule

## Related Files

- `/home/z/zero_world/frontend/zero_world/lib/services/auth_service.dart`
- `/home/z/zero_world/frontend/zero_world/lib/services/api_service.dart`
- `/home/z/zero_world/frontend/zero_world/lib/services/concierge_service.dart`
- `/home/z/zero_world/frontend/zero_world/lib/main.dart`
- `/home/z/zero_world/backend/app/routers/concierge.py`
- `/home/z/zero_world/nginx/nginx.conf`
