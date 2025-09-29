#!/bin/bash
# MongoDB initialization script for WAN access

# Create admin user and database
cat > /docker-entrypoint-initdb.d/init-mongo.js << 'EOF'
// Switch to admin database for authentication
db = db.getSiblingDB('admin');

// Create the root user with new credentials
db.createUser({
  user: 'zer01',
  pwd: 'wldps2025!',
  roles: [
    { role: 'userAdminAnyDatabase', db: 'admin' },
    { role: 'readWriteAnyDatabase', db: 'admin' },
    { role: 'dbAdminAnyDatabase', db: 'admin' },
    { role: 'clusterAdmin', db: 'admin' }
  ]
});

// Switch to zero_world database
db = db.getSiblingDB('zero_world');

// Create application user for the zero_world database
db.createUser({
  user: 'zer01',
  pwd: 'wldps2025!',
  roles: [
    { role: 'readWrite', db: 'zero_world' }
  ]
});

// Create collections and indexes
db.createCollection('users');
db.createCollection('listings');
db.createCollection('chats');
db.createCollection('messages');
db.createCollection('community_posts');
db.createCollection('community_comments');

// Create indexes
db.users.createIndex({ "email": 1 }, { unique: true });
db.chats.createIndex({ "participants_hash": 1 }, { unique: true });
db.messages.createIndex({ "chat_id": 1, "created_at": 1 });
db.listings.createIndex({ "is_active": 1, "created_at": -1 });
db.community_posts.createIndex({ "community_id": 1, "created_at": -1 });
db.community_comments.createIndex({ "post_id": 1, "created_at": -1 });

print("Database initialization complete!");
EOF