import pytest
from httpx import AsyncClient
from typing import Dict

from app.core.security import generate_verification_code


@pytest.mark.asyncio
async def test_register(async_client: AsyncClient, api_key_headers: Dict[str, str]):
    """Test user registration."""
    # Test data
    user_data = {
        "email": "newuser@example.com",
        "password": "securepassword123"
    }
    
    # Test registration
    response = await async_client.post(
        "/api/auth/register", 
        json=user_data,
        headers=api_key_headers
    )
    
    # Verify response
    assert response.status_code == 201
    assert "message" in response.json()
    assert "verification code" in response.json()["message"].lower()


@pytest.mark.asyncio
async def test_verify_email(async_client: AsyncClient, api_key_headers: Dict[str, str]):
    """Test email verification."""
    # Test data
    user_data = {
        "email": "verifyuser@example.com",
        "password": "securepassword123"
    }
    
    # Register user
    response = await async_client.post(
        "/api/auth/register", 
        json=user_data,
        headers=api_key_headers
    )
    assert response.status_code == 201
    
    # Get verification code from database
    from app.db.mongodb import db
    user = await db.get_database()["users"].find_one({"email": user_data["email"]})
    assert user is not None
    verification_code = user["verification_code"]
    
    # Test verification
    verify_data = {"email": user_data["email"], "verification_code": verification_code}
    response = await async_client.post(
        "/api/auth/verify-email",
        json=verify_data,
        headers=api_key_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "token_type" in data
    assert data["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_verify_email_invalid_code(async_client: AsyncClient, api_key_headers: Dict[str, str]):
    """Test email verification with invalid code."""
    # Test data
    user_data = {
        "email": "invalidcode@example.com",
        "password": "securepassword123"
    }
    
    # Register user
    response = await async_client.post(
        "/api/auth/register", 
        json=user_data,
        headers=api_key_headers
    )
    assert response.status_code == 201
    
    # Test verification with invalid code
    verify_data = {"email": user_data["email"], "verification_code": "INVALID"}
    response = await async_client.post(
        "/api/auth/verify-email",
        json=verify_data,
        headers=api_key_headers
    )
    
    # Verify response
    assert response.status_code == 400
    assert "detail" in response.json()


@pytest.mark.asyncio
async def test_login(
    async_client: AsyncClient, 
    api_key_headers: Dict[str, str],
    test_user: Dict[str, str],
    user_token_headers: Dict[str, str]  # This fixture registers and verifies a user
):
    """Test user login."""
    # Login with valid credentials
    form_data = {
        "username": test_user["email"],
        "password": test_user["password"]
    }
    
    response = await async_client.post(
        "/api/auth/login",
        data=form_data,  # Login endpoint uses form data
        headers=api_key_headers
    )
    
    # Verify response
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "token_type" in data
    assert data["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_login_invalid_credentials(async_client: AsyncClient, api_key_headers: Dict[str, str]):
    """Test login with invalid credentials."""
    # Login with invalid credentials
    form_data = {
        "username": "nonexistent@example.com",
        "password": "wrongpassword"
    }
    
    response = await async_client.post(
        "/api/auth/login",
        data=form_data,
        headers=api_key_headers
    )
    
    # Verify response
    assert response.status_code == 401
    assert "detail" in response.json()


@pytest.mark.asyncio
async def test_request_password_reset(
    async_client: AsyncClient, 
    api_key_headers: Dict[str, str],
    test_user: Dict[str, str]
):
    """Test password reset request."""
    # Request password reset
    reset_data = {"email": test_user["email"]}
    
    response = await async_client.post(
        "/api/auth/request-password-reset",
        json=reset_data,
        headers=api_key_headers
    )
    
    # Verify response
    assert response.status_code == 200
    assert "message" in response.json()


@pytest.mark.asyncio
async def test_reset_password(
    async_client: AsyncClient, 
    api_key_headers: Dict[str, str],
    test_user: Dict[str, str]
):
    """Test password reset."""
    # Request password reset
    reset_data = {"email": test_user["email"]}
    
    response = await async_client.post(
        "/api/auth/request-password-reset",
        json=reset_data,
        headers=api_key_headers
    )
    assert response.status_code == 200
    
    # Get verification code from database
    from app.db.mongodb import db
    user = await db.get_database()["users"].find_one({"email": test_user["email"]})
    assert user is not None
    verification_code = user["verification_code"]
    
    # Reset password
    new_password = "newpassword123"
    reset_data = {
        "email": test_user["email"],
        "verification_code": verification_code,
        "new_password": new_password
    }
    
    response = await async_client.post(
        "/api/auth/reset-password",
        json=reset_data,
        headers=api_key_headers
    )
    
    # Verify response
    assert response.status_code == 200
    assert "message" in response.json()
    
    # Try to login with new password
    form_data = {
        "username": test_user["email"],
        "password": new_password
    }
    
    response = await async_client.post(
        "/api/auth/login",
        data=form_data,
        headers=api_key_headers
    )
    
    # Verify login works with new password
    assert response.status_code == 200
    assert "access_token" in response.json()
