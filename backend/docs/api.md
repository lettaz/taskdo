# TaskDo API Documentation

This document provides technical documentation for the TaskDo API endpoints.

## Base URL

All API endpoints are prefixed with `/api`.

## Authentication

Most endpoints require authentication using one of two methods:

### 1. API Key Authentication

All endpoints are protected with API key authentication. You must include the API key in the `X-API-Key` header for all requests:

```
X-API-Key: your_api_key_here
```

The API key is defined in your `.env` file as `API_KEY`.

### 2. JWT Bearer Token Authentication

In addition to the API key, user-specific endpoints also require a Bearer token in the Authorization header:

1. Register a user: `POST /api/auth/register`
2. Verify email: `POST /api/auth/verify-email`
3. Login: `POST /api/auth/login`
4. Use the returned access token in subsequent requests: `Authorization: Bearer {token}`

Both authentication methods must be used together for protected endpoints - the API key identifies the client application, while the JWT token identifies the specific user.

### Authentication in Swagger UI

When using the Swagger UI documentation (available at `/docs`), you can authenticate in two ways:

1. Click the "Authorize" button at the top right of the page
2. In the dialog that appears:
   - For API key authentication: Enter your API key in the `ApiKeyAuth` section
   - For JWT authentication: Use the OAuth2PasswordBearer section and click "Authorize" with your credentials, or manually enter the token obtained from the login endpoint

This will apply authentication to all subsequent API calls made through the Swagger UI interface.

## API Endpoints

### Authentication

#### Register a new user

```
POST /api/auth/register
```

**Headers:**
```
X-API-Key: your_api_key_here
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "strongpassword",
  "name": "John Doe"
}
```

**Response:**
```json
{
  "message": "Verification email sent",
  "user_id": "60d21b4667d0d8992e610c85"
}
```

#### Verify Email

```
POST /api/auth/verify-email
```

**Headers:**
```
X-API-Key: your_api_key_here
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "verification_code": "123456"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

#### Login

```
POST /api/auth/login
```

**Headers:**
```
X-API-Key: your_api_key_here
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "strongpassword"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

#### Request Password Reset

```
POST /api/auth/request-password-reset
```

**Headers:**
```
X-API-Key: your_api_key_here
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Password reset email sent"
}
```

#### Reset Password

```
POST /api/auth/reset-password
```

**Headers:**
```
X-API-Key: your_api_key_here
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "reset_code": "123456",
  "new_password": "newstrongpassword"
}
```

**Response:**
```json
{
  "message": "Password reset successful"
}
```

#### Logout

```
POST /api/auth/logout
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:**
```json
{
  "message": "Successfully logged out"
}
```

### User Profile

#### Get Current User Profile

```
GET /api/users/me
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:**
```json
{
  "_id": "60d21b4667d0d8992e610c84",
  "email": "user@example.com",
  "name": "John Doe",
  "profile_picture": "profile-pic-url.jpg",
  "timezone": "America/New_York",
  "notification_preferences": {
    "email_notifications": true,
    "push_notifications": false
  },
  "is_verified": true,
  "created_at": "2023-01-01T12:00:00",
  "updated_at": "2023-01-01T12:00:00",
  "last_login": "2023-01-02T14:30:00"
}
```

#### Update Current User Profile

```
PUT /api/users/me
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "name": "John Doe",
  "profile_picture": "profile-pic-url.jpg",
  "timezone": "America/New_York",
  "notification_preferences": {
    "email_notifications": true,
    "push_notifications": false
  }
}
```

**Response:**
```json
{
  "_id": "60d21b4667d0d8992e610c84",
  "email": "user@example.com",
  "name": "John Doe",
  "profile_picture": "profile-pic-url.jpg",
  "timezone": "America/New_York",
  "notification_preferences": {
    "email_notifications": true,
    "push_notifications": false
  },
  "is_verified": true,
  "created_at": "2023-01-01T12:00:00",
  "updated_at": "2023-01-02T15:45:00",
  "last_login": "2023-01-02T14:30:00"
}
```

#### Deactivate Account

```
DELETE /api/users/me
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:**
```json
{
  "message": "Account deactivated successfully"
}
```

### Projects

#### Create a Project

```
POST /api/projects
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "name": "Work Project",
  "description": "Tasks related to work",
  "color": "#FF5733",
  "deadline": "2023-12-31T23:59:59"
}
```

**Response:**
```json
{
  "_id": "60d21b4667d0d8992e610c85",
  "name": "Work Project",
  "description": "Tasks related to work",
  "color": "#FF5733",
  "deadline": "2023-12-31T23:59:59",
  "created_at": "2023-01-01T12:00:00",
  "updated_at": "2023-01-01T12:00:00",
  "is_archived": false,
  "user_id": "60d21b4667d0d8992e610c84"
}
```

#### Get All Projects

```
GET /api/projects
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Query Parameters:**
- `include_archived` (boolean, optional): Whether to include archived projects

**Response:**
```json
[
  {
    "_id": "60d21b4667d0d8992e610c85",
    "name": "Work Project",
    "description": "Tasks related to work",
    "color": "#FF5733",
    "deadline": "2023-12-31T23:59:59",
    "created_at": "2023-01-01T12:00:00",
    "updated_at": "2023-01-01T12:00:00",
    "is_archived": false,
    "user_id": "60d21b4667d0d8992e610c84"
  }
]
```

#### Get a Project

```
GET /api/projects/{project_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:**
```json
{
  "_id": "60d21b4667d0d8992e610c85",
  "name": "Work Project",
  "description": "Tasks related to work",
  "color": "#FF5733",
  "deadline": "2023-12-31T23:59:59",
  "created_at": "2023-01-01T12:00:00",
  "updated_at": "2023-01-01T12:00:00",
  "is_archived": false,
  "user_id": "60d21b4667d0d8992e610c84"
}
```

#### Update a Project

```
PUT /api/projects/{project_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "name": "Updated Work Project",
  "description": "Updated description",
  "color": "#33FF57",
  "deadline": "2024-06-30T23:59:59"
}
```

**Response:** Updated project object

#### Archive/Delete a Project

```
DELETE /api/projects/{project_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:**
```json
{
  "message": "Project archived successfully"
}
```

### Tasks

#### Create a Task

```
POST /api/tasks
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "name": "Complete documentation",
  "project_id": "60d21b4667d0d8992e610c85",
  "estimated_pomodoros": 4,
  "due_date": "2023-10-15T17:00:00",
  "priority": "high",
  "tags": ["60d21b4667d0d8992e610c86"],
  "notes": "Make sure to include all API endpoints",
  "subtasks": [
    {"description": "Document auth routes", "completed": false},
    {"description": "Document project routes", "completed": true}
  ]
}
```

**Response:** Created task object

#### Get All Tasks

```
GET /api/tasks
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Query Parameters:**
- `project_id` (string, optional): Filter by project
- `status` (string, optional): Filter by status (not_started, in_progress, completed)
- `priority` (string, optional): Filter by priority (low, medium, high)
- `tag_id` (string, optional): Filter by tag
- `due_before` (string, optional): Filter by due date before this date
- `due_after` (string, optional): Filter by due date after this date
- `is_deleted` (boolean, optional): Whether to include deleted tasks
- `search` (string, optional): Search by name or notes

**Response:** Array of task objects

#### Get a Task

```
GET /api/tasks/{task_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Query Parameters:**
- `include_deleted` (boolean, optional): Whether to include deleted tasks

**Response:** Task object

#### Update a Task

```
PUT /api/tasks/{task_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:** Task update object with any fields to update

**Response:** Updated task object

#### Update Task Status

```
PUT /api/tasks/{task_id}/status
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "status": "in_progress"
}
```

**Response:** Updated task object

#### Delete a Task

```
DELETE /api/tasks/{task_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:**
```json
{
  "message": "Task deleted successfully"
}
```

### Tags

#### Create a Tag

```
POST /api/tags
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "name": "Work",
  "color": "#3498DB"
}
```

**Response:** Created tag object

#### Get All Tags

```
GET /api/tags
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:** Array of tag objects

#### Get a Tag

```
GET /api/tags/{tag_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:** Tag object

#### Update a Tag

```
PUT /api/tags/{tag_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "name": "Updated Tag Name",
  "color": "#2ECC71"
}
```

**Response:** Updated tag object

#### Delete a Tag

```
DELETE /api/tags/{tag_id}
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:**
```json
{
  "message": "Tag deleted successfully"
}
```

### Pomodoro

#### Start a Pomodoro

```
POST /api/pomodoro/start
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Request Body:**
```json
{
  "task_id": "60d21b4667d0d8992e610c87",
  "duration_minutes": 25
}
```

**Response:** Created pomodoro object

#### Get Active Pomodoro

```
GET /api/pomodoro/active
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:** Active pomodoro object or 404 if none active

#### Complete a Pomodoro

```
PUT /api/pomodoro/{pomodoro_id}/complete
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:** Updated pomodoro object

#### Cancel a Pomodoro

```
PUT /api/pomodoro/{pomodoro_id}/cancel
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Response:** Updated pomodoro object

#### Get Pomodoro History

```
GET /api/pomodoro/history
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Query Parameters:**
- `limit` (integer, optional): Number of records to return
- `offset` (integer, optional): Offset for pagination
- `start_date` (string, optional): Filter by start date
- `end_date` (string, optional): Filter by end date
- `task_id` (string, optional): Filter by task

**Response:** Array of pomodoro objects

#### Get Pomodoro Statistics

```
GET /api/pomodoro/stats
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Query Parameters:**
- `date` (string, optional): Get stats for a specific date (YYYY-MM-DD)

**Response:**
```json
{
  "total_pomodoros": 10,
  "completed_pomodoros": 8,
  "total_minutes": 200
}
```

#### Get Weekly Pomodoro Statistics

```
GET /api/pomodoro/stats/week
```

**Headers:**
```
X-API-Key: your_api_key_here
Authorization: Bearer your_access_token
```

**Query Parameters:**
- `start_date` (string, optional): Start date for the week (YYYY-MM-DD)

**Response:** Array of daily statistics objects for 7 days

## Error Responses

All API endpoints return standardized error responses:

```json
{
  "detail": "Error message describing what went wrong"
}
```

Common HTTP status codes:
- `400`: Bad Request
- `401`: Unauthorized (Invalid JWT token or missing API key)
- `403`: Forbidden
- `404`: Not Found
- `409`: Conflict
- `422`: Validation Error
- `500`: Internal Server Error 