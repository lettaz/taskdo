from datetime import datetime
from typing import Dict, List, Optional, Any
from bson import ObjectId

from ..core.exceptions import DatabaseException, NotFoundException
from .base import CRUDBase, _convert_object_ids
from ..schemas.project import ProjectResponse


class CRUDProject(CRUDBase):
    def __init__(self):
        super().__init__("projects")
    
    async def create_project(
        self, user_id: str, project_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Create a new project for a user.
        
        Args:
            user_id: User ID
            project_data: Project data
            
        Returns:
            Created project
        """
        # Add timestamps and user ID
        db_obj = {
            **project_data,
            "user_id": user_id,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "is_archived": False
        }
        
        # Create project
        try:
            project_id = await self.create(db_obj)
            db_obj["_id"] = project_id if isinstance(project_id, ObjectId) else ObjectId(project_id)
            return ProjectResponse.from_mongo(db_obj).dict(by_alias=True)
        except Exception as e:
            raise DatabaseException(detail=f"Error creating project: {e}")
    
    async def get_projects_by_user(
        self, user_id: str, skip: int = 0, limit: int = 100, include_archived: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Get all projects for a user.
        
        Args:
            user_id: User ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            include_archived: Whether to include archived projects
            
        Returns:
            List of projects
        """
        filters = {"user_id": user_id}
        
        if not include_archived:
            filters["is_archived"] = False
        
        collection = await self.get_collection()
        cursor = collection.find(filters).skip(skip).limit(limit)
        results = await cursor.to_list(length=limit)
        
        return [ProjectResponse.from_mongo(doc).dict(by_alias=True) for doc in results]
    
    async def get_project(self, project_id: str, user_id: str) -> Dict[str, Any]:
        """
        Get a specific project for a user.
        
        Args:
            project_id: Project ID
            user_id: User ID
            
        Returns:
            Project details
        """
        collection = await self.get_collection()
        project = await collection.find_one({"_id": ObjectId(project_id)})
        
        if not project or project.get("user_id") != user_id:
            raise NotFoundException(detail="Project not found")
        
        return ProjectResponse.from_mongo(project).dict(by_alias=True)
    
    async def update_project(
        self, project_id: str, user_id: str, update_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Update a project.
        
        Args:
            project_id: Project ID
            user_id: User ID
            update_data: Project data to update
            
        Returns:
            Updated project
        """
        # Verify project exists and belongs to user
        collection = await self.get_collection()
        project = await collection.find_one({"_id": ObjectId(project_id)})
        
        if not project or project.get("user_id") != user_id:
            raise NotFoundException(detail="Project not found")
        
        # Add update timestamp
        db_obj = {
            **update_data,
            "updated_at": datetime.utcnow()
        }
        
        # Update project
        result = await collection.update_one(
            {"_id": ObjectId(project_id)},
            {"$set": db_obj}
        )
        
        if result.modified_count == 0:
            raise DatabaseException(detail="Failed to update project")
        
        # Get updated project
        updated_project = await collection.find_one({"_id": ObjectId(project_id)})
        return ProjectResponse.from_mongo(updated_project).dict(by_alias=True)
    
    async def archive_project(self, project_id: str, user_id: str) -> bool:
        """
        Archive a project.
        
        Args:
            project_id: Project ID
            user_id: User ID
            
        Returns:
            Whether the project was archived
        """
        # Verify project exists and belongs to user
        collection = await self.get_collection()
        project = await collection.find_one({"_id": ObjectId(project_id)})
        
        if not project or project.get("user_id") != user_id:
            raise NotFoundException(detail="Project not found")
        
        # Archive project
        result = await collection.update_one(
            {"_id": ObjectId(project_id)},
            {"$set": {
                "is_archived": True,
                "updated_at": datetime.utcnow()
            }}
        )
        
        return result.modified_count > 0


project_crud = CRUDProject()
