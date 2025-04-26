from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, Field, validator, field_serializer
from bson import ObjectId

from .common import PyObjectId, MongoBaseModel


class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    color: str
    deadline: Optional[datetime] = None
    
    @validator('color')
    def validate_color(cls, v):
        # Check if color is a valid hex color code
        if not v.startswith('#') or len(v) not in [4, 7]:
            raise ValueError('Color must be a valid hex color code')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Website Redesign",
                "description": "Complete redesign of company website",
                "color": "#3498db",
                "deadline": "2023-12-31T23:59:59Z"
            }
        }


class ProjectCreate(ProjectBase):
    pass


class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    color: Optional[str] = None
    deadline: Optional[datetime] = None
    
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
                "name": "Updated Website Redesign",
                "description": "Complete redesign of company website with new branding",
                "color": "#2980b9",
                "deadline": "2024-01-31T23:59:59Z"
            }
        }


class ProjectResponse(ProjectBase):
    id: str = Field(alias="_id")
    user_id: str
    created_at: datetime
    updated_at: datetime
    is_archived: bool = False
    
    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "_id": "60d21b4967d0d8992e610c85",
                "user_id": "60d21b4967d0d8992e610c86",
                "name": "Website Redesign",
                "description": "Complete redesign of company website",
                "color": "#3498db",
                "deadline": "2023-12-31T23:59:59Z",
                "created_at": "2023-04-01T12:00:00Z",
                "updated_at": "2023-04-01T12:00:00Z",
                "is_archived": False
            }
        }
        
    @classmethod
    def from_mongo(cls, data: dict):
        """Create a response model from MongoDB data."""
        if data.get("_id") and isinstance(data["_id"], ObjectId):
            data["_id"] = str(data["_id"])
        return cls(**data)
