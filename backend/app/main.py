import logging
import traceback
import os
from pathlib import Path
from fastapi import FastAPI, Request, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, HTMLResponse
from fastapi.exceptions import RequestValidationError
from fastapi.staticfiles import StaticFiles

from .config import settings
from .core.exceptions import TaskdoException
from .db.mongodb import db
from .api import auth, projects, tasks, tags, pomodoro, profile
from .core.security import api_key_header, oauth2_scheme

# Get the directory where static files are stored
STATIC_DIR = Path(__file__).parent / "static"
if not STATIC_DIR.exists():
    STATIC_DIR.mkdir(exist_ok=True)
    with open(STATIC_DIR / "swagger-ui.js", "w") as f:
        f.write("""
// Helper function to set a Bearer token in Swagger UI
window.setApiToken = function(token) {
  if (!token) {
    console.error("No token provided");
    return;
  }
  
  // Format token if needed
  if (!token.startsWith("Bearer ")) {
    token = "Bearer " + token;
  }
  
  // Try to set the token in Swagger UI's auth mechanism
  try {
    const authActions = window.ui.getSystem().authActions;
    authActions.authorize({
      BearerAuth: {
        name: "BearerAuth",
        schema: { type: "http", scheme: "bearer" },
        value: token
      }
    });
    console.log("Token set successfully");
  } catch (e) {
    console.error("Failed to set token:", e);
  }
}
        """)

# Configure logging
logging.basicConfig(
    level=logging.getLevelName(settings.LOG_LEVEL.upper()), # Use LOG_LEVEL from settings
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Ensure specific loggers are set to DEBUG if needed (troubleshooting)
if settings.LOG_LEVEL.upper() == "DEBUG":
    logging.getLogger("app.crud.users").setLevel(logging.DEBUG)
    logging.getLogger("app.api.auth").setLevel(logging.DEBUG)

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    description="""
    API for Taskdo - A Productivity Management Application
    
    ## Authentication
    
    This API uses two forms of authentication:
    
    1. API Key: Required for all endpoints via the X-API-Key header
       - In Swagger UI: Click Authorize and enter your API key in the APIKeyHeader section
    
    2. JWT Token: Required for user-specific endpoints
       - Click Authorize, then enter your email and password in the OAuth2 section
    """,
    version="1.0.0",
    openapi_url="/openapi.json",
    swagger_ui_parameters={
        "persistAuthorization": True,
        "tryItOutEnabled": True,
        "displayRequestDuration": True,
        "filter": True,
    }
)

# Add static files
try:
    app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")
except Exception as e:
    logger.error(f"Error mounting static files: {e}")

# Define tags for API documentation - these are the only tags we want
app.openapi_tags = [
    {"name": "Authentication", "description": "Authentication operations"},
    {"name": "Projects", "description": "Project management operations"},
    {"name": "Tasks", "description": "Task management operations"},
    {"name": "Tags", "description": "Tag management operations"},
    {"name": "Pomodoro", "description": "Pomodoro timer operations"},
    {"name": "User Profile", "description": "User profile operations"},
]

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development only. For production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add security schemes to OpenAPI documentation
app.openapi_components = {
    "securitySchemes": {
        "APIKeyHeader": {
            "type": "apiKey",
            "in": "header",
            "name": settings.API_KEY_NAME,
            "description": "API key authentication",
        },
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "JWT token authentication",
        }
    }
}

# Apply security globally - all endpoints will require both authentication methods
app.openapi_extra = {
    "security": [
        {"APIKeyHeader": [], "BearerAuth": []}
    ]
}

# Exception handler for custom exceptions
@app.exception_handler(TaskdoException)
async def taskdo_exception_handler(request: Request, exc: TaskdoException):
    logger.error(f"TaskdoException: {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail},
        headers=getattr(exc, "headers", {})
    )


# Exception handler for validation errors
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    logger.error(f"Validation error: {exc}")
    return JSONResponse(
        status_code=422,
        content={"detail": str(exc)},
    )


# Exception handler for all other exceptions
@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {str(exc)}")
    logger.error(traceback.format_exc())
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


# Startup event handler
@app.on_event("startup")
async def startup_db_client():
    logger.info("Starting up Taskdo API")
    await db.connect_to_database()


# Shutdown event handler
@app.on_event("shutdown")
async def shutdown_db_client():
    logger.info("Shutting down Taskdo API")
    await db.close_database_connection()


# Root endpoint
@app.get("/", include_in_schema=False)
async def root():
    return {
        "message": "Welcome to Taskdo API",
        "documentation": "/docs"
    }


# Include routers with consistent tags
app.include_router(auth.router, tags=["Authentication"])
app.include_router(projects.router, tags=["Projects"])
app.include_router(tasks.router, tags=["Tasks"])
app.include_router(tags.router, tags=["Tags"])
app.include_router(pomodoro.router, tags=["Pomodoro"])
app.include_router(profile.router, tags=["User Profile"])
