# 🔒 Get Your App Certified - Simple Steps

## Current Status
- ✅ DNS configured: zn-01.com → 122.44.174.254
- ✅ Services running
- ⏳ Need Let's Encrypt certificate

## Quick Certification (3 Steps)

### Step 1: Stop Nginx (to free port 80)
```bash
cd /home/z/zero_world
docker-compose stop nginx
```

### Step 2: Get Certificate
```bash
docker-compose run --rm certbot certonly \
    --standalone \
    --preferred-challenges http \
    --email admin@zn-01.com \
    --agree-tos \
    --no-eff-email \
    -d zn-01.com \
    -d www.zn-01.com
```

### Step 3: Update Nginx Config
```bash
# Edit nginx/nginx.conf
# Change these two lines:
# FROM:
#   ssl_certificate /etc/ssl/certs/zn-01.com.crt;
#   ssl_certificate_key /etc/ssl/private/zn-01.com.key;
# TO:
#   ssl_certificate /etc/letsencrypt/live/zn-01.com/fullchain.pem;
#   ssl_certificate_key /etc/letsencrypt/live/zn-01.com/privkey.pem;

# Then restart
docker-compose up -d
```

## OR: Use Script
```bash
chmod +x scripts/quick_certify.sh
./scripts/quick_certify.sh
```

## Verify
```bash
curl -I https://zn-01.com
# Should show: HTTP/2 200

# Check in browser:
# https://zn-01.com - should show green padlock 🔒
```

## SSL Test
https://www.ssllabs.com/ssltest/analyze.html?d=zn-01.com

Target: **A+ rating**

---

**Next**: After certification, your app will have:
- ✅ Trusted HTTPS (green padlock)
- ✅ Auto-renewal (every 90 days)
- ✅ Production-ready security
- ✅ Browser trust
