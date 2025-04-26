import pytest
from httpx import AsyncClient
from typing import Dict
from datetime import datetime, timedelta


@pytest.mark.asyncio
async def test_create_task(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict,
    test_tag: Dict
):
    """Test task creation."""
    # Test data
    task_data = {
        "name": "New Task",
        "project_id": test_project["_id"],
        "estimated_pomodoros": 3,
        "due_date": (datetime.utcnow() + timedelta(days=5)).isoformat(),
        "priority": "high",
        "tags": [test_tag["_id"]],
        "notes": "This is a test task with notes"
    }
    
    # Test task creation
    response = await async_client.post(
        "/api/tasks",
        json=task_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == task_data["name"]
    assert data["project_id"] == task_data["project_id"]
    assert data["estimated_pomodoros"] == task_data["estimated_pomodoros"]
    assert data["priority"] == task_data["priority"]
    assert data["tags"] == task_data["tags"]
    assert data["notes"] == task_data["notes"]
    assert "_id" in data
    assert "created_at" in data
    assert "updated_at" in data
    assert "status" in data
    assert data["status"] == "not_started"
    assert "completed_pomodoros" in data
    assert data["completed_pomodoros"] == 0
    assert "is_archived" in data
    assert data["is_archived"] is False
    assert "is_deleted" in data
    assert data["is_deleted"] is False


@pytest.mark.asyncio
async def test_get_tasks(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict  # This fixture creates a task
):
    """Test getting all tasks."""
    # Get tasks
    response = await async_client.get(
        "/api/tasks",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1  # At least the test task should be there
    
    # Verify the test task is in the results
    found = False
    for task in data:
        if task["_id"] == test_task["_id"]:
            found = True
            break
    
    assert found, "Test task not found in results"


@pytest.mark.asyncio
async def test_get_tasks_with_filters(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict,
    test_task: Dict,
    test_tag: Dict
):
    """Test getting tasks with filters."""
    # Test various filters
    
    # Filter by project
    response = await async_client.get(
        f"/api/tasks?project_id={test_project['_id']}",
        headers=user_token_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    for task in data:
        assert task["project_id"] == test_project["_id"]
    
    # Filter by status
    response = await async_client.get(
        "/api/tasks?status=not_started",
        headers=user_token_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    for task in data:
        assert task["status"] == "not_started"
    
    # Filter by priority
    response = await async_client.get(
        "/api/tasks?priority=high",
        headers=user_token_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    for task in data:
        assert task["priority"] == "high"
    
    # Filter by tag
    response = await async_client.get(
        f"/api/tasks?tag_id={test_tag['_id']}",
        headers=user_token_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    for task in data:
        assert test_tag["_id"] in task["tags"]


@pytest.mark.asyncio
async def test_get_task(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test getting a specific task."""
    # Get task
    response = await async_client.get(
        f"/api/tasks/{test_task['_id']}",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == test_task["_id"]
    assert data["name"] == test_task["name"]
    assert data["estimated_pomodoros"] == test_task["estimated_pomodoros"]


@pytest.mark.asyncio
async def test_update_task(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test updating a task."""
    # Update data
    update_data = {
        "name": "Updated Task",
        "estimated_pomodoros": 5,
        "priority": "medium",
        "subtasks": [
            {"description": "Subtask 1", "completed": False},
            {"description": "Subtask 2", "completed": True}
        ]
    }
    
    # Update task
    response = await async_client.put(
        f"/api/tasks/{test_task['_id']}",
        json=update_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == test_task["_id"]
    assert data["name"] == update_data["name"]
    assert data["estimated_pomodoros"] == update_data["estimated_pomodoros"]
    assert data["priority"] == update_data["priority"]
    assert len(data["subtasks"]) == 2
    assert data["subtasks"][0]["description"] == update_data["subtasks"][0]["description"]
    assert data["subtasks"][0]["completed"] == update_data["subtasks"][0]["completed"]
    assert data["subtasks"][1]["description"] == update_data["subtasks"][1]["description"]
    assert data["subtasks"][1]["completed"] == update_data["subtasks"][1]["completed"]


@pytest.mark.asyncio
async def test_update_task_status(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_task: Dict
):
    """Test updating a task's status."""
    # Update status
    status_data = {"status": "in_progress"}
    
    # Update task status
    response = await async_client.put(
        f"/api/tasks/{test_task['_id']}/status",
        json=status_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == test_task["_id"]
    assert data["status"] == status_data["status"]
    
    # Update to completed
    status_data = {"status": "completed"}
    
    response = await async_client.put(
        f"/api/tasks/{test_task['_id']}/status",
        json=status_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == status_data["status"]


@pytest.mark.asyncio
async def test_delete_task(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict
):
    """Test soft deleting a task."""
    # Create a task to delete
    task_data = {
        "name": "Task to Delete",
        "project_id": test_project["_id"],
        "estimated_pomodoros": 1,
        "priority": "low"
    }
    
    response = await async_client.post(
        "/api/tasks",
        json=task_data,
        headers=user_token_headers
    )
    assert response.status_code == 201
    task = response.json()
    
    # Delete task
    response = await async_client.delete(
        f"/api/tasks/{task['_id']}",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "deleted" in data["message"].lower()
    
    # Verify task is marked as deleted
    response = await async_client.get(
        f"/api/tasks/{task['_id']}",
        headers=user_token_headers
    )
    assert response.status_code == 404  # Should return not found for deleted tasks
    
    # Verify we can get it with include_deleted flag
    response = await async_client.get(
        f"/api/tasks/{task['_id']}?include_deleted=true",
        headers=user_token_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_deleted"] is True


@pytest.mark.asyncio
async def test_get_deleted_tasks(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test getting deleted tasks."""
    # Get deleted tasks
    response = await async_client.get(
        "/api/tasks?is_deleted=true",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    
    # Verify at least one deleted task exists
    if len(data) > 0:
        assert all(task["is_deleted"] for task in data), "Not all tasks are marked as deleted"


@pytest.mark.asyncio
async def test_invalid_task_id(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test accessing a task with an invalid ID."""
    # Try to get a non-existent task
    response = await async_client.get(
        "/api/tasks/000000000000000000000000",  # Valid ObjectId but doesn't exist
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 404
    assert "detail" in response.json()
