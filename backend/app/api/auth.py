from fastapi import APIRouter, Depends, Body, BackgroundTasks
from fastapi.security import OAuth2PasswordRequestForm
import logging
from pydantic import ValidationError
from jose import jwt, JWTError

from ..core.exceptions import BadRequestException, UnauthorizedException, NotFoundException
from ..core.security import create_access_token, verify_api_key, api_key_header, get_current_user_payload
from ..core.email import send_verification_email, send_password_reset_email
from ..crud.users import user_crud
from ..schemas.user import (
    UserCreate, UserVerify, RequestPasswordReset, PasswordReset, 
    Token, UserResponse
)
from ..config import settings

router = APIRouter(prefix="/api/auth", tags=["Authentication"])
logger = logging.getLogger(__name__)


@router.post("/register", response_model=dict, status_code=201, dependencies=[Depends(verify_api_key)])
async def register(
    background_tasks: BackgroundTasks,
    user_in: UserCreate = Body(...)
):
    """
    Register a new user.
    
    - **email**: Required - Valid email address
    - **password**: Required - Minimum 8 characters
    """
    try:
        logger.debug(f"Registering user with email: {user_in.email}")
        
        # Create user
        user = await user_crud.create_user(user_in.email, user_in.password)
        
        # Send verification email as a background task
        logger.debug(f"Adding email sending task to background")
        background_tasks.add_task(
            send_verification_email,
            user_in.email,
            user["verification_code"]
        )
        
        logger.info(f"User registered successfully: {user_in.email}")
        return {
            "message": "User registered successfully. Please check your email for verification code."
        }
    except Exception as e:
        logger.error(f"Error in register endpoint: {str(e)}")
        # If there's already an exception from our application, re-raise it
        if isinstance(e, (BadRequestException, UnauthorizedException, NotFoundException)):
            raise
        # Otherwise wrap it in a BadRequestException
        raise BadRequestException(str(e))


@router.post("/verify", response_model=Token)
async def verify_email(user_data: UserVerify = Body(...)):
    """
    Verify a user's email with the verification code.
    
    - **email**: Required - Email address
    - **verification_code**: Required - Verification code sent to the email
    """
    try:
        logger.debug(f"Verifying email for: {user_data.email}")
        user = await user_crud.verify_email(user_data.email, user_data.verification_code)
        access_token = create_access_token(subject=str(user["_id"]))
        logger.info(f"Email verified successfully for: {user_data.email}")
        return {"access_token": access_token, "token_type": "bearer"}
    except Exception as e:
        logger.error(f"Error in verify_email endpoint: {str(e)}")
        # If there's already an exception from our application, re-raise it
        if isinstance(e, (BadRequestException, UnauthorizedException, NotFoundException)):
            raise
        # Otherwise wrap it in a BadRequestException
        raise BadRequestException(str(e))


@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Authenticate a user and return an access token.
    
    - **username**: Required - Email address
    - **password**: Required - Password
    
    Note: client_id and client_secret fields can be left empty
    """
    try:
        logger.debug(f"Login attempt for: {form_data.username}")
        
        # Authenticate user
        user = await user_crud.authenticate_user(form_data.username, form_data.password)
        
        if not user:
            logger.warning(f"Failed login attempt for: {form_data.username} - Invalid credentials")
            raise UnauthorizedException(detail="Incorrect email or password")
        
        if not user.get("is_verified", False):
            logger.warning(f"Failed login attempt for: {form_data.username} - Email not verified")
            raise UnauthorizedException(detail="Email not verified")
        
        # Generate access token
        access_token = create_access_token(subject=str(user["_id"]))
        
        # Update last login
        await user_crud.update_last_login(str(user["_id"]))
        
        logger.info(f"Successful login for: {form_data.username}")
        return {
            "access_token": access_token,
            "token_type": "bearer"
        }
    except Exception as e:
        logger.error(f"Error in login endpoint: {str(e)}")
        # If there's already an exception from our application, re-raise it
        if isinstance(e, (BadRequestException, UnauthorizedException, NotFoundException)):
            raise
        # Otherwise wrap it in a BadRequestException
        raise UnauthorizedException(detail="Authentication failed")


@router.post("/logout", response_model=dict)
async def logout(payload: dict = Depends(get_current_user_payload)):
    """
    Logout a user. 
    
    This endpoint doesn't actually invalidate the token since JWTs are stateless,
    but it provides a standard endpoint for clients to call when logging out.
    Clients should delete the token from their storage after calling this endpoint.
    
    Note: For a complete logout solution, implement token blacklisting in a production environment.
    """
    try:
        # In a stateless JWT authentication system, we can't truly invalidate tokens
        # A proper implementation would include a token blacklist or use refresh tokens
        
        # For now, we'll just acknowledge the logout request
        return {"message": "Successfully logged out"}
    except Exception as e:
        logger.error(f"Error in logout endpoint: {str(e)}")
        raise BadRequestException(detail="Logout failed")


@router.post("/request-reset-password", response_model=dict)
async def request_reset_password(
    background_tasks: BackgroundTasks,
    request_data: RequestPasswordReset = Body(...)
):
    """
    Request a password reset.
    
    - **email**: Required - Email address to reset password for
    """
    try:
        logger.debug(f"Password reset requested for: {request_data.email}")
        
        # Generate reset code
        verification_code = await user_crud.request_password_reset(request_data.email)
        
        if verification_code:
            # Send password reset email as a background task
            logger.debug(f"Adding reset email task to background")
            background_tasks.add_task(
                send_password_reset_email,
                request_data.email,
                verification_code
            )
            logger.info(f"Password reset email sent to: {request_data.email}")
        else:
            # Even if user not found, return success for security
            logger.warning(f"Password reset requested for non-existent user: {request_data.email}")
            
        # For security reasons, always return success even if email doesn't exist
        return {"message": "If your email is registered, you will receive a reset code."}
    except Exception as e:
        logger.error(f"Error in request_reset_password endpoint: {str(e)}")
        # For security reasons, don't expose the error
        return {"message": "If your email is registered, you will receive a reset code."}


@router.post("/reset-password", response_model=dict)
async def reset_password(reset_data: PasswordReset = Body(...)):
    """
    Reset a password with verification code.
    
    - **email**: Required - Email address
    - **verification_code**: Required - Code received in email
    - **new_password**: Required - New password to set
    """
    try:
        logger.debug(f"Resetting password for: {reset_data.email}")
        success = await user_crud.reset_password(
            reset_data.email, 
            reset_data.verification_code,
            reset_data.new_password
        )
        
        if not success:
            raise BadRequestException(detail="Invalid verification code or email")
            
        logger.info(f"Password reset successfully for: {reset_data.email}")
        return {"message": "Password reset successfully"}
    except Exception as e:
        logger.error(f"Error in reset_password endpoint: {str(e)}")
        # If there's already an exception from our application, re-raise it
        if isinstance(e, (BadRequestException, UnauthorizedException, NotFoundException)):
            raise
        # Otherwise wrap it in a BadRequestException
        raise BadRequestException(detail="Failed to reset password")


@router.post("/token", response_model=Token, include_in_schema=False)
async def get_token(
    api_key: str = Depends(api_key_header),
    token: str = Body(..., embed=True)
):
    """
    Endpoint to directly use a token for Swagger UI authorization.
    This is not visible in the API documentation as it's only for Swagger UI.
    """
    if api_key != settings.API_KEY:
        raise UnauthorizedException(detail="Invalid API key")
    
    try:
        # Verify token is valid
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        return {"access_token": token, "token_type": "bearer"}
    except (JWTError, ValidationError):
        raise UnauthorizedException(detail="Could not validate token")
