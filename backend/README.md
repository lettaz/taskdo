# Taskdo Backend

FastAPI backend for the Taskdo productivity management application.

## Overview

This backend provides a REST API for the Taskdo Flutter frontend. It is built with FastAPI and MongoDB, and supports user authentication, project and task management, tagging, and Pomodoro session tracking.

## Technology Stack

- **Framework**: FastAPI 0.95+
- **Python Version**: 3.10+
- **Database**: MongoDB 6.0
- **ODM**: Motor (Asynchronous MongoDB driver)
- **Authentication**: JWT + API Key
- **Email**: SMTP

## Documentation

Comprehensive technical documentation is available in the `docs/` directory:

- [API Documentation](docs/api.md): Detailed documentation of all API endpoints with request/response examples
- [Architecture Documentation](docs/architecture.md): Overview of the system architecture and design
- [Testing Documentation](docs/testing.md): Guide to the testing setup and procedures

## Setup Instructions

### Prerequisites

- Python 3.10+
- Docker and Docker Compose (optional)

### Environment Setup

1. Copy the example environment file:
   ```
   cp .env.example .env
   ```

2. Edit the `.env` file with your configuration settings:
   - MongoDB connection details
   - Secret key for JWT
   - Email SMTP server details

### Running with Docker Compose

The easiest way to run the backend is with Docker Compose, which will set up both the backend and MongoDB:

```bash
cd ..  # Navigate to the project root
docker-compose up -d
```

The API will be available at http://localhost:8000

### Running Locally Without Docker

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Make sure MongoDB is running and accessible via the URI in your `.env` file.

3. Run the FastAPI server:
   ```bash
   uvicorn app.main:app --reload
   ```

## API Documentation

Once the server is running, you can access the interactive API documentation at:

- Swagger UI: http://localhost:8000/docs

## Development

### Project Structure

```
backend/
│
├── app/
│   ├── __init__.py
│   ├── main.py                  # FastAPI application entry point
│   ├── config.py                # Application configuration
│   │
│   ├── api/                     # API routes
│   │   ├── __init__.py
│   │   ├── auth.py              # Authentication endpoints
│   │   ├── projects.py          # Project management endpoints
│   │   ├── tasks.py             # Task management endpoints
│   │   ├── tags.py              # Tag management endpoints
│   │   └── pomodoro.py          # Pomodoro timer endpoints
│   │
│   ├── core/                    # Core functionality
│   │   ├── __init__.py
│   │   ├── security.py          # Authentication and security
│   │   ├── email.py             # Email functionality
│   │   └── exceptions.py        # Custom exceptions
│   │
│   ├── crud/                    # Database operations
│   │   ├── __init__.py
│   │   ├── base.py              # Base CRUD operations
│   │   ├── users.py             # User CRUD operations
│   │   ├── projects.py          # Project CRUD operations
│   │   ├── tasks.py             # Task CRUD operations
│   │   ├── tags.py              # Tag CRUD operations
│   │   └── pomodoro.py          # Pomodoro session CRUD operations
│   │
│   ├── db/                      # Database connection
│   │   ├── __init__.py
│   │   └── mongodb.py           # MongoDB connection setup
│   │
│   ├── models/                  # Database models
│   │   ├── __init__.py
│   │   ├── user.py              # User model
│   │   ├── project.py           # Project model
│   │   ├── task.py              # Task model
│   │   ├── tag.py               # Tag model
│   │   └── pomodoro.py          # Pomodoro session model
│   │
│   └── schemas/                 # Pydantic schemas
│       ├── __init__.py
│       ├── user.py              # User schema
│       ├── project.py           # Project schema
│       ├── task.py              # Task schema
│       ├── tag.py               # Tag schema
│       └── pomodoro.py          # Pomodoro session schema
│
├── tests/                       # Test directory
│   ├── __init__.py
│   ├── conftest.py              # Test configuration
│   ├── test_auth.py             # Auth tests
│   ├── test_projects.py         # Project tests
│   ├── test_tasks.py            # Task tests
│   ├── test_tags.py             # Tag tests
│   └── test_pomodoro.py         # Pomodoro tests
│
├── docs/                        # Documentation directory
│   ├── api.md                   # API endpoint documentation
│   ├── architecture.md          # System architecture documentation
│   └── testing.md               # Testing documentation and guidelines
│
├── Dockerfile                   # Container definition
├── requirements.txt             # Python dependencies
├── run_tests.sh                 # Script to run tests
└── .env.example                 # Environment variables example
```

### Running Tests

Tests are implemented using pytest:

```bash
# Run tests directly
pytest tests/

# Or use the provided script
./run_tests.sh
```

The test script sets up the necessary environment variables and can also generate test coverage reports if the coverage package is installed.

## Security

- API endpoints are protected with API key authentication
- User authentication is handled via JWT tokens
- Passwords are hashed using bcrypt
- Email verification is required for new accounts 