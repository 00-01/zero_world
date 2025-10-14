#!/bin/bash

# Let's Encrypt SSL Certificate Setup for Zero World
# This script sets up a free, trusted SSL certificate

set -e

DOMAIN="zn-01.com"
EMAIL="admin@zn-01.com"  # Change this to your email
WEBROOT="/var/www/certbot"

echo "=========================================="
echo "Let's Encrypt SSL Certificate Setup"
echo "=========================================="
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Step 1: Stop current services
echo "[1/5] Stopping services..."
docker-compose down

# Step 2: Update nginx configuration for Let's Encrypt verification
echo "[2/5] Updating nginx configuration..."
cat > nginx/nginx.conf.letsencrypt << 'EOF'
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

    # HTTP server for Let's Encrypt verification
    server {
        listen 80;
        server_name zn-01.com www.zn-01.com;

        # Let's Encrypt verification
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        # Redirect everything else to HTTPS (after cert is obtained)
        location / {
            return 301 https://$host$request_uri;
        }
    }

    # HTTPS server (will be activated after getting certificate)
    server {
        listen 443 ssl;
        server_name zn-01.com www.zn-01.com;

        # Let's Encrypt SSL certificates
        ssl_certificate /etc/letsencrypt/live/zn-01.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/zn-01.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/zn-01.com/chain.pem;

        # Enhanced SSL/TLS configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_session_cache shared:TLS:2m;
        ssl_session_timeout 1h;
        ssl_session_tickets off;
        
        # OCSP stapling
        ssl_stapling on;
        ssl_stapling_verify on;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

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
EOF

# Backup current nginx config
cp nginx/nginx.conf nginx/nginx.conf.backup

# Step 3: Create temporary HTTP-only nginx config for verification
cat > nginx/nginx.conf.http << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name zn-01.com www.zn-01.com;

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

# Use HTTP-only config temporarily
cp nginx/nginx.conf.http nginx/nginx.conf

# Step 4: Start services with HTTP only
echo "[3/5] Starting services with HTTP only..."
mkdir -p certbot/www
docker-compose up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Step 5: Obtain Let's Encrypt certificate
echo "[4/5] Obtaining Let's Encrypt certificate..."
echo ""
echo "IMPORTANT: Make sure your domain DNS points to this server's IP address!"
echo "Press ENTER to continue or CTRL+C to cancel..."
read

docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d $DOMAIN \
    -d www.$DOMAIN

# Step 6: Update nginx config to use Let's Encrypt certificate
echo "[5/5] Activating HTTPS with Let's Encrypt certificate..."
cp nginx/nginx.conf.letsencrypt nginx/nginx.conf

# Restart nginx with new configuration
docker-compose restart nginx

echo ""
echo "=========================================="
echo "✅ SSL CERTIFICATE SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Your website is now secured with Let's Encrypt!"
echo ""
echo "Certificate locations:"
echo "  Certificate: /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
echo "  Private Key: /etc/letsencrypt/live/$DOMAIN/privkey.pem"
echo "  Chain: /etc/letsencrypt/live/$DOMAIN/chain.pem"
echo ""
echo "The certificate will auto-renew every 12 hours via certbot container."
echo ""
echo "Test your site:"
echo "  https://$DOMAIN"
echo "  https://www.$DOMAIN"
echo ""
echo "Check SSL rating:"
echo "  https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
echo ""
