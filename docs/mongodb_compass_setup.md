# MongoDB Compass Connection Guide for Zero World

## 🔌 Connection Details

**MongoDB Connection Information:**
- **Host**: `localhost` (or `127.0.0.1`)
- **Port**: `27017`
- **Authentication**: Yes
- **Username**: `root`
- **Password**: `example`
- **Authentication Database**: `admin`
- **Database Name**: `zero_world`

## 📋 Connection String

Use this connection string in MongoDB Compass:

```
mongodb://root:example@localhost:27017/zero_world?authSource=admin
```

## 🚀 Step-by-Step Connection in MongoDB Compass

### Method 1: Using Connection String (Recommended)

1. **Open MongoDB Compass**
2. **Click "New Connection"**
3. **Paste the connection string**:
   ```
   mongodb://root:example@localhost:27017/zeromarket?authSource=admin
   ```
4. **Click "Connect"**

### Method 2: Manual Configuration

1. **Open MongoDB Compass**
2. **Click "New Connection"**
3. **Fill in the details**:
   - **Hostname**: `localhost`
   - **Port**: `27017`
   - **Authentication**: `Username/Password`
   - **Username**: `root`
   - **Password**: `example`
   - **Authentication Database**: `admin`
   - **Default Database**: `zero_world`
4. **Click "Connect"**

## 📊 Database Structure

Once connected, you'll see the following collections in the `zero_world` database:

### 🏪 Collections Overview:

1. **`users`** - User accounts and authentication data
   - Contains user profiles, emails, hashed passwords
   - Used for login and user management

2. **`listings`** - Marketplace listings
   - Product/service listings with titles, descriptions, prices
   - Connected to users via `owner_id`

3. **`chats`** - Chat conversations
   - Chat rooms between users
   - Can be linked to specific listings

4. **`messages`** - Individual chat messages
   - Messages within chat conversations
   - Links to chats via `chat_id`

5. **`community_posts`** - Community forum posts
   - User-generated content and discussions
   - Links to users via `author_id`

## 🔍 Useful Queries to Try in Compass

### View All Users
```javascript
// In the users collection
{}
```

### View Active Listings
```javascript
// In the listings collection
{ "is_active": true }
```

### View Recent Messages
```javascript
// In the messages collection, sort by created_at descending
{}
// Then sort by: { "created_at": -1 }
```

### Find User by Email
```javascript
// In the users collection
{ "email": "test@example.com" }
```

### Find Listings by Price Range
```javascript
// In the listings collection
{ "price": { "$gte": 10, "$lte": 100 } }
```

## 🛠️ MongoDB Compass Features You Can Use

### 1. **Schema Analysis**
- Click on any collection
- Go to "Schema" tab
- See data types and field distribution

### 2. **Query Builder**
- Use the visual query builder for complex queries
- No need to write MongoDB syntax

### 3. **Aggregation Pipeline Builder**
- Create complex data transformations visually
- Export to code when ready

### 4. **Index Management**
- View existing indexes
- Create new indexes for performance
- Analyze query performance

### 5. **Real-time Data**
- Enable "Real Time" to see live updates
- Useful when testing the app

### 6. **Export/Import Data**
- Export collections to JSON/CSV
- Import data from files
- Backup and restore functionality

## 🔒 Security Notes

- **Development Environment**: These credentials are for development only
- **Production**: Change username/password for production deployment
- **Network Access**: Currently accessible from localhost only
- **Firewall**: Port 27017 is now open on your local machine

## 🚨 Troubleshooting

### Connection Failed?
1. **Check Docker**: `docker ps | grep mongo`
2. **Check Port**: `netstat -an | grep 27017`
3. **Check Logs**: `docker logs zero_world_mongodb_1`

### Authentication Error?
1. **Verify Credentials**: Username=`root`, Password=`example`
2. **Check Auth Database**: Must be `admin`
3. **Connection String**: Use the exact string provided above

### Database Not Found?
1. **Check Database Name**: Should be `zeromarket` (not `zero_world`)
2. **Run App First**: The database is created when the app runs
3. **Create Test Data**: Use the app to create some users/listings

## 🔄 Restart Services if Needed

If you need to restart MongoDB:

```bash
cd /home/z/zero_world
docker-compose restart mongodb
```

Or restart all services:
```bash
cd /home/z/zero_world
docker-compose down && docker-compose up -d
```

## ✅ Success Indicators

You'll know the connection is working when:

- ✅ MongoDB Compass shows "Connected" status
- ✅ You can see the `zeromarket` database
- ✅ Collections (`users`, `listings`, `chats`, `messages`, `community_posts`) are visible
- ✅ You can browse documents in each collection
- ✅ Schema analysis shows actual data structure

Happy database browsing! 🎉