# TaskDo Backend Architecture

This document describes the architecture and design of the TaskDo backend.

## Technology Stack

- **FastAPI**: Web framework for building APIs with Python
- **MongoDB**: NoSQL database for storing application data
- **Motor**: Asynchronous MongoDB driver for Python
- **Pydantic**: Data validation and settings management
- **PyJWT**: JSON Web Token implementation for Python
- **Passlib**: Password hashing library
- **Pytest**: Testing framework

## Project Structure

```
backend/
├── app/
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py         # Authentication routes
│   │   ├── projects.py     # Project management routes
│   │   ├── tasks.py        # Task management routes
│   │   ├── tags.py         # Tag management routes
│   │   └── pomodoro.py     # Pomodoro timer routes
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py       # Application configuration
│   │   ├── security.py     # Security utilities (JWT, password hashing)
│   │   └── errors.py       # Custom error handlers
│   ├── db/
│   │   ├── __init__.py
│   │   └── mongodb.py      # MongoDB connection management
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py         # User models
│   │   ├── project.py      # Project models
│   │   ├── task.py         # Task models
│   │   ├── tag.py          # Tag models
│   │   └── pomodoro.py     # Pomodoro models
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth.py         # Authentication business logic
│   │   ├── email.py        # Email service (simulated for development)
│   │   ├── projects.py     # Project service
│   │   ├── tasks.py        # Task service
│   │   ├── tags.py         # Tag service
│   │   └── pomodoro.py     # Pomodoro service
│   ├── __init__.py
│   └── main.py             # Application entry point
├── tests/
│   ├── conftest.py         # Test fixtures
│   ├── test_auth.py        # Auth tests
│   ├── test_projects.py    # Project tests
│   ├── test_tasks.py       # Task tests
│   ├── test_tags.py        # Tag tests
│   ├── test_pomodoro.py    # Pomodoro tests
│   └── test_main.py        # Main app tests
├── docs/
│   ├── api.md              # API documentation
│   ├── architecture.md     # This file
│   └── testing.md          # Testing documentation
├── .env                    # Environment variables (not in version control)
├── .env.example            # Example environment variables
├── requirements.txt        # Python dependencies
├── pytest.ini             # Pytest configuration
└── run_tests.sh           # Script to run tests
```

## Architecture Overview

The TaskDo backend follows a layered architecture pattern with clear separation of concerns:

### 1. API Layer (`app/api/`)

This layer contains the API endpoints that handle HTTP requests and responses. It:
- Defines the routes using FastAPI decorators
- Validates incoming requests using Pydantic models
- Delegates business logic to the service layer
- Returns appropriate HTTP responses and status codes

### 2. Service Layer (`app/services/`)

This layer contains the business logic of the application. It:
- Implements the core functionality for each feature
- Interacts with the database through model operations
- Performs validations and business rule checks
- Is independent of HTTP-specific concerns

### 3. Model Layer (`app/models/`)

This layer defines the data models used throughout the application. It:
- Uses Pydantic for data validation and serialization
- Defines the structure of database documents
- Provides methods for document transformation
- Handles model relationships

### 4. Database Layer (`app/db/`)

This layer manages database connections and operations. It:
- Sets up and maintains the MongoDB connection
- Provides helper functions for database operations
- Handles connection pooling and lifecycle management

### 5. Core Layer (`app/core/`)

This layer contains common utilities and configurations. It:
- Manages application settings and environment variables
- Implements security functions like JWT handling
- Provides error handling mechanisms
- Contains other shared utilities

## Authentication Flow

1. User registers with email and password
2. System sends a verification code (simulated in development)
3. User verifies email with the code
4. User logs in with email and password
5. System issues a JWT token
6. User includes token in subsequent requests

## Data Model

### User
- Email (unique)
- Password (hashed)
- Name
- Verification status
- Verification code
- Reset password code
- Creation and update timestamps

### Project
- Name
- Description
- Color
- Deadline
- Is archived flag
- User ID (owner)
- Creation and update timestamps

### Task
- Name
- Project ID (reference)
- Estimated Pomodoros
- Completed Pomodoros
- Due date
- Priority (low, medium, high)
- Status (not_started, in_progress, completed)
- Tags (list of tag IDs)
- Notes
- Subtasks (embedded documents)
- Is archived flag
- Is deleted flag
- User ID (owner)
- Creation and update timestamps

### Tag
- Name
- Color
- User ID (owner)
- Creation and update timestamps

### Pomodoro
- Task ID (reference)
- Duration in minutes
- Status (in_progress, completed, canceled)
- Start time
- End time
- Expected end time
- User ID (owner)
- Creation and update timestamps

## Error Handling

The application uses a standardized error handling approach:
- Custom exceptions for specific error types
- Exception handlers that convert exceptions to appropriate HTTP responses
- Consistent error response format

## API Security

- API key authentication required for all endpoints (via X-API-Key header)
- JWT-based authentication for protected endpoints
- Password hashing using bcrypt
- Email verification for registration
- Rate limiting (to be implemented)
- CORS protection

## Testing Strategy

Tests are organized by feature and use pytest fixtures for common setup:
- Unit tests for individual functions
- Integration tests for API endpoints
- Test database isolation
- Mocked external dependencies

## Future Improvements

- Real email service integration
- Full-text search for tasks
- Advanced filtering and sorting
- Recurring tasks
- User preferences
- Team collaboration features 