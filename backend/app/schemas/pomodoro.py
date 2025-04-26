from datetime import datetime
from enum import Enum
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field

from .common import PyObjectId, MongoBaseModel


class PomodoroType(str, Enum):
    WORK = "work"
    BREAK = "break"


class PomodoroSessionCreate(BaseModel):
    task_id: str
    type: PomodoroType = PomodoroType.WORK
    start_time: datetime
    
    class Config:
        json_schema_extra = {
            "example": {
                "task_id": "60d21b4967d0d8992e610c87",
                "type": "work",
                "start_time": "2023-04-01T14:00:00Z"
            }
        }


class PomodoroSessionComplete(BaseModel):
    end_time: datetime
    completed: bool = True
    interrupted: bool = False
    
    class Config:
        json_schema_extra = {
            "example": {
                "end_time": "2023-04-01T14:25:00Z",
                "completed": True,
                "interrupted": False
            }
        }


class PomodoroSessionInDB(BaseModel, MongoBaseModel):
    id: Any = Field(default_factory=PyObjectId, alias="_id")
    user_id: str
    task_id: str
    start_time: datetime
    end_time: Optional[datetime] = None
    duration: Optional[int] = None  # in seconds
    type: PomodoroType
    completed: Optional[bool] = None
    interrupted: Optional[bool] = None
    created_at: datetime
    
    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "_id": "60d21b4967d0d8992e610c89",
                "user_id": "60d21b4967d0d8992e610c86",
                "task_id": "60d21b4967d0d8992e610c87",
                "start_time": "2023-04-01T14:00:00Z",
                "end_time": "2023-04-01T14:25:00Z",
                "duration": 1500,  # 25 minutes
                "type": "work",
                "completed": True,
                "interrupted": False,
                "created_at": "2023-04-01T14:00:00Z"
            }
        }


class PomodoroSessionResponse(PomodoroSessionInDB):
    pass


class PomodoroStats(BaseModel):
    total_sessions: int = 0
    completed_sessions: int = 0
    total_duration: int = 0  # in seconds
    work_sessions: int = 0
    break_sessions: int = 0
    
    class Config:
        json_schema_extra = {
            "example": {
                "total_sessions": 10,
                "completed_sessions": 8,
                "total_duration": 12000,  # 3 hours 20 minutes
                "work_sessions": 8,
                "break_sessions": 2
            }
        }
