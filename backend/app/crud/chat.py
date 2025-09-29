"""
CRUD operations for Chat and Message collections.
"""
from typing import Dict, List, Optional, Any
from datetime import datetime
from pymongo.collection import Collection
from app.crud.base import CRUDBase
from app.schemas.chat import ChatCreate, MessageCreate


class CRUDChat(CRUDBase):
    def __init__(self, collection: Collection):
        super().__init__(collection)

    def create_chat(self, *, chat_in: ChatCreate, user_id: str) -> Dict[str, Any]:
        """Create a new chat between two users."""
        participants = sorted([user_id, chat_in.participant_id])
        participants_hash = "::".join(participants)
        
        # Check if chat already exists
        existing = self.find_one({"participants_hash": participants_hash})
        if existing:
            return existing
        
        chat_data = {
            "participants": participants,
            "participants_hash": participants_hash,
            "last_message_at": None,
            "last_message": None
        }
        
        return self.create(obj_in=chat_data)

    def get_user_chats(self, *, user_id: str, skip: int = 0, limit: int = 50) -> List[Dict[str, Any]]:
        """Get all chats for a user."""
        filter_dict = {"participants": user_id}
        
        return self.get_multi(
            skip=skip,
            limit=limit,
            filter_dict=filter_dict,
            sort_by="last_message_at"
        )

    def get_chat_between_users(self, *, user1_id: str, user2_id: str) -> Optional[Dict[str, Any]]:
        """Get chat between two specific users."""
        participants = sorted([user1_id, user2_id])
        participants_hash = "::".join(participants)
        
        return self.find_one({"participants_hash": participants_hash})

    def update_last_message(
        self, 
        *, 
        chat_id: str, 
        message_content: str, 
        timestamp: datetime
    ) -> Optional[Dict[str, Any]]:
        """Update the last message info for a chat."""
        update_data = {
            "last_message": message_content,
            "last_message_at": timestamp
        }
        
        return self.update(id=chat_id, obj_in=update_data)

    def is_participant(self, *, chat_id: str, user_id: str) -> bool:
        """Check if user is a participant in the chat."""
        chat = self.get(chat_id)
        return chat is not None and user_id in chat.get("participants", [])


class CRUDMessage(CRUDBase):
    def __init__(self, collection: Collection, chat_crud: CRUDChat):
        super().__init__(collection)
        self.chat_crud = chat_crud

    def create_message(
        self, 
        *, 
        message_in: MessageCreate, 
        chat_id: str, 
        sender_id: str
    ) -> Optional[Dict[str, Any]]:
        """Create a new message in a chat."""
        # Verify user is participant in chat
        if not self.chat_crud.is_participant(chat_id=chat_id, user_id=sender_id):
            return None
        
        message_data = message_in.model_dump()
        additional_fields = {
            "chat_id": chat_id,
            "sender_id": sender_id,
            "is_read": False,
            "edited_at": None
        }
        
        # Create the message
        message = self.create(obj_in=message_data, additional_fields=additional_fields)
        
        # Update chat's last message
        self.chat_crud.update_last_message(
            chat_id=chat_id,
            message_content=message_data["content"],
            timestamp=message["created_at"]
        )
        
        return message

    def get_chat_messages(
        self, 
        *, 
        chat_id: str, 
        user_id: str,
        skip: int = 0, 
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get messages for a chat (only if user is participant)."""
        # Verify user is participant in chat
        if not self.chat_crud.is_participant(chat_id=chat_id, user_id=user_id):
            return []
        
        filter_dict = {"chat_id": chat_id}
        
        return self.get_multi(
            skip=skip,
            limit=limit,
            filter_dict=filter_dict,
            sort_by="created_at"
        )

    def update_message(
        self, 
        *, 
        message_id: str, 
        content: str, 
        sender_id: str
    ) -> Optional[Dict[str, Any]]:
        """Update a message (only by sender)."""
        # Check if message exists and belongs to sender
        existing = self.get(message_id)
        if not existing or existing.get("sender_id") != sender_id:
            return None
        
        update_data = {
            "content": content,
            "edited_at": datetime.utcnow()
        }
        
        return self.update(id=message_id, obj_in=update_data)

    def delete_message(self, *, message_id: str, sender_id: str) -> bool:
        """Delete a message (only by sender)."""
        # Check if message exists and belongs to sender
        existing = self.get(message_id)
        if not existing or existing.get("sender_id") != sender_id:
            return False
        
        return self.delete(id=message_id)

    def mark_as_read(self, *, message_id: str, user_id: str) -> Optional[Dict[str, Any]]:
        """Mark a message as read."""
        message = self.get(message_id)
        if not message:
            return None
        
        # Verify user is participant in the chat
        chat_id = message.get("chat_id")
        if not self.chat_crud.is_participant(chat_id=chat_id, user_id=user_id):
            return None
        
        return self.update(id=message_id, obj_in={"is_read": True})

    def mark_chat_messages_as_read(self, *, chat_id: str, user_id: str) -> int:
        """Mark all unread messages in a chat as read for a user."""
        # Verify user is participant in chat
        if not self.chat_crud.is_participant(chat_id=chat_id, user_id=user_id):
            return 0
        
        # Update all unread messages not sent by the user
        result = self.collection.update_many(
            {
                "chat_id": chat_id,
                "sender_id": {"$ne": user_id},
                "is_read": False
            },
            {
                "$set": {
                    "is_read": True,
                    "updated_at": datetime.utcnow()
                }
            }
        )
        
        return result.modified_count

    def get_unread_count(self, *, user_id: str) -> int:
        """Get total unread message count for a user."""
        # Get all chats for user
        user_chats = self.chat_crud.get_user_chats(user_id=user_id, limit=1000)
        chat_ids = [chat["_id"] for chat in user_chats]
        
        if not chat_ids:
            return 0
        
        # Count unread messages not sent by the user
        return self.collection.count_documents({
            "chat_id": {"$in": chat_ids},
            "sender_id": {"$ne": user_id},
            "is_read": False
        })

    def search_messages(
        self, 
        *, 
        chat_id: str, 
        query: str, 
        user_id: str,
        skip: int = 0, 
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Search messages in a chat."""
        # Verify user is participant in chat
        if not self.chat_crud.is_participant(chat_id=chat_id, user_id=user_id):
            return []
        
        search_filter = {
            "chat_id": chat_id,
            "content": {"$regex": query, "$options": "i"}
        }
        
        return self.find_many(
            search_filter,
            skip=skip,
            limit=limit,
            sort_by="created_at"
        )