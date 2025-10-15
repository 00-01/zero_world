"""
Base CRUD operations for MongoDB collections.
"""
from datetime import datetime
from typing import Any, Dict, List, Optional, Type, TypeVar, Union
from uuid import uuid4

from pydantic import BaseModel
from pymongo.collection import Collection
from pymongo.errors import DuplicateKeyError

ModelType = TypeVar("ModelType", bound=BaseModel)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class CRUDBase:
    def __init__(self, collection: Collection):
        self.collection = collection

    def create(
        self, 
        *, 
        obj_in: Union[CreateSchemaType, Dict[str, Any]], 
        additional_fields: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Create a new document in the collection."""
        if isinstance(obj_in, BaseModel):
            obj_data = obj_in.model_dump()
        else:
            obj_data = obj_in.copy()
        
        # Add default fields
        obj_data["_id"] = str(uuid4())
        obj_data["created_at"] = datetime.utcnow()
        obj_data["updated_at"] = None
        
        # Add any additional fields
        if additional_fields:
            obj_data.update(additional_fields)
        
        try:
            self.collection.insert_one(obj_data)
            return obj_data
        except DuplicateKeyError as e:
            raise ValueError(f"Document with this data already exists: {e}")

    def get(self, id: str) -> Optional[Dict[str, Any]]:
        """Get a document by ID."""
        return self.collection.find_one({"_id": id})

    def get_multi(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
        filter_dict: Optional[Dict[str, Any]] = None,
        sort_by: Optional[str] = None,
        sort_order: int = -1
    ) -> List[Dict[str, Any]]:
        """Get multiple documents with optional filtering and pagination."""
        query = filter_dict or {}
        
        cursor = self.collection.find(query).skip(skip).limit(min(limit, 100))
        
        if sort_by:
            cursor = cursor.sort(sort_by, sort_order)
        
        return list(cursor)

    def update(
        self,
        *,
        id: str,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]]
    ) -> Optional[Dict[str, Any]]:
        """Update a document by ID."""
        # Check if document exists
        existing = self.collection.find_one({"_id": id})
        if not existing:
            return None
        
        if isinstance(obj_in, BaseModel):
            update_data = obj_in.model_dump(exclude_unset=True)
        else:
            update_data = obj_in.copy()
        
        # Remove None values and empty updates
        update_data = {k: v for k, v in update_data.items() if v is not None}
        
        if not update_data:
            return existing
        
        # Add updated timestamp
        update_data["updated_at"] = datetime.utcnow()
        
        # Update the document
        self.collection.update_one(
            {"_id": id}, 
            {"$set": update_data}
        )
        
        # Return updated document
        existing.update(update_data)
        return existing

    def delete(self, *, id: str) -> bool:
        """Delete a document by ID."""
        result = self.collection.delete_one({"_id": id})
        return result.deleted_count > 0

    def soft_delete(self, *, id: str) -> Optional[Dict[str, Any]]:
        """Soft delete a document by setting is_active to False."""
        return self.update(
            id=id, 
            obj_in={"is_active": False, "deleted_at": datetime.utcnow()}
        )

    def count(self, filter_dict: Optional[Dict[str, Any]] = None) -> int:
        """Count documents matching the filter."""
        query = filter_dict or {}
        return self.collection.count_documents(query)

    def exists(self, filter_dict: Dict[str, Any]) -> bool:
        """Check if a document exists matching the filter."""
        return self.collection.find_one(filter_dict) is not None

    def find_one(self, filter_dict: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Find a single document matching the filter."""
        return self.collection.find_one(filter_dict)

    def find_many(
        self,
        filter_dict: Dict[str, Any],
        *,
        skip: int = 0,
        limit: int = 100,
        sort_by: Optional[str] = None,
        sort_order: int = -1
    ) -> List[Dict[str, Any]]:
        """Find multiple documents matching the filter."""
        cursor = self.collection.find(filter_dict).skip(skip).limit(min(limit, 100))
        
        if sort_by:
            cursor = cursor.sort(sort_by, sort_order)
        
        return list(cursor)

    def aggregate(self, pipeline: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Perform an aggregation query."""
        return list(self.collection.aggregate(pipeline))

    def bulk_create(self, objects: List[Union[CreateSchemaType, Dict[str, Any]]]) -> List[Dict[str, Any]]:
        """Create multiple documents at once."""
        documents = []
        for obj in objects:
            if isinstance(obj, BaseModel):
                obj_data = obj.model_dump()
            else:
                obj_data = obj.copy()
            
            obj_data["_id"] = str(uuid4())
            obj_data["created_at"] = datetime.utcnow()
            obj_data["updated_at"] = None
            documents.append(obj_data)
        
        if documents:
            self.collection.insert_many(documents)
        
        return documents

    def bulk_update(self, updates: List[Dict[str, Any]]) -> int:
        """Update multiple documents at once."""
        if not updates:
            return 0
        
        operations = []
        for update in updates:
            if "_id" not in update:
                continue
            
            doc_id = update.pop("_id")
            update["updated_at"] = datetime.utcnow()
            
            operations.append({
                "updateOne": {
                    "filter": {"_id": doc_id},
                    "update": {"$set": update}
                }
            })
        
        if operations:
            result = self.collection.bulk_write(operations)
            return result.modified_count
        
        return 0

    def bulk_delete(self, ids: List[str]) -> int:
        """Delete multiple documents by IDs."""
        if not ids:
            return 0
        
        result = self.collection.delete_many({"_id": {"$in": ids}})
        return result.deleted_count