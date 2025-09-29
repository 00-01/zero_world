"""
CRUD operations for Listing collection.
"""
from typing import Dict, List, Optional, Any
from datetime import datetime
from pymongo.collection import Collection
from app.crud.base import CRUDBase
from app.schemas.listing import ListingCreate, ListingUpdate


class CRUDListing(CRUDBase):
    def __init__(self, collection: Collection):
        super().__init__(collection)

    def create_listing(self, *, listing_in: ListingCreate, owner_id: str) -> Dict[str, Any]:
        """Create a new listing."""
        listing_data = listing_in.model_dump()
        additional_fields = {
            "owner_id": owner_id,
            "is_active": True,
            "view_count": 0,
            "favorite_count": 0
        }
        
        return self.create(obj_in=listing_data, additional_fields=additional_fields)

    def get_active_listings(
        self, 
        *, 
        skip: int = 0, 
        limit: int = 50,
        category: Optional[str] = None,
        location: Optional[str] = None,
        min_price: Optional[float] = None,
        max_price: Optional[float] = None
    ) -> List[Dict[str, Any]]:
        """Get active listings with optional filtering."""
        filter_dict = {"is_active": True}
        
        if category:
            filter_dict["category"] = {"$regex": category, "$options": "i"}
        
        if location:
            filter_dict["location"] = {"$regex": location, "$options": "i"}
        
        if min_price is not None or max_price is not None:
            price_filter = {}
            if min_price is not None:
                price_filter["$gte"] = min_price
            if max_price is not None:
                price_filter["$lte"] = max_price
            filter_dict["price"] = price_filter
        
        return self.get_multi(
            skip=skip, 
            limit=limit, 
            filter_dict=filter_dict, 
            sort_by="created_at"
        )

    def get_user_listings(
        self, 
        *, 
        owner_id: str, 
        skip: int = 0, 
        limit: int = 50,
        include_inactive: bool = False
    ) -> List[Dict[str, Any]]:
        """Get listings by a specific user."""
        filter_dict = {"owner_id": owner_id}
        
        if not include_inactive:
            filter_dict["is_active"] = True
        
        return self.get_multi(
            skip=skip, 
            limit=limit, 
            filter_dict=filter_dict, 
            sort_by="created_at"
        )

    def update_listing(
        self, 
        *, 
        listing_id: str, 
        listing_update: ListingUpdate,
        owner_id: str
    ) -> Optional[Dict[str, Any]]:
        """Update a listing (only by owner)."""
        # Check if listing exists and belongs to user
        existing = self.get(listing_id)
        if not existing or existing.get("owner_id") != owner_id:
            return None
        
        return self.update(id=listing_id, obj_in=listing_update)

    def deactivate_listing(self, *, listing_id: str, owner_id: str) -> Optional[Dict[str, Any]]:
        """Deactivate a listing (soft delete)."""
        # Check if listing exists and belongs to user
        existing = self.get(listing_id)
        if not existing or existing.get("owner_id") != owner_id:
            return None
        
        return self.update(id=listing_id, obj_in={"is_active": False})

    def reactivate_listing(self, *, listing_id: str, owner_id: str) -> Optional[Dict[str, Any]]:
        """Reactivate a listing."""
        # Check if listing exists and belongs to user
        existing = self.get(listing_id)
        if not existing or existing.get("owner_id") != owner_id:
            return None
        
        return self.update(id=listing_id, obj_in={"is_active": True})

    def search_listings(
        self, 
        *, 
        query: str, 
        skip: int = 0, 
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Search listings by title and description."""
        search_filter = {
            "is_active": True,
            "$or": [
                {"title": {"$regex": query, "$options": "i"}},
                {"description": {"$regex": query, "$options": "i"}},
                {"category": {"$regex": query, "$options": "i"}},
                {"location": {"$regex": query, "$options": "i"}}
            ]
        }
        
        return self.find_many(
            search_filter, 
            skip=skip, 
            limit=limit, 
            sort_by="created_at"
        )

    def increment_view_count(self, *, listing_id: str) -> Optional[Dict[str, Any]]:
        """Increment the view count for a listing."""
        result = self.collection.update_one(
            {"_id": listing_id},
            {"$inc": {"view_count": 1}}
        )
        
        if result.modified_count > 0:
            return self.get(listing_id)
        return None

    def get_popular_listings(self, *, limit: int = 10) -> List[Dict[str, Any]]:
        """Get most viewed active listings."""
        return self.get_multi(
            limit=limit,
            filter_dict={"is_active": True},
            sort_by="view_count"
        )

    def get_recent_listings(self, *, limit: int = 10) -> List[Dict[str, Any]]:
        """Get most recent active listings."""
        return self.get_multi(
            limit=limit,
            filter_dict={"is_active": True},
            sort_by="created_at"
        )

    def get_listings_by_category(
        self, 
        *, 
        category: str, 
        skip: int = 0, 
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get listings by category."""
        filter_dict = {
            "is_active": True,
            "category": {"$regex": f"^{category}$", "$options": "i"}
        }
        
        return self.get_multi(
            skip=skip,
            limit=limit,
            filter_dict=filter_dict,
            sort_by="created_at"
        )

    def get_categories(self) -> List[str]:
        """Get all unique categories."""
        pipeline = [
            {"$match": {"is_active": True, "category": {"$ne": None}}},
            {"$group": {"_id": "$category"}},
            {"$sort": {"_id": 1}}
        ]
        
        results = self.aggregate(pipeline)
        return [result["_id"] for result in results if result["_id"]]