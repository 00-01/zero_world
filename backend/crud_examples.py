#!/usr/bin/env python3
"""
Example usage of CRUD functions.
This script demonstrates how to use the CRUD operations.
"""
import asyncio
import os
from datetime import datetime
from pymongo import MongoClient

from app.crud.service import CRUDService
from app.schemas.user import UserCreate
from app.schemas.listing import ListingCreate
from app.schemas.community import CommunityPostCreate
from app.schemas.chat import ChatCreate, MessageCreate


def get_database():
    """Get database connection."""
    mongodb_url = os.getenv("MONGODB_URL", "mongodb://localhost:27017/")
    client = MongoClient(mongodb_url)
    return client["zeromarket"]


def example_user_operations(crud_service: CRUDService):
    """Example user CRUD operations."""
    print("=== User Operations ===")
    
    # Create a user
    user_data = UserCreate(
        name="John Doe",
        email="john.doe@example.com", 
        password="securepassword123"
    )
    
    user = crud_service.user.create_user(user_in=user_data)
    print(f"Created user: {user['name']} ({user['_id']})")
    
    # Get user by email
    found_user = crud_service.user.get_by_email("john.doe@example.com")
    if found_user:
        print(f"Found user by email: {found_user['name']}")
    
    # Update user profile
    updated_user = crud_service.user.update_profile(
        user_id=user['_id'],
        profile_data={"bio": "Software developer passionate about sustainability"}
    )
    if updated_user:
        print(f"Updated user bio: {updated_user['bio']}")
    
    # Search users
    users = crud_service.user.search_users(query="john")
    print(f"Found {len(users)} users matching 'john'")
    
    return user


def example_listing_operations(crud_service: CRUDService, user_id: str):
    """Example listing CRUD operations."""
    print("\n=== Listing Operations ===")
    
    # Create listings
    listing_data = ListingCreate(
        title="MacBook Pro 2021",
        description="Excellent condition MacBook Pro with M1 chip. Barely used, perfect for students or professionals.",
        price=1200.00,
        category="Electronics",
        location="San Francisco, CA",
        image_urls=["https://example.com/macbook1.jpg", "https://example.com/macbook2.jpg"]
    )
    
    listing = crud_service.listing.create_listing(
        listing_in=listing_data,
        owner_id=user_id
    )
    print(f"Created listing: {listing['title']} - ${listing['price']}")
    
    # Create another listing
    bike_listing = ListingCreate(
        title="Mountain Bike - Trek",
        description="Great mountain bike for trails. Well maintained with recent tune-up.",
        price=450.00,
        category="Sports",
        location="Portland, OR"
    )
    
    bike = crud_service.listing.create_listing(
        listing_in=bike_listing,
        owner_id=user_id
    )
    print(f"Created listing: {bike['title']} - ${bike['price']}")
    
    # Get active listings
    active_listings = crud_service.listing.get_active_listings(limit=10)
    print(f"Found {len(active_listings)} active listings")
    
    # Search listings
    search_results = crud_service.listing.search_listings(query="MacBook")
    print(f"Found {len(search_results)} listings matching 'MacBook'")
    
    # Get listings by category
    electronics = crud_service.listing.get_listings_by_category(category="Electronics")
    print(f"Found {len(electronics)} electronics listings")
    
    # Increment view count
    viewed_listing = crud_service.listing.increment_view_count(listing_id=listing['_id'])
    if viewed_listing:
        print(f"Incremented view count for listing: {viewed_listing['view_count']} views")
    
    # Get user's listings
    user_listings = crud_service.listing.get_user_listings(owner_id=user_id)
    print(f"User has {len(user_listings)} listings")
    
    return listing, bike


def example_community_operations(crud_service: CRUDService, user_id: str):
    """Example community CRUD operations."""
    print("\n=== Community Operations ===")
    
    # Create a community post
    post_data = CommunityPostCreate(
        title="Tips for Sustainable Living",
        content="Here are some great tips I've learned for reducing waste and living more sustainably. First, always carry a reusable water bottle...",
        tags=["sustainability", "tips", "environment", "lifestyle"]
    )
    
    post = crud_service.community_post.create_post(
        post_in=post_data,
        author_id=user_id
    )
    print(f"Created post: {post['title']}")
    
    # Create another post
    marketplace_post = CommunityPostCreate(
        title="Welcome to Zero World!",
        content="This is a community for sharing and trading items sustainably. Let's build a circular economy together!",
        tags=["welcome", "community", "marketplace"]
    )
    
    welcome_post = crud_service.community_post.create_post(
        post_in=marketplace_post,
        author_id=user_id
    )
    print(f"Created post: {welcome_post['title']}")
    
    # Get posts
    recent_posts = crud_service.community_post.get_posts(limit=10)
    print(f"Found {len(recent_posts)} recent posts")
    
    # Search posts
    search_results = crud_service.community_post.search_posts(query="sustainable")
    print(f"Found {len(search_results)} posts matching 'sustainable'")
    
    # Get posts by tag
    tagged_posts = crud_service.community_post.get_posts_by_tag(tag="sustainability")
    print(f"Found {len(tagged_posts)} posts with 'sustainability' tag")
    
    # Add a comment
    from app.schemas.community import CommunityCommentCreate
    comment_data = CommunityCommentCreate(
        content="Great tips! I especially like the reusable water bottle suggestion."
    )
    
    comment = crud_service.community_comment.create_comment(
        comment_in=comment_data,
        post_id=post['_id'],
        author_id=user_id
    )
    if comment:
        print(f"Added comment to post: {comment['content'][:50]}...")
    
    # Get post comments
    comments = crud_service.community_comment.get_post_comments(post_id=post['_id'])
    print(f"Post has {len(comments)} comments")
    
    return post, welcome_post


def example_chat_operations(crud_service: CRUDService, user1_id: str):
    """Example chat and message CRUD operations."""
    print("\n=== Chat Operations ===")
    
    # Create a second user for chat
    user2_data = UserCreate(
        name="Jane Smith",
        email="jane.smith@example.com",
        password="anotherpassword123"
    )
    user2 = crud_service.user.create_user(user_in=user2_data)
    print(f"Created second user: {user2['name']}")
    
    # Create a chat
    chat_data = ChatCreate(participant_id=user2['_id'])
    chat = crud_service.chat.create_chat(
        chat_in=chat_data,
        user_id=user1_id
    )
    print(f"Created chat between users")
    
    # Send messages
    message1_data = MessageCreate(
        content="Hi! I'm interested in your MacBook listing. Is it still available?"
    )
    message1 = crud_service.message.create_message(
        message_in=message1_data,
        chat_id=chat['_id'],
        sender_id=user2['_id']
    )
    print(f"User2 sent message: {message1['content'][:50]}...")
    
    message2_data = MessageCreate(
        content="Yes, it's still available! Would you like to meet to see it?"
    )
    message2 = crud_service.message.create_message(
        message_in=message2_data,
        chat_id=chat['_id'],
        sender_id=user1_id
    )
    print(f"User1 replied: {message2['content'][:50]}...")
    
    # Get chat messages
    messages = crud_service.message.get_chat_messages(
        chat_id=chat['_id'],
        user_id=user1_id
    )
    print(f"Chat has {len(messages)} messages")
    
    # Get user's chats
    user_chats = crud_service.chat.get_user_chats(user_id=user1_id)
    print(f"User1 has {len(user_chats)} chats")
    
    return chat, user2


def example_advanced_operations(crud_service: CRUDService):
    """Example advanced operations."""
    print("\n=== Advanced Operations ===")
    
    # Get collection statistics
    stats = crud_service.database.command("dbStats")
    print(f"Database size: ~{stats.get('dataSize', 0) / 1024 / 1024:.2f} MB")
    
    # Bulk operations example
    from app.crud.utils import DatabaseUtils, QueryBuilder
    
    collections = crud_service.get_all_collections()
    
    # Get collection stats
    collection_stats = DatabaseUtils.get_collection_stats(collections)
    for name, stats in collection_stats.items():
        if 'total_count' in stats:
            print(f"{name}: {stats['total_count']} documents")
    
    # Query builder example
    query_builder = QueryBuilder()
    query_builder.add_filter("is_active", True)
    query_builder.add_filter("price", 500, "$lte")
    query_builder.add_sort("created_at", -1)
    
    query_result = query_builder.build()
    print(f"Built query: {query_result['filter']}")
    
    # Use the query with listings
    affordable_listings = crud_service.listing.find_many(
        filter_dict=query_result['filter'],
        limit=5
    )
    print(f"Found {len(affordable_listings)} affordable listings")


def main():
    """Main function demonstrating all CRUD operations."""
    print("Zero World CRUD Examples")
    print("=" * 50)
    
    # Initialize database and CRUD service
    database = get_database()
    crud_service = CRUDService(database)
    
    # Health check
    health = crud_service.health_check()
    print(f"Database status: {health['database_status']}")
    
    try:
        # Run examples
        user = example_user_operations(crud_service)
        listing, bike = example_listing_operations(crud_service, user['_id'])
        post, welcome_post = example_community_operations(crud_service, user['_id'])
        chat, user2 = example_chat_operations(crud_service, user['_id'])
        example_advanced_operations(crud_service)
        
        print("\n=== Summary ===")
        print("✅ User operations completed")
        print("✅ Listing operations completed") 
        print("✅ Community operations completed")
        print("✅ Chat operations completed")
        print("✅ Advanced operations completed")
        print("\nAll CRUD operations demonstrated successfully!")
        
    except Exception as e:
        print(f"Error during operations: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        # Clean up test data (optional)
        print("\nCleaning up test data...")
        # You might want to remove test data here
        pass


if __name__ == "__main__":
    main()