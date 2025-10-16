"""
CRUD service setup and dependency injection.
"""
from typing import Generator
from fastapi import Depends, Request
from pymongo.database import Database

from app.crud.user import CRUDUser
from app.crud.listing import CRUDListing
from app.crud.chat import CRUDChat, CRUDMessage
from app.crud.community import CRUDCommunityPost, CRUDCommunityComment


def get_database(request: Request) -> Database:
    """Get database from request app."""
    return request.app.database


def get_user_crud(db: Database = Depends(get_database)) -> CRUDUser:
    """Get User CRUD instance."""
    return CRUDUser(db["users"])


def get_listing_crud(db: Database = Depends(get_database)) -> CRUDListing:
    """Get Listing CRUD instance."""
    return CRUDListing(db["listings"])


def get_chat_crud(db: Database = Depends(get_database)) -> CRUDChat:
    """Get Chat CRUD instance."""
    return CRUDChat(db["chats"])


def get_message_crud(
    db: Database = Depends(get_database), 
    chat_crud: CRUDChat = Depends(get_chat_crud)
) -> CRUDMessage:
    """Get Message CRUD instance."""
    return CRUDMessage(db["messages"], chat_crud)


def get_community_post_crud(db: Database = Depends(get_database)) -> CRUDCommunityPost:
    """Get Community Post CRUD instance."""
    return CRUDCommunityPost(db["community_posts"])


def get_community_comment_crud(
    db: Database = Depends(get_database),
    post_crud: CRUDCommunityPost = Depends(get_community_post_crud)
) -> CRUDCommunityComment:
    """Get Community Comment CRUD instance."""
    return CRUDCommunityComment(db["community_comments"], post_crud)


class CRUDService:
    """
    Main service class that provides access to all CRUD operations.
    Can be used as an alternative to dependency injection.
    """
    
    def __init__(self, database: Database):
        self.database = database
        
        # Initialize CRUD instances
        self.user = CRUDUser(database["users"])
        self.listing = CRUDListing(database["listings"])
        self.chat = CRUDChat(database["chats"])
        self.message = CRUDMessage(database["messages"], self.chat)
        self.community_post = CRUDCommunityPost(database["community_posts"])
        self.community_comment = CRUDCommunityComment(database["community_comments"], self.community_post)
    
    def get_all_collections(self) -> dict:
        """Get all collections for batch operations."""
        return {
            "users": self.database["users"],
            "listings": self.database["listings"], 
            "chats": self.database["chats"],
            "messages": self.database["messages"],
            "community_posts": self.database["community_posts"],
            "community_comments": self.database["community_comments"]
        }
    
    def health_check(self) -> dict:
        """Check database connectivity and collection stats."""
        try:
            # Ping database
            self.database.command("ping")
            
            collections = self.get_all_collections()
            stats = {}
            
            for name, collection in collections.items():
                try:
                    count = collection.count_documents({})
                    stats[name] = {"count": count, "status": "ok"}
                except Exception as e:
                    stats[name] = {"count": 0, "status": f"error: {str(e)}"}
            
            return {
                "database_status": "ok",
                "collections": stats
            }
            
        except Exception as e:
            return {
                "database_status": f"error: {str(e)}",
                "collections": {}
            }