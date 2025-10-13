#!/bin/bash

# Quick Let's Encrypt Certification for Zero World

cd /home/z/zero_world

echo "🔒 Getting HTTPS Certificate for zn-01.com..."
echo ""

# Obtain certificate using existing certbot container
docker-compose run --rm certbot certonly \
    --standalone \
    --preferred-challenges http \
    --email admin@zn-01.com \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    --non-interactive \
    -d zn-01.com \
    -d www.zn-01.com

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Certificate obtained!"
    echo ""
    echo "Now updating nginx configuration..."
    
    # Update nginx config
    sudo sed -i 's|/etc/ssl/certs/zn-01.com.crt|/etc/letsencrypt/live/zn-01.com/fullchain.pem|g' nginx/nginx.conf
    sudo sed -i 's|/etc/ssl/private/zn-01.com.key|/etc/letsencrypt/live/zn-01.com/privkey.pem|g' nginx/nginx.conf
    
    # Restart services
    docker-compose restart nginx
    
    echo ""
    echo "🎉 Done! Your app is now certified with HTTPS!"
    echo ""
    echo "Test it: https://zn-01.com"
else
    echo ""
    echo "❌ Failed. You may need to stop nginx first:"
    echo "   docker-compose stop nginx"
    echo "   Then run this script again"
fi
