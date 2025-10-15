"""
CRUD operations for User collection.
"""
from typing import Dict, List, Optional, Any
from pymongo.collection import Collection
from app.crud.base import CRUDBase
from app.schemas.user import UserCreate, UserPublic
from app.core.security import get_password_hash


class CRUDUser(CRUDBase):
    def __init__(self, collection: Collection):
        super().__init__(collection)

    def create_user(self, *, user_in: UserCreate) -> Dict[str, Any]:
        """Create a new user with hashed password."""
        user_data = user_in.model_dump()
        user_data["hashed_password"] = get_password_hash(user_data.pop("password"))
        user_data["email"] = user_data["email"].lower()
        user_data["bio"] = None
        user_data["avatar_url"] = None
        
        return self.create(obj_in=user_data)

    def get_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get user by email address."""
        return self.find_one({"email": email.lower()})

    def authenticate(self, email: str, password: str) -> Optional[Dict[str, Any]]:
        """Authenticate user by email and password."""
        from app.core.security import verify_password
        
        user = self.get_by_email(email)
        if not user:
            return None
        
        if not verify_password(password, user.get("hashed_password", "")):
            return None
        
        return user

    def update_profile(self, *, user_id: str, profile_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Update user profile information."""
        # Remove sensitive fields that shouldn't be updated directly
        safe_fields = {k: v for k, v in profile_data.items() 
                      if k not in ["hashed_password", "_id", "created_at"]}
        
        if "email" in safe_fields:
            safe_fields["email"] = safe_fields["email"].lower()
        
        return self.update(id=user_id, obj_in=safe_fields)

    def change_password(self, *, user_id: str, new_password: str) -> Optional[Dict[str, Any]]:
        """Change user password."""
        hashed_password = get_password_hash(new_password)
        return self.update(id=user_id, obj_in={"hashed_password": hashed_password})

    def get_active_users(self, *, skip: int = 0, limit: int = 100) -> List[Dict[str, Any]]:
        """Get active users (could be extended with is_active field)."""
        return self.get_multi(skip=skip, limit=limit, sort_by="created_at")

    def search_users(self, *, query: str, skip: int = 0, limit: int = 20) -> List[Dict[str, Any]]:
        """Search users by name or email."""
        search_filter = {
            "$or": [
                {"name": {"$regex": query, "$options": "i"}},
                {"email": {"$regex": query, "$options": "i"}}
            ]
        }
        return self.find_many(search_filter, skip=skip, limit=limit, sort_by="name", sort_order=1)

    def get_public_profile(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user's public profile (without sensitive data)."""
        user = self.get(user_id)
        if not user:
            return None
        
        # Remove sensitive information
        user.pop("hashed_password", None)
        return user

    def delete_user(self, *, user_id: str) -> bool:
        """Delete a user (consider soft delete for production)."""
        # In production, you might want to soft delete and anonymize data
        return self.delete(id=user_id)