#!/bin/bash

echo "🔍 MongoDB Compass Connection Test"
echo "=================================="

echo ""
echo "📋 Connection Details:"
echo "  Host: localhost"
echo "  Port: 27017"
echo "  Username: root"
echo "  Password: example"
echo "  Auth Database: admin"
echo "  Target Database: zeromarket"

echo ""
echo "🔗 Connection String:"
echo "mongodb://root:example@localhost:27017/zero_world?authSource=admin"

echo ""
echo "🧪 Testing Connection..."

# Test basic connection
if mongosh --quiet "mongodb://root:example@localhost:27017/zero_world?authSource=admin" --eval "print('✅ Connection successful!')" 2>/dev/null; then
    echo ""
    echo "📊 Database Statistics:"
    mongosh --quiet "mongodb://root:example@localhost:27017/zero_world?authSource=admin" --eval "
        const stats = db.stats();
        print('Database: ' + stats.db);
        print('Collections: ' + stats.collections);
        print('Documents: ' + stats.objects);
        print('Data Size: ' + (stats.dataSize / 1024).toFixed(2) + ' KB');
    "
    
    echo ""
    echo "📋 Collections:"
    mongosh --quiet "mongodb://root:example@localhost:27017/zero_world?authSource=admin" --eval "
        db.getCollectionNames().forEach(function(name) {
            const count = db.getCollection(name).countDocuments();
            print('  • ' + name + ': ' + count + ' documents');
        });
    "
    
    echo ""
    echo "🎉 MongoDB is ready for Compass connection!"
    echo ""
    echo "📝 Next Steps:"
    echo "  1. Open MongoDB Compass"
    echo "  2. Click 'New Connection'"
    echo "  3. Paste connection string (shown above)"
    echo "  4. Click 'Connect'"
    echo ""
    echo "🔍 You'll be able to browse:"
    echo "  • Users (authentication data)"
    echo "  • Listings (marketplace items)"
    echo "  • Chats (conversations)"
    echo "  • Messages (chat messages)"
    echo "  • Community Posts (forum posts)"
    
else
    echo "❌ Connection failed. Checking troubleshooting steps..."
    
    echo ""
    echo "🔧 Troubleshooting:"
    
    # Check if MongoDB container is running
    if docker ps | grep -q mongo; then
        echo "  ✅ MongoDB container is running"
    else
        echo "  ❌ MongoDB container is not running"
        echo "     Run: docker-compose up -d mongodb"
    fi
    
    # Check if port is accessible
    if netstat -an | grep -q ":27017.*LISTEN"; then
        echo "  ✅ Port 27017 is listening"
    else
        echo "  ❌ Port 27017 is not accessible"
        echo "     Check docker-compose.yml ports configuration"
    fi
    
    # Check Docker logs
    echo ""
    echo "📋 Recent MongoDB logs:"
    docker logs zero_world_mongodb_1 --tail 5 2>/dev/null || echo "  Could not retrieve logs"
fi

echo ""
echo "🌐 Web Access:"
echo "  Your app: https://www.zn-01.com"
echo "  API docs: https://www.zn-01.com/api/docs"