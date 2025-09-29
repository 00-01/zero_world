#!/bin/bash

# Get SSL certificates for the domain
echo "Getting SSL certificates for zn-01.com and www.zn-01.com..."

# Run certbot to get certificates
docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email admin@zn-01.com \
    --agree-tos \
    --no-eff-email \
    -d zn-01.com \
    -d www.zn-01.com

# Check if certificates were created
if [ -f "/etc/letsencrypt/live/zn-01.com/fullchain.pem" ]; then
    echo "✅ SSL certificates obtained successfully!"
    echo "🔄 Restarting nginx to use SSL certificates..."
    docker-compose restart nginx
    echo "✅ Setup complete! Your site should now be available at https://www.zn-01.com"
else
    echo "❌ Failed to obtain SSL certificates"
    echo "ℹ️  Your site is still available at http://www.zn-01.com"
fi