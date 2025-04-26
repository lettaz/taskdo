from typing import List, Optional
from fastapi import APIRouter, Depends, Query, Path, Body, Security

from ..core.security import get_current_user_payload, verify_api_key, api_key_header, oauth2_scheme
from ..crud.projects import project_crud
from ..schemas.project import ProjectCreate, ProjectUpdate, ProjectResponse


router = APIRouter(prefix="/api/projects", tags=["Projects"])


@router.get(
    "",
    response_model=List[ProjectResponse],
    summary="Get all projects",
    description="Retrieve all projects for the authenticated user with optional pagination and filtering.",
    operation_id="get_projects",
)
async def get_projects(
    skip: int = Query(0, ge=0, description="Number of projects to skip"),
    limit: int = Query(100, ge=1, le=100, description="Maximum number of projects to return"),
    include_archived: bool = Query(False, description="Whether to include archived projects"),
    user_payload: dict = Depends(get_current_user_payload),
    api_key: str = Security(api_key_header),
):
    """
    Get all projects for the authenticated user.
    """
    user_id = user_payload["sub"]
    projects = await project_crud.get_projects_by_user(
        user_id, skip=skip, limit=limit, include_archived=include_archived
    )
    return projects


@router.post(
    "",
    response_model=ProjectResponse,
    status_code=201,
    summary="Create a new project",
    description="Create a new project for the authenticated user.",
    operation_id="create_project",
)
async def create_project(
    project_in: ProjectCreate = Body(..., description="Project data"),
    user_payload: dict = Depends(get_current_user_payload),
    api_key: str = Security(api_key_header),
):
    """
    Create a new project.
    
    - **name**: Required - Project name
    - **description**: Optional - Project description
    - **color**: Required - Hex color code
    - **deadline**: Optional - Project deadline
    """
    user_id = user_payload["sub"]
    project = await project_crud.create_project(user_id, project_in.dict())
    return project


@router.get(
    "/{project_id}",
    response_model=ProjectResponse,
    summary="Get a specific project",
    description="Retrieve details of a specific project.",
    operation_id="get_project",
)
async def get_project(
    project_id: str = Path(..., description="Project ID"),
    user_payload: dict = Depends(get_current_user_payload),
    api_key: str = Security(api_key_header),
):
    """
    Get a specific project.
    
    - **project_id**: Required - Project ID
    """
    user_id = user_payload["sub"]
    project = await project_crud.get_project(project_id, user_id)
    return project


@router.put(
    "/{project_id}",
    response_model=ProjectResponse,
    summary="Update a project",
    description="Update details of an existing project.",
    operation_id="update_project",
)
async def update_project(
    project_id: str = Path(..., description="Project ID"),
    project_in: ProjectUpdate = Body(..., description="Project data to update"),
    user_payload: dict = Depends(get_current_user_payload),
    api_key: str = Security(api_key_header),
):
    """
    Update a project.
    
    - **project_id**: Required - Project ID
    - **name**: Optional - Project name
    - **description**: Optional - Project description
    - **color**: Optional - Hex color code
    - **deadline**: Optional - Project deadline
    """
    user_id = user_payload["sub"]
    
    # Filter out None values
    update_data = {k: v for k, v in project_in.dict().items() if v is not None}
    
    project = await project_crud.update_project(project_id, user_id, update_data)
    return project


@router.delete(
    "/{project_id}",
    response_model=dict,
    summary="Archive a project",
    description="Archive an existing project.",
    operation_id="archive_project",
)
async def archive_project(
    project_id: str = Path(..., description="Project ID"),
    user_payload: dict = Depends(get_current_user_payload),
    api_key: str = Security(api_key_header),
):
    """
    Archive a project.
    
    - **project_id**: Required - Project ID
    """
    user_id = user_payload["sub"]
    archived = await project_crud.archive_project(project_id, user_id)
    
    if archived:
        return {"message": "Project archived successfully"}
    return {"message": "Failed to archive project"}
