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

"""Custom exception hierarchy for the File Storage Backend.

Every exception carries an ``http_status`` attribute so that the FastAPI
exception handlers in ``main.py`` can translate it into the correct
HTTP response without hard-coding status codes in multiple places.
"""

from __future__ import annotations


class StorageError(Exception):
    """Base exception for all storage-related errors."""

    http_status: int = 500
    error_type: str = "storage_error"

    def __init__(self, detail: str) -> None:
        self.detail = detail
        super().__init__(detail)


class FileNotFoundError_(StorageError):
    """Raised when the requested file does not exist on disk.

    Named with a trailing underscore to avoid shadowing the built-in
    ``FileNotFoundError``.
    """

    http_status: int = 404
    error_type: str = "file_not_found"


class PathTraversalError(StorageError):
    """Raised when a resolved path escapes the storage root.

    This is a **security** exception — the request is malicious or
    malformed and must be rejected unconditionally.
    """

    http_status: int = 403
    error_type: str = "path_traversal"


class PermissionDeniedError(StorageError):
    """Raised when the OS denies a read/write/delete operation."""

    http_status: int = 403
    error_type: str = "permission_denied"


class StorageFullError(StorageError):
    """Raised when insufficient disk space is available for a write."""

    http_status: int = 507
    error_type: str = "storage_full"


class FileTooLargeError(StorageError):
    """Raised when an uploaded file exceeds ``MAX_FILE_SIZE_BYTES``."""

    http_status: int = 413
    error_type: str = "file_too_large"


class InvalidMimeTypeError(StorageError):
    """Raised when the file's MIME type is not in the whitelist."""

    http_status: int = 415
    error_type: str = "invalid_mime_type"
