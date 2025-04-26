from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from bson import ObjectId

from ..core.exceptions import DatabaseException, NotFoundException
from ..crud.tasks import task_crud
from .base import CRUDBase


class CRUDPomodoro(CRUDBase):
    def __init__(self):
        super().__init__("pomodoro_sessions")
    
    async def start_session(
        self, user_id: str, task_id: str, session_type: str
    ) -> Dict[str, Any]:
        """
        Start a new Pomodoro session.
        
        Args:
            user_id: User ID
            task_id: Task ID
            session_type: Session type (work or break)
            
        Returns:
            Created session
        """
        # Verify task exists and belongs to user
        await task_crud.get_task(task_id, user_id)
        
        # Create session
        now = datetime.utcnow()
        session_data = {
            "user_id": user_id,
            "task_id": task_id,
            "start_time": now,
            "end_time": None,
            "duration": None,
            "type": session_type,
            "completed": None,
            "interrupted": None,
            "created_at": now
        }
        
        try:
            session_id = await self.create(session_data)
            session_data["_id"] = session_id
            return session_data
        except Exception as e:
            raise DatabaseException(detail=f"Error starting Pomodoro session: {e}")
    
    async def end_session(
        self, session_id: str, user_id: str, completed: bool, interrupted: bool
    ) -> Dict[str, Any]:
        """
        End a Pomodoro session.
        
        Args:
            session_id: Session ID
            user_id: User ID
            completed: Whether the session was completed
            interrupted: Whether the session was interrupted
            
        Returns:
            Updated session
        """
        # Get session
        session = await self.get(session_id)
        
        if not session or session.get("user_id") != user_id:
            raise NotFoundException(detail="Pomodoro session not found")
        
        if session.get("end_time"):
            raise DatabaseException(detail="Session already ended")
        
        # Update session
        now = datetime.utcnow()
        start_time = session.get("start_time")
        duration = int((now - start_time).total_seconds())
        
        update_data = {
            "end_time": now,
            "duration": duration,
            "completed": completed,
            "interrupted": interrupted
        }
        
        updated = await self.update(session_id, update_data)
        
        if not updated:
            raise DatabaseException(detail="Failed to end Pomodoro session")
        
        # If completed and it's a work session, increment completed pomodoros for the task
        if completed and session.get("type") == "work":
            await task_crud.increment_completed_pomodoros(session.get("task_id"), user_id)
        
        # Get updated session
        return await self.get(session_id)
    
    async def get_sessions_by_user(
        self,
        user_id: str,
        from_date: Optional[datetime] = None,
        to_date: Optional[datetime] = None,
        task_id: Optional[str] = None,
        session_type: Optional[str] = None,
        completed: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """
        Get Pomodoro sessions for a user with optional filtering.
        
        Args:
            user_id: User ID
            from_date: Start date for filtering
            to_date: End date for filtering
            task_id: Filter by task
            session_type: Filter by session type
            completed: Filter by completion status
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of Pomodoro sessions
        """
        filters = {"user_id": user_id}
        
        date_filter = {}
        if from_date:
            date_filter["$gte"] = from_date
        if to_date:
            date_filter["$lte"] = to_date
        
        if date_filter:
            filters["start_time"] = date_filter
        
        if task_id:
            filters["task_id"] = task_id
        
        if session_type:
            filters["type"] = session_type
        
        if completed is not None:
            filters["completed"] = completed
        
        return await self.get_multi(skip=skip, limit=limit, filters=filters)
    
    async def get_session(self, session_id: str, user_id: str) -> Dict[str, Any]:
        """
        Get a specific Pomodoro session.
        
        Args:
            session_id: Session ID
            user_id: User ID
            
        Returns:
            Pomodoro session details
        """
        session = await self.get(session_id)
        
        if not session or session.get("user_id") != user_id:
            raise NotFoundException(detail="Pomodoro session not found")
        
        return session
    
    async def get_stats(
        self,
        user_id: str,
        from_date: Optional[datetime] = None,
        to_date: Optional[datetime] = None,
        task_id: Optional[str] = None,
        project_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Get Pomodoro statistics for a user.
        
        Args:
            user_id: User ID
            from_date: Start date for filtering
            to_date: End date for filtering
            task_id: Filter by task
            project_id: Filter by project
            
        Returns:
            Pomodoro statistics
        """
        # Build match stage for aggregation
        match_stage = {"user_id": user_id, "type": "work"}
        
        if from_date or to_date:
            date_filter = {}
            if from_date:
                date_filter["$gte"] = from_date
            if to_date:
                date_filter["$lte"] = to_date
            match_stage["start_time"] = date_filter
        
        if task_id:
            match_stage["task_id"] = task_id
        
        # Get project tasks if project_id is provided
        if project_id:
            project_tasks = await task_crud.get_tasks_by_user(
                user_id, project_id=project_id
            )
            if project_tasks:
                task_ids = [str(task["_id"]) for task in project_tasks]
                match_stage["task_id"] = {"$in": task_ids}
        
        # Get total stats
        collection = await self.get_collection()
        
        total_sessions = await collection.count_documents(match_stage)
        
        # Only proceed with aggregation if there are sessions
        if total_sessions == 0:
            return {
                "total_sessions": 0,
                "total_work_time": 0,
                "total_completed": 0,
                "total_interrupted": 0,
                "sessions_by_day": {},
                "sessions_by_task": {},
                "sessions_by_project": {}
            }
        
        # Add filters for completed sessions
        completed_match = {**match_stage, "completed": True}
        interrupted_match = {**match_stage, "interrupted": True}
        
        total_completed = await collection.count_documents(completed_match)
        total_interrupted = await collection.count_documents(interrupted_match)
        
        # Calculate total work time
        pipeline = [
            {"$match": match_stage},
            {"$group": {"_id": None, "total_duration": {"$sum": "$duration"}}}
        ]
        
        duration_result = await self.aggregate(pipeline)
        total_work_time = duration_result[0]["total_duration"] if duration_result else 0
        
        # Get sessions by day
        pipeline = [
            {"$match": match_stage},
            {
                "$group": {
                    "_id": {
                        "$dateToString": {
                            "format": "%Y-%m-%d",
                            "date": "$start_time"
                        }
                    },
                    "count": {"$sum": 1}
                }
            }
        ]
        
        day_results = await self.aggregate(pipeline)
        sessions_by_day = {result["_id"]: result["count"] for result in day_results}
        
        # Get sessions by task
        pipeline = [
            {"$match": match_stage},
            {"$group": {"_id": "$task_id", "count": {"$sum": 1}}}
        ]
        
        task_results = await self.aggregate(pipeline)
        sessions_by_task = {str(result["_id"]): result["count"] for result in task_results}
        
        # Get sessions by project
        # This requires a join with the tasks collection
        sessions_by_project = {}
        
        if sessions_by_task:
            for task_id, count in sessions_by_task.items():
                try:
                    task = await task_crud.get_task(task_id, user_id)
                    if task and task.get("project_id"):
                        project_id = task["project_id"]
                        if project_id in sessions_by_project:
                            sessions_by_project[project_id] += count
                        else:
                            sessions_by_project[project_id] = count
                except:
                    # Skip if task not found or other error
                    continue
        
        return {
            "total_sessions": total_sessions,
            "total_work_time": total_work_time,
            "total_completed": total_completed,
            "total_interrupted": total_interrupted,
            "sessions_by_day": sessions_by_day,
            "sessions_by_task": sessions_by_task,
            "sessions_by_project": sessions_by_project
        }


pomodoro_crud = CRUDPomodoro()
