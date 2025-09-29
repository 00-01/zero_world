#!/bin/bash
# Script to update MongoDB with new WAN access credentials

echo "🔄 Updating MongoDB for WAN access with new credentials..."

# Stop all services
echo "⏹️  Stopping services..."
docker-compose down

# Remove old MongoDB data to start fresh with new credentials
echo "🗑️  Removing old MongoDB data..."
docker volume rm zero_world_mongodb_data 2>/dev/null || true

# Restart services with new configuration
echo "🚀 Starting services with new configuration..."
docker-compose up -d mongodb

# Wait for MongoDB to be ready
echo "⏳ Waiting for MongoDB to initialize..."
sleep 15

# Check if MongoDB is responding
echo "🔍 Testing MongoDB connection..."
docker exec zero_world_mongodb_1 mongosh --eval "db.adminCommand('ping')" || {
    echo "❌ MongoDB connection test failed"
    exit 1
}

# Start the rest of the services
echo "🚀 Starting remaining services..."
docker-compose up -d

echo "✅ MongoDB WAN access setup complete!"
echo ""
echo "🔐 Connection Details:"
echo "   Host: $(curl -s ifconfig.me || echo 'YOUR_SERVER_IP')"
echo "   Port: 27017"
echo "   Username: zer01"
echo "   Password: wldps2025!"
echo "   Database: zero_world"
echo "   Connection String: mongodb://zer01:wldps2025!@$(curl -s ifconfig.me || echo 'YOUR_SERVER_IP'):27017/zero_world?authSource=admin"
echo ""
echo "📝 Note: Make sure port 27017 is open in your firewall for WAN access"