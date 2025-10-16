"""
Database utilities and helper functions.
"""
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional, Union
from pymongo.collection import Collection
from pymongo import ASCENDING, DESCENDING


class DatabaseUtils:
    """Utility class for common database operations."""
    
    @staticmethod
    def create_indexes(collections: Dict[str, Collection]) -> Dict[str, List[str]]:
        """Create recommended indexes for all collections."""
        index_results = {}
        
        try:
            # Users collection indexes
            users = collections.get("users")
            if users:
                user_indexes = []
                user_indexes.append(users.create_index("email", unique=True))
                user_indexes.append(users.create_index("created_at"))
                user_indexes.append(users.create_index([("name", "text"), ("email", "text")]))
                index_results["users"] = user_indexes
            
            # Listings collection indexes
            listings = collections.get("listings")
            if listings:
                listing_indexes = []
                listing_indexes.append(listings.create_index([("is_active", 1), ("created_at", -1)]))
                listing_indexes.append(listings.create_index("owner_id"))
                listing_indexes.append(listings.create_index("category"))
                listing_indexes.append(listings.create_index("location"))
                listing_indexes.append(listings.create_index([("price", 1)]))
                listing_indexes.append(listings.create_index([("title", "text"), ("description", "text")]))
                listing_indexes.append(listings.create_index("view_count"))
                index_results["listings"] = listing_indexes
            
            # Chats collection indexes
            chats = collections.get("chats")
            if chats:
                chat_indexes = []
                chat_indexes.append(chats.create_index("participants_hash", unique=True))
                chat_indexes.append(chats.create_index("participants"))
                chat_indexes.append(chats.create_index("last_message_at"))
                index_results["chats"] = chat_indexes
            
            # Messages collection indexes
            messages = collections.get("messages")
            if messages:
                message_indexes = []
                message_indexes.append(messages.create_index([("chat_id", 1), ("created_at", 1)]))
                message_indexes.append(messages.create_index("sender_id"))
                message_indexes.append(messages.create_index([("chat_id", 1), ("is_read", 1)]))
                message_indexes.append(messages.create_index([("content", "text")]))
                index_results["messages"] = message_indexes
            
            # Community posts collection indexes
            community_posts = collections.get("community_posts")
            if community_posts:
                post_indexes = []
                post_indexes.append(community_posts.create_index([("created_at", -1)]))
                post_indexes.append(community_posts.create_index("author_id"))
                post_indexes.append(community_posts.create_index("tags"))
                post_indexes.append(community_posts.create_index("like_count"))
                post_indexes.append(community_posts.create_index([("title", "text"), ("content", "text")]))
                post_indexes.append(community_posts.create_index("is_pinned"))
                post_indexes.append(community_posts.create_index("is_locked"))
                index_results["community_posts"] = post_indexes
            
            # Community comments collection indexes
            community_comments = collections.get("community_comments")
            if community_comments:
                comment_indexes = []
                comment_indexes.append(community_comments.create_index([("post_id", 1), ("created_at", 1)]))
                comment_indexes.append(community_comments.create_index("author_id"))
                comment_indexes.append(community_comments.create_index([("content", "text")]))
                index_results["community_comments"] = comment_indexes
                
        except Exception as e:
            print(f"Index creation error: {e}")
        
        return index_results
    
    @staticmethod
    def cleanup_old_data(
        collections: Dict[str, Collection], 
        days_to_keep: int = 365
    ) -> Dict[str, int]:
        """Clean up old data from collections."""
        cutoff_date = datetime.utcnow() - timedelta(days=days_to_keep)
        cleanup_results = {}
        
        try:
            # Clean up old inactive listings
            listings = collections.get("listings")
            if listings:
                result = listings.delete_many({
                    "is_active": False,
                    "updated_at": {"$lt": cutoff_date}
                })
                cleanup_results["old_listings"] = result.deleted_count
            
            # Clean up old messages (optional - be careful with this)
            # messages = collections.get("messages")
            # if messages:
            #     result = messages.delete_many({
            #         "created_at": {"$lt": cutoff_date}
            #     })
            #     cleanup_results["old_messages"] = result.deleted_count
            
        except Exception as e:
            print(f"Cleanup error: {e}")
        
        return cleanup_results
    
    @staticmethod
    def get_collection_stats(collections: Dict[str, Collection]) -> Dict[str, Dict]:
        """Get statistics for all collections."""
        stats = {}
        
        for name, collection in collections.items():
            try:
                count = collection.count_documents({})
                size = collection.estimated_document_count()
                
                # Get some basic aggregation stats
                if name == "listings":
                    active_count = collection.count_documents({"is_active": True})
                    categories = list(collection.distinct("category", {"is_active": True}))
                    
                    stats[name] = {
                        "total_count": count,
                        "active_count": active_count,
                        "categories": len(categories),
                        "category_list": categories[:10]  # First 10 categories
                    }
                
                elif name == "users":
                    recent_users = collection.count_documents({
                        "created_at": {"$gte": datetime.utcnow() - timedelta(days=30)}
                    })
                    
                    stats[name] = {
                        "total_count": count,
                        "recent_registrations": recent_users
                    }
                
                elif name == "community_posts":
                    recent_posts = collection.count_documents({
                        "created_at": {"$gte": datetime.utcnow() - timedelta(days=30)}
                    })
                    tags = list(collection.distinct("tags"))
                    
                    stats[name] = {
                        "total_count": count,
                        "recent_posts": recent_posts,
                        "unique_tags": len(tags)
                    }
                
                else:
                    stats[name] = {
                        "total_count": count,
                        "estimated_size": size
                    }
                    
            except Exception as e:
                stats[name] = {"error": str(e)}
        
        return stats
    
    @staticmethod
    def backup_collection_data(
        collection: Collection, 
        filter_query: Optional[Dict] = None
    ) -> List[Dict]:
        """Backup collection data to a list."""
        query = filter_query or {}
        return list(collection.find(query))
    
    @staticmethod
    def restore_collection_data(
        collection: Collection, 
        data: List[Dict], 
        clear_existing: bool = False
    ) -> int:
        """Restore collection data from a list."""
        if clear_existing:
            collection.delete_many({})
        
        if data:
            result = collection.insert_many(data)
            return len(result.inserted_ids)
        
        return 0
    
    @staticmethod
    def migrate_data(
        source_collection: Collection,
        target_collection: Collection,
        transformation_func: Optional[callable] = None,
        batch_size: int = 1000
    ) -> int:
        """Migrate data between collections with optional transformation."""
        migrated_count = 0
        
        cursor = source_collection.find().batch_size(batch_size)
        
        batch = []
        for document in cursor:
            if transformation_func:
                document = transformation_func(document)
            
            batch.append(document)
            
            if len(batch) >= batch_size:
                target_collection.insert_many(batch)
                migrated_count += len(batch)
                batch = []
        
        # Insert remaining documents
        if batch:
            target_collection.insert_many(batch)
            migrated_count += len(batch)
        
        return migrated_count


class QueryBuilder:
    """Helper class for building complex MongoDB queries."""
    
    def __init__(self):
        self.query = {}
        self.sort_criteria = []
        self.projection = {}
    
    def add_filter(self, field: str, value: Any, operator: str = "$eq") -> "QueryBuilder":
        """Add a filter condition to the query."""
        if operator == "$eq":
            self.query[field] = value
        else:
            if field not in self.query:
                self.query[field] = {}
            self.query[field][operator] = value
        return self
    
    def add_text_search(self, text: str, fields: List[str]) -> "QueryBuilder":
        """Add text search across multiple fields."""
        text_conditions = []
        for field in fields:
            text_conditions.append({field: {"$regex": text, "$options": "i"}})
        
        if text_conditions:
            if "$or" in self.query:
                self.query["$and"] = [{"$or": self.query.pop("$or")}, {"$or": text_conditions}]
            else:
                self.query["$or"] = text_conditions
        
        return self
    
    def add_date_range(self, field: str, start_date: datetime, end_date: datetime) -> "QueryBuilder":
        """Add date range filter."""
        self.query[field] = {
            "$gte": start_date,
            "$lte": end_date
        }
        return self
    
    def add_in_filter(self, field: str, values: List[Any]) -> "QueryBuilder":
        """Add 'in' filter for multiple values."""
        self.query[field] = {"$in": values}
        return self
    
    def add_sort(self, field: str, direction: int = -1) -> "QueryBuilder":
        """Add sort criteria."""
        self.sort_criteria.append((field, direction))
        return self
    
    def add_projection(self, fields: List[str], include: bool = True) -> "QueryBuilder":
        """Add field projection."""
        for field in fields:
            self.projection[field] = 1 if include else 0
        return self
    
    def build(self) -> Dict[str, Any]:
        """Build and return the final query."""
        result = {"filter": self.query}
        
        if self.sort_criteria:
            result["sort"] = self.sort_criteria
        
        if self.projection:
            result["projection"] = self.projection
        
        return result
    
    def get_aggregation_pipeline(self) -> List[Dict[str, Any]]:
        """Convert query to aggregation pipeline."""
        pipeline = []
        
        if self.query:
            pipeline.append({"$match": self.query})
        
        if self.sort_criteria:
            sort_dict = {}
            for field, direction in self.sort_criteria:
                sort_dict[field] = direction
            pipeline.append({"$sort": sort_dict})
        
        if self.projection:
            pipeline.append({"$project": self.projection})
        
        return pipeline