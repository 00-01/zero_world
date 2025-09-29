#!/bin/bash

echo "🔒 Option 3: Self-Signed SSL Certificate Setup"
echo "=============================================="

# Step 1: Create SSL directory
echo "Step 1: Creating SSL certificate directory..."
sudo mkdir -p /etc/ssl/private /etc/ssl/certs

# Step 2: Generate self-signed certificate
echo ""
echo "Step 2: Generating self-signed SSL certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/zn-01.com.key \
    -out /etc/ssl/certs/zn-01.com.crt \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=ZeroWorld/OU=IT/CN=zn-01.com/subjectAltName=DNS:zn-01.com,DNS:www.zn-01.com"

# Step 3: Set proper permissions
echo ""
echo "Step 3: Setting proper permissions..."
sudo chmod 644 /etc/ssl/certs/zn-01.com.crt
sudo chmod 600 /etc/ssl/private/zn-01.com.key

# Step 4: Create nginx configuration for self-signed SSL
echo ""
echo "Step 4: Creating nginx configuration for self-signed SSL..."
cat > /home/z/zero_world/nginx/nginx-self-signed.conf << 'EOF'
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

        # Health check available on HTTP
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Redirect everything else to HTTPS
        location / {
            return 301 https://$host$request_uri;
        }
    }

    # HTTPS server with self-signed certificate
    server {
        listen 443 ssl;
        server_name zn-01.com www.zn-01.com;

        # Self-signed SSL certificates
        ssl_certificate /etc/ssl/certs/zn-01.com.crt;
        ssl_certificate_key /etc/ssl/private/zn-01.com.key;

        # SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1d;
        ssl_session_tickets off;

        # Security headers
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

# Step 5: Update docker-compose to use self-signed SSL config and mount certificates
echo ""
echo "Step 5: Updating docker-compose configuration..."

# Backup current docker-compose
cp /home/z/zero_world/docker-compose.yml /home/z/zero_world/docker-compose.yml.backup-$(date +%Y%m%d-%H%M%S)

# Update nginx service in docker-compose.yml
cat > /tmp/nginx_service.yml << 'EOF'
  nginx:
    build: ./nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
    volumes:
      - ./nginx/nginx-self-signed.conf:/etc/nginx/nginx.conf:ro
      - /etc/ssl/certs/zn-01.com.crt:/etc/ssl/certs/zn-01.com.crt:ro
      - /etc/ssl/private/zn-01.com.key:/etc/ssl/private/zn-01.com.key:ro
    restart: unless-stopped
EOF

# Replace nginx service in docker-compose.yml
sed -i '/^  nginx:/,/^  [a-zA-Z]/{/^  [a-zA-Z]/!d;}' /home/z/zero_world/docker-compose.yml
sed -i '/^  nginx:/d' /home/z/zero_world/docker-compose.yml
sed -i '/^  certbot:/i\  nginx:\
    build: ./nginx\
    ports:\
      - "80:80"\
      - "443:443"\
    depends_on:\
      - backend\
      - frontend\
    volumes:\
      - ./nginx/nginx-self-signed.conf:/etc/nginx/nginx.conf:ro\
      - /etc/ssl/certs/zn-01.com.crt:/etc/ssl/certs/zn-01.com.crt:ro\
      - /etc/ssl/private/zn-01.com.key:/etc/ssl/private/zn-01.com.key:ro\
    restart: unless-stopped\
' /home/z/zero_world/docker-compose.yml

# Step 6: Restart services with SSL
echo ""
echo "Step 6: Restarting services with self-signed SSL..."
docker-compose down
docker-compose up -d

# Wait for services to start
sleep 10

# Step 7: Test SSL access
echo ""
echo "Step 7: Testing SSL access..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/health 2>/dev/null)
HTTPS_STATUS=$(curl -s -k -o /dev/null -w "%{http_code}" https://www.zn-01.com/health 2>/dev/null)

echo "HTTP Health Check: $HTTP_STATUS"
echo "HTTPS Health Check: $HTTPS_STATUS"

if [ "$HTTPS_STATUS" -eq 200 ]; then
    echo ""
    echo "🎉 Self-Signed SSL Setup Complete!"
    echo "=================================="
    echo "🌐 Your website is now available at:"
    echo "   • https://www.zn-01.com (with browser warning)"
    echo "   • https://zn-01.com (with browser warning)"
    echo "   • https://www.zn-01.com/api/"
    echo "   • https://www.zn-01.com/health"
    echo ""
    echo "⚠️  Browser Security Warning:"
    echo "   Browsers will show a security warning because this is a self-signed certificate."
    echo "   Click 'Advanced' -> 'Proceed to www.zn-01.com (unsafe)' to access the site."
    echo ""
    echo "🔒 Certificate Details:"
    echo "   • Type: Self-signed"
    echo "   • Valid for: zn-01.com, www.zn-01.com"
    echo "   • Expires: $(date -d '+365 days' '+%Y-%m-%d')"
    echo ""
    echo "🔄 To get a trusted certificate later:"
    echo "   1. Use Cloudflare (recommended)"
    echo "   2. Fix Let's Encrypt connectivity issues"
    echo "   3. Use a commercial SSL provider"
    
    # Show certificate info
    echo ""
    echo "📋 Certificate Information:"
    openssl x509 -in /etc/ssl/certs/zn-01.com.crt -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
    
else
    echo ""
    echo "❌ SSL setup failed"
    echo "Check nginx logs: docker-compose logs nginx"
fi

echo ""
echo "✅ Setup completed!"