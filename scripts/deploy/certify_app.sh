#!/bin/bash

# Zero World - Let's Encrypt Certificate Setup
# Production-ready automated setup

set -e

DOMAIN="zn-01.com"
EMAIL="admin@zn-01.com"

echo "=========================================="
echo "🔒 ZERO WORLD - HTTPS CERTIFICATION"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "Server IP: $(curl -s -4 ifconfig.me)"
echo "DNS IP: $(dig +short $DOMAIN | head -1)"
echo ""

# Verify DNS
SERVER_IP=$(curl -s -4 ifconfig.me)
DNS_IP=$(dig +short $DOMAIN | head -1)

if [ "$SERVER_IP" != "$DNS_IP" ]; then
    echo "❌ ERROR: DNS mismatch!"
    echo "   Server IP: $SERVER_IP"
    echo "   DNS IP: $DNS_IP"
    echo ""
    echo "Please update your DNS to point to $SERVER_IP"
    exit 1
fi

echo "✅ DNS configured correctly"
echo ""

# Step 1: Backup current nginx config
echo "[1/6] Backing up current configuration..."
cd /home/z/zero_world
cp nginx/nginx.conf nginx/nginx.conf.backup-$(date +%Y%m%d-%H%M%S)

# Step 2: Stop services
echo "[2/6] Stopping services..."
docker-compose down

# Step 3: Create certbot directory
echo "[3/6] Preparing directories..."
mkdir -p certbot/www

# Step 4: Create HTTP-only nginx config for verification
echo "[4/6] Creating temporary HTTP configuration..."
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name zn-01.com www.zn-01.com;

        # Let's Encrypt verification
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 200 "Let's Encrypt verification in progress...";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Step 5: Start services
echo "[5/6] Starting services..."
docker-compose up -d nginx

# Wait for nginx to start
sleep 5

# Step 6: Obtain certificate
echo "[6/6] Obtaining Let's Encrypt certificate..."
echo ""
echo "⏳ This may take 1-2 minutes..."
echo ""

docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d $DOMAIN \
    -d www.$DOMAIN

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Certificate obtained successfully!"
    echo ""
    
    # Step 7: Update nginx config for HTTPS
    echo "[7/7] Configuring HTTPS..."
    
    cat > nginx/nginx.conf << 'EOF'
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

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general_limit:10m rate=30r/s;

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

        # Enhanced SSL/TLS configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
        ssl_session_cache shared:TLS:2m;
        ssl_session_timeout 1h;
        ssl_session_tickets off;
        
        # OCSP stapling
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 8.8.8.8 8.8.4.4 valid=300s;
        resolver_timeout 5s;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob:; style-src 'self' 'unsafe-inline'; img-src 'self' data: https: blob:; font-src 'self' data:; connect-src 'self' https: wss: ws:; worker-src 'self' blob:; child-src 'self' blob:; frame-ancestors 'self';" always;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Prevent caching of critical files
            if ($request_uri ~* \.(html|js)$) {
                add_header Cache-Control "no-cache, no-store, must-revalidate";
                add_header Pragma "no-cache";
                add_header Expires 0;
            }
            
            # Rate limiting
            limit_req zone=general_limit burst=50 nodelay;
        }

        # Backend API
        location = /api {
            return 308 /api/;
        }

        location /api/ {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect off;
            
            # Rate limiting for API
            limit_req zone=api_limit burst=20 nodelay;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
    
    # Restart all services with new config
    docker-compose down
    docker-compose up -d
    
    # Wait for services
    echo ""
    echo "⏳ Starting all services..."
    sleep 10
    
    echo ""
    echo "=========================================="
    echo "🎉 HTTPS CERTIFICATE SETUP COMPLETE!"
    echo "=========================================="
    echo ""
    echo "✅ Your website is now secured with Let's Encrypt!"
    echo ""
    echo "Certificate Details:"
    echo "  • Domain: $DOMAIN"
    echo "  • Certificate: /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    echo "  • Private Key: /etc/letsencrypt/live/$DOMAIN/privkey.pem"
    echo "  • Valid for: 90 days"
    echo "  • Auto-renewal: Every 12 hours via certbot"
    echo ""
    echo "Test your secure site:"
    echo "  🔒 https://$DOMAIN"
    echo "  🔒 https://www.$DOMAIN"
    echo ""
    echo "Check SSL rating:"
    echo "  https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
    echo ""
    echo "Next steps:"
    echo "  1. Visit https://$DOMAIN in your browser"
    echo "  2. Verify green padlock 🔒 appears"
    echo "  3. Check certificate details in browser"
    echo ""
    
else
    echo ""
    echo "❌ Certificate acquisition failed!"
    echo ""
    echo "Common issues:"
    echo "  1. Port 80 is blocked by firewall"
    echo "  2. DNS not propagated yet (wait 5-10 minutes)"
    echo "  3. Domain not pointing to this server"
    echo ""
    echo "Restoring backup configuration..."
    cp nginx/nginx.conf.backup-* nginx/nginx.conf 2>/dev/null || true
    docker-compose up -d
    exit 1
fi
