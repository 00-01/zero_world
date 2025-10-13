#!/bin/bash

# Zero World - Manual HTTPS Certification Guide

echo "=========================================="
echo "🔒 MANUAL HTTPS CERTIFICATION GUIDE"
echo "=========================================="
echo ""
echo "Follow these steps to certify your app:"
echo ""

echo "Step 1: Stop nginx (FREE PORT 80)"
echo "-----------------------------------"
echo "docker-compose stop nginx"
echo ""

echo "Step 2: GET CERTIFICATE"
echo "-----------------------------------"
echo "docker-compose run --rm certbot certonly \\"
echo "    --standalone \\"
echo "    --preferred-challenges http \\"
echo "    --email admin@zn-01.com \\"
echo "    --agree-tos \\"
echo "    --no-eff-email \\"
echo "    -d zn-01.com \\"
echo "    -d www.zn-01.com"
echo ""

echo "Step 3: UPDATE NGINX CONFIG"
echo "-----------------------------------"
echo "Edit nginx/nginx.conf and change:"
echo ""
echo "FROM:"
echo "  ssl_certificate /etc/ssl/certs/zn-01.com.crt;"
echo "  ssl_certificate_key /etc/ssl/private/zn-01.com.key;"
echo ""
echo "TO:"
echo "  ssl_certificate /etc/letsencrypt/live/zn-01.com/fullchain.pem;"
echo "  ssl_certificate_key /etc/letsencrypt/live/zn-01.com/privkey.pem;"
echo ""

echo "Step 4: RESTART SERVICES"
echo "-----------------------------------"
echo "docker-compose up -d"
echo ""

echo "Step 5: VERIFY"
echo "-----------------------------------"
echo "curl -I https://zn-01.com"
echo "# Should return: HTTP/2 200"
echo ""

echo "Step 6: TEST IN BROWSER"
echo "-----------------------------------"
echo "Visit: https://zn-01.com"
echo "Look for: Green padlock 🔒"
echo ""

echo "=========================================="
echo ""
echo "OR run these commands now:"
echo ""

read -p "Do you want me to run these commands now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd /home/z/zero_world
    
    echo ""
    echo "Stopping nginx..."
    docker-compose stop nginx
    
    echo ""
    echo "Getting certificate..."
    docker-compose run --rm certbot certonly \
        --standalone \
        --preferred-challenges http \
        --email admin@zn-01.com \
        --agree-tos \
        --no-eff-email \
        -d zn-01.com \
        -d www.zn-01.com
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Certificate obtained!"
        echo ""
        echo "Now updating nginx config..."
        
        # Backup
        cp nginx/nginx.conf nginx/nginx.conf.pre-letsencrypt
        
        # Update
        sed -i 's|/etc/ssl/certs/zn-01.com.crt|/etc/letsencrypt/live/zn-01.com/fullchain.pem|g' nginx/nginx.conf
        sed -i 's|/etc/ssl/private/zn-01.com.key|/etc/letsencrypt/live/zn-01.com/privkey.pem|g' nginx/nginx.conf
        
        echo "Restarting services..."
        docker-compose up -d
        
        sleep 5
        
        echo ""
        echo "🎉🎉🎉 SUCCESS! 🎉🎉🎉"
        echo ""
        echo "Your app is now certified with HTTPS!"
        echo ""
        echo "Test it:"
        echo "  https://zn-01.com"
        echo "  https://www.zn-01.com"
        echo ""
        echo "Check SSL rating:"
        echo "  https://www.ssllabs.com/ssltest/analyze.html?d=zn-01.com"
        echo ""
    else
        echo ""
        echo "❌ Failed to get certificate"
        echo ""
        echo "Common issues:"
        echo "  1. Port 80 blocked by firewall"
        echo "  2. Another service using port 80"
        echo "  3. DNS not fully propagated"
        echo ""
        echo "Starting services again..."
        docker-compose up -d
    fi
fi
