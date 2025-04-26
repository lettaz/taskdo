from datetime import datetime
from enum import Enum
from typing import List, Optional, Any
from pydantic import BaseModel, Field, validator

from .common import PyObjectId, MongoBaseModel


class TaskStatus(str, Enum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"


class TaskPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class SubTask(BaseModel):
    description: str
    completed: bool = False
    
    class Config:
        schema_extra = {
            "example": {
                "description": "Research competitors",
                "completed": False
            }
        }


class TaskBase(BaseModel):
    name: str
    project_id: Optional[str] = None
    estimated_pomodoros: Optional[int] = None
    due_date: Optional[datetime] = None
    priority: TaskPriority = TaskPriority.MEDIUM
    tags: List[str] = []
    notes: Optional[str] = None
    
    @validator('estimated_pomodoros')
    def validate_estimated_pomodoros(cls, v):
        if v < 0:
            raise ValueError('Estimated pomodoros must be a non-negative integer')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Design wireframes",
                "project_id": "60d21b4967d0d8992e610c85",
                "estimated_pomodoros": 4,
                "due_date": "2023-05-15T17:00:00Z",
                "priority": "high",
                "tags": ["60d21b4967d0d8992e610c88"],
                "notes": "Focus on mobile-first design"
            }
        }


class TaskCreate(TaskBase):
    subtasks: List[SubTask] = []
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Design wireframes",
                "project_id": "60d21b4967d0d8992e610c85",
                "estimated_pomodoros": 4,
                "due_date": "2023-05-15T17:00:00Z",
                "priority": "high",
                "tags": ["60d21b4967d0d8992e610c88"],
                "notes": "Focus on mobile-first design",
                "subtasks": [
                    {"description": "Research competitors", "completed": False},
                    {"description": "Sketch initial concepts", "completed": False}
                ]
            }
        }


class TaskUpdate(BaseModel):
    name: Optional[str] = None
    project_id: Optional[str] = None
    estimated_pomodoros: Optional[int] = None
    due_date: Optional[datetime] = None
    priority: Optional[TaskPriority] = None
    tags: Optional[List[str]] = None
    notes: Optional[str] = None
    subtasks: Optional[List[SubTask]] = None
    
    @validator('estimated_pomodoros')
    def validate_estimated_pomodoros(cls, v):
        if v is not None and v < 0:
            raise ValueError('Estimated pomodoros must be a non-negative integer')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Updated wireframes task",
                "project_id": "60d21b4967d0d8992e610c85",
                "estimated_pomodoros": 5,
                "due_date": "2023-05-20T17:00:00Z",
                "priority": "medium",
                "tags": ["60d21b4967d0d8992e610c88"],
                "notes": "Focus on mobile-first design with updated branding",
                "subtasks": [
                    {"description": "Research competitors", "completed": True},
                    {"description": "Sketch initial concepts", "completed": False},
                    {"description": "Create digital mockups", "completed": False}
                ]
            }
        }


class TaskStatusUpdate(BaseModel):
    status: TaskStatus
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "completed"
            }
        }


class TaskInDB(TaskBase, MongoBaseModel):
    id: Any = Field(default_factory=PyObjectId, alias="_id")
    user_id: str
    completed_pomodoros: int = 0
    status: TaskStatus = TaskStatus.NOT_STARTED
    subtasks: List[SubTask] = []
    created_at: datetime
    updated_at: datetime
    is_archived: bool = False
    is_deleted: bool = False
    
    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "_id": "60d21b4967d0d8992e610c87",
                "user_id": "60d21b4967d0d8992e610c86",
                "name": "Design wireframes",
                "project_id": "60d21b4967d0d8992e610c85",
                "estimated_pomodoros": 4,
                "completed_pomodoros": 2,
                "due_date": "2023-05-15T17:00:00Z",
                "priority": "high",
                "tags": ["60d21b4967d0d8992e610c88"],
                "status": "in_progress",
                "notes": "Focus on mobile-first design",
                "subtasks": [
                    {"description": "Research competitors", "completed": True},
                    {"description": "Sketch initial concepts", "completed": False}
                ],
                "created_at": "2023-04-01T12:00:00Z",
                "updated_at": "2023-04-02T14:30:00Z",
                "is_archived": False,
                "is_deleted": False
            }
        }


class TaskResponse(TaskInDB):
    pass
