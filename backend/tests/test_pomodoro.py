import pytest
from httpx import AsyncClient
from typing import Dict
from datetime import datetime, timedelta


@pytest.mark.asyncio
async def test_start_pomodoro(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test starting a pomodoro session."""
    # Start a pomodoro
    pomodoro_data = {
        "task_id": test_task["_id"],
        "duration_minutes": 25
    }
    
    response = await async_client.post(
        "/api/pomodoro/start",
        json=pomodoro_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 201
    data = response.json()
    assert data["task_id"] == test_task["_id"]
    assert data["duration_minutes"] == pomodoro_data["duration_minutes"]
    assert data["status"] == "in_progress"
    assert "start_time" in data
    assert "expected_end_time" in data
    assert "_id" in data
    
    # Store pomodoro session ID for other tests
    pomodoro_id = data["_id"]
    return pomodoro_id


@pytest.mark.asyncio
async def test_get_active_pomodoro(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test getting the active pomodoro session."""
    # First, ensure we have an active pomodoro
    pomodoro_id = await test_start_pomodoro(async_client, user_token_headers, test_task)
    
    # Get active pomodoro
    response = await async_client.get(
        "/api/pomodoro/active",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == pomodoro_id
    assert data["task_id"] == test_task["_id"]
    assert data["status"] == "in_progress"
    assert "start_time" in data
    assert "expected_end_time" in data


@pytest.mark.asyncio
async def test_complete_pomodoro(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test completing a pomodoro session."""
    # First, start a pomodoro
    pomodoro_id = await test_start_pomodoro(async_client, user_token_headers, test_task)
    
    # Complete the pomodoro
    response = await async_client.put(
        f"/api/pomodoro/{pomodoro_id}/complete",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == pomodoro_id
    assert data["status"] == "completed"
    assert "end_time" in data
    
    # Check if task's completed_pomodoros got incremented
    task_response = await async_client.get(
        f"/api/tasks/{test_task['_id']}",
        headers=user_token_headers
    )
    task_data = task_response.json()
    assert task_data["completed_pomodoros"] >= 1


@pytest.mark.asyncio
async def test_cancel_pomodoro(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test canceling a pomodoro session."""
    # First, start a pomodoro
    pomodoro_id = await test_start_pomodoro(async_client, user_token_headers, test_task)
    
    # Cancel the pomodoro
    response = await async_client.put(
        f"/api/pomodoro/{pomodoro_id}/cancel",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == pomodoro_id
    assert data["status"] == "canceled"
    assert "end_time" in data


@pytest.mark.asyncio
async def test_get_pomodoro_history(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test getting pomodoro history."""
    # First, start and complete a pomodoro to ensure we have history
    pomodoro_id = await test_start_pomodoro(async_client, user_token_headers, test_task)
    
    # Complete the pomodoro
    await async_client.put(
        f"/api/pomodoro/{pomodoro_id}/complete",
        headers=user_token_headers
    )
    
    # Get pomodoro history
    response = await async_client.get(
        "/api/pomodoro/history",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    
    # Verify the completed pomodoro is in the history
    found = False
    for pomodoro in data:
        if pomodoro["_id"] == pomodoro_id:
            found = True
            assert pomodoro["status"] == "completed"
            break
    
    assert found, "Completed pomodoro not found in history"


@pytest.mark.asyncio
async def test_get_pomodoro_stats(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test getting pomodoro statistics."""
    # First, start and complete a pomodoro to ensure we have data for stats
    pomodoro_id = await test_start_pomodoro(async_client, user_token_headers, test_task)
    
    # Complete the pomodoro
    await async_client.put(
        f"/api/pomodoro/{pomodoro_id}/complete",
        headers=user_token_headers
    )
    
    # Get pomodoro stats for today
    today = datetime.utcnow().date().isoformat()
    response = await async_client.get(
        f"/api/pomodoro/stats?date={today}",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert "total_pomodoros" in data
    assert data["total_pomodoros"] >= 1
    assert "total_minutes" in data
    assert data["total_minutes"] >= 25  # Assuming default 25-minute pomodoros
    assert "completed_pomodoros" in data
    assert data["completed_pomodoros"] >= 1


@pytest.mark.asyncio
async def test_get_pomodoro_stats_for_week(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test getting pomodoro statistics for the week."""
    # Get start of the week (Monday)
    today = datetime.utcnow().date()
    start_of_week = (today - timedelta(days=today.weekday())).isoformat()
    
    # Get pomodoro stats for the week
    response = await async_client.get(
        f"/api/pomodoro/stats/week?start_date={start_of_week}",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 7  # Should have stats for 7 days
    
    # Verify the structure of daily stats
    for day_stats in data:
        assert "date" in day_stats
        assert "total_pomodoros" in day_stats
        assert "completed_pomodoros" in day_stats
        assert "total_minutes" in day_stats
        assert isinstance(day_stats["total_pomodoros"], int)
        assert isinstance(day_stats["completed_pomodoros"], int)
        assert isinstance(day_stats["total_minutes"], int)


@pytest.mark.asyncio
async def test_invalid_pomodoro_id(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test operations with an invalid pomodoro ID."""
    # Try to complete a non-existent pomodoro
    response = await async_client.put(
        "/api/pomodoro/000000000000000000000000/complete",  # Valid ObjectId but doesn't exist
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 404
    assert "detail" in response.json()


@pytest.mark.asyncio
async def test_cannot_start_multiple_active_pomodoros(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test that a user cannot have multiple active pomodoro sessions."""
    # First, start a pomodoro
    await test_start_pomodoro(async_client, user_token_headers, test_task)
    
    # Try to start another pomodoro while one is active
    pomodoro_data = {
        "task_id": test_task["_id"],
        "duration_minutes": 25
    }
    
    response = await async_client.post(
        "/api/pomodoro/start",
        json=pomodoro_data,
        headers=user_token_headers
    )
    
    # Verify response indicates we cannot start another active pomodoro
    assert response.status_code == 400
    assert "detail" in response.json()
    assert "active pomodoro" in response.json()["detail"].lower()
