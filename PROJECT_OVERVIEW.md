# TaskDo Project Overview

This document provides a comprehensive overview of the TaskDo application, including its architecture, components, and implementation status. It serves as a central directory to all documentation in the project.

### Documentation

- [Project Brief](documentation/taskdo-project-brief-final.md.md): Taskdo (Productivity Management Application)

## Project Structure

TaskDo follows a microservices architecture with two main components:

```
TaskDo/
├── backend/            # FastAPI backend service
├── frontend/           # Flutter frontend application
├── documentation/      # Project documentation
├── docker-compose.yml  # Docker Compose configuration
└── README.md           # Project README
```

## Backend

The backend is built with FastAPI and provides a RESTful API for the TaskDo application. It handles authentication, data persistence, and business logic.

### Key Components

- **FastAPI Application**: Provides the API endpoints for the application
- **MongoDB**: NoSQL database for storing application data
- **JWT Authentication**: Secure authentication using JSON Web Tokens
- **Email Service**: For verification and password reset functionality

### Documentation

- [Backend README](backend/README.md): Setup and development guide
- [API Documentation](backend/docs/api.md): API endpoints and usage
- [Architecture Documentation](backend/docs/architecture.md): System architecture and design
- [Testing Documentation](backend/docs/testing.md): Testing strategies and procedures

## Frontend

The frontend is built with Flutter and provides a cross-platform user interface for the TaskDo application. The frontend is not dockerized and needs to be run locally.

### Key Components

- **Flutter Application**: Cross-platform UI for desktop and mobile
- **BLoC Pattern**: State management for the application
- **Go Router**: Navigation management
- **Material Design**: UI components and theming

### Documentation

- [Frontend README](frontend/README.md): Setup and development guide
- [Frontend Specification](frontend/taskdo-frontend-specification.md): Detailed design specifications

## Current Implementation Status

### Backend

- ✅ Authentication API (Login, Register, Verification, Password Reset)
- ✅ Projects API (CRUD operations)
- ✅ Tasks API (CRUD operations)
- ✅ Tags API (CRUD operations)
- ✅ Pomodoro API (Start, Complete, Cancel, History)
- ✅ Settings API (User preferences)
- ✅ API documentation
- ✅ Docker containerization

### Frontend

- ✅ Authentication screens (Login, Register, Verification, Password Reset)
- ✅ Dashboard screen
- ✅ Projects management (List, Create, Update, Delete)
- ✅ Tasks management (List, Create, Update, Delete)
- ⚠️ Tags management (Partially implemented)
- ⚠️ Pomodoro timer (Partially implemented)
- ⚠️ Reports screen (Not implemented)
- ✅ Settings screen
- ✅ Responsive design for desktop and mobile

## Getting Started

### Prerequisites

- Docker and Docker Compose (for backend)
- Flutter SDK (for frontend)
- Git

### Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/TaskDo.git
   cd TaskDo
   ```

2. Create a `.env` file in the root directory based on `.env.example`:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. Build and start the backend services:
   ```bash
   docker-compose up --build
   ```

4. Set up and run the frontend locally:
   ```bash
   cd frontend
   flutter pub get
   flutter run -d chrome  # or other target device
   ```

5. Access the application:
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs
   - Frontend: Run locally on your device

## Development Workflow

### Backend Development

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the development server:
   ```bash
   uvicorn app.main:app --reload
   ```

### Frontend Development

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -d chrome  # or your preferred device
   ```

## Environment Variables

The application uses environment variables for configuration. These can be set in a `.env` file or directly in the environment.

Key environment variables include:

- `MONGO_USER`: MongoDB username
- `MONGO_PASSWORD`: MongoDB password
- `SECRET_KEY`: JWT secret key
- `API_KEY`: API key for authentication
- `EMAIL_SENDER`: Email address for sending notifications
- `EMAIL_PASSWORD`: Password for the email account

For a complete list, see the `.env.example` file.

## API Authentication

The API uses two levels of authentication:

1. **API Key**: Required for all endpoints, passed in the `X-API-Key` header
2. **JWT Token**: Required for user-specific endpoints, passed in the `Authorization` header as a bearer token

## Architecture Overview

### Data Flow

1. The frontend sends requests to the backend API
2. The backend authenticates the request
3. The backend processes the request (e.g., querying the database)
4. The backend returns a response to the frontend
5. The frontend updates its state and UI

### State Management

The frontend uses the BLoC pattern for state management:

1. UI components dispatch events to BLoCs
2. BLoCs process events and update state
3. UI components rebuild when state changes

## Future Enhancements

- Offline support
- Data export/import
- Advanced analytics
- Team collaboration features
- Calendar integration
- Third-party integrations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 