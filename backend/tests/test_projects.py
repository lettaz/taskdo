import pytest
from httpx import AsyncClient
from typing import Dict
from datetime import datetime, timedelta


@pytest.mark.asyncio
async def test_create_project(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test project creation."""
    # Test data
    project_data = {
        "name": "New Project",
        "description": "A test project",
        "color": "#3498db",
        "deadline": (datetime.utcnow() + timedelta(days=30)).isoformat()
    }
    
    # Test project creation
    response = await async_client.post(
        "/api/projects",
        json=project_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == project_data["name"]
    assert data["description"] == project_data["description"]
    assert data["color"] == project_data["color"]
    assert "_id" in data
    assert "created_at" in data
    assert "updated_at" in data
    assert "is_archived" in data
    assert data["is_archived"] is False


@pytest.mark.asyncio
async def test_get_projects(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict  # This fixture creates a project
):
    """Test getting all projects."""
    # Get projects
    response = await async_client.get(
        "/api/projects",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1  # At least the test project should be there
    
    # Verify the test project is in the results
    found = False
    for project in data:
        if project["_id"] == test_project["_id"]:
            found = True
            break
    
    assert found, "Test project not found in results"


@pytest.mark.asyncio
async def test_get_project(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict
):
    """Test getting a specific project."""
    # Get project
    response = await async_client.get(
        f"/api/projects/{test_project['_id']}",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == test_project["_id"]
    assert data["name"] == test_project["name"]
    assert data["description"] == test_project["description"]
    assert data["color"] == test_project["color"]


@pytest.mark.asyncio
async def test_update_project(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict
):
    """Test updating a project."""
    # Update data
    update_data = {
        "name": "Updated Project",
        "description": "Updated description",
        "color": "#2980b9"
    }
    
    # Update project
    response = await async_client.put(
        f"/api/projects/{test_project['_id']}",
        json=update_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == test_project["_id"]
    assert data["name"] == update_data["name"]
    assert data["description"] == update_data["description"]
    assert data["color"] == update_data["color"]


@pytest.mark.asyncio
async def test_archive_project(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict
):
    """Test archiving a project."""
    # Archive project
    response = await async_client.delete(
        f"/api/projects/{test_project['_id']}",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "archived" in data["message"].lower()
    
    # Verify project is archived
    response = await async_client.get(
        f"/api/projects/{test_project['_id']}",
        headers=user_token_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_archived"] is True


@pytest.mark.asyncio
async def test_get_archived_projects(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test getting archived projects."""
    # Get archived projects
    response = await async_client.get(
        "/api/projects?include_archived=true",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    
    # Verify at least one archived project exists
    archived_found = False
    for project in data:
        if project["is_archived"]:
            archived_found = True
            break
    
    assert archived_found, "No archived projects found"


@pytest.mark.asyncio
async def test_invalid_project_id(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test accessing a project with an invalid ID."""
    # Try to get a non-existent project
    response = await async_client.get(
        "/api/projects/000000000000000000000000",  # Valid ObjectId but doesn't exist
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 404
    assert "detail" in response.json()
