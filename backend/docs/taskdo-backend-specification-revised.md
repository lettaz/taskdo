# Taskdo Backend Specification

## 1. Overview

The Taskdo backend will be built with FastAPI and MongoDB, providing a robust API for the Flutter frontend. This specification details the requirements for implementing the backend services.

## 2. Technology Stack

- **Framework**: FastAPI 0.95+
- **Python Version**: 3.10+
- **Database**: MongoDB 6.0 (with authentication)
- **ODM**: Motor (Asynchronous MongoDB driver)
- **Authentication**: 
  - JWT for user authentication
  - API Key for service authentication
- **Validation**: Pydantic
- **Email Service**: SMTP
- **Testing**: Pytest
- **Containerization**: Docker

## 3. Project Structure

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
├── Dockerfile                   # Container definition
├── requirements.txt             # Python dependencies
└── .env.example                 # Environment variables example
```

## 4. Database Schema

### 4.1. User Collection

| Field | Type | Description |
|-------|------|-------------|
| _id | ObjectId | Unique identifier |
| email | String | User email (unique) |
| password | String | Hashed password |
| verification_code | String | Email verification code |
| is_verified | Boolean | Whether email is verified |
| created_at | DateTime | Account creation timestamp |
| updated_at | DateTime | Last update timestamp |
| last_login | DateTime | Last login timestamp |

### 4.2. Project Collection

| Field | Type | Description |
|-------|------|-------------|
| _id | ObjectId | Unique identifier |
| user_id | ObjectId | Reference to user |
| name | String | Project name |
| description | String | Project description |
| color | String | Hex color code |
| deadline | DateTime | Project deadline |
| created_at | DateTime | Creation timestamp |
| updated_at | DateTime | Last update timestamp |
| is_archived | Boolean | Archive status |

### 4.3. Task Collection

| Field | Type | Description |
|-------|------|-------------|
| _id | ObjectId | Unique identifier |
| user_id | ObjectId | Reference to user |
| project_id | ObjectId | Reference to project (can be null) |
| name | String | Task name |
| estimated_pomodoros | Integer | Estimated pomodoro sessions |
| completed_pomodoros | Integer | Completed pomodoro sessions |
| due_date | DateTime | Task due date |
| priority | String | Priority level (high, medium, low, none) |
| tags | Array[ObjectId] | References to tags |
| status | String | Task status (not_started, in_progress, completed) |
| notes | String | Task notes |
| subtasks | Array[Object] | Subtasks with description and completed status |
| created_at | DateTime | Creation timestamp |
| updated_at | DateTime | Last update timestamp |
| is_archived | Boolean | Archive status |
| is_deleted | Boolean | Deletion status (soft delete) |

### 4.4. Tag Collection

| Field | Type | Description |
|-------|------|-------------|
| _id | ObjectId | Unique identifier |
| user_id | ObjectId | Reference to user |
| name | String | Tag name |
| color | String | Hex color code |
| created_at | DateTime | Creation timestamp |

### 4.5. Pomodoro Session Collection

| Field | Type | Description |
|-------|------|-------------|
| _id | ObjectId | Unique identifier |
| user_id | ObjectId | Reference to user |
| task_id | ObjectId | Reference to task |
| start_time | DateTime | Session start time |
| end_time | DateTime | Session end time |
| duration | Integer | Duration in seconds |
| type | String | Session type (work, break) |
| completed | Boolean | Whether completed fully |
| interrupted | Boolean | Whether interrupted |
| created_at | DateTime | Creation timestamp |

## 5. API Endpoints Specification

### 5.1. Authentication Endpoints

#### `POST /api/auth/register`
Register a new user.

**Request Body**:
- email (required): User email
- password (required): User password

**Response**:
- 201 Created: User created successfully with verification message
- 400 Bad Request: Invalid input
- 409 Conflict: Email already exists

#### `POST /api/auth/verify-email`
Verify user email.

**Request Body**:
- email (required): User email
- verification_code (required): Code sent to email

**Response**:
- 200 OK: Email verified successfully with access token
- 400 Bad Request: Invalid verification code
- 404 Not Found: User not found

#### `POST /api/auth/login`
Login user.

**Request Body**:
- email (required): User email
- password (required): User password

**Response**:
- 200 OK: Login successful with access token
- 400 Bad Request: Invalid credentials
- 401 Unauthorized: Email not verified

#### `POST /api/auth/request-password-reset`
Request password reset.

**Request Body**:
- email (required): User email

**Response**:
- 200 OK: Password reset email sent
- 404 Not Found: User not found

#### `POST /api/auth/reset-password`
Reset password with verification code.

**Request Body**:
- email (required): User email
- verification_code (required): Code sent to email
- new_password (required): New password

**Response**:
- 200 OK: Password reset successful
- 400 Bad Request: Invalid verification code
- 404 Not Found: User not found

### 5.2. Project Endpoints

#### `GET /api/projects`
Get all projects for the authenticated user.

**Authentication**: JWT Token

**Response**:
- 200 OK: List of projects
- 401 Unauthorized: Authentication failure

#### `POST /api/projects`
Create a new project.

**Authentication**: JWT Token

**Request Body**:
- name (required): Project name
- description (optional): Project description
- color (required): Hex color code
- deadline (optional): Project deadline

**Response**:
- 201 Created: Project created successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure

#### `GET /api/projects/{project_id}`
Get a specific project.

**Authentication**: JWT Token

**Path Parameters**:
- project_id (required): Project ID

**Response**:
- 200 OK: Project details with associated tasks
- 401 Unauthorized: Authentication failure
- 404 Not Found: Project not found

#### `PUT /api/projects/{project_id}`
Update a project.

**Authentication**: JWT Token

**Path Parameters**:
- project_id (required): Project ID

**Request Body**:
- name (optional): Project name
- description (optional): Project description
- color (optional): Hex color code
- deadline (optional): Project deadline

**Response**:
- 200 OK: Project updated successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure
- 404 Not Found: Project not found

#### `DELETE /api/projects/{project_id}`
Archive a project.

**Authentication**: JWT Token

**Path Parameters**:
- project_id (required): Project ID

**Response**:
- 200 OK: Project archived successfully
- 401 Unauthorized: Authentication failure
- 404 Not Found: Project not found

### 5.3. Task Endpoints

#### `GET /api/tasks`
Get tasks for the authenticated user.

**Authentication**: JWT Token

**Query Parameters**:
- project_id (optional): Filter by project
- status (optional): Filter by status
- priority (optional): Filter by priority
- tag_id (optional): Filter by tag
- is_deleted (optional): Include deleted tasks

**Response**:
- 200 OK: List of tasks
- 401 Unauthorized: Authentication failure

#### `POST /api/tasks`
Create a new task.

**Authentication**: JWT Token

**Request Body**:
- project_id (optional): Project ID
- name (required): Task name
- estimated_pomodoros (required): Estimated pomodoro sessions
- due_date (optional): Task due date
- priority (required): Priority level
- tags (optional): Array of tag IDs

**Response**:
- 201 Created: Task created successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure
- 404 Not Found: Project not found

#### `GET /api/tasks/{task_id}`
Get a specific task.

**Authentication**: JWT Token

**Path Parameters**:
- task_id (required): Task ID

**Response**:
- 200 OK: Task details with associated data
- 401 Unauthorized: Authentication failure
- 404 Not Found: Task not found

#### `PUT /api/tasks/{task_id}`
Update a task.

**Authentication**: JWT Token

**Path Parameters**:
- task_id (required): Task ID

**Request Body**:
- project_id (optional): Project ID
- name (optional): Task name
- estimated_pomodoros (optional): Estimated pomodoro sessions
- due_date (optional): Task due date
- priority (optional): Priority level
- tags (optional): Array of tag IDs
- notes (optional): Task notes
- subtasks (optional): Array of subtask objects

**Response**:
- 200 OK: Task updated successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure
- 404 Not Found: Task not found

#### `PUT /api/tasks/{task_id}/status`
Update task status.

**Authentication**: JWT Token

**Path Parameters**:
- task_id (required): Task ID

**Request Body**:
- status (required): New status

**Response**:
- 200 OK: Status updated successfully
- 400 Bad Request: Invalid status
- 401 Unauthorized: Authentication failure
- 404 Not Found: Task not found

#### `DELETE /api/tasks/{task_id}`
Soft delete a task.

**Authentication**: JWT Token

**Path Parameters**:
- task_id (required): Task ID

**Response**:
- 200 OK: Task deleted successfully
- 401 Unauthorized: Authentication failure
- 404 Not Found: Task not found

### 5.4. Tag Endpoints

#### `GET /api/tags`
Get all tags for the authenticated user.

**Authentication**: JWT Token

**Response**:
- 200 OK: List of tags
- 401 Unauthorized: Authentication failure

#### `POST /api/tags`
Create a new tag.

**Authentication**: JWT Token

**Request Body**:
- name (required): Tag name
- color (required): Hex color code

**Response**:
- 201 Created: Tag created successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure

#### `PUT /api/tags/{tag_id}`
Update a tag.

**Authentication**: JWT Token

**Path Parameters**:
- tag_id (required): Tag ID

**Request Body**:
- name (optional): Tag name
- color (optional): Hex color code

**Response**:
- 200 OK: Tag updated successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure
- 404 Not Found: Tag not found

#### `DELETE /api/tags/{tag_id}`
Delete a tag.

**Authentication**: JWT Token

**Path Parameters**:
- tag_id (required): Tag ID

**Response**:
- 200 OK: Tag deleted successfully
- 401 Unauthorized: Authentication failure
- 404 Not Found: Tag not found

### 5.5. Pomodoro Endpoints

#### `POST /api/pomodoro/start`
Start a pomodoro session.

**Authentication**: JWT Token

**Request Body**:
- task_id (required): Task ID
- type (required): Session type (work, break)

**Response**:
- 201 Created: Session started successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure
- 404 Not Found: Task not found

#### `PUT /api/pomodoro/{session_id}/end`
End a pomodoro session.

**Authentication**: JWT Token

**Path Parameters**:
- session_id (required): Session ID

**Request Body**:
- completed (required): Whether completed fully
- interrupted (required): Whether interrupted

**Response**:
- 200 OK: Session ended successfully
- 400 Bad Request: Invalid input
- 401 Unauthorized: Authentication failure
- 404 Not Found: Session not found

#### `GET /api/pomodoro/stats`
Get pomodoro statistics.

**Authentication**: JWT Token

**Query Parameters**:
- from_date (optional): Start date for stats
- to_date (optional): End date for stats
- task_id (optional): Filter by task
- project_id (optional): Filter by project

**Response**:
- 200 OK: Pomodoro statistics
- 401 Unauthorized: Authentication failure

## 6. Security Requirements

### 6.1. Authentication

- Implement JWT-based authentication for user sessions
- Store passwords using bcrypt hashing
- Set appropriate token expiration time (30 minutes recommended)
- Implement token refresh mechanism

### 6.2. API Security

- Implement API key authentication for all endpoints
- Store API key in environment variables
- Use a custom header (e.g., X-API-Key) for API key transmission
- Exclude documentation routes from API key requirement

### 6.3. Database Security

- Configure MongoDB with authentication enabled
- Create dedicated database user with appropriate permissions
- Use secure connection string with credentials
- Store database credentials in environment variables
- Implement MongoDB initialization script for secure setup

## 7. Email Verification

- Generate random verification codes for email verification
- Send verification emails on registration
- Implement endpoint for verifying email with code
- Only allow authenticated operations after email verification
- Support password reset via email verification

## 8. API Documentation

- Enable comprehensive Swagger UI documentation
- Add detailed descriptions for all endpoints
- Include request/response examples
- Document authentication requirements
- Provide usage guidelines in documentation
- Make documentation accessible without API key

## 9. Deployment Configuration

### 9.1. Docker

- Create Dockerfile for backend service
- Use appropriate base image
- Install dependencies from requirements.txt
- Configure appropriate entry point

### 9.2. Environment Variables

The backend requires the following environment variables:

- **Database Configuration**:
  - MONGO_URI: MongoDB connection string with authentication
  - MONGO_DB: Database name
  - MONGO_USER: Database user
  - MONGO_PASSWORD: Database password
  - MONGO_ROOT_USERNAME: MongoDB admin username
  - MONGO_ROOT_PASSWORD: MongoDB admin password

- **Authentication**:
  - SECRET_KEY: Secret key for JWT token generation
  - ALGORITHM: JWT algorithm (HS256 recommended)
  - ACCESS_TOKEN_EXPIRE_MINUTES: Token expiration time

- **API Security**:
  - API_KEY: Secret API key
  - API_KEY_NAME: API key header name

- **Email Service**:
  - EMAIL_SENDER: Sender email address
  - EMAIL_PASSWORD: Sender email password
  - SMTP_SERVER: SMTP server address
  - SMTP_PORT: SMTP server port

### 9.3. Docker Compose(Root project directory i guess?)

- Configure MongoDB service with authentication
- Mount volume for database persistence
- Include initialization script for database setup
- Configure backend service with appropriate environment variables
- Set up appropriate networking between services

## 10. Performance Considerations

### 10.1. Database Indexing

- Create indexes for frequently queried fields:
  - User collection: email (unique)
  - Project collection: user_id
  - Task collection: user_id, project_id, status
  - Tag collection: user_id
  - Pomodoro session collection: user_id, task_id

### 10.2. Query Optimization

- Use projection to retrieve only necessary fields
- Implement pagination for list endpoints
- Use aggregation pipeline for complex reporting queries
- Optimize relationship queries

## 11. Error Handling

- Implement consistent error response format
- Use appropriate HTTP status codes
- Provide meaningful error messages
- Implement global exception handling
- Log errors with context information

## 12. Testing Requirements

- Write tests for all API endpoints
- Test authentication and authorization
- Test business logic
- Set up test database with appropriate fixtures
- Implement CI/CD integration for tests

## 13. Implementation Notes

- Follow FastAPI best practices for implementation
- Use asynchronous programming where appropriate
- Implement proper database connection management
- Follow RESTful API design principles
