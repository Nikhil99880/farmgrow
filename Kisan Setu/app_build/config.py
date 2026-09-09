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

"""Centralised configuration for the File Storage & Management Backend."""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path


@dataclass(frozen=True, slots=True)
class Settings:
    """Immutable application settings.

    All paths are resolved to absolute form at construction time so that
    every downstream consumer works with canonical, unambiguous locations.
    """

    # ── Storage ──────────────────────────────────────────────────────────
    STORAGE_ROOT: Path = field(
        default_factory=lambda: (
            Path(__file__).resolve().parent / "uploads"
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
    CORS_ORIGINS: list[str] = field(
        default_factory=lambda: [
            "http://localhost:3000",
            "http://localhost:8000",
            "http://127.0.0.1:8000",
        ],
    )

    # ── Disk guard ───────────────────────────────────────────────────────
    MIN_FREE_DISK_BYTES: int = 100 * 1024 * 1024  # 100 MB safety margin

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

    Environment variable overrides can be layered in here when needed.
    """
    storage_root_env = os.getenv("STORAGE_ROOT")
    if storage_root_env:
        return Settings(STORAGE_ROOT=Path(storage_root_env).resolve())
    return Settings()
