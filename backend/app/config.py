import os
from typing import List, Optional
from pydantic_settings import BaseSettings
from pydantic import EmailStr, validator


class Settings(BaseSettings):
    # MongoDB Settings
    MONGO_URI: str
    MONGO_DB: str
    MONGO_USER: str
    MONGO_PASSWORD: str
    MONGO_ROOT_USERNAME: str
    MONGO_ROOT_PASSWORD: str
    
    # Authentication Settings
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # API Security
    API_KEY: str
    API_KEY_NAME: str = "X-API-Key"
    
    # Email Settings
    EMAIL_SENDER: EmailStr
    EMAIL_PASSWORD: str
    SMTP_SERVER: str
    SMTP_PORT: int
    
    # App Settings
    APP_NAME: str = "TaskDo API"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"
    
    # CORS Settings
    ALLOWED_ORIGINS: str
    
    # Logging Settings
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    @validator("MONGO_URI", pre=True)
    def validate_mongo_uri(cls, v: Optional[str]) -> str:
        return v or "mongodb://localhost:27017"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
