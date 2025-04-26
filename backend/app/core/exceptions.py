from fastapi import HTTPException, status


class TaskdoException(HTTPException):
    """Base class for all application exceptions"""
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    detail = "An unexpected error occurred"
    
    def __init__(self, detail=None, headers=None):
        super().__init__(
            status_code=self.status_code,
            detail=detail or self.detail,
            headers=headers
        )


class NotFoundException(TaskdoException):
    """Resource not found exception"""
    status_code = status.HTTP_404_NOT_FOUND
    detail = "Resource not found"


class UnauthorizedException(TaskdoException):
    """Unauthorized access exception"""
    status_code = status.HTTP_401_UNAUTHORIZED
    detail = "Unauthorized access"
    headers = {"WWW-Authenticate": "Bearer"}


class ForbiddenException(TaskdoException):
    """Forbidden access exception"""
    status_code = status.HTTP_403_FORBIDDEN
    detail = "Forbidden access"


class BadRequestException(TaskdoException):
    """Bad request exception"""
    status_code = status.HTTP_400_BAD_REQUEST
    detail = "Bad request"


class DatabaseException(TaskdoException):
    """Database operation exception"""
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    detail = "Database operation failed"


class EmailException(TaskdoException):
    """Email operation exception"""
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    detail = "Email operation failed"


class ValidationException(TaskdoException):
    """Validation exception"""
    status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
    detail = "Validation error"


class ConflictException(TaskdoException):
    """Conflict exception"""
    status_code = status.HTTP_409_CONFLICT
    detail = "Resource already exists"
