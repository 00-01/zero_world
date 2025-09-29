#!/bin/bash

echo "🔒 Manual SSL Certificate Setup for zn-01.com"
echo "=============================================="

# Step 1: Check current status
echo "Step 1: Checking current setup..."
echo "Current server IP: $(curl -s ifconfig.me)"
echo "Testing current HTTP access..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/health 2>/dev/null)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ HTTP access working (status: $HTTP_STATUS)"
else
    echo "❌ HTTP access failed (status: $HTTP_STATUS)"
    echo "Please ensure HTTP is working first before getting SSL certificates"
    exit 1
fi

# Step 2: Stop nginx to free port 80 for standalone certbot
echo ""
echo "Step 2: Temporarily stopping nginx to free port 80..."
docker-compose stop nginx

# Wait a moment for port to be freed
sleep 3

# Step 3: Use certbot standalone method
echo ""
echo "Step 3: Requesting SSL certificates from Let's Encrypt..."
echo "This may take a few minutes..."

sudo certbot certonly \
    --standalone \
    --preferred-challenges http \
    --http-01-port 80 \
    --email admin@zn-01.com \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d zn-01.com \
    -d www.zn-01.com

# Step 4: Check if certificates were obtained
if [ -f "/etc/letsencrypt/live/zn-01.com/fullchain.pem" ]; then
    echo ""
    echo "✅ SSL certificates obtained successfully!"
    
    # Show certificate details
    echo ""
    echo "📋 Certificate Information:"
    sudo openssl x509 -in /etc/letsencrypt/live/zn-01.com/fullchain.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
    
    # Step 5: Update nginx configuration to use SSL
    echo ""
    echo "Step 5: Updating nginx configuration to use SSL certificates..."
    
    # Backup current config
    cp /home/z/zero_world/docker-compose.yml /home/z/zero_world/docker-compose.yml.backup
    
    # Update docker-compose.yml to use production nginx config with SSL
    sed -i 's|nginx-http-only.conf|nginx-prod.conf|g' /home/z/zero_world/docker-compose.yml
    
    # Step 6: Start services with SSL configuration
    echo ""
    echo "Step 6: Starting services with SSL configuration..."
    docker-compose up -d
    
    # Wait for services to start
    sleep 10
    
    # Step 7: Test SSL access
    echo ""
    echo "Step 7: Testing SSL access..."
    
    HTTPS_STATUS=$(curl -s -k -o /dev/null -w "%{http_code}" https://www.zn-01.com/health 2>/dev/null)
    if [ "$HTTPS_STATUS" -eq 200 ]; then
        echo "✅ HTTPS access working (status: $HTTPS_STATUS)"
        
        echo ""
        echo "🎉 SSL Setup Complete!"
        echo "===================="
        echo "🌐 Your website is now available at:"
        echo "   • https://www.zn-01.com"
        echo "   • https://zn-01.com"
        echo "   • https://www.zn-01.com/api/"
        echo "   • https://www.zn-01.com/health"
        echo ""
        echo "🔒 SSL Certificate Details:"
        echo "   • Issuer: Let's Encrypt"
        echo "   • Valid for: zn-01.com, www.zn-01.com"
        echo "   • Auto-renewal: Set up with certbot"
        
        # Test both HTTP and HTTPS
        echo ""
        echo "🧪 Final Tests:"
        echo "HTTP Health: $(curl -s http://www.zn-01.com/health)"
        echo "HTTPS Health: $(curl -s -k https://www.zn-01.com/health)"
        
    else
        echo "⚠️  HTTPS not working yet (status: $HTTPS_STATUS)"
        echo "Certificates obtained but there might be a configuration issue"
        echo "Check nginx logs: docker-compose logs nginx"
    fi
    
else
    echo ""
    echo "❌ Failed to obtain SSL certificates"
    echo ""
    echo "Possible reasons:"
    echo "• Port 80 not accessible from internet"
    echo "• Firewall blocking connections"
    echo "• Domain not pointing to this server"
    echo "• Rate limiting from Let's Encrypt"
    
    echo ""
    echo "🔄 Reverting to HTTP-only configuration..."
    docker-compose start nginx
    
    echo ""
    echo "Your site is still available at:"
    echo "• http://www.zn-01.com"
fi

echo ""
echo "📝 Logs saved to: /var/log/letsencrypt/letsencrypt.log"