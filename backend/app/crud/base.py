from typing import Any, Dict, List, Optional, Union
from bson import ObjectId
from pymongo.results import DeleteResult, InsertOneResult, UpdateResult
from ..db.mongodb import db
from ..core.exceptions import DatabaseException


def _convert_object_ids(obj: Any) -> Any:
    """
    Convert MongoDB ObjectIds to strings recursively.
    
    Args:
        obj: Object to convert
        
    Returns:
        Converted object
    """
    if isinstance(obj, ObjectId):
        return str(obj)
    elif isinstance(obj, dict):
        # Revert: Convert all ObjectIds, including _id
        return {k: _convert_object_ids(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [_convert_object_ids(item) for item in obj]
    return obj


class CRUDBase:
    def __init__(self, collection_name: str):
        self.collection_name = collection_name
    
    async def get_collection(self):
        """Get the MongoDB collection."""
        return db.get_database()[self.collection_name]
    
    async def get(self, id: str) -> Optional[Dict[str, Any]]:
        """Get a document by ID."""
        try:
            collection = await self.get_collection()
            result = await collection.find_one({"_id": ObjectId(id)})
            return _convert_object_ids(result) if result else None
        except Exception as e:
            raise DatabaseException(detail=f"Error retrieving document: {e}")
    
    async def get_by_field(self, field: str, value: Any) -> Optional[Dict[str, Any]]:
        """Get a document by a specific field."""
        try:
            collection = await self.get_collection()
            result = await collection.find_one({field: value})
            return _convert_object_ids(result) if result else None
        except Exception as e:
            raise DatabaseException(detail=f"Error retrieving document: {e}")
    
    async def get_multi(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """Get multiple documents."""
        try:
            collection = await self.get_collection()
            query = filters or {}
            cursor = collection.find(query).skip(skip).limit(limit)
            results = await cursor.to_list(length=limit)
            return [_convert_object_ids(doc) for doc in results]
        except Exception as e:
            raise DatabaseException(detail=f"Error retrieving documents: {e}")
    
    async def create(self, obj_in: Dict[str, Any]) -> str:
        """Create a new document."""
        try:
            collection = await self.get_collection()
            result: InsertOneResult = await collection.insert_one(obj_in)
            return str(result.inserted_id)
        except Exception as e:
            raise DatabaseException(detail=f"Error creating document: {e}")
    
    async def update(
        self,
        id: str,
        obj_in: Dict[str, Any]
    ) -> bool:
        """Update a document by ID."""
        try:
            collection = await self.get_collection()
            result: UpdateResult = await collection.update_one(
                {"_id": ObjectId(id)},
                {"$set": obj_in}
            )
            return result.modified_count > 0
        except Exception as e:
            raise DatabaseException(detail=f"Error updating document: {e}")
    
    async def delete(self, id: str) -> bool:
        """Delete a document by ID."""
        try:
            collection = await self.get_collection()
            result: DeleteResult = await collection.delete_one({"_id": ObjectId(id)})
            return result.deleted_count > 0
        except Exception as e:
            raise DatabaseException(detail=f"Error deleting document: {e}")
    
    async def count(self, filters: Optional[Dict[str, Any]] = None) -> int:
        """Count documents with optional filtering."""
        try:
            collection = await self.get_collection()
            query = filters or {}
            return await collection.count_documents(query)
        except Exception as e:
            raise DatabaseException(detail=f"Error counting documents: {e}")
    
    async def aggregate(self, pipeline: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Execute an aggregation pipeline."""
        try:
            collection = await self.get_collection()
            cursor = collection.aggregate(pipeline)
            results = await cursor.to_list(length=None)
            return [_convert_object_ids(doc) for doc in results]
        except Exception as e:
            raise DatabaseException(detail=f"Error executing aggregation: {e}")
