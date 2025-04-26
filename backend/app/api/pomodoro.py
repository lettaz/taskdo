from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, Query, Path, Body

from ..core.security import get_current_user_payload, verify_api_key
from ..crud.pomodoro import pomodoro_crud
from ..schemas.pomodoro import (
    PomodoroSessionCreate, PomodoroSessionComplete, PomodoroSessionResponse,
    PomodoroStats, PomodoroType
)


router = APIRouter(prefix="/api/pomodoro", tags=["Pomodoro"])


@router.post(
    "/start",
    response_model=PomodoroSessionResponse,
    status_code=201,
    dependencies=[Depends(verify_api_key)]
)
async def start_pomodoro_session(
    session_in: PomodoroSessionCreate = Body(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Start a pomodoro session.
    
    - **task_id**: Required - Task ID
    - **type**: Required - Session type (work, break)
    """
    user_id = user_payload["sub"]
    session = await pomodoro_crud.start_session(
        user_id, session_in.task_id, session_in.type
    )
    return session


@router.put(
    "/{session_id}/end",
    response_model=PomodoroSessionResponse,
    dependencies=[Depends(verify_api_key)]
)
async def end_pomodoro_session(
    session_id: str = Path(...),
    session_end: PomodoroSessionComplete = Body(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    End a pomodoro session.
    
    - **session_id**: Required - Session ID
    - **completed**: Required - Whether completed fully
    - **interrupted**: Required - Whether interrupted
    """
    user_id = user_payload["sub"]
    session = await pomodoro_crud.end_session(
        session_id, user_id, session_end.completed, session_end.interrupted
    )
    return session


@router.get(
    "/stats",
    response_model=PomodoroStats,
    dependencies=[Depends(verify_api_key)]
)
async def get_pomodoro_stats(
    from_date: Optional[datetime] = Query(None),
    to_date: Optional[datetime] = Query(None),
    task_id: Optional[str] = Query(None),
    project_id: Optional[str] = Query(None),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Get pomodoro statistics.
    
    - **from_date**: Optional - Start date for stats
    - **to_date**: Optional - End date for stats
    - **task_id**: Optional - Filter by task
    - **project_id**: Optional - Filter by project
    """
    user_id = user_payload["sub"]
    stats = await pomodoro_crud.get_stats(
        user_id,
        from_date=from_date,
        to_date=to_date,
        task_id=task_id,
        project_id=project_id
    )
    return stats


@router.get(
    "/sessions",
    response_model=List[PomodoroSessionResponse],
    dependencies=[Depends(verify_api_key)]
)
async def get_pomodoro_sessions(
    from_date: Optional[datetime] = Query(None),
    to_date: Optional[datetime] = Query(None),
    task_id: Optional[str] = Query(None),
    type: Optional[PomodoroType] = Query(None),
    completed: Optional[bool] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Get pomodoro sessions with optional filtering.
    
    - **from_date**: Optional - Start date for filtering
    - **to_date**: Optional - End date for filtering
    - **task_id**: Optional - Filter by task
    - **type**: Optional - Filter by session type (work, break)
    - **completed**: Optional - Filter by completion status
    - **skip**: Number of sessions to skip (pagination)
    - **limit**: Maximum number of sessions to return (pagination)
    """
    user_id = user_payload["sub"]
    sessions = await pomodoro_crud.get_sessions_by_user(
        user_id,
        from_date=from_date,
        to_date=to_date,
        task_id=task_id,
        session_type=type.value if type else None,
        completed=completed,
        skip=skip,
        limit=limit
    )
    return sessions


@router.get(
    "/{session_id}",
    response_model=PomodoroSessionResponse,
    dependencies=[Depends(verify_api_key)]
)
async def get_pomodoro_session(
    session_id: str = Path(...),
    user_payload: dict = Depends(get_current_user_payload)
):
    """
    Get a specific pomodoro session.
    
    - **session_id**: Required - Session ID
    """
    user_id = user_payload["sub"]
    session = await pomodoro_crud.get_session(session_id, user_id)
    return session
