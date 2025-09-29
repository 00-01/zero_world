#!/bin/bash

echo "🔒 Setting up HTTPS for www.zn-01.com"
echo "======================================"

# Step 1: Ensure HTTP is working first
echo "Step 1: Testing HTTP access..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/health)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ HTTP access working (status: $HTTP_STATUS)"
else
    echo "❌ HTTP access failed (status: $HTTP_STATUS)"
    echo "Please ensure the site is accessible over HTTP first"
    exit 1
fi

# Step 2: Test ACME challenge directory
echo ""
echo "Step 2: Testing ACME challenge path..."
echo "test-$(date)" > /home/z/zero_world/certbot/www/test-challenge.txt
CHALLENGE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://www.zn-01.com/.well-known/acme-challenge/test-challenge.txt)
if [ "$CHALLENGE_STATUS" -eq 200 ]; then
    echo "✅ ACME challenge path accessible"
    rm -f /home/z/zero_world/certbot/www/test-challenge.txt
else
    echo "❌ ACME challenge path failed (status: $CHALLENGE_STATUS)"
    echo "This is required for Let's Encrypt certificate generation"
fi

# Step 3: Manual certificate generation command
echo ""
echo "Step 3: Manual certificate generation"
echo "======================================"
echo "Run the following command to get SSL certificates:"
echo ""
echo "sudo certbot certonly --webroot \\"
echo "  --webroot-path=/home/z/zero_world/certbot/www \\"
echo "  --email admin@zn-01.com \\"
echo "  --agree-tos \\"
echo "  --no-eff-email \\"
echo "  -d zn-01.com \\"
echo "  -d www.zn-01.com"
echo ""
echo "After getting certificates, update docker-compose.yml to use:"
echo "  - ./nginx/nginx-prod.conf:/etc/nginx/nginx.conf:ro"
echo ""
echo "Then restart: docker-compose restart nginx"

# Step 4: Current status
echo ""
echo "Step 4: Current Status"
echo "====================="
echo "🌐 Your website is accessible at:"
echo "   • http://www.zn-01.com/"
echo "   • http://zn-01.com/"
echo ""
echo "🔧 API endpoints available at:"
echo "   • http://www.zn-01.com/api/"
echo "   • http://www.zn-01.com/api/health"
echo ""
echo "📊 Health check:"
echo "   • http://www.zn-01.com/health"
echo ""

# Test some key endpoints
echo "Testing key endpoints:"
echo "----------------------"

echo -n "Health check: "
curl -s http://www.zn-01.com/health

echo -n "API health: "
curl -s http://www.zn-01.com/api/health | jq -r '.status // "unknown"'

echo -n "Main site: "
if curl -s http://www.zn-01.com/ | grep -q "DOCTYPE html"; then
    echo "✅ Loading"
else
    echo "❌ Not loading properly"
fi

echo ""
echo "🎉 Your Zero World application is now accessible at www.zn-01.com!"