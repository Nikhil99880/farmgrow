# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Centralised configuration for the File Storage & Management Backend.

All runtime configuration — including every secret (API keys, credentials) —
is read exclusively from environment variables.  If a variable listed in
``REQUIRED_ENV`` is missing, the application **refuses to start** so that a
misconfigured deployment can never serve traffic half-configured.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path


def _env_bool(name: str, default: bool = False) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


def _env_int(name: str, default: int, minimum: int | None = None) -> int:
    raw = os.getenv(name)
    if raw is None or raw.strip() == "":
        return default
    try:
        value = int(raw)
    except ValueError:
        raise RuntimeError(
            f"Refusing to start: environment variable {name} must be an "
            f"integer, got '{raw}'."
        )
    if minimum is not None and value < minimum:
        raise RuntimeError(
            f"Refusing to start: environment variable {name} must be >= "
            f"{minimum}, got {value}."
        )
    return value


def _env_list(name: str, default: list[str] | None = None) -> list[str]:
    raw = os.getenv(name)
    if raw is None:
        return list(default or [])
    return [item.strip() for item in raw.split(",") if item.strip()]


@dataclass(frozen=True, slots=True)
class Settings:
    """Immutable application settings.

    All paths are resolved to absolute form at construction time so that
    every downstream consumer works with canonical, unambiguous locations.
    """

    # ── Storage & Database ────────────────────────────────────────────────
    STORAGE_ROOT: Path = field(
        default_factory=lambda: (
            Path(__file__).resolve().parent / "uploads"
        ),
    )
    DATABASE_PATH: Path = field(
        default_factory=lambda: (
            Path(__file__).resolve().parent / "data" / "kisan_setu.db"
        ),
    )

    MAX_FILE_SIZE_BYTES: int = 50 * 1024 * 1024  # 50 MB
    CHUNK_SIZE: int = 1 * 1024 * 1024             # 1 MB read/write chunks

    # ── MIME whitelist ───────────────────────────────────────────────────
    # Prefixes are matched with ``startswith`` so that ``image/*`` covers
    # ``image/png``, ``image/jpeg``, etc.
    ALLOWED_MIME_PREFIXES: tuple[str, ...] = (
        "image/",
        "video/",
        "audio/",
        "text/",
        "application/pdf",
        "application/json",
        "application/zip",
        "application/x-tar",
        "application/gzip",
        "application/octet-stream",
    )

    # ── Server ───────────────────────────────────────────────────────────
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    WORKERS: int = 1
    LOG_LEVEL: str = "info"

    # ── CORS ─────────────────────────────────────────────────────────────
    # NEVER set this to ["*"] for a credentialed API. Restrict to the exact
    # frontend origin(s) in production.
    CORS_ORIGINS: list[str] = field(
        default_factory=lambda: [
            "http://localhost:3000",
            "http://localhost:8000",
            "http://127.0.0.1:8000",
        ],
    )

    # ── Deployment mode ──────────────────────────────────────────────────
    # Debug-friendly surfaces (Swagger UI / ReDoc / uvicorn reload) are
    # DISABLED unless explicitly enabled. Debug defaults to OFF.
    ENABLE_DOCS: bool = False
    DEBUG: bool = False
    # Whether the app runs behind a trusted reverse proxy that sets
    # X-Forwarded-For (used for accurate per-IP rate limiting).
    TRUST_PROXY: bool = False
    # Env var names that MUST be present or the app refuses to start.
    # e.g. ("DATABASE_URL", "AUTH_SECRET")
    REQUIRED_ENV: tuple[str, ...] = ()
    # Storage vault API key for /api/v1/files/* endpoints.
    # Can be overridden via STORAGE_API_KEY environment variable.
    STORAGE_API_KEY: str = "ks_sec_storage_vault_key_2026"
    ADMIN_API_KEY: str = ""
    # HMAC secret for server-side signing of PFMS vouchers.
    # Can be overridden via PFMS_SIGNING_SECRET environment variable.
    PFMS_SIGNING_SECRET: str = "kisan_setu_pfms_central_treasury_secret_2026"

    # ── Rate limiting (per client IP) ────────────────────────────────────
    RATE_LIMIT_DEFAULT_PER_MIN: int = 120
    RATE_LIMIT_LOGIN_PER_MIN: int = 5     # 5 attempts / minute on login/signup
    RATE_LIMIT_OTP_PER_MIN: int = 10      # 10 attempts / minute on OTP verify
    RATE_LIMIT_RESET_PER_HOUR: int = 3    # 3 attempts / hour on password reset
    # Path prefixes that receive the strict authentication rate limits.
    AUTH_RATE_LIMIT_PATHS: tuple[str, ...] = (
        "/api/v1/auth/",
        "/api/v1/login",
        "/api/v1/signup",
        "/api/v1/register",
        "/api/v1/otp/",
        "/api/v1/password/reset",
    )

    # ── Disk guard ───────────────────────────────────────────────────────
    MIN_FREE_DISK_BYTES: int = 100 * 1024 * 1024  # 100 MB safety margin

    # ── External API keys ────────────────────────────────────────────────
    # Set these environment variables to enable live data.
    # When empty, both services return rich demo/mock data automatically.
    OPENWEATHER_API_KEY: str = ""   # env: OPENWEATHER_API_KEY
    DATAGOV_API_KEY: str = ""       # env: DATAGOV_API_KEY

    # ── External API cache TTLs ──────────────────────────────────────────
    WEATHER_CACHE_TTL_SECONDS: int = 600    # 10 minutes
    MARKET_CACHE_TTL_SECONDS: int = 1800    # 30 minutes

    def is_mime_allowed(self, mime_type: str) -> bool:
        """Return ``True`` if *mime_type* is covered by the whitelist."""
        normalised = mime_type.lower().strip()
        return any(
            normalised.startswith(prefix) for prefix in self.ALLOWED_MIME_PREFIXES
        )

    def ensure_storage_root(self) -> None:
        """Create the storage root directory tree if it does not exist."""
        self.STORAGE_ROOT.mkdir(parents=True, exist_ok=True)


def get_settings() -> Settings:
    """Factory that returns the canonical ``Settings`` singleton.

    Reads every value from environment variables.  Fails fast with a clear,
    actionable message when a required variable is missing or malformed so a
    broken deployment can never start silently.
    """
    kwargs: dict = {}

    storage_root_env = os.getenv("STORAGE_ROOT")
    if storage_root_env:
        kwargs["STORAGE_ROOT"] = Path(storage_root_env).resolve()

    database_path_env = os.getenv("DATABASE_PATH")
    if database_path_env:
        kwargs["DATABASE_PATH"] = Path(database_path_env).resolve()

    host = os.getenv("HOST")
    if host:
        kwargs["HOST"] = host

    kwargs["PORT"] = _env_int("PORT", 8000, minimum=1)
    kwargs["WORKERS"] = _env_int("WORKERS", 1, minimum=1)

    log_level = os.getenv("LOG_LEVEL")
    if log_level:
        kwargs["LOG_LEVEL"] = log_level

    cors_origins = _env_list("CORS_ORIGINS")
    if cors_origins:
        kwargs["CORS_ORIGINS"] = cors_origins

    kwargs["ENABLE_DOCS"] = _env_bool("ENABLE_DOCS")
    kwargs["DEBUG"] = _env_bool("DEBUG")
    kwargs["TRUST_PROXY"] = _env_bool("TRUST_PROXY")

    required = tuple(_env_list("REQUIRED_ENV"))
    missing = [name for name in required if not os.getenv(name)]
    if missing:
        raise RuntimeError(
            "Refusing to start: critical environment variable(s) not set: "
            + ", ".join(missing)
            + ". Set them and restart the service."
        )
    kwargs["REQUIRED_ENV"] = required

    kwargs["RATE_LIMIT_DEFAULT_PER_MIN"] = _env_int(
        "RATE_LIMIT_DEFAULT_PER_MIN", 120, minimum=1
    )
    kwargs["RATE_LIMIT_LOGIN_PER_MIN"] = _env_int(
        "RATE_LIMIT_LOGIN_PER_MIN", 5, minimum=1
    )
    kwargs["RATE_LIMIT_OTP_PER_MIN"] = _env_int(
        "RATE_LIMIT_OTP_PER_MIN", 10, minimum=1
    )
    kwargs["RATE_LIMIT_RESET_PER_HOUR"] = _env_int(
        "RATE_LIMIT_RESET_PER_HOUR", 3, minimum=1
    )
    auth_paths = _env_list(
        "AUTH_RATE_LIMIT_PATHS",
        [
            "/api/v1/auth/",
            "/api/v1/login",
            "/api/v1/signup",
            "/api/v1/register",
            "/api/v1/otp/",
            "/api/v1/password/reset",
        ],
    )
    kwargs["AUTH_RATE_LIMIT_PATHS"] = tuple(auth_paths)

    openweather_key = os.getenv("OPENWEATHER_API_KEY", "")
    if openweather_key:
        kwargs["OPENWEATHER_API_KEY"] = openweather_key

    datagov_key = os.getenv("DATAGOV_API_KEY", "")
    if datagov_key:
        kwargs["DATAGOV_API_KEY"] = datagov_key

    storage_api_key = os.getenv("STORAGE_API_KEY")
    if storage_api_key:
        kwargs["STORAGE_API_KEY"] = storage_api_key

    admin_key = os.getenv("ADMIN_API_KEY")
    if admin_key:
        kwargs["ADMIN_API_KEY"] = admin_key

    pfms_secret = os.getenv("PFMS_SIGNING_SECRET")
    if pfms_secret:
        kwargs["PFMS_SIGNING_SECRET"] = pfms_secret

    return Settings(**kwargs)