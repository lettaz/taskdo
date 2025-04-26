from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, EmailStr, Field, validator

from .common import PyObjectId, MongoBaseModel


class UserBase(BaseModel):
    email: EmailStr
    
    class Config:
        schema_extra = {
            "example": {
                "email": "user@example.com"
            }
        }


class UserCreate(UserBase):
    password: str
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "strongpassword"
            }
        }


class UserLogin(UserBase):
    password: str
    
    class Config:
        schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "securepassword123"
            }
        }


class UserVerify(BaseModel):
    email: EmailStr
    verification_code: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "verification_code": "ABC123"
            }
        }


class RequestPasswordReset(BaseModel):
    email: EmailStr
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com"
            }
        }


class PasswordReset(BaseModel):
    email: EmailStr
    verification_code: str
    new_password: str
    
    @validator('new_password')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "verification_code": "ABC123",
                "new_password": "newstrongpassword"
            }
        }


class UserResponse(UserBase, MongoBaseModel):
    id: Any = Field(default_factory=PyObjectId, alias="_id")
    is_verified: bool
    created_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "_id": "60d21b4967d0d8992e610c85",
                "email": "user@example.com",
                "is_verified": True,
                "created_at": "2023-04-01T12:00:00Z",
                "last_login": "2023-04-02T14:30:00Z"
            }
        }


class UserInDB(UserBase, MongoBaseModel):
    id: Any = Field(default_factory=PyObjectId, alias="_id")
    password: str
    is_verified: bool = False
    verification_code: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        populate_by_name = True


class Token(BaseModel):
    access_token: str
    token_type: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer"
            }
        }


class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    profile_picture: Optional[str] = None
    timezone: Optional[str] = None
    notification_preferences: Optional[dict] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "John Doe",
                "profile_picture": "profile-pic-url.jpg",
                "timezone": "America/New_York",
                "notification_preferences": {
                    "email_notifications": True,
                    "push_notifications": False
                }
            }
        }
