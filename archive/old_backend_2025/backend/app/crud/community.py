"""
CRUD operations for Community Posts and Comments.
"""
from typing import Dict, List, Optional, Any
from datetime import datetime
from pymongo.collection import Collection
from app.crud.base import CRUDBase
from app.schemas.community import CommunityPostCreate, CommunityCommentCreate


class CRUDCommunityPost(CRUDBase):
    def __init__(self, collection: Collection):
        super().__init__(collection)

    def create_post(self, *, post_in: CommunityPostCreate, author_id: str) -> Dict[str, Any]:
        """Create a new community post."""
        post_data = post_in.model_dump()
        additional_fields = {
            "author_id": author_id,
            "like_count": 0,
            "comment_count": 0,
            "is_pinned": False,
            "is_locked": False
        }
        
        return self.create(obj_in=post_data, additional_fields=additional_fields)

    def get_posts(
        self, 
        *, 
        skip: int = 0, 
        limit: int = 50,
        tag: Optional[str] = None,
        author_id: Optional[str] = None,
        include_locked: bool = True
    ) -> List[Dict[str, Any]]:
        """Get community posts with optional filtering."""
        filter_dict = {}
        
        if tag:
            filter_dict["tags"] = tag
        
        if author_id:
            filter_dict["author_id"] = author_id
        
        if not include_locked:
            filter_dict["is_locked"] = {"$ne": True}
        
        return self.get_multi(
            skip=skip,
            limit=limit,
            filter_dict=filter_dict,
            sort_by="created_at"
        )

    def get_post_by_id(self, *, post_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific post by ID."""
        return self.get(post_id)

    def update_post(
        self, 
        *, 
        post_id: str, 
        post_data: Dict[str, Any], 
        author_id: str
    ) -> Optional[Dict[str, Any]]:
        """Update a post (only by author)."""
        # Check if post exists and belongs to author
        existing = self.get(post_id)
        if not existing or existing.get("author_id") != author_id:
            return None
        
        # Remove fields that shouldn't be updated directly
        safe_fields = {k: v for k, v in post_data.items() 
                      if k not in ["_id", "author_id", "created_at", "like_count", "comment_count"]}
        
        return self.update(id=post_id, obj_in=safe_fields)

    def delete_post(self, *, post_id: str, author_id: str) -> bool:
        """Delete a post (only by author)."""
        # Check if post exists and belongs to author
        existing = self.get(post_id)
        if not existing or existing.get("author_id") != author_id:
            return False
        
        return self.delete(id=post_id)

    def search_posts(
        self, 
        *, 
        query: str, 
        skip: int = 0, 
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Search posts by title and content."""
        search_filter = {
            "$or": [
                {"title": {"$regex": query, "$options": "i"}},
                {"content": {"$regex": query, "$options": "i"}},
                {"tags": {"$regex": query, "$options": "i"}}
            ],
            "is_locked": {"$ne": True}
        }
        
        return self.find_many(
            search_filter,
            skip=skip,
            limit=limit,
            sort_by="created_at"
        )

    def get_posts_by_tag(
        self, 
        *, 
        tag: str, 
        skip: int = 0, 
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get posts with a specific tag."""
        filter_dict = {
            "tags": tag,
            "is_locked": {"$ne": True}
        }
        
        return self.get_multi(
            skip=skip,
            limit=limit,
            filter_dict=filter_dict,
            sort_by="created_at"
        )

    def get_popular_posts(
        self, 
        *, 
        limit: int = 10, 
        days: int = 7
    ) -> List[Dict[str, Any]]:
        """Get most liked posts in the last N days."""
        from datetime import timedelta
        
        since_date = datetime.utcnow() - timedelta(days=days)
        filter_dict = {
            "created_at": {"$gte": since_date},
            "is_locked": {"$ne": True}
        }
        
        return self.get_multi(
            limit=limit,
            filter_dict=filter_dict,
            sort_by="like_count"
        )

    def get_pinned_posts(self) -> List[Dict[str, Any]]:
        """Get pinned posts."""
        filter_dict = {"is_pinned": True}
        
        return self.get_multi(
            filter_dict=filter_dict,
            sort_by="created_at"
        )

    def pin_post(self, *, post_id: str) -> Optional[Dict[str, Any]]:
        """Pin a post (admin function)."""
        return self.update(id=post_id, obj_in={"is_pinned": True})

    def unpin_post(self, *, post_id: str) -> Optional[Dict[str, Any]]:
        """Unpin a post (admin function)."""
        return self.update(id=post_id, obj_in={"is_pinned": False})

    def lock_post(self, *, post_id: str) -> Optional[Dict[str, Any]]:
        """Lock a post (admin function)."""
        return self.update(id=post_id, obj_in={"is_locked": True})

    def unlock_post(self, *, post_id: str) -> Optional[Dict[str, Any]]:
        """Unlock a post (admin function)."""
        return self.update(id=post_id, obj_in={"is_locked": False})

    def increment_comment_count(self, *, post_id: str) -> Optional[Dict[str, Any]]:
        """Increment comment count for a post."""
        result = self.collection.update_one(
            {"_id": post_id},
            {"$inc": {"comment_count": 1}}
        )
        
        if result.modified_count > 0:
            return self.get(post_id)
        return None

    def decrement_comment_count(self, *, post_id: str) -> Optional[Dict[str, Any]]:
        """Decrement comment count for a post."""
        result = self.collection.update_one(
            {"_id": post_id},
            {"$inc": {"comment_count": -1}}
        )
        
        if result.modified_count > 0:
            return self.get(post_id)
        return None

    def get_all_tags(self) -> List[str]:
        """Get all unique tags used in posts."""
        pipeline = [
            {"$unwind": "$tags"},
            {"$group": {"_id": "$tags"}},
            {"$sort": {"_id": 1}}
        ]
        
        results = self.aggregate(pipeline)
        return [result["_id"] for result in results if result["_id"]]


class CRUDCommunityComment(CRUDBase):
    def __init__(self, collection: Collection, post_crud: CRUDCommunityPost):
        super().__init__(collection)
        self.post_crud = post_crud

    def create_comment(
        self, 
        *, 
        comment_in: CommunityCommentCreate, 
        post_id: str, 
        author_id: str
    ) -> Optional[Dict[str, Any]]:
        """Create a new comment on a post."""
        # Check if post exists and is not locked
        post = self.post_crud.get(post_id)
        if not post or post.get("is_locked"):
            return None
        
        comment_data = comment_in.model_dump()
        additional_fields = {
            "post_id": post_id,
            "author_id": author_id,
            "like_count": 0,
            "is_edited": False
        }
        
        # Create the comment
        comment = self.create(obj_in=comment_data, additional_fields=additional_fields)
        
        # Increment comment count on post
        self.post_crud.increment_comment_count(post_id=post_id)
        
        return comment

    def get_post_comments(
        self, 
        *, 
        post_id: str, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Get comments for a specific post."""
        filter_dict = {"post_id": post_id}
        
        return self.get_multi(
            skip=skip,
            limit=limit,
            filter_dict=filter_dict,
            sort_by="created_at",
            sort_order=1  # Oldest first for comments
        )

    def update_comment(
        self, 
        *, 
        comment_id: str, 
        content: str, 
        author_id: str
    ) -> Optional[Dict[str, Any]]:
        """Update a comment (only by author)."""
        # Check if comment exists and belongs to author
        existing = self.get(comment_id)
        if not existing or existing.get("author_id") != author_id:
            return None
        
        update_data = {
            "content": content,
            "is_edited": True
        }
        
        return self.update(id=comment_id, obj_in=update_data)

    def delete_comment(self, *, comment_id: str, author_id: str) -> bool:
        """Delete a comment (only by author)."""
        # Check if comment exists and belongs to author
        existing = self.get(comment_id)
        if not existing or existing.get("author_id") != author_id:
            return False
        
        post_id = existing.get("post_id")
        
        # Delete the comment
        if self.delete(id=comment_id):
            # Decrement comment count on post
            if post_id:
                self.post_crud.decrement_comment_count(post_id=post_id)
            return True
        
        return False

    def get_user_comments(
        self, 
        *, 
        author_id: str, 
        skip: int = 0, 
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get comments by a specific user."""
        filter_dict = {"author_id": author_id}
        
        return self.get_multi(
            skip=skip,
            limit=limit,
            filter_dict=filter_dict,
            sort_by="created_at"
        )