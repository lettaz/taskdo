from typing import List
from fastapi import APIRouter, Depends, Query, Path, Body

from ..core.security import get_current_user_payload, verify_api_key
from ..crud.tags import tag_crud
from ..schemas.tag import TagCreate, TagUpdate, TagResponse


router = APIRouter(prefix="/api/tags", tags=["Tags"])


@router.get(
    "",
    response_model=List[TagResponse],
    dependencies=[Depends(verify_api_key)]
)
async def get_tags(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Get all tags for the authenticated user.
    
    - **skip**: Number of tags to skip (pagination)
    - **limit**: Maximum number of tags to return (pagination)
    """
    user_id = user_payload["sub"]
    tags = await tag_crud.get_tags_by_user(user_id, skip=skip, limit=limit)
    return tags


@router.post(
    "",
    response_model=TagResponse,
    status_code=201,
    dependencies=[Depends(verify_api_key)]
)
async def create_tag(
    tag_in: TagCreate = Body(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Create a new tag.
    
    - **name**: Required - Tag name
    - **color**: Required - Hex color code
    """
    user_id = user_payload["sub"]
    tag = await tag_crud.create_tag(user_id, tag_in.dict())
    return tag


@router.put(
    "/{tag_id}",
    response_model=TagResponse,
    dependencies=[Depends(verify_api_key)]
)
async def update_tag(
    tag_id: str = Path(...),
    tag_in: TagUpdate = Body(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Update a tag.
    
    - **tag_id**: Required - Tag ID
    - **name**: Optional - Tag name
    - **color**: Optional - Hex color code
    """
    user_id = user_payload["sub"]
    
    # Filter out None values
    update_data = {k: v for k, v in tag_in.dict().items() if v is not None}
    
    tag = await tag_crud.update_tag(tag_id, user_id, update_data)
    return tag


@router.delete(
    "/{tag_id}",
    response_model=dict,
    dependencies=[Depends(verify_api_key)]
)
async def delete_tag(
    tag_id: str = Path(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Delete a tag.
    
    - **tag_id**: Required - Tag ID
    """
    user_id = user_payload["sub"]
    deleted = await tag_crud.delete_tag(tag_id, user_id)
    
    if deleted:
        return {"message": "Tag deleted successfully"}
    return {"message": "Failed to delete tag"}
