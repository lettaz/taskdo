from datetime import datetime
from typing import Optional
from bson import ObjectId
from pydantic import Field

from ..db.mongodb import db


async def get_user_collection():
    """Get the users collection from the database."""
    return db.get_database()["users"]


async def find_user_by_email(email: str):
    """Find a user by email."""
    collection = await get_user_collection()
    return await collection.find_one({"email": email.lower()})


async def find_user_by_id(user_id: str):
    """Find a user by ID."""
    collection = await get_user_collection()
    return await collection.find_one({"_id": ObjectId(user_id)})


async def create_user(user_data: dict):
    """Create a new user."""
    collection = await get_user_collection()
    user_data["email"] = user_data["email"].lower()
    user_data["created_at"] = datetime.utcnow()
    user_data["updated_at"] = datetime.utcnow()
    
    result = await collection.insert_one(user_data)
    return result.inserted_id


async def update_user(user_id: str, update_data: dict):
    """Update user data."""
    collection = await get_user_collection()
    update_data["updated_at"] = datetime.utcnow()
    
    result = await collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": update_data}
    )
    return result.modified_count > 0


async def update_user_by_email(email: str, update_data: dict):
    """Update user data by email."""
    collection = await get_user_collection()
    update_data["updated_at"] = datetime.utcnow()
    
    result = await collection.update_one(
        {"email": email.lower()},
        {"$set": update_data}
    )
    return result.modified_count > 0


async def verify_user_email(email: str, verification_code: str):
    """Verify a user's email address."""
    collection = await get_user_collection()
    
    result = await collection.update_one(
        {
            "email": email.lower(),
            "verification_code": verification_code
        },
        {
            "$set": {
                "is_verified": True,
                "updated_at": datetime.utcnow()
            }
        }
    )
    return result.modified_count > 0


async def update_last_login(user_id: str):
    """Update user's last login timestamp."""
    collection = await get_user_collection()
    
    result = await collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {"last_login": datetime.utcnow()}}
    )
    return result.modified_count > 0
