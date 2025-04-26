import pytest
from httpx import AsyncClient
from typing import Dict


@pytest.mark.asyncio
async def test_create_tag(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test tag creation."""
    # Test data
    tag_data = {
        "name": "Testing",
        "color": "#9b59b6"
    }
    
    # Test tag creation
    response = await async_client.post(
        "/api/tags",
        json=tag_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == tag_data["name"]
    assert data["color"] == tag_data["color"]
    assert "_id" in data
    assert "created_at" in data


@pytest.mark.asyncio
async def test_create_duplicate_tag(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_tag: Dict
):
    """Test creating a tag with a duplicate name."""
    # Test data - same name as test_tag
    tag_data = {
        "name": test_tag["name"],
        "color": "#9b59b6"
    }
    
    # Test tag creation with duplicate name
    response = await async_client.post(
        "/api/tags",
        json=tag_data,
        headers=user_token_headers
    )
    
    # Verify response - should fail
    assert response.status_code == 409
    assert "detail" in response.json()
    assert "exists" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_get_tags(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_tag: Dict  # This fixture creates a tag
):
    """Test getting all tags."""
    # Get tags
    response = await async_client.get(
        "/api/tags",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1  # At least the test tag should be there
    
    # Verify the test tag is in the results
    found = False
    for tag in data:
        if tag["_id"] == test_tag["_id"]:
            found = True
            break
    
    assert found, "Test tag not found in results"


@pytest.mark.asyncio
async def test_update_tag(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_tag: Dict
):
    """Test updating a tag."""
    # Update data
    update_data = {
        "name": "Updated Tag",
        "color": "#8e44ad"
    }
    
    # Update tag
    response = await async_client.put(
        f"/api/tags/{test_tag['_id']}",
        json=update_data,
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert data["_id"] == test_tag["_id"]
    assert data["name"] == update_data["name"]
    assert data["color"] == update_data["color"]


@pytest.mark.asyncio
async def test_update_tag_duplicate_name(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test updating a tag with a duplicate name."""
    # Create two tags
    tag1_data = {
        "name": "Tag One",
        "color": "#1abc9c"
    }
    
    tag2_data = {
        "name": "Tag Two",
        "color": "#2ecc71"
    }
    
    response1 = await async_client.post(
        "/api/tags",
        json=tag1_data,
        headers=user_token_headers
    )
    assert response1.status_code == 201
    tag1 = response1.json()
    
    response2 = await async_client.post(
        "/api/tags",
        json=tag2_data,
        headers=user_token_headers
    )
    assert response2.status_code == 201
    tag2 = response2.json()
    
    # Try to update tag2 to have the same name as tag1
    update_data = {
        "name": tag1_data["name"]
    }
    
    response = await async_client.put(
        f"/api/tags/{tag2['_id']}",
        json=update_data,
        headers=user_token_headers
    )
    
    # Verify response - should fail
    assert response.status_code == 409
    assert "detail" in response.json()
    assert "exists" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_delete_tag(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test deleting a tag."""
    # Create a tag to delete
    tag_data = {
        "name": "To Delete",
        "color": "#e74c3c"
    }
    
    response = await async_client.post(
        "/api/tags",
        json=tag_data,
        headers=user_token_headers
    )
    assert response.status_code == 201
    tag = response.json()
    
    # Delete tag
    response = await async_client.delete(
        f"/api/tags/{tag['_id']}",
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "deleted" in data["message"].lower()
    
    # Verify tag is deleted
    response = await async_client.get(
        f"/api/tags/{tag['_id']}",
        headers=user_token_headers
    )
    assert response.status_code == 404
    assert "detail" in response.json()


@pytest.mark.asyncio
async def test_invalid_tag_id(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str]
):
    """Test accessing a tag with an invalid ID."""
    # Try to get a non-existent tag
    response = await async_client.get(
        "/api/tags/000000000000000000000000",  # Valid ObjectId but doesn't exist
        headers=user_token_headers
    )
    
    # Verify response
    assert response.status_code == 404
    assert "detail" in response.json()
