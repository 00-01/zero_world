# 🔒 HTTPS Certificate Setup Guide - Zero World

## Overview

This guide will help you set up a **FREE, trusted HTTPS certificate** from Let's Encrypt for your Zero World platform.

---

## 📋 Prerequisites

### 1. Domain Name
- ✅ You have: `zn-01.com` and `www.zn-01.com`
- ✅ Domain must be registered and active

### 2. DNS Configuration
**CRITICAL**: Your domain DNS must point to your server's IP address

```bash
# Check your server's public IP
curl -4 ifconfig.me

# Verify DNS is pointing correctly
nslookup zn-01.com
nslookup www.zn-01.com

# Both should return your server's IP address
```

### 3. Port Requirements
- Port 80 (HTTP) - **MUST be open** for Let's Encrypt verification
- Port 443 (HTTPS) - For secure connections

```bash
# Check if ports are open
sudo ufw status
# or
sudo iptables -L -n | grep -E '80|443'
```

---

## 🚀 Method 1: Automatic Setup (Recommended)

### Step 1: Prepare the Script

```bash
cd /home/z/zero_world
chmod +x scripts/setup_letsencrypt.sh
```

### Step 2: Edit Configuration

Open `scripts/setup_letsencrypt.sh` and update:

```bash
DOMAIN="zn-01.com"
EMAIL="your-email@example.com"  # ← Change this to your real email
```

### Step 3: Run the Script

```bash
./scripts/setup_letsencrypt.sh
```

The script will:
1. ✅ Stop current services
2. ✅ Update nginx configuration
3. ✅ Start services in HTTP mode
4. ✅ Obtain Let's Encrypt certificate
5. ✅ Switch to HTTPS mode
6. ✅ Restart services

---

## 🔧 Method 2: Manual Setup (Step-by-Step)

### Step 1: Verify DNS Configuration

```bash
# Check if your domain points to this server
dig +short zn-01.com
dig +short www.zn-01.com

# Compare with your server IP
curl -4 ifconfig.me
```

**If IPs don't match, update your DNS settings first!**

### Step 2: Stop Current Services

```bash
cd /home/z/zero_world
docker-compose down
```

### Step 3: Create Certbot Directory

```bash
mkdir -p certbot/www
```

### Step 4: Update Nginx for HTTP Challenge

Create a temporary nginx configuration:

```bash
cat > nginx/nginx.conf.temp << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name zn-01.com www.zn-01.com;

        # Let's Encrypt verification path
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOF

# Backup current config and use temporary
cp nginx/nginx.conf nginx/nginx.conf.backup
cp nginx/nginx.conf.temp nginx/nginx.conf
```

### Step 5: Start Services

```bash
docker-compose up -d
```

### Step 6: Obtain Certificate

```bash
docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email your-email@example.com \
    --agree-tos \
    --no-eff-email \
    -d zn-01.com \
    -d www.zn-01.com
```

**Expected output:**
```
Congratulations! Your certificate and chain have been saved at:
/etc/letsencrypt/live/zn-01.com/fullchain.pem
Your key file has been saved at:
/etc/letsencrypt/live/zn-01.com/privkey.pem
```

### Step 7: Update Nginx for HTTPS

Update `nginx/nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }

    upstream frontend {
        server frontend:80;
    }

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name zn-01.com www.zn-01.com;

        # Let's Encrypt verification
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        # Redirect to HTTPS
        location / {
            return 301 https://$host$request_uri;
        }
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name zn-01.com www.zn-01.com;

        # Let's Encrypt SSL certificates
        ssl_certificate /etc/letsencrypt/live/zn-01.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/zn-01.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/zn-01.com/chain.pem;

        # SSL Configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_stapling on;
        ssl_stapling_verify on;

        # Security Headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Backend API
        location /api/ {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### Step 8: Update Docker Compose Volumes

Edit `docker-compose.yml` to ensure certbot volumes are mounted:

```yaml
nginx:
  volumes:
    - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    - /etc/letsencrypt:/etc/letsencrypt:ro
    - ./certbot/www:/var/www/certbot:ro

certbot:
  image: certbot/certbot:latest
  volumes:
    - /etc/letsencrypt:/etc/letsencrypt
    - /var/lib/letsencrypt:/var/lib/letsencrypt
    - ./certbot/www:/var/www/certbot
```

### Step 9: Restart Services

```bash
docker-compose restart nginx
```

---

## ✅ Verification

### Test HTTPS Connection

```bash
# Test HTTPS
curl -I https://zn-01.com
curl -I https://www.zn-01.com

# Should return: HTTP/2 200
```

### Test HTTP Redirect

```bash
# Test HTTP redirect to HTTPS
curl -I http://zn-01.com

# Should return: HTTP/1.1 301 Moved Permanently
# Location: https://zn-01.com/
```

### Check Certificate Details

```bash
# View certificate info
openssl s_client -connect zn-01.com:443 -servername zn-01.com < /dev/null | openssl x509 -noout -dates

# Should show:
# notBefore: [date]
# notAfter: [date in ~90 days]
```

### SSL Labs Test

Visit: https://www.ssllabs.com/ssltest/analyze.html?d=zn-01.com

Target grade: **A or A+**

---

## 🔄 Certificate Auto-Renewal

Your `certbot` container is already configured to auto-renew certificates every 12 hours.

### Check Renewal Status

```bash
# Check certbot logs
docker-compose logs certbot

# Manually test renewal (dry run)
docker-compose run --rm certbot renew --dry-run
```

### Force Manual Renewal

```bash
# Force renewal (if needed)
docker-compose run --rm certbot renew --force-renewal
docker-compose restart nginx
```

---

## 🐛 Troubleshooting

### Issue 1: "Domain verification failed"

**Cause**: DNS not pointing to your server

**Solution**:
```bash
# 1. Verify DNS
dig +short zn-01.com
# Should match: curl -4 ifconfig.me

# 2. Wait for DNS propagation (can take up to 48 hours)
# 3. Check your domain registrar settings
```

### Issue 2: "Port 80 is already in use"

**Cause**: Another service is using port 80

**Solution**:
```bash
# Find what's using port 80
sudo lsof -i :80

# Stop the service
sudo systemctl stop apache2  # or nginx, or other service
```

### Issue 3: "Too many failed attempts"

**Cause**: Let's Encrypt rate limit (5 failures per hour)

**Solution**:
```bash
# Use staging environment for testing
docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email your-email@example.com \
    --agree-tos \
    --staging \
    -d zn-01.com \
    -d www.zn-01.com

# When successful, remove --staging and run again
```

### Issue 4: "Certificate not found after obtaining"

**Solution**:
```bash
# Check certificate location
sudo ls -la /etc/letsencrypt/live/zn-01.com/

# Ensure volumes are mounted correctly in docker-compose.yml
docker-compose down
docker-compose up -d
```

### Issue 5: "ERR_CERT_AUTHORITY_INVALID" in browser

**Cause**: Nginx is still using self-signed certificate

**Solution**:
```bash
# 1. Verify Let's Encrypt certificate exists
sudo ls -la /etc/letsencrypt/live/zn-01.com/fullchain.pem

# 2. Check nginx config points to Let's Encrypt cert
grep "ssl_certificate" nginx/nginx.conf

# 3. Restart nginx
docker-compose restart nginx

# 4. Clear browser cache or use incognito mode
```

---

## 📊 Certificate Information

### Let's Encrypt Benefits
- ✅ **FREE** - No cost
- ✅ **Trusted** - Recognized by all browsers
- ✅ **Automatic** - Auto-renewal
- ✅ **Secure** - Industry standard encryption
- ✅ **Fast** - Certificate issued in minutes

### Certificate Lifecycle
- **Valid for**: 90 days
- **Auto-renewal**: Every 60 days (by certbot)
- **Manual renewal**: `docker-compose run --rm certbot renew`

### Files Created
```
/etc/letsencrypt/
├── live/
│   └── zn-01.com/
│       ├── fullchain.pem  → Full certificate chain
│       ├── privkey.pem    → Private key
│       ├── cert.pem       → Certificate only
│       └── chain.pem      → Intermediate certificates
├── archive/              → Certificate backups
└── renewal/              → Renewal configuration
```

---

## 🎯 Quick Command Reference

```bash
# Obtain certificate
docker-compose run --rm certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email your@email.com \
  --agree-tos \
  -d zn-01.com -d www.zn-01.com

# Renew certificate
docker-compose run --rm certbot renew

# Test renewal (dry run)
docker-compose run --rm certbot renew --dry-run

# Force renewal
docker-compose run --rm certbot renew --force-renewal

# Check certificate expiry
echo | openssl s_client -connect zn-01.com:443 2>/dev/null | openssl x509 -noout -dates

# View certificate details
openssl s_client -connect zn-01.com:443 -servername zn-01.com < /dev/null

# Restart nginx after config change
docker-compose restart nginx

# View certbot logs
docker-compose logs -f certbot

# View nginx logs
docker-compose logs -f nginx
```

---

## 🔐 Security Best Practices

### 1. Strong SSL Configuration
```nginx
# Use modern protocols only
ssl_protocols TLSv1.2 TLSv1.3;

# Strong ciphers
ssl_ciphers HIGH:!aNULL:!MD5;

# Enable HSTS
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### 2. OCSP Stapling
```nginx
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
```

### 3. Security Headers
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

---

## 📚 Additional Resources

- **Let's Encrypt**: https://letsencrypt.org/
- **Certbot Documentation**: https://certbot.eff.org/
- **SSL Labs Test**: https://www.ssllabs.com/ssltest/
- **Mozilla SSL Config Generator**: https://ssl-config.mozilla.org/
- **Certificate Transparency Log**: https://crt.sh/?q=zn-01.com

---

## ✅ Success Checklist

- [ ] Domain DNS points to server IP
- [ ] Port 80 and 443 are open
- [ ] Let's Encrypt certificate obtained
- [ ] Nginx configured with Let's Encrypt paths
- [ ] HTTPS works: `https://zn-01.com`
- [ ] HTTP redirects to HTTPS
- [ ] SSL Labs grade: A or A+
- [ ] Auto-renewal configured
- [ ] Browser shows green padlock 🔒

---

**Status**: Ready for production HTTPS deployment  
**Certificate Provider**: Let's Encrypt  
**Cost**: FREE  
**Renewal**: Automatic  

🎉 **Your Zero World platform will be secured with industry-standard HTTPS!**
