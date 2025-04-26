from datetime import datetime
from typing import Dict, List, Optional, Any
import logging
from bson import ObjectId

from ..core.exceptions import DatabaseException, ConflictException, NotFoundException, BadRequestException
from ..core.security import get_password_hash, verify_password, generate_verification_code
from .base import CRUDBase, _convert_object_ids

logger = logging.getLogger(__name__)


class CRUDUser(CRUDBase):
    def __init__(self):
        super().__init__("users")
    
    async def create_user(self, email: str, password: str) -> Dict[str, Any]:
        """
        Create a new user with email verification.
        
        Args:
            email: User email
            password: Plain password to be hashed
            
        Returns:
            User document with verification code
        """
        # Check if user already exists
        existing_user = await self.get_by_field("email", email.lower())
        if existing_user:
            raise ConflictException(detail="Email already registered")
        
        # Generate verification code
        verification_code = generate_verification_code()
        
        # Prepare user data
        user_data = {
            "email": email.lower(),
            "password": get_password_hash(password),
            "verification_code": verification_code,
            "is_verified": False,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "last_login": None
        }
        
        # Create user
        try:
            user_id = await self.create(user_data)
            user_data["_id"] = user_id
            return user_data
        except Exception as e:
            raise DatabaseException(detail=f"Error creating user: {e}")
    
    async def authenticate_user(self, email: str, password: str) -> Optional[Dict[str, Any]]:
        """
        Authenticate a user with email and password.
        
        Args:
            email: User email
            password: Plain password
            
        Returns:
            User document if authentication successful, None otherwise
        """
        user = await self.get_by_field("email", email.lower())
        if not user:
            return None
        
        if not verify_password(password, user["password"]):
            return None
        
        return user
    
    async def verify_email(self, email: str, verification_code: str) -> Dict[str, Any]:
        """
        Verify a user's email.
        
        Args:
            email: User email
            verification_code: Verification code sent to the user
            
        Returns:
            User document after verification
        
        Raises:
            NotFoundException: If user doesn't exist
            BadRequestException: If verification code is invalid
        """
        logger.debug(f"CRUD: Entered verify_email for {email} with code {verification_code}")
        # First check if the user exists
        user = await self.get_by_field("email", email.lower())
        if not user:
            raise NotFoundException(detail="User not found")
        logger.debug(f"User found for verification: {email}")
            
        # Check if already verified
        if user.get("is_verified", False):
            logger.debug(f"User {email} is already verified.")
            return user
        logger.debug(f"User {email} is not verified yet.")
            
        # Check verification code
        stored_code = user.get("verification_code")
        if stored_code != verification_code:
            logger.warning(f"Invalid verification code provided for {email}. Expected: {stored_code}, Got: {verification_code}")
            raise BadRequestException(detail="Invalid verification code")
        logger.debug(f"Verification code matched for {email}.")
        
        collection = await self.get_collection()
        
        # Construct the filter_id safely, checking the type (will be string from get_by_field)
        filter_id = user["_id"] if isinstance(user["_id"], ObjectId) else ObjectId(user["_id"])
        
        # Update user's verification status using collection.update_one
        result = await collection.update_one(
            {"_id": filter_id},
            {
                "$set": {
                    "is_verified": True,
                    "verification_code": None,  # Clear verification code after use
                    "updated_at": datetime.utcnow(),
                    "last_login": datetime.utcnow()
                }
            }
        )
        
        # Check result.modified_count
        if result.modified_count == 0:
            # Log details before raising the exception
            logger.error(f"Failed verification update for {email}. Matched: {result.matched_count}, Modified: {result.modified_count}")
            logger.error(f"User state before update attempt: {user}") # Log the user doc fetched earlier
            logger.error(f"Provided verification code: {verification_code}")
            raise DatabaseException(detail="Failed to verify email")
        logger.debug(f"Successfully updated verification status for {email}.") # Added this log back
            
        # Get updated user using self.get, which needs a string ID
        updated_user = await self.get(user["_id"]) # user["_id"] is already string here
        
        if not updated_user:
            raise DatabaseException(detail="Failed to retrieve user after verification")
        
        return updated_user
    
    async def request_password_reset(self, email: str) -> Optional[str]:
        """
        Generate and store a password reset code.
        
        Args:
            email: User email
            
        Returns:
            Verification code if user exists, None otherwise
        """
        user = await self.get_by_field("email", email.lower())
        if not user:
            return None
        
        verification_code = generate_verification_code()
        
        try:
            await self.update(
                str(user["_id"]),
                {
                    "verification_code": verification_code,
                    "updated_at": datetime.utcnow()
                }
            )
            return verification_code
        except Exception as e:
            raise DatabaseException(detail=f"Error requesting password reset: {e}")
    
    async def reset_password(self, email: str, verification_code: str, new_password: str) -> bool:
        """
        Reset a user's password with verification code.
        
        Args:
            email: User email
            verification_code: Verification code sent to the user
            new_password: New password to set
            
        Returns:
            True if password reset successful, False otherwise
            
        Raises:
            BadRequestException: If verification code is invalid
            NotFoundException: If user doesn't exist
        """
        from ..core.exceptions import BadRequestException
        
        # First check if the user exists
        user = await self.get_by_field("email", email.lower())
        if not user:
            raise NotFoundException(detail="User not found")
            
        # Check verification code
        if not user.get("verification_code") or user.get("verification_code") != verification_code:
            raise BadRequestException(detail="Invalid verification code")
        
        collection = await self.get_collection()
        
        # Update user's password and clear verification code
        result = await collection.update_one(
            {"_id": user["_id"]},
            {
                "$set": {
                    "password": get_password_hash(new_password),
                    "verification_code": None,
                    "updated_at": datetime.utcnow()
                }
            }
        )
        
        if result.modified_count == 0:
            raise DatabaseException(detail="Failed to reset password")
            
        return True
    
    async def update_last_login(self, user_id: str) -> bool:
        """
        Update a user's last login timestamp.
        
        Args:
            user_id: User ID
            
        Returns:
            True if update successful, False otherwise
        """
        return await self.update(
            user_id,
            {"last_login": datetime.utcnow()}
        )
        
    async def get_user_profile(self, user_id: str) -> Dict[str, Any]:
        """
        Get a user's profile.
        
        Args:
            user_id: User ID
            
        Returns:
            User profile data
            
        Raises:
            NotFoundException: If user doesn't exist
        """
        user = await self.get(user_id)
        if not user:
            raise NotFoundException(detail="User not found")
            
        # Remove sensitive information from the user object
        if "password" in user:
            del user["password"]
        if "verification_code" in user:
            del user["verification_code"]
            
        return user
        
    async def update_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Update a user's profile.
        
        Args:
            user_id: User ID
            profile_data: Profile data to update
            
        Returns:
            Updated user profile data
            
        Raises:
            NotFoundException: If user doesn't exist
            DatabaseException: If update fails
        """
        # Ensure user exists
        user = await self.get(user_id)
        if not user:
            raise NotFoundException(detail="User not found")
            
        # Add updated_at timestamp
        profile_data["updated_at"] = datetime.utcnow()
        
        # Update user
        success = await self.update(user_id, profile_data)
        if not success:
            raise DatabaseException(detail="Failed to update user profile")
            
        # Get updated user
        updated_user = await self.get_user_profile(user_id)
        return updated_user


user_crud = CRUDUser()
