# CRUD Functions for Zero World

This directory contains comprehensive CRUD (Create, Read, Update, Delete) functions for the Zero World application. These functions provide a clean, consistent interface for database operations across all entities in your application.

## 📁 Structure

```
backend/app/crud/
├── __init__.py          # CRUD module initialization
├── base.py              # Base CRUD class with common operations
├── user.py              # User-specific CRUD operations
├── listing.py           # Listing-specific CRUD operations
├── chat.py              # Chat and Message CRUD operations
├── community.py         # Community Post and Comment CRUD operations
├── service.py           # CRUD service setup and dependency injection
└── utils.py             # Database utilities and query builder
```

## 🚀 Features

### Base CRUD Operations (Available for all entities)
- ✅ **Create**: Insert new documents with automatic ID generation and timestamps
- ✅ **Read**: Get single or multiple documents with filtering and pagination
- ✅ **Update**: Update documents with automatic timestamp tracking
- ✅ **Delete**: Hard delete or soft delete (deactivation)
- ✅ **Search**: Text search across multiple fields
- ✅ **Bulk Operations**: Create, update, or delete multiple documents at once
- ✅ **Aggregation**: Run complex MongoDB aggregation queries

### Entity-Specific Operations

#### User CRUD (`CRUDUser`)
- User registration with password hashing
- Authentication and password verification
- Profile updates and password changes
- User search by name or email
- Public profile retrieval (without sensitive data)

#### Listing CRUD (`CRUDListing`)
- Create listings with ownership tracking
- Advanced filtering (category, location, price range)
- Search listings by text
- View count tracking and popular listings
- User's listings management
- Category management
- Activate/deactivate listings

#### Chat & Message CRUD (`CRUDChat`, `CRUDMessage`)
- Create chats between users with duplicate prevention
- Message creation with participant verification
- Message threading and conversation management
- Read status tracking
- Unread message counts
- Message search within chats

#### Community CRUD (`CRUDCommunityPost`, `CRUDCommunityComment`)
- Create posts with tagging system
- Comment management with post association
- Tag-based filtering and search
- Popular posts by likes and time
- Pin/unpin and lock/unlock posts (admin features)
- Comment count tracking

## 🔧 Usage

### 1. Using Dependency Injection (Recommended)

```python
from fastapi import APIRouter, Depends
from app.crud.service import get_listing_crud
from app.crud.listing import CRUDListing

router = APIRouter()

@router.post("/listings/")
async def create_listing(
    payload: ListingCreate,
    current_user=Depends(get_current_user),
    listing_crud: CRUDListing = Depends(get_listing_crud)
):
    listing = listing_crud.create_listing(
        listing_in=payload,
        owner_id=current_user["_id"]
    )
    return ListingPublic(**listing)
```

### 2. Using CRUD Service Class

```python
from app.crud.service import CRUDService

# Initialize service
crud_service = CRUDService(database)

# Use any CRUD operations
user = crud_service.user.create_user(user_in=user_data)
listings = crud_service.listing.get_active_listings(limit=10)
posts = crud_service.community_post.search_posts(query="sustainability")
```

### 3. Direct CRUD Class Usage

```python
from app.crud.user import CRUDUser

# Initialize CRUD instance
user_crud = CRUDUser(database["users"])

# Perform operations
user = user_crud.create_user(user_in=user_data)
found_user = user_crud.get_by_email("user@example.com")
```

## 📝 Examples

### Creating a User
```python
from app.schemas.user import UserCreate

user_data = UserCreate(
    name="John Doe",
    email="john@example.com",
    password="securepassword"
)

user = crud_service.user.create_user(user_in=user_data)
print(f"Created user: {user['name']} ({user['_id']})")
```

### Advanced Listing Search
```python
# Search with multiple filters
listings = crud_service.listing.get_active_listings(
    category="Electronics",
    location="San Francisco",
    min_price=100.0,
    max_price=1000.0,
    limit=20
)

# Text search
results = crud_service.listing.search_listings(
    query="MacBook Pro",
    limit=10
)
```

### Community Operations
```python
from app.schemas.community import CommunityPostCreate

# Create a post
post_data = CommunityPostCreate(
    title="Sustainable Living Tips",
    content="Here are some great tips...",
    tags=["sustainability", "tips", "environment"]
)

post = crud_service.community_post.create_post(
    post_in=post_data,
    author_id=user_id
)

# Add a comment
comment_data = CommunityCommentCreate(content="Great post!")
comment = crud_service.community_comment.create_comment(
    comment_in=comment_data,
    post_id=post['_id'],
    author_id=user_id
)
```

### Chat and Messaging
```python
from app.schemas.chat import ChatCreate, MessageCreate

# Start a chat
chat_data = ChatCreate(participant_id=other_user_id)
chat = crud_service.chat.create_chat(
    chat_in=chat_data,
    user_id=current_user_id
)

# Send a message
message_data = MessageCreate(content="Hello! Is this item still available?")
message = crud_service.message.create_message(
    message_in=message_data,
    chat_id=chat['_id'],
    sender_id=current_user_id
)
```

## 🛠️ Database Utilities

### Query Builder
```python
from app.crud.utils import QueryBuilder

# Build complex queries
query = (QueryBuilder()
    .add_filter("is_active", True)
    .add_filter("price", 500, "$lte")
    .add_text_search("MacBook", ["title", "description"])
    .add_sort("created_at", -1)
    .build())

results = collection.find(query["filter"])
```

### Database Statistics
```python
from app.crud.utils import DatabaseUtils

collections = crud_service.get_all_collections()
stats = DatabaseUtils.get_collection_stats(collections)
print(f"Users: {stats['users']['total_count']}")
print(f"Active listings: {stats['listings']['active_count']}")
```

### Index Management
```python
# Create recommended indexes
DatabaseUtils.create_indexes(collections)

# Cleanup old data
cleanup_results = DatabaseUtils.cleanup_old_data(collections, days_to_keep=365)
```

## 🧪 Testing

Run the example script to test all CRUD operations:

```bash
cd backend
python crud_examples.py
```

This will:
1. Create sample users, listings, posts, and chats
2. Demonstrate all CRUD operations
3. Show advanced querying and utilities
4. Clean up test data

## 🔒 Security Features

- **Password Hashing**: Automatic password hashing for user creation
- **Ownership Verification**: Users can only modify their own content
- **Input Validation**: All inputs validated through Pydantic schemas
- **Soft Delete**: Important data is deactivated rather than permanently deleted
- **Access Control**: Chat participants verification for message operations

## 📊 Performance Features

- **Pagination**: Built-in pagination for all list operations
- **Indexing**: Comprehensive indexing recommendations
- **Bulk Operations**: Efficient bulk create/update/delete operations
- **Query Optimization**: Query builder for complex, optimized queries
- **Aggregation**: Support for MongoDB aggregation pipelines

## 🚀 Getting Started

1. **Install Dependencies**: Ensure pymongo and FastAPI dependencies are installed
2. **Database Setup**: Make sure MongoDB is running and accessible
3. **Import CRUD**: Import the CRUD classes or use dependency injection
4. **Use Operations**: Start with basic CRUD operations and expand as needed

## 🔄 Migration from Existing Code

To migrate from your existing router code:

1. Replace direct database operations with CRUD methods
2. Use dependency injection to inject CRUD instances
3. Update error handling to use CRUD return values
4. Add pagination and filtering where beneficial

Example migration:
```python
# Before
listings = request.app.database["listings"].find({"is_active": True}).limit(50)

# After
listings = listing_crud.get_active_listings(limit=50)
```

This CRUD system provides a robust foundation for your application's data layer with improved maintainability, consistency, and features.