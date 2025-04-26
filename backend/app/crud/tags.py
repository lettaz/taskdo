from datetime import datetime
from typing import Dict, List, Optional, Any
from bson import ObjectId

from ..core.exceptions import DatabaseException, NotFoundException, ConflictException
from .base import CRUDBase


class CRUDTag(CRUDBase):
    def __init__(self):
        super().__init__("tags")
    
    async def create_tag(self, user_id: str, tag_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new tag for a user.
        
        Args:
            user_id: User ID
            tag_data: Tag data
            
        Returns:
            Created tag
        """
        # Check if a tag with the same name already exists for the user
        existing_tag = await self.get_collection()
        existing = await existing_tag.find_one({
            "user_id": user_id,
            "name": tag_data["name"]
        })
        
        if existing:
            raise ConflictException(detail="Tag with this name already exists")
        
        # Add timestamps and user ID
        db_obj = {
            **tag_data,
            "user_id": user_id,
            "created_at": datetime.utcnow()
        }
        
        # Create tag
        try:
            tag_id = await self.create(db_obj)
            db_obj["_id"] = tag_id
            return db_obj
        except Exception as e:
            raise DatabaseException(detail=f"Error creating tag: {e}")
    
    async def get_tags_by_user(
        self, user_id: str, skip: int = 0, limit: int = 100
    ) -> List[Dict[str, Any]]:
        """
        Get all tags for a user.
        
        Args:
            user_id: User ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of tags
        """
        filters = {"user_id": user_id}
        
        return await self.get_multi(skip=skip, limit=limit, filters=filters)
    
    async def get_tag(self, tag_id: str, user_id: str) -> Dict[str, Any]:
        """
        Get a specific tag for a user.
        
        Args:
            tag_id: Tag ID
            user_id: User ID
            
        Returns:
            Tag details
        """
        tag = await self.get(tag_id)
        
        if not tag or tag.get("user_id") != user_id:
            raise NotFoundException(detail="Tag not found")
        
        return tag
    
    async def update_tag(
        self, tag_id: str, user_id: str, update_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Update a tag.
        
        Args:
            tag_id: Tag ID
            user_id: User ID
            update_data: Tag data to update
            
        Returns:
            Updated tag
        """
        # Verify tag exists and belongs to user
        tag = await self.get_tag(tag_id, user_id)
        
        # Check for duplicate name if name is being updated
        if "name" in update_data and update_data["name"] != tag["name"]:
            existing_tag = await self.get_collection()
            existing = await existing_tag.find_one({
                "user_id": user_id,
                "name": update_data["name"],
                "_id": {"$ne": ObjectId(tag_id)}
            })
            
            if existing:
                raise ConflictException(detail="Tag with this name already exists")
        
        # Update tag
        updated = await self.update(tag_id, update_data)
        
        if not updated:
            raise DatabaseException(detail="Failed to update tag")
        
        # Get updated tag
        return await self.get_tag(tag_id, user_id)
    
    async def delete_tag(self, tag_id: str, user_id: str) -> bool:
        """
        Delete a tag.
        
        Args:
            tag_id: Tag ID
            user_id: User ID
            
        Returns:
            Whether the tag was deleted
        """
        # Verify tag exists and belongs to user
        await self.get_tag(tag_id, user_id)
        
        # Delete tag
        return await self.delete(tag_id)


tag_crud = CRUDTag()
