import os
import pytest
import asyncio
from datetime import datetime, timedelta
from typing import Dict, Generator, AsyncGenerator
from fastapi import FastAPI
from fastapi.testclient import TestClient
from httpx import AsyncClient
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import ServerSelectionTimeoutError

from app.main import app
from app.db.mongodb import db
from app.config import settings
from app.core.security import create_access_token


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for each test case."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
def test_app() -> FastAPI:
    """Get FastAPI application."""
    return app


@pytest.fixture(scope="session")
def test_client(test_app: FastAPI) -> Generator:
    """Create a test client for the FastAPI application."""
    with TestClient(test_app) as client:
        yield client


@pytest.fixture(scope="session")
async def async_client(test_app: FastAPI) -> AsyncGenerator:
    """Create an async client for the FastAPI application."""
    async with AsyncClient(app=test_app, base_url="http://test") as client:
        yield client


@pytest.fixture(scope="session", autouse=True)
async def setup_test_db():
    """Set up a test database for running tests."""
    # Use a different database for testing
    test_db_name = f"{settings.MONGO_DB}_test"
    
    # Replace the database in the application
    original_db = settings.MONGO_DB
    settings.MONGO_DB = test_db_name
    
    # Connect to MongoDB
    try:
        await db.connect_to_database()
        
        # Wait for connection to be ready
        client = AsyncIOMotorClient(settings.MONGO_URI)
        # Wait at most 5 seconds for connection
        await client.admin.command('ismaster')
        
        # Clear the test database before running tests
        await client.drop_database(test_db_name)
        
        yield
        
        # Clean up after tests
        await client.drop_database(test_db_name)
        await db.close_database_connection()
        
    except ServerSelectionTimeoutError:
        pytest.skip("MongoDB is not available")
    
    finally:
        # Restore the original database name
        settings.MONGO_DB = original_db


@pytest.fixture
async def api_key_headers() -> Dict[str, str]:
    """Get headers with API key."""
    return {settings.API_KEY_NAME: settings.API_KEY}


@pytest.fixture
async def test_user() -> Dict[str, str]:
    """Create a test user."""
    return {
        "email": "test@example.com",
        "password": "password123"
    }


@pytest.fixture
async def user_token_headers(
    async_client: AsyncClient, api_key_headers: Dict[str, str], test_user: Dict[str, str]
) -> Dict[str, str]:
    """Create user, verify email and get token headers."""
    # Register user
    response = await async_client.post(
        "/api/auth/register", 
        json=test_user,
        headers=api_key_headers
    )
    assert response.status_code == 201
    
    # Get user from database and verify email directly
    user = await db.get_database()["users"].find_one({"email": test_user["email"]})
    assert user is not None
    
    verification_code = user["verification_code"]
    
    # Verify email
    response = await async_client.post(
        "/api/auth/verify-email",
        json={"email": test_user["email"], "verification_code": verification_code},
        headers=api_key_headers
    )
    assert response.status_code == 200
    token = response.json()["access_token"]
    
    # Return headers with token
    return {
        **api_key_headers,
        "Authorization": f"Bearer {token}"
    }


@pytest.fixture
async def test_project(async_client: AsyncClient, user_token_headers: Dict[str, str]) -> Dict:
    """Create a test project."""
    project_data = {
        "name": "Test Project",
        "description": "A test project",
        "color": "#3498db",
        "deadline": (datetime.utcnow() + timedelta(days=30)).isoformat()
    }
    
    response = await async_client.post(
        "/api/projects",
        json=project_data,
        headers=user_token_headers
    )
    assert response.status_code == 201
    
    return response.json()


@pytest.fixture
async def test_tag(async_client: AsyncClient, user_token_headers: Dict[str, str]) -> Dict:
    """Create a test tag."""
    tag_data = {
        "name": "Important",
        "color": "#e74c3c"
    }
    
    response = await async_client.post(
        "/api/tags",
        json=tag_data,
        headers=user_token_headers
    )
    assert response.status_code == 201
    
    return response.json()


@pytest.fixture
async def test_task(
    async_client: AsyncClient, 
    user_token_headers: Dict[str, str],
    test_project: Dict,
    test_tag: Dict
) -> Dict:
    """Create a test task."""
    task_data = {
        "name": "Test Task",
        "project_id": test_project["_id"],
        "estimated_pomodoros": 2,
        "due_date": (datetime.utcnow() + timedelta(days=7)).isoformat(),
        "priority": "high",
        "tags": [test_tag["_id"]],
        "notes": "This is a test task"
    }
    
    response = await async_client.post(
        "/api/tasks",
        json=task_data,
        headers=user_token_headers
    )
    assert response.status_code == 201
    
    return response.json()
