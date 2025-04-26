import random
import string
from datetime import datetime, timedelta
from typing import Any, Dict, Optional, Union

from fastapi import Depends, Security, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, APIKeyHeader
from jose import jwt
from passlib.context import CryptContext
from pydantic import ValidationError

from ..config import settings
from ..core.exceptions import UnauthorizedException
from ..schemas.user import UserInDB

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# API Key security scheme
api_key_header = APIKeyHeader(name=settings.API_KEY_NAME, description="API key for application authentication")

# OAuth2 Bearer token security scheme
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/auth/login",
    description="JWT token for user authentication"
)


def generate_verification_code(length: int = 6) -> str:
    """Generate a random verification code."""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against a hash."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)


def create_access_token(
    subject: Union[str, Any], expires_delta: Optional[timedelta] = None
) -> str:
    """Create a JWT access token."""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


async def verify_api_key(api_key: str = Security(api_key_header)) -> bool:
    """Verify the API key."""
    if api_key != settings.API_KEY:
        raise UnauthorizedException(detail="Invalid API key")
    return True


def get_current_user_payload(token: str = Depends(oauth2_scheme)) -> Dict[str, Any]:
    """Decode JWT token and extract user ID."""
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        return payload
    except (jwt.JWTError, ValidationError):
        raise UnauthorizedException(detail="Could not validate credentials")
