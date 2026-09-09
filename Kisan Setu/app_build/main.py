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

"""FastAPI application entry-point for the File Storage & Management Backend.

Run with::

    python main.py

or directly via Uvicorn::

    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

from __future__ import annotations

import logging
import shutil
from contextlib import asynccontextmanager
from typing import AsyncIterator

import uvicorn
from fastapi import FastAPI, File, Form, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse

from config import Settings, get_settings
from exceptions import (
    FileTooLargeError,
    InvalidMimeTypeError,
    PathTraversalError,
    PermissionDeniedError,
    StorageError,
    StorageFullError,
    FileNotFoundError_,
)
from schemas import (
    DeleteResponse,
    DirectoryListingResponse,
    ErrorResponse,
    FileMetadataResponse,
    HealthResponse,
    UploadResponse,
)
from storage_service import StorageService

logger = logging.getLogger(__name__)

# ── Application settings & service ──────────────────────────────────────

settings: Settings = get_settings()
storage: StorageService = StorageService(settings)


# ── Lifespan ─────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    """Startup/shutdown lifecycle hook.

    Ensures the storage root directory exists before the first request
    is served.
    """
    settings.ensure_storage_root()
    logger.info(
        "Storage root ready at '%s'.", settings.STORAGE_ROOT.resolve(),
    )
    yield
    logger.info("File Storage Backend shutting down.")


# ── FastAPI app ──────────────────────────────────────────────────────────

app = FastAPI(
    title="Kisan Setu — File Storage & Management Backend",
    description=(
        "Production-ready async file storage service. Supports chunked "
        "uploads, secure streaming downloads, deletion, and directory "
        "metadata scanning."
    ),
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS middleware ──────────────────────────────────────────────────────

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Exception handlers ──────────────────────────────────────────────────

@app.exception_handler(StorageError)
async def storage_error_handler(
    _request: Request,
    exc: StorageError,
) -> JSONResponse:
    """Translate any ``StorageError`` subclass into a structured JSON response."""
    logger.warning(
        "%s [%d]: %s", exc.error_type, exc.http_status, exc.detail,
    )
    return JSONResponse(
        status_code=exc.http_status,
        content=ErrorResponse(
            detail=exc.detail,
            status_code=exc.http_status,
            error_type=exc.error_type,
        ).model_dump(),
    )


# ── Routes ───────────────────────────────────────────────────────────────

# -- Health ---------------------------------------------------------------

@app.get(
    "/api/v1/health",
    response_model=HealthResponse,
    tags=["Health"],
    summary="Service health check",
)
async def health_check() -> HealthResponse:
    """Return service health status and available disk space."""
    usage = shutil.disk_usage(settings.STORAGE_ROOT)
    return HealthResponse(
        storage_root=str(settings.STORAGE_ROOT.resolve()),
        free_disk_bytes=usage.free,
    )


# -- Upload ---------------------------------------------------------------

@app.post(
    "/api/v1/files/upload",
    response_model=UploadResponse,
    status_code=201,
    tags=["Files"],
    summary="Upload a file",
    responses={
        413: {"model": ErrorResponse, "description": "File too large"},
        415: {"model": ErrorResponse, "description": "MIME type not allowed"},
        507: {"model": ErrorResponse, "description": "Insufficient disk space"},
    },
)
async def upload_file(
    file: UploadFile = File(..., description="The file to upload."),
    subdirectory: str | None = Form(
        default=None,
        description="Optional subdirectory under the storage root.",
    ),
) -> UploadResponse:
    """Accept a multipart file upload with optional subdirectory placement.

    The file is streamed to disk in **1 MB chunks** to keep memory usage
    constant.  MIME type and file size are validated before the write is
    committed.
    """
    result = await storage.upload_file(
        file_content=None,
        filename=file.filename or "untitled",
        content_type=file.content_type,
        read_chunk=file.read,
        subdirectory=subdirectory,
    )
    return result


# -- Download --------------------------------------------------------------

@app.get(
    "/api/v1/files/download/{file_path:path}",
    tags=["Files"],
    summary="Download a file",
    responses={
        404: {"model": ErrorResponse, "description": "File not found"},
        403: {"model": ErrorResponse, "description": "Path traversal blocked"},
    },
)
async def download_file(file_path: str) -> FileResponse:
    """Stream a file download.

    The ``{file_path:path}`` converter captures the full remaining URL
    segment, including slashes, so that nested paths work naturally.
    """
    abs_path, mime = await storage.download_file(file_path)
    return FileResponse(
        path=abs_path,
        media_type=mime,
        filename=abs_path.name,
    )


# -- Delete ----------------------------------------------------------------

@app.delete(
    "/api/v1/files/{file_path:path}",
    response_model=DeleteResponse,
    tags=["Files"],
    summary="Delete a file",
    responses={
        404: {"model": ErrorResponse, "description": "File not found"},
        403: {"model": ErrorResponse, "description": "Path traversal blocked"},
    },
)
async def delete_file(file_path: str) -> DeleteResponse:
    """Remove a file from storage."""
    return await storage.delete_file(file_path)


# -- Metadata --------------------------------------------------------------

@app.get(
    "/api/v1/files/metadata/{file_path:path}",
    response_model=FileMetadataResponse,
    tags=["Files"],
    summary="Get file metadata",
    responses={
        404: {"model": ErrorResponse, "description": "File not found"},
        403: {"model": ErrorResponse, "description": "Path traversal blocked"},
    },
)
async def get_file_metadata(file_path: str) -> FileMetadataResponse:
    """Return metadata (size, MIME type, timestamps) for a single file."""
    return await storage.get_file_metadata(file_path)


# -- Directory listing -----------------------------------------------------

@app.get(
    "/api/v1/files/list",
    response_model=DirectoryListingResponse,
    tags=["Files"],
    summary="List directory contents",
    responses={
        404: {"model": ErrorResponse, "description": "Directory not found"},
        403: {"model": ErrorResponse, "description": "Path traversal blocked"},
    },
)
async def list_directory(
    subdirectory: str | None = None,
) -> DirectoryListingResponse:
    """Scan a directory and return metadata for every file it contains.

    Defaults to the storage root when ``subdirectory`` is omitted.
    """
    return await storage.list_directory(subdirectory)


# ── Uvicorn entry-point ──────────────────────────────────────────────────

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    )
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        workers=settings.WORKERS,
        log_level=settings.LOG_LEVEL,
        reload=False,
    )
