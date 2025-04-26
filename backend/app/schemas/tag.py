from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, Field, validator

from .common import PyObjectId, MongoBaseModel


class TagBase(BaseModel):
    name: str
    color: str
    
    @validator('color')
    def validate_color(cls, v):
        # Check if color is a valid hex color code
        if not v.startswith('#') or len(v) not in [4, 7]:
            raise ValueError('Color must be a valid hex color code')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Urgent",
                "color": "#e74c3c"
            }
        }


class TagCreate(TagBase):
    pass


class TagUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None
    
    @validator('color')
    def validate_color(cls, v):
        if v is not None:
            # Check if color is a valid hex color code
            if not v.startswith('#') or len(v) not in [4, 7]:
                raise ValueError('Color must be a valid hex color code')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Very Urgent",
                "color": "#c0392b"
            }
        }


class TagInDB(TagBase, MongoBaseModel):
    id: Any = Field(default_factory=PyObjectId, alias="_id")
    user_id: str
    created_at: datetime
    
    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "_id": "60d21b4967d0d8992e610c88",
                "user_id": "60d21b4967d0d8992e610c86",
                "name": "Urgent",
                "color": "#e74c3c",
                "created_at": "2023-04-01T12:00:00Z"
            }
        }


class TagResponse(TagInDB):
    pass
