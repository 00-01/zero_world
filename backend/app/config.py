import os
from typing import Optional


def _str_env(var_name: str, default: str) -> str:
    """Fetch a string environment variable with empty-string tolerance."""
    raw_value = os.getenv(var_name)
    if raw_value is None or raw_value.strip() == "":
        return default
    return raw_value


def _int_env(var_name: str, default: int) -> int:
    """Safely parse integer environment variables with fallback defaults."""
    raw_value = os.getenv(var_name)
    if raw_value is None or raw_value.strip() == "":
        return default
    try:
        return int(raw_value)
    except ValueError:
        return default


class Settings:
    """Application settings sourced from environment variables."""

    # MongoDB Configuration
    MONGODB_URL: str = _str_env("MONGODB_URL", "mongodb://mongodb:27017/")
    MONGODB_DATABASE: str = _str_env("MONGODB_DATABASE", "zero_world")

    # JWT Configuration
    JWT_SECRET_KEY: str = _str_env("JWT_SECRET", "fallback-secret-change-in-production")
    JWT_ALGORITHM: str = _str_env("JWT_ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = _int_env("ACCESS_TOKEN_EXPIRE_MINUTES", 60)

    # Domain Configuration
    DOMAIN_NAME: str = _str_env("DOMAIN_NAME", "localhost")

    # SSL Configuration
    SSL_CERT_PATH: Optional[str] = _str_env("SSL_CERT_PATH", "") or None
    SSL_KEY_PATH: Optional[str] = _str_env("SSL_KEY_PATH", "") or None

    # External Access
    EXTERNAL_MONGODB_HOST: Optional[str] = _str_env("EXTERNAL_MONGODB_HOST", "") or None

    # Security
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"

    def get_mongodb_connection_string(self) -> str:
        """Get the MongoDB connection string."""
        return self.MONGODB_URL

    def get_external_mongodb_string(self) -> str:
        """Get external MongoDB connection string for documentation."""
        if self.EXTERNAL_MONGODB_HOST:
            username = _str_env("MONGODB_USERNAME", "")
            password = _str_env("MONGODB_PASSWORD", "")
            return (
                f"mongodb://{username}:{password}@{self.EXTERNAL_MONGODB_HOST}:27017/"
                f"{self.MONGODB_DATABASE}?authSource=admin"
            )
        return self.MONGODB_URL


settings = Settings()