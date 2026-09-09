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

"""Pydantic v2 schemas for request/response contracts.

All models use strict ``model_config`` to reject unexpected fields and
enforce immutability at the serialisation boundary.
"""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


# ── Response Models ──────────────────────────────────────────────────────


class FileMetadataResponse(BaseModel):
    """Metadata for a single stored file."""

    model_config = ConfigDict(
        strict=True,
        frozen=True,
        populate_by_name=True,
    )

    filename: str = Field(
        ...,
        description="Base name of the file (e.g. 'report.pdf').",
    )
    relative_path: str = Field(
        ...,
        description="Path relative to the storage root.",
    )
    size_bytes: int = Field(
        ...,
        ge=0,
        description="File size in bytes.",
    )
    mime_type: str = Field(
        ...,
        description="Detected MIME type of the file.",
    )
    created_at: datetime = Field(
        ...,
        description="File creation timestamp (UTC).",
    )
    modified_at: datetime = Field(
        ...,
        description="Last modification timestamp (UTC).",
    )


class DirectoryListingResponse(BaseModel):
    """Aggregated listing of files in a directory."""

    model_config = ConfigDict(strict=True, frozen=True)

    directory: str = Field(
        ...,
        description="Scanned directory path relative to storage root.",
    )
    files: list[FileMetadataResponse] = Field(
        default_factory=list,
        description="List of file metadata entries.",
    )
    total_count: int = Field(
        ...,
        ge=0,
        description="Total number of files in the listing.",
    )
    total_size_bytes: int = Field(
        ...,
        ge=0,
        description="Sum of all file sizes in bytes.",
    )


class UploadResponse(BaseModel):
    """Confirmation payload returned after a successful upload."""

    model_config = ConfigDict(strict=True, frozen=True)

    filename: str
    relative_path: str
    size_bytes: int = Field(..., ge=0)
    mime_type: str
    message: str = "File uploaded successfully."


class DeleteResponse(BaseModel):
    """Confirmation payload returned after a successful deletion."""

    model_config = ConfigDict(strict=True, frozen=True)

    filename: str
    relative_path: str
    message: str = "File deleted successfully."


class HealthResponse(BaseModel):
    """Minimal health-check payload."""

    model_config = ConfigDict(strict=True, frozen=True)

    status: str = "healthy"
    service: str = "file-storage-backend"
    storage_root: str
    free_disk_bytes: int = Field(..., ge=0)


class ErrorResponse(BaseModel):
    """Standardised error envelope."""

    model_config = ConfigDict(strict=True, frozen=True)

    detail: str
    status_code: int
    error_type: str
