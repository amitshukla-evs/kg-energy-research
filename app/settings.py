"""Validated Neo4j settings loaded from the checkout's .env."""

from pathlib import Path

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

ROOT = Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=ROOT / ".env",
        env_file_encoding="utf-8",
        env_prefix="NEO4J_",
        extra="ignore",
        hide_input_in_errors=True,
    )

    password: SecretStr = Field(min_length=1)
    uri: str = "neo4j://localhost:7687"
    username: str = "neo4j"
    database: str = "neo4j"


def settings_from_env(env_file: Path | None = None) -> Settings:
    return Settings(_env_file=env_file) if env_file is not None else Settings()
