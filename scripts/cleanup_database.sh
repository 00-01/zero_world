#!/bin/bash

echo "🧹 Zero World Database Cleanup & Setup"
echo "======================================"

# Database connection details
DB_HOST="localhost"
DB_PORT="27017"
DB_USER="root"
DB_PASS="example"
DB_AUTH="admin"

echo ""
echo "📋 Current Database Status:"
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH --eval "
console.log('Databases:');
db.adminCommand('listDatabases').databases.forEach(db => {
    if (db.name !== 'admin' && db.name !== 'config' && db.name !== 'local') {
        console.log('• ' + db.name + ' (' + (db.sizeOnDisk/1024).toFixed(2) + ' KB)');
    }
});
"

echo ""
echo "🗑️ Cleaning up old data..."

# Drop existing databases to start fresh
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH --eval "
console.log('Dropping zeromarket database...');
db.getSiblingDB('zeromarket').dropDatabase();
console.log('Dropping zero_world database (if exists)...');
db.getSiblingDB('zero_world').dropDatabase();
console.log('✅ Cleanup complete');
"

echo ""
echo "🔧 Setting up Zero World database..."

# Create the new database with proper collections and indexes
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH --eval "
// Switch to zero_world database
db = db.getSiblingDB('zero_world');

console.log('Creating collections with proper schema...');

// Create users collection with indexes
console.log('• Creating users collection');
db.createCollection('users');
db.users.createIndex({ 'email': 1 }, { unique: true });
db.users.createIndex({ 'created_at': -1 });

// Create listings collection with indexes  
console.log('• Creating listings collection');
db.createCollection('listings');
db.listings.createIndex({ 'owner_id': 1 });
db.listings.createIndex({ 'is_active': 1, 'created_at': -1 });
db.listings.createIndex({ 'category': 1 });
db.listings.createIndex({ 'price': 1 });
db.listings.createIndex({ 'title': 'text', 'description': 'text' });

// Create chats collection with indexes
console.log('• Creating chats collection');
db.createCollection('chats');
db.chats.createIndex({ 'participants_hash': 1 }, { unique: true });
db.chats.createIndex({ 'participants': 1 });
db.chats.createIndex({ 'listing_context.listing_id': 1 });

// Create messages collection with indexes
console.log('• Creating messages collection');
db.createCollection('messages');
db.messages.createIndex({ 'chat_id': 1, 'created_at': 1 });
db.messages.createIndex({ 'sender_id': 1 });

// Create community_posts collection with indexes
console.log('• Creating community_posts collection');
db.createCollection('community_posts');
db.community_posts.createIndex({ 'author_id': 1 });
db.community_posts.createIndex({ 'created_at': -1 });
db.community_posts.createIndex({ 'tags': 1 });

// Create community_comments collection with indexes
console.log('• Creating community_comments collection');  
db.createCollection('community_comments');
db.community_comments.createIndex({ 'post_id': 1 });
db.community_comments.createIndex({ 'author_id': 1 });
db.community_comments.createIndex({ 'created_at': -1 });

console.log('✅ Database setup complete');
"

echo ""
echo "📊 New Database Structure:"
docker exec zero_world_mongodb_1 mongosh --username $DB_USER --password $DB_PASS --authenticationDatabase $DB_AUTH zero_world --eval "
console.log('Collections in zero_world database:');
db.getCollectionNames().forEach(name => {
    const count = db.getCollection(name).countDocuments();
    const indexes = db.getCollection(name).getIndexes().length;
    console.log('• ' + name + ': ' + count + ' documents, ' + indexes + ' indexes');
});
"

echo ""
echo "🔧 Next Steps:"
echo "1. Update backend configuration to use 'zero_world' database"
echo "2. Restart backend service"
echo "3. Test the application"
echo ""
echo "📋 New MongoDB Compass Connection:"
echo "mongodb://root:example@localhost:27017/zero_world?authSource=admin"