import os
from typing import Optional

class Settings:
    """Application settings from environment variables"""
    
    # MongoDB Configuration
    MONGODB_URL: str = os.getenv("MONGODB_URL", "mongodb://mongodb:27017/")
    MONGODB_DATABASE: str = os.getenv("MONGODB_DATABASE", "zero_world")
    
    # JWT Configuration
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET", "fallback-secret-change-in-production")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))
    
    # Domain Configuration
    DOMAIN_NAME: str = os.getenv("DOMAIN_NAME", "localhost")
    
    # SSL Configuration
    SSL_CERT_PATH: Optional[str] = os.getenv("SSL_CERT_PATH")
    SSL_KEY_PATH: Optional[str] = os.getenv("SSL_KEY_PATH")
    
    # External Access
    EXTERNAL_MONGODB_HOST: Optional[str] = os.getenv("EXTERNAL_MONGODB_HOST")
    
    # Security
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    def get_mongodb_connection_string(self) -> str:
        """Get the MongoDB connection string"""
        return self.MONGODB_URL
    
    def get_external_mongodb_string(self) -> str:
        """Get external MongoDB connection string for documentation"""
        if self.EXTERNAL_MONGODB_HOST:
            username = os.getenv("MONGODB_USERNAME", "")
            password = os.getenv("MONGODB_PASSWORD", "")
            return f"mongodb://{username}:{password}@{self.EXTERNAL_MONGODB_HOST}:27017/{self.MONGODB_DATABASE}?authSource=admin"
        return self.MONGODB_URL

settings = Settings()