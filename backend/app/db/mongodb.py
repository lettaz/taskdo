import logging
from motor.motor_asyncio import AsyncIOMotorClient
from ..config import settings

logger = logging.getLogger(__name__)


class MongoDB:
    client: AsyncIOMotorClient = None
    
    async def connect_to_database(self):
        """Create database connection."""
        logger.info("Connecting to MongoDB")
        
        try:
            self.client = AsyncIOMotorClient(
                settings.MONGO_URI,
                username=settings.MONGO_USER,
                password=settings.MONGO_PASSWORD
            )
            logger.info("Connected to MongoDB successfully")
        except Exception as e:
            logger.error(f"Error connecting to MongoDB: {e}")
            raise
    
    async def close_database_connection(self):
        """Close database connection."""
        logger.info("Closing connection to MongoDB")
        
        if self.client:
            self.client.close()
            logger.info("MongoDB connection closed")
    
    def get_database(self):
        """Get database instance."""
        return self.client[settings.MONGO_DB]


# Create a singleton instance
db = MongoDB()
