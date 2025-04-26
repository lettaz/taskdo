from fastapi import APIRouter, Depends, Body
from bson import ObjectId
import logging

from ..core.security import get_current_user_payload
from ..core.exceptions import BadRequestException, NotFoundException
from ..crud.users import user_crud
from ..schemas.user import UserResponse, ProfileUpdate

router = APIRouter(prefix="/api/users", tags=["User Profile"])
logger = logging.getLogger(__name__)


@router.get("/me", response_model=UserResponse)
async def get_my_profile(payload: dict = Depends(get_current_user_payload)):
    """
    Get the current user's profile information.
    
    Returns:
        User profile data
    """
    try:
        user_id = payload.get("sub")
        logger.debug(f"Fetching profile for user ID: {user_id}")
        
        user = await user_crud.get_user_profile(user_id)
        
        logger.info(f"Profile fetched successfully for user ID: {user_id}")
        return user
    except Exception as e:
        logger.error(f"Error in get_my_profile endpoint: {str(e)}")
        if isinstance(e, NotFoundException):
            raise
        raise BadRequestException(detail=f"Error retrieving profile: {str(e)}")


@router.put("/me", response_model=UserResponse)
async def update_my_profile(
    profile_data: ProfileUpdate = Body(...),
    payload: dict = Depends(get_current_user_payload)
):
    """
    Update the current user's profile information.
    
    - **name**: Optional - User's name
    - **profile_picture**: Optional - URL or reference to profile picture
    - **timezone**: Optional - User's timezone
    - **notification_preferences**: Optional - User's notification preferences
    
    Returns:
        Updated user profile data
    """
    try:
        user_id = payload.get("sub")
        logger.debug(f"Updating profile for user ID: {user_id} with data: {profile_data}")
        
        updated_user = await user_crud.update_user_profile(
            user_id,
            profile_data.dict(exclude_unset=True)
        )
        
        logger.info(f"Profile updated successfully for user ID: {user_id}")
        return updated_user
    except Exception as e:
        logger.error(f"Error in update_my_profile endpoint: {str(e)}")
        if isinstance(e, NotFoundException):
            raise
        raise BadRequestException(detail=f"Error updating profile: {str(e)}")


@router.delete("/me", response_model=dict)
async def deactivate_account(payload: dict = Depends(get_current_user_payload)):
    """
    Deactivate the current user's account.
    This doesn't delete the account but marks it as inactive.
    
    Returns:
        Confirmation message
    """
    try:
        user_id = payload.get("sub")
        logger.debug(f"Deactivating account for user ID: {user_id}")
        
        # Update user's active status
        success = await user_crud.update(
            user_id,
            {
                "is_active": False,
                "updated_at": ObjectId().generation_time  # Current time
            }
        )
        
        if not success:
            raise BadRequestException(detail="Failed to deactivate account")
            
        logger.info(f"Account deactivated successfully for user ID: {user_id}")
        return {"message": "Account deactivated successfully"}
    except Exception as e:
        logger.error(f"Error in deactivate_account endpoint: {str(e)}")
        if isinstance(e, NotFoundException):
            raise
        raise BadRequestException(detail=f"Error deactivating account: {str(e)}") 