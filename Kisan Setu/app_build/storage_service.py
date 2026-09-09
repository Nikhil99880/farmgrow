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

"""Async file storage engine.

``StorageService`` is the single entry-point for all file I/O.  Every
public method validates paths through ``_validate_path`` *before*
touching the filesystem, ensuring that no operation can escape the
configured storage root.

Chunk-based upload streaming keeps memory pressure constant regardless
of file size.
"""

from __future__ import annotations

import logging
import mimetypes
import os
import shutil
from datetime import datetime, timezone
from pathlib import Path

import aiofiles

from config import Settings
from exceptions import (
    FileNotFoundError_,
    FileTooLargeError,
    InvalidMimeTypeError,
    PathTraversalError,
    PermissionDeniedError,
    StorageFullError,
)
from schemas import (
    DeleteResponse,
    DirectoryListingResponse,
    FileMetadataResponse,
    UploadResponse,
)

logger = logging.getLogger(__name__)


class StorageService:
    """Async file storage operations backed by local disk.

    Parameters
    ----------
    settings:
        Application configuration instance.  Injected at construction
        so that the service is easily testable with alternate settings.
    """

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._root: Path = settings.STORAGE_ROOT.resolve()

    # ── Path safety ──────────────────────────────────────────────────────

    def _validate_path(self, relative_path: str) -> Path:
        """Resolve *relative_path* against the storage root and reject traversals.

        Parameters
        ----------
        relative_path:
            User-supplied path fragment.  May contain forward- or
            back-slashes but **must not** escape the storage root after
            resolution.

        Returns
        -------
        Path
            Canonical, absolute path guaranteed to be inside
            ``self._root``.

        Raises
        ------
        PathTraversalError
            If the resolved path lands outside the storage root.
        """
        # Normalise separators and strip leading slashes so that
        # ``/etc/passwd`` doesn't bypass the join.
        cleaned = relative_path.replace("\\", "/").lstrip("/")

        # Reject obviously malicious patterns early.
        if ".." in cleaned.split("/"):
            raise PathTraversalError(
                f"Path traversal detected in '{relative_path}'."
            )

        candidate = (self._root / cleaned).resolve()

        # The resolved path *must* be inside (or equal to) the root.
        try:
            candidate.relative_to(self._root)
        except ValueError:
            raise PathTraversalError(
                f"Resolved path '{candidate}' escapes storage root."
            )

        return candidate

    # ── MIME / size validation ───────────────────────────────────────────

    def _resolve_mime_type(
        self,
        filename: str,
        declared_content_type: str | None,
    ) -> str:
        """Determine the effective MIME type for *filename*.

        Priority:
        1. ``mimetypes`` guess from the file extension.
        2. Declared ``Content-Type`` header from the upload.
        3. Fallback to ``application/octet-stream``.

        Raises
        ------
        InvalidMimeTypeError
            If the resolved type is not in the whitelist.
        """
        guessed, _ = mimetypes.guess_type(filename, strict=False)
        effective = guessed or declared_content_type or "application/octet-stream"

        if not self._settings.is_mime_allowed(effective):
            raise InvalidMimeTypeError(
                f"MIME type '{effective}' is not allowed. "
                f"Permitted prefixes: {self._settings.ALLOWED_MIME_PREFIXES}"
            )
        return effective

    def _check_disk_space(self) -> None:
        """Raise ``StorageFullError`` if free disk space is too low."""
        try:
            usage = shutil.disk_usage(self._root)
        except OSError as exc:
            raise StorageFullError(
                f"Unable to query disk usage: {exc}"
            ) from exc

        if usage.free < self._settings.MIN_FREE_DISK_BYTES:
            raise StorageFullError(
                f"Insufficient disk space. "
                f"Free: {usage.free:,} bytes, "
                f"required minimum: {self._settings.MIN_FREE_DISK_BYTES:,} bytes."
            )

    # ── File metadata helper ─────────────────────────────────────────────

    def _build_metadata(self, abs_path: Path) -> FileMetadataResponse:
        """Build a ``FileMetadataResponse`` from an on-disk file."""
        stat = abs_path.stat()
        mime, _ = mimetypes.guess_type(abs_path.name, strict=False)
        relative = abs_path.relative_to(self._root)

        return FileMetadataResponse(
            filename=abs_path.name,
            relative_path=str(relative).replace("\\", "/"),
            size_bytes=stat.st_size,
            mime_type=mime or "application/octet-stream",
            created_at=datetime.fromtimestamp(stat.st_ctime, tz=timezone.utc),
            modified_at=datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc),
        )

    # ── Public API ───────────────────────────────────────────────────────

    async def upload_file(
        self,
        file_content: bytes | None,
        filename: str,
        content_type: str | None,
        read_chunk: object | None = None,
        subdirectory: str | None = None,
    ) -> UploadResponse:
        """Stream an uploaded file to disk in fixed-size chunks.

        Parameters
        ----------
        file_content:
            If provided, the complete file bytes (used when the caller
            has already consumed the ``UploadFile``).  When ``None``,
            *read_chunk* must be a callable returning awaitable chunks.
        filename:
            Original filename from the upload.
        content_type:
            Declared MIME ``Content-Type`` header.
        read_chunk:
            An ``async`` callable ``(size) -> bytes`` for streaming
            reads.  Typically ``upload_file.read``.
        subdirectory:
            Optional sub-path under the storage root.

        Returns
        -------
        UploadResponse
        """
        # 1. MIME validation
        mime = self._resolve_mime_type(filename, content_type)

        # 2. Disk space guard
        self._check_disk_space()

        # 3. Build target path
        if subdirectory:
            target_dir = self._validate_path(subdirectory)
        else:
            target_dir = self._root

        target_dir.mkdir(parents=True, exist_ok=True)
        target_file = target_dir / filename

        # Re-validate the final path (filename itself could be crafted).
        self._validate_path(
            str(target_file.relative_to(self._root))
        )

        # 4. Chunked async write
        total_bytes = 0
        try:
            async with aiofiles.open(target_file, "wb") as out:
                if read_chunk is not None:
                    while True:
                        chunk = await read_chunk(self._settings.CHUNK_SIZE)
                        if not chunk:
                            break
                        total_bytes += len(chunk)
                        if total_bytes > self._settings.MAX_FILE_SIZE_BYTES:
                            # Clean up the partial file.
                            await out.close()
                            target_file.unlink(missing_ok=True)
                            raise FileTooLargeError(
                                f"File exceeds maximum size of "
                                f"{self._settings.MAX_FILE_SIZE_BYTES:,} bytes."
                            )
                        await out.write(chunk)
                elif file_content is not None:
                    total_bytes = len(file_content)
                    if total_bytes > self._settings.MAX_FILE_SIZE_BYTES:
                        raise FileTooLargeError(
                            f"File exceeds maximum size of "
                            f"{self._settings.MAX_FILE_SIZE_BYTES:,} bytes."
                        )
                    await out.write(file_content)
                else:
                    raise ValueError(
                        "Either 'file_content' or 'read_chunk' must be provided."
                    )
        except PermissionError as exc:
            raise PermissionDeniedError(
                f"Cannot write to '{target_file}': {exc}"
            ) from exc
        except OSError as exc:
            # Catch disk-full and other OS-level write failures.
            target_file.unlink(missing_ok=True)
            raise StorageFullError(
                f"OS error during write: {exc}"
            ) from exc

        relative = str(target_file.relative_to(self._root)).replace("\\", "/")
        logger.info(
            "Uploaded %s (%s bytes, %s)", relative, total_bytes, mime,
        )

        return UploadResponse(
            filename=filename,
            relative_path=relative,
            size_bytes=total_bytes,
            mime_type=mime,
        )

    async def download_file(
        self,
        relative_path: str,
    ) -> tuple[Path, str]:
        """Validate and return the absolute path + MIME type for streaming.

        The caller (the route handler) passes the result straight into
        ``FileResponse``.

        Raises
        ------
        FileNotFoundError_
            If the file does not exist.
        """
        abs_path = self._validate_path(relative_path)

        if not abs_path.is_file():
            raise FileNotFoundError_(
                f"File not found: '{relative_path}'."
            )

        mime, _ = mimetypes.guess_type(abs_path.name, strict=False)
        return abs_path, mime or "application/octet-stream"

    async def delete_file(self, relative_path: str) -> DeleteResponse:
        """Remove a file from disk.

        Raises
        ------
        FileNotFoundError_
            If the file does not exist.
        PermissionDeniedError
            If the OS blocks the deletion.
        """
        abs_path = self._validate_path(relative_path)

        if not abs_path.is_file():
            raise FileNotFoundError_(
                f"File not found: '{relative_path}'."
            )

        try:
            abs_path.unlink()
        except PermissionError as exc:
            raise PermissionDeniedError(
                f"Cannot delete '{relative_path}': {exc}"
            ) from exc

        logger.info("Deleted %s", relative_path)

        return DeleteResponse(
            filename=abs_path.name,
            relative_path=relative_path,
        )

    async def get_file_metadata(
        self,
        relative_path: str,
    ) -> FileMetadataResponse:
        """Return metadata for a single file.

        Raises
        ------
        FileNotFoundError_
            If the file does not exist.
        """
        abs_path = self._validate_path(relative_path)

        if not abs_path.is_file():
            raise FileNotFoundError_(
                f"File not found: '{relative_path}'."
            )

        return self._build_metadata(abs_path)

    async def list_directory(
        self,
        subdirectory: str | None = None,
    ) -> DirectoryListingResponse:
        """Scan a directory and return metadata for every file it contains.

        Only regular files are included (symlinks, directories, and
        special files are skipped).

        Parameters
        ----------
        subdirectory:
            Optional path relative to the storage root.  Defaults to
            the root itself.
        """
        if subdirectory:
            target = self._validate_path(subdirectory)
        else:
            target = self._root

        if not target.is_dir():
            raise FileNotFoundError_(
                f"Directory not found: '{subdirectory or '/'}'."
            )

        files: list[FileMetadataResponse] = []
        total_size = 0

        try:
            for entry in sorted(target.iterdir()):
                if entry.is_file():
                    meta = self._build_metadata(entry)
                    files.append(meta)
                    total_size += meta.size_bytes
        except PermissionError as exc:
            raise PermissionDeniedError(
                f"Cannot read directory '{subdirectory or '/'}': {exc}"
            ) from exc

        relative_dir = (
            str(target.relative_to(self._root)).replace("\\", "/")
            if target != self._root
            else "."
        )

        return DirectoryListingResponse(
            directory=relative_dir,
            files=files,
            total_count=len(files),
            total_size_bytes=total_size,
        )
