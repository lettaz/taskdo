import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_root_endpoint(test_client):
    """Test the root endpoint of the API."""
    response = await test_client.get("/")
    
    assert response.status_code == 200
    assert "message" in response.json()
    assert "TaskDo API" in response.json()["message"]
    assert "version" in response.json()


@pytest.mark.asyncio
async def test_docs_endpoint(test_client):
    """Test that the docs endpoint is accessible."""
    response = await test_client.get("/docs")
    
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]


@pytest.mark.asyncio
async def test_redoc_endpoint(test_client):
    """Test that the redoc endpoint is accessible."""
    response = await test_client.get("/redoc")
    
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]


@pytest.mark.asyncio
async def test_openapi_schema(test_client):
    """Test that the OpenAPI schema is accessible."""
    response = await test_client.get("/openapi.json")
    
    assert response.status_code == 200
    
    schema = response.json()
    assert "openapi" in schema
    assert "info" in schema
    assert "title" in schema["info"]
    assert "TaskDo API" in schema["info"]["title"]
    assert "paths" in schema
    
    # Verify that our main API paths are in the schema
    assert "/api/auth/register" in schema["paths"]
    assert "/api/projects" in schema["paths"]
    assert "/api/tasks" in schema["paths"]
    assert "/api/tags" in schema["paths"]
    assert "/api/pomodoro/start" in schema["paths"]


@pytest.mark.asyncio
async def test_cors_headers(test_client):
    """Test that CORS headers are properly set."""
    # Send OPTIONS request to check CORS headers
    response = await test_client.options(
        "/",
        headers={"Origin": "http://localhost:3000", "Access-Control-Request-Method": "GET"}
    )
    
    assert response.status_code == 200
    assert "access-control-allow-origin" in response.headers
    assert "access-control-allow-methods" in response.headers
    assert "access-control-allow-headers" in response.headers


@pytest.mark.asyncio
async def test_invalid_endpoint(test_client):
    """Test accessing an invalid endpoint."""
    response = await test_client.get("/nonexistent-endpoint")
    
    assert response.status_code == 404
    assert "detail" in response.json() 