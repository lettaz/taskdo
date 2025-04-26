from typing import List, Optional
from fastapi import APIRouter, Depends, Query, Path, Body

from ..core.security import get_current_user_payload, verify_api_key
from ..crud.tasks import task_crud
from ..schemas.task import (
    TaskCreate, TaskUpdate, TaskStatusUpdate, TaskResponse, 
    TaskStatus, TaskPriority
)


router = APIRouter(prefix="/api/tasks", tags=["Tasks"])


@router.get(
    "",
    response_model=List[TaskResponse],
    dependencies=[Depends(verify_api_key)]
)
async def get_tasks(
    project_id: Optional[str] = Query(None),
    status: Optional[TaskStatus] = Query(None),
    priority: Optional[TaskPriority] = Query(None),
    tag_id: Optional[str] = Query(None),
    is_deleted: bool = Query(False),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Get tasks for the authenticated user with optional filtering.
    
    - **project_id**: Optional - Filter by project
    - **status**: Optional - Filter by status
    - **priority**: Optional - Filter by priority
    - **tag_id**: Optional - Filter by tag
    - **is_deleted**: Optional - Include deleted tasks
    - **skip**: Number of tasks to skip (pagination)
    - **limit**: Maximum number of tasks to return (pagination)
    """
    user_id = user_payload["sub"]
    
    tasks = await task_crud.get_tasks_by_user(
        user_id,
        project_id=project_id,
        status=status.value if status else None,
        priority=priority.value if priority else None,
        tag_id=tag_id,
        include_deleted=is_deleted,
        skip=skip,
        limit=limit
    )
    
    return tasks


@router.post(
    "",
    response_model=TaskResponse,
    status_code=201,
    dependencies=[Depends(verify_api_key)]
)
async def create_task(
    task_in: TaskCreate = Body(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Create a new task.
    
    - **name**: Required - Task name
    - **project_id**: Optional - Project ID
    - **estimated_pomodoros**: Required - Estimated pomodoro sessions
    - **due_date**: Optional - Task due date
    - **priority**: Required - Priority level (high, medium, low, none)
    - **tags**: Optional - Array of tag IDs
    - **notes**: Optional - Task notes
    """
    user_id = user_payload["sub"]
    task = await task_crud.create_task(user_id, task_in.dict())
    return task


@router.get(
    "/{task_id}",
    response_model=TaskResponse,
    dependencies=[Depends(verify_api_key)]
)
async def get_task(
    task_id: str = Path(...),
    include_deleted: bool = Query(False),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Get a specific task.
    
    - **task_id**: Required - Task ID
    - **include_deleted**: Optional - Include deleted tasks
    """
    user_id = user_payload["sub"]
    task = await task_crud.get_task(task_id, user_id, include_deleted=include_deleted)
    return task


@router.put(
    "/{task_id}",
    response_model=TaskResponse,
    dependencies=[Depends(verify_api_key)]
)
async def update_task(
    task_id: str = Path(...),
    task_in: TaskUpdate = Body(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Update a task.
    
    - **task_id**: Required - Task ID
    - **name**: Optional - Task name
    - **project_id**: Optional - Project ID
    - **estimated_pomodoros**: Optional - Estimated pomodoro sessions
    - **due_date**: Optional - Task due date
    - **priority**: Optional - Priority level
    - **tags**: Optional - Array of tag IDs
    - **notes**: Optional - Task notes
    - **subtasks**: Optional - Array of subtask objects
    """
    user_id = user_payload["sub"]
    
    # Filter out None values
    update_data = {k: v for k, v in task_in.dict().items() if v is not None}
    
    task = await task_crud.update_task(task_id, user_id, update_data)
    return task


@router.put(
    "/{task_id}/status",
    response_model=TaskResponse,
    dependencies=[Depends(verify_api_key)]
)
async def update_task_status(
    task_id: str = Path(...),
    status_update: TaskStatusUpdate = Body(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Update task status.
    
    - **task_id**: Required - Task ID
    - **status**: Required - New status
    """
    user_id = user_payload["sub"]
    task = await task_crud.update_task_status(task_id, user_id, status_update.status)
    return task


@router.delete(
    "/{task_id}",
    response_model=dict,
    dependencies=[Depends(verify_api_key)]
)
async def delete_task(
    task_id: str = Path(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Soft delete a task.
    
    - **task_id**: Required - Task ID
    """
    user_id = user_payload["sub"]
    deleted = await task_crud.delete_task(task_id, user_id)
    
    if deleted:
        return {"message": "Task deleted successfully"}
    return {"message": "Failed to delete task"}
