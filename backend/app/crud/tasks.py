from datetime import datetime
from typing import Dict, List, Optional, Any
from bson import ObjectId

from ..core.exceptions import DatabaseException, NotFoundException
from ..schemas.task import TaskStatus
from .base import CRUDBase


class CRUDTask(CRUDBase):
    def __init__(self):
        super().__init__("tasks")
    
    async def create_task(
        self, user_id: str, task_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Create a new task for a user.
        
        Args:
            user_id: User ID
            task_data: Task data
            
        Returns:
            Created task
        """
        # Add timestamps, user ID, and default values
        db_obj = {
            **task_data,
            "user_id": user_id,
            "completed_pomodoros": 0,
            "status": TaskStatus.NOT_STARTED,
            "subtasks": [],
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "is_archived": False,
            "is_deleted": False
        }
        
        # Create task
        try:
            task_id = await self.create(db_obj)
            db_obj["_id"] = task_id
            return db_obj
        except Exception as e:
            raise DatabaseException(detail=f"Error creating task: {e}")
    
    async def get_tasks_by_user(
        self,
        user_id: str,
        project_id: Optional[str] = None,
        status: Optional[str] = None,
        priority: Optional[str] = None,
        tag_id: Optional[str] = None,
        include_deleted: bool = False,
        skip: int = 0,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """
        Get tasks for a user with optional filtering.
        
        Args:
            user_id: User ID
            project_id: Optional filter by project ID
            status: Optional filter by status
            priority: Optional filter by priority
            tag_id: Optional filter by tag ID
            include_deleted: Whether to include deleted tasks
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of tasks
        """
        filters = {"user_id": user_id}
        
        if project_id:
            filters["project_id"] = project_id
        
        if status:
            filters["status"] = status
        
        if priority:
            filters["priority"] = priority
        
        if tag_id:
            filters["tags"] = tag_id
        
        if not include_deleted:
            filters["is_deleted"] = False
        
        return await self.get_multi(skip=skip, limit=limit, filters=filters)
    
    async def get_task(
        self, task_id: str, user_id: str, include_deleted: bool = False
    ) -> Dict[str, Any]:
        """
        Get a specific task for a user.
        
        Args:
            task_id: Task ID
            user_id: User ID
            include_deleted: Whether to include deleted tasks
            
        Returns:
            Task details
        """
        task = await self.get(task_id)
        
        if not task or task.get("user_id") != user_id:
            raise NotFoundException(detail="Task not found")
        
        if task.get("is_deleted", False) and not include_deleted:
            raise NotFoundException(detail="Task has been deleted")
        
        return task
    
    async def update_task(
        self, task_id: str, user_id: str, update_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Update a task.
        
        Args:
            task_id: Task ID
            user_id: User ID
            update_data: Task data to update
            
        Returns:
            Updated task
        """
        # Verify task exists and belongs to user
        task = await self.get_task(task_id, user_id)
        
        # Add update timestamp
        db_obj = {
            **update_data,
            "updated_at": datetime.utcnow()
        }
        
        # Update task
        updated = await self.update(task_id, db_obj)
        
        if not updated:
            raise DatabaseException(detail="Failed to update task")
        
        # Get updated task
        return await self.get_task(task_id, user_id)
    
    async def update_task_status(
        self, task_id: str, user_id: str, status: str
    ) -> Dict[str, Any]:
        """
        Update a task's status.
        
        Args:
            task_id: Task ID
            user_id: User ID
            status: New status
            
        Returns:
            Updated task
        """
        return await self.update_task(task_id, user_id, {"status": status})
    
    async def delete_task(self, task_id: str, user_id: str) -> bool:
        """
        Soft delete a task (mark as deleted).
        
        Args:
            task_id: Task ID
            user_id: User ID
            
        Returns:
            Whether the task was marked as deleted
        """
        # Verify task exists and belongs to user
        await self.get_task(task_id, user_id)
        
        # Mark as deleted
        db_obj = {
            "is_deleted": True,
            "updated_at": datetime.utcnow()
        }
        
        return await self.update(task_id, db_obj)
    
    async def increment_completed_pomodoros(
        self, task_id: str, user_id: str
    ) -> Dict[str, Any]:
        """
        Increment the completed pomodoros count for a task.
        
        Args:
            task_id: Task ID
            user_id: User ID
            
        Returns:
            Updated task
        """
        # Verify task exists and belongs to user
        task = await self.get_task(task_id, user_id)
        
        collection = await self.get_collection()
        
        # Increment completed_pomodoros and update timestamp
        result = await collection.update_one(
            {"_id": ObjectId(task_id)},
            {
                "$inc": {"completed_pomodoros": 1},
                "$set": {"updated_at": datetime.utcnow()}
            }
        )
        
        if result.modified_count == 0:
            raise DatabaseException(detail="Failed to update completed pomodoros")
        
        # Get updated task
        return await self.get_task(task_id, user_id)


task_crud = CRUDTask()
