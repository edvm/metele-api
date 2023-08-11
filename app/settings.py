from pydantic import BaseSettings


class Settings(BaseSettings):
    """Base settings."""

    # Global settings
    DEBUG: bool = False

    # Server settings
    HOST: str = "0.0.0.0"
    PORT: int = 7000
    API_PREFIX: str = "/api"
    PROJECT_NAME: str = "FastAPI Template"
    VERSION: str = "0.1.0"

    class Config:
        """Config."""

        env_file = ".env"
        env_file_encoding = "utf-8"
