from typing import Any
from pydantic import model_validator
from bson import ObjectId


class PyObjectId(ObjectId):
    """Custom type for handling MongoDB ObjectId."""
    
    @classmethod
    def __get_validators__(cls):
        yield cls.validate
    
    @classmethod
    def validate(cls, v):
        if not isinstance(v, ObjectId):
            if not ObjectId.is_valid(v):
                raise ValueError("Invalid ObjectId")
            v = ObjectId(v)
        return str(v)


class MongoBaseModel:
    """Base model with MongoDB ObjectId handling."""
    
    @model_validator(mode='before')
    @classmethod
    def convert_object_ids(cls, data: Any) -> Any:
        """Convert ObjectId to string in the model."""
        if isinstance(data, dict):
            # Convert _id from ObjectId to string if it exists
            if "_id" in data and isinstance(data["_id"], ObjectId):
                data["_id"] = str(data["_id"])
                
            # Also convert any other IDs that might be ObjectIds
            for field in data:
                if field.endswith("_id") and isinstance(data[field], ObjectId):
                    data[field] = str(data[field])
                
                # Handle list of ObjectIds (e.g., tags)
                if isinstance(data[field], list):
                    for i, item in enumerate(data[field]):
                        if isinstance(item, ObjectId):
                            data[field][i] = str(item)
                
        return data 