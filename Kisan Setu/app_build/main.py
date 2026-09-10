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

    uvicorn main:app --host 0.0.0.0 --port 8000
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import logging
import shutil
import secrets
import time
import uuid
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import AsyncIterator

import uvicorn
from fastapi import Depends, FastAPI, File, Form, Header, HTTPException, Query, Request, UploadFile
from fastapi.exceptions import RequestValidationError
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
from database import DatabaseService
from market_service import MarketService
from rate_limit import RateLimiter
from schemas import (
    CommoditiesResponse,
    DatabaseHealthResponse,
    DatabaseStatsResponse,
    DeleteResponse,
    DirectoryListingResponse,
    ErrorResponse,
    FarmerCreateRequest,
    FarmerListResponse,
    FarmerResponse,
    FarmerUpdateRequest,
    FileMetadataResponse,
    HealthResponse,
    MarketPricesResponse,
    PaymentCalculationRequest,
    PaymentCalculationResponse,
    PFMSVoucherListResponse,
    PFMSVoucherMintRequest,
    PFMSVoucherResponse,
    SlotBookingCreateRequest,
    SlotBookingListResponse,
    SlotBookingResponse,
    UploadResponse,
    WeatherResponse,
)
from storage_service import StorageService
from weather_service import WeatherService

logger = logging.getLogger(__name__)

# ── Application settings & services ─────────────────────────────────────

settings: Settings = get_settings()
storage: StorageService = StorageService(settings)
db_service: DatabaseService = DatabaseService(settings)
weather_service: WeatherService = WeatherService(settings)
market_service: MarketService = MarketService(settings)
rate_limiter: RateLimiter = RateLimiter(settings)
INDEX_HTML_PATH = Path(__file__).resolve().parent.parent / "index.html"

# Endpoints that must stay exempt from rate limiting so operational
# monitoring (and the SPA landing page) can never be self-blocked.
RATE_LIMIT_EXEMPT_PATHS = ("/api/v1/health", "/api/v1/db/health")

# Generic client-visible messages per error type. Internals (paths, stack
# traces, database details) are logged server-side only — never echoed.
_GENERIC_ERROR_MESSAGES: dict[str, str] = {
    "file_not_found": "The requested file or directory was not found.",
    "path_traversal": "The request was blocked.",
    "permission_denied": "Operation not permitted.",
    "storage_full": "Insufficient storage space.",
    "file_too_large": "File exceeds the maximum allowed size.",
    "invalid_mime_type": "File type is not allowed.",
    "storage_error": "The storage operation could not be completed.",
    "rate_limited": "Too many requests. Please try again later.",
    "validation_error": "Invalid request parameters.",
    "internal_error": "An unexpected internal error occurred.",
    "unauthorized": "Authentication required.",
    "http_error": "Request was rejected.",
}
_GENERIC_DEFAULT_MESSAGE = _GENERIC_ERROR_MESSAGES["storage_error"]

# Content-Security-Policy values.
# The landing page loads its styling from Tailwind's Play CDN and fonts from
# Google CDNs, so its policy must permit exactly those origins.
_INDEX_CSP = (
    "default-src 'self'; "
    "script-src 'self' https://cdn.tailwindcss.com; "
    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; "
    "font-src 'self' https://fonts.gstatic.com; "
    "img-src 'self' data: https://lh3.googleusercontent.com; "
    "connect-src 'self'"
)
# API/file responses carry no executable content: block everything foreign.
_API_CSP = "default-src 'self'"


# ── Security & request-correlation middleware ─────────────────────────

def _client_ip(request: Request) -> str:
    """Best-effort client IP, honouring a trusted reverse proxy."""
    if settings.TRUST_PROXY:
        forwarded = request.headers.get("x-forwarded-for")
        if forwarded:
            return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def _apply_security_headers(response: object, path: str, request_id: str) -> None:
    """Attach security and correlation headers to any response type."""
    headers = getattr(response, "headers", None)
    if headers is not None:
        headers["X-Request-ID"] = request_id
        headers["X-Content-Type-Options"] = "nosniff"
        headers["X-Frame-Options"] = "DENY"
        headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        headers["Content-Security-Policy"] = (
            _INDEX_CSP if path == "/" else _API_CSP
        )
        headers["Referrer-Policy"] = "no-referrer"


def _error_response_body(
    status_code: int, error_type: str, request_id: str | None
) -> dict:
    return ErrorResponse(
        detail=_GENERIC_ERROR_MESSAGES.get(error_type, _GENERIC_DEFAULT_MESSAGE),
        status_code=status_code,
        error_type=error_type,
        request_id=request_id,
    ).model_dump()


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
    if not settings.STORAGE_API_KEY:
        logger.error(
            "CRITICAL SECURITY WARNING: STORAGE_API_KEY is unset! "
            "Storage vault endpoints will strictly reject unauthenticated access."
        )
    else:
        logger.info("Storage Vault authentication active.")
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
    # Interactive docs (Swagger UI / ReDoc) are disabled by default. They
    # expose the full API surface to anyone who can reach the service; set
    # ENABLE_DOCS=true only for non-production environments.
    docs_url="/docs" if settings.ENABLE_DOCS else None,
    redoc_url="/redoc" if settings.ENABLE_DOCS else None,
    # The OpenAPI JSON is a route/parameter manual for attackers. Disable it
    # in the same breath as the interactive docs, or /api/* stays enumerable.
    openapi_url="/openapi.json" if settings.ENABLE_DOCS else None,
)

# ── CORS middleware ──────────────────────────────────────────────────────

# Origins are taken from CORS_ORIGINS (env) — never "*" in production.
# Credentials are only enabled for explicit, trusted origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)


def _b64url_decode(s: str) -> bytes:
    """Decode base64url string with required padding."""
    s += "=" * ((4 - len(s) % 4) % 4)
    return base64.urlsafe_b64decode(s.encode("ascii"))


def _verify_storage_token(token: str) -> bool:
    """Validate bearer token against STORAGE_API_KEY (API key or HMAC-SHA256 JWT).

    Supports:
    1. Direct high-entropy API key verification with constant-time equality.
    2. Signed JWT token (HS256) verification with claims & expiration validation.
    """
    expected_key = settings.STORAGE_API_KEY
    if not token or not expected_key:
        return False

    # 1. Constant-time API Key check (prevents timing side-channel attacks)
    if secrets.compare_digest(token, expected_key):
        return True

    # 2. Cryptographic JWT HS256 Token verification
    try:
        parts = token.split(".")
        if len(parts) == 3:
            h_b64, p_b64, sig_b64 = parts
            signing_input = f"{h_b64}.{p_b64}".encode("ascii")
            expected_sig = hmac.new(
                expected_key.encode("utf-8"), signing_input, hashlib.sha256
            ).digest()
            actual_sig = _b64url_decode(sig_b64)
            if secrets.compare_digest(expected_sig, actual_sig):
                header = json.loads(_b64url_decode(h_b64))
                if header.get("alg") == "HS256":
                    payload = json.loads(_b64url_decode(p_b64))
                    exp = payload.get("exp")
                    if exp is not None and time.time() > float(exp):
                        return False  # Expired token
                    nbf = payload.get("nbf")
                    if nbf is not None and time.time() < float(nbf):
                        return False  # Token not active yet
                    return True
    except Exception:
        pass

    return False


# ── Middleware: request ID + security headers + rate limiting ─────────

@app.middleware("http")
async def security_and_rate_limit_middleware(
    request: Request,
    call_next,
):
    request_id = request.headers.get("X-Request-ID") or uuid.uuid4().hex
    request.state.request_id = request_id

    client_ip = _client_ip(request)
    path = request.url.path

    # ── Strict Authentication Middleware for Storage & DB APIs ──────────────
    # Rejects any unauthenticated request with a 401 Unauthorized status
    # before executing any file operations, uploads, or deletion logic.
    if request.method != "OPTIONS":
        normalized_path = path.rstrip("/")
        if normalized_path == "/api/v1/files" or normalized_path.startswith("/api/v1/files/"):
            auth_header = request.headers.get("Authorization") or ""
            api_key_header = request.headers.get("X-API-Key") or ""
            token = ""
            if auth_header.startswith("Bearer "):
                token = auth_header[7:].strip()
            elif api_key_header:
                token = api_key_header.strip()

            if not _verify_storage_token(token):
                logger.warning(
                    "UNAUTHORIZED_STORAGE_ACCESS_ATTEMPT: %s %s from IP %s (request_id=%s)",
                    request.method, path, client_ip, request_id,
                )
                response = JSONResponse(
                    status_code=401,
                    content=_error_response_body(401, "unauthorized", request_id),
                    headers={
                        "WWW-Authenticate": 'Bearer realm="kisan-setu-vault", error="invalid_token", error_description="Missing or invalid authentication credentials"'
                    },
                )
                _apply_security_headers(response, path, request_id)
                return response

        elif path.startswith("/api/v1/db/"):
            expected_admin_key = settings.ADMIN_API_KEY
            if expected_admin_key:
                auth_header = request.headers.get("Authorization") or ""
                token = auth_header[7:].strip() if auth_header.startswith("Bearer ") else ""
                if not (token and secrets.compare_digest(token, expected_admin_key)):
                    logger.warning(
                        "Unauthenticated DB access attempt to %s from %s (request_id=%s)",
                        path, client_ip, request_id,
                    )
                    response = JSONResponse(
                        status_code=401,
                        content=_error_response_body(401, "unauthorized", request_id),
                        headers={"WWW-Authenticate": "Bearer"},
                    )
                    _apply_security_headers(response, path, request_id)
                    return response

    # Rate limit every /api route except preflight (OPTIONS) and exempt paths.
    if (
        request.method != "OPTIONS"
        and path.startswith("/api/")
        and not path.startswith(RATE_LIMIT_EXEMPT_PATHS)
    ):
        allowed, retry_after = rate_limiter.enforce(client_ip, path)
        if not allowed:
            logger.warning(
                "Rate limit exceeded for IP %s on %s (retry after %ds, request_id=%s)",
                client_ip, path, retry_after, request_id,
            )
            response = JSONResponse(
                status_code=429,
                content=_error_response_body(429, "rate_limited", request_id),
                headers={"Retry-After": str(retry_after)},
            )
            _apply_security_headers(response, path, request_id)
            return response

    response = await call_next(request)
    _apply_security_headers(response, path, request_id)
    return response


# ── Exception handlers ──────────────────────────────────────────────────

@app.exception_handler(StorageError)
async def storage_error_handler(
    request: Request,
    exc: StorageError,
) -> JSONResponse:
    """Translate any ``StorageError`` subclass into a structured JSON response.

    Full internal detail (absolute paths, filesystem specifics) is written
    to the server log only; clients receive a generic, safe message plus a
    correlation ID.
    """
    request_id = getattr(request.state, "request_id", None)
    logger.warning(
        "%s [%d]: %s (request_id=%s)",
        exc.error_type, exc.http_status, exc.detail, request_id,
    )
    return JSONResponse(
        status_code=exc.http_status,
        content=_error_response_body(exc.http_status, exc.error_type, request_id),
    )


@app.exception_handler(RequestValidationError)
async def validation_error_handler(
    request: Request,
    exc: RequestValidationError,
) -> JSONResponse:
    """Return a generic 422 envelope; validation specifics go to logs only."""
    request_id = getattr(request.state, "request_id", None)
    logger.warning(
        "Validation error (request_id=%s): %s", request_id, exc.errors(),
    )
    return JSONResponse(
        status_code=422,
        content=_error_response_body(422, "validation_error", request_id),
    )


@app.exception_handler(HTTPException)
async def http_error_handler(
    request: Request,
    exc: HTTPException,
) -> JSONResponse:
    """Envelope any FastAPI HTTPException (auth deps, etc.) consistently."""
    request_id = getattr(request.state, "request_id", None)
    logger.warning(
        "HTTP %d (request_id=%s): %s", exc.status_code, request_id, exc.detail,
    )
    return JSONResponse(
        status_code=exc.status_code,
        content=_error_response_body(exc.status_code, "http_error", request_id),
        headers={"WWW-Authenticate": "Bearer"} if exc.status_code == 401 else None,
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(
    request: Request,
    exc: Exception,
) -> JSONResponse:
    """Catch-all: never leak internals, always return a correlation ID."""
    request_id = getattr(request.state, "request_id", None)
    logger.exception(
        "Unhandled error (request_id=%s): %s", request_id, exc,
    )
    return JSONResponse(
        status_code=500,
        content=_error_response_body(500, "internal_error", request_id),
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
    return HealthResponse(free_disk_bytes=usage.free)


# ── Storage Authentication Dependency ─────────────────────────────────────

def require_storage_auth(
    authorization: str | None = Header(None, alias="Authorization"),
    x_api_key: str | None = Header(None, alias="X-API-Key"),
) -> str:
    """FastAPI security dependency for storage API endpoints.

    Rejects any unauthenticated or unauthorized caller with 401 Unauthorized
    before file operations, uploads, or deletion logic can execute.
    """
    token = ""
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:].strip()
    elif x_api_key:
        token = x_api_key.strip()

    if not _verify_storage_token(token):
        raise HTTPException(
            status_code=401,
            detail="Storage API requires valid authentication credentials (Bearer token, JWT, or X-API-Key).",
            headers={
                "WWW-Authenticate": 'Bearer realm="kisan-setu-vault", error="invalid_token", error_description="Missing or invalid authentication credentials"'
            },
        )
    return token


# -- Upload ---------------------------------------------------------------

@app.post(
    "/api/v1/files/upload",
    response_model=UploadResponse,
    status_code=201,
    dependencies=[Depends(require_storage_auth)],
    tags=["Files"],
    summary="Upload a file",
    responses={
        401: {"model": ErrorResponse, "description": "Authentication required"},
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
    dependencies=[Depends(require_storage_auth)],
    tags=["Files"],
    summary="Download a file",
    responses={
        401: {"model": ErrorResponse, "description": "Authentication required"},
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
    dependencies=[Depends(require_storage_auth)],
    tags=["Files"],
    summary="Delete a file",
    responses={
        401: {"model": ErrorResponse, "description": "Authentication required"},
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
    dependencies=[Depends(require_storage_auth)],
    tags=["Files"],
    summary="Get file metadata",
    responses={
        401: {"model": ErrorResponse, "description": "Authentication required"},
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
    dependencies=[Depends(require_storage_auth)],
    tags=["Files"],
    summary="List directory contents",
    responses={
        401: {"model": ErrorResponse, "description": "Authentication required"},
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


# -- Web Application Root --------------------------------------------------

@app.get(
    "/",
    tags=["Web"],
    summary="Serve Kisan Setu web application",
    include_in_schema=False,
)
async def serve_index() -> FileResponse:
    """Serve the single-page agricultural procurement web application."""
    if INDEX_HTML_PATH.is_file():
        return FileResponse(
            path=INDEX_HTML_PATH,
            media_type="text/html",
            headers={"Cache-Control": "no-cache"},
        )
    return JSONResponse(
        status_code=404,
        content=_error_response_body(404, "file_not_found", None),
    )


# -- Weather API -----------------------------------------------------------

@app.get(
    "/api/v1/weather",
    response_model=WeatherResponse,
    tags=["Weather"],
    summary="Real-time agricultural weather & advisory",
)
async def get_weather(
    lat: float = 29.6857,
    lon: float = 76.9905,
    location: str = "Karnal",
) -> WeatherResponse:
    """Return real-time or cached weather data with farm-specific advisory.

    Coordinates default to Karnal, Haryana (lat=29.6857, lon=76.9905).
    Falls back gracefully to rich demo weather if OPENWEATHER_API_KEY is unset.
    """
    return await weather_service.get_weather(lat=lat, lon=lon, location=location)


# -- Market / Crop Prices API ----------------------------------------------

@app.get(
    "/api/v1/market/prices",
    response_model=MarketPricesResponse,
    tags=["Market"],
    summary="Current mandi crop prices & MSP benchmark",
)
async def get_market_prices(
    commodity: str = "Wheat",
    state: str = "Haryana",
) -> MarketPricesResponse:
    """Return daily mandi crop prices across mandis from Agmarknet.

    Calculates comparison with Government Minimum Support Price (MSP).
    Falls back gracefully to verified demo records if DATAGOV_API_KEY is unset.
    """
    return await market_service.get_prices(commodity=commodity, state=state)


@app.get(
    "/api/v1/market/commodities",
    response_model=CommoditiesResponse,
    tags=["Market"],
    summary="List tracked agricultural commodities",
)
async def list_commodities() -> CommoditiesResponse:
    """Return list of agricultural commodities supported by price lookups."""
    return market_service.get_supported_commodities()


# ── SQL Relational Database Endpoints ────────────────────────────────────

@app.get(
    "/api/v1/db/health",
    response_model=DatabaseHealthResponse,
    tags=["Database"],
    summary="SQL database health and integrity check",
)
async def get_db_health() -> DatabaseHealthResponse:
    """Return SQLite WAL mode status, file metrics, and integrity verification."""
    data = await db_service.health_check()
    return DatabaseHealthResponse(**data)


@app.get(
    "/api/v1/db/stats",
    response_model=DatabaseStatsResponse,
    tags=["Database"],
    summary="SQL database records and counters",
)
async def get_db_stats() -> DatabaseStatsResponse:
    """Return live table row counts and database storage size."""
    data = await db_service.get_stats()
    return DatabaseStatsResponse(**data)


@app.get(
    "/api/v1/db/farmers",
    response_model=FarmerListResponse,
    tags=["Database"],
    summary="List registered farmers",
)
async def list_farmers(limit: int = Query(50, ge=1, le=200)) -> FarmerListResponse:
    """Return list of registered farmers stored in the SQL database."""
    farmers = await db_service.list_farmers(limit=limit)
    return FarmerListResponse(
        farmers=[FarmerResponse(**f) for f in farmers],
        total=len(farmers),
    )


@app.post(
    "/api/v1/db/farmers",
    response_model=FarmerResponse,
    status_code=201,
    tags=["Database"],
    summary="Create or register a farmer in SQL DB",
)
async def create_farmer(payload: FarmerCreateRequest) -> FarmerResponse:
    """Create a new farmer or update existing record by mobile number."""
    record = await db_service.create_farmer(payload.model_dump())
    return FarmerResponse(**record)


@app.get(
    "/api/v1/db/farmers/{identifier}",
    response_model=FarmerResponse,
    tags=["Database"],
    summary="Fetch farmer details by ID or mobile",
)
async def get_farmer(identifier: str) -> FarmerResponse:
    """Fetch complete farmer profile including land records and bank accounts."""
    record = await db_service.get_farmer_by_id_or_mobile(identifier)
    if not record:
        return JSONResponse(
            status_code=404,
            content={"detail": f"Farmer '{identifier}' not found in database."},
        )
    return FarmerResponse(**record)


@app.put(
    "/api/v1/db/farmers/{farmer_id}",
    response_model=FarmerResponse,
    tags=["Database"],
    summary="Update farmer details in SQL DB",
)
async def update_farmer(farmer_id: str, payload: FarmerUpdateRequest) -> FarmerResponse:
    """Update farmer personal information (name, village, mobile)."""
    record = await db_service.update_farmer(farmer_id, payload.model_dump(exclude_unset=True))
    if not record:
        return JSONResponse(
            status_code=404,
            content={"detail": f"Farmer '{farmer_id}' not found in database."},
        )
    return FarmerResponse(**record)


@app.get(
    "/api/v1/db/bookings",
    response_model=SlotBookingListResponse,
    tags=["Database"],
    summary="List mandi slot bookings and gate passes",
)
async def list_bookings(farmer_id: str | None = None, limit: int = Query(50, ge=1, le=200)) -> SlotBookingListResponse:
    """Return all slot bookings / gate passes from the SQL database."""
    bookings = await db_service.list_bookings(farmer_id=farmer_id, limit=limit)
    return SlotBookingListResponse(
        bookings=[SlotBookingResponse(**b) for b in bookings],
        total=len(bookings),
    )


@app.post(
    "/api/v1/db/bookings",
    response_model=SlotBookingResponse,
    status_code=201,
    tags=["Database"],
    summary="Create mandi slot booking in SQL DB",
)
async def create_booking(payload: SlotBookingCreateRequest) -> SlotBookingResponse:
    """Record a mandi slot booking and generate a digital gate pass token in SQL."""
    record = await db_service.create_booking(payload.model_dump())
    return SlotBookingResponse(**record)


@app.get(
    "/api/v1/db/bookings/{token_number}",
    response_model=SlotBookingResponse,
    tags=["Database"],
    summary="Fetch gate pass by token number",
)
async def get_booking(token_number: str) -> SlotBookingResponse:
    """Fetch slot booking details by token number."""
    record = await db_service.get_booking_by_token(token_number)
    if not record:
        return JSONResponse(
            status_code=404,
            content={"detail": f"Booking token '{token_number}' not found in database."},
        )
    return SlotBookingResponse(**record)


# ── Server-Side Payment & PFMS DBT Voucher Endpoints ─────────────────────


@app.post(
    "/api/v1/payments/calculate",
    response_model=PaymentCalculationResponse,
    tags=["Payments"],
    summary="Calculate verified farmer procurement payout using official MSP rates",
)
async def calculate_payment(
    payload: PaymentCalculationRequest,
) -> PaymentCalculationResponse:
    """Calculate verified farmer procurement payout using official MSP rates.

    All mathematical calculation and government rate lookups are executed
    on the backend to strictly prevent client-side price/quantity tampering.
    """
    result = await db_service.calculate_payment(
        commodity=payload.commodity,
        quantity=payload.quantity_quintals,
    )
    return PaymentCalculationResponse(**result)


@app.post(
    "/api/v1/payments/voucher/mint",
    response_model=PFMSVoucherResponse,
    status_code=201,
    tags=["Payments"],
    summary="Cryptographically mint and record an authentic PFMS DBT voucher",
)
async def mint_pfms_voucher(
    payload: PFMSVoucherMintRequest,
) -> PFMSVoucherResponse:
    """Mint and record a server-signed PFMS Direct Benefit Transfer voucher.

    Computes tamper-proof HMAC-SHA256 audit hashes and server digital
    signatures backed by persistent SQLite storage. Prevents unauthorized
    client-side voucher forging.
    """
    record = await db_service.mint_pfms_voucher(payload.model_dump())
    return PFMSVoucherResponse(**record)


@app.get(
    "/api/v1/payments/voucher/{voucher_ref}",
    response_model=PFMSVoucherResponse,
    tags=["Payments"],
    summary="Fetch and verify authentic PFMS DBT voucher",
)
async def get_pfms_voucher(voucher_ref: str) -> PFMSVoucherResponse:
    """Retrieve an authenticated PFMS voucher by voucher_ref or UTR number."""
    record = await db_service.get_pfms_voucher(voucher_ref)
    if not record:
        return JSONResponse(
            status_code=404,
            content={"detail": f"PFMS voucher '{voucher_ref}' not found in registry."},
        )
    return PFMSVoucherResponse(**record)


@app.get(
    "/api/v1/payments/vouchers",
    response_model=PFMSVoucherListResponse,
    tags=["Payments"],
    summary="List official PFMS DBT vouchers",
)
async def list_pfms_vouchers(
    farmer_id: str | None = None,
    limit: int = Query(50, ge=1, le=200),
) -> PFMSVoucherListResponse:
    """List authenticated PFMS vouchers issued by the central server."""
    vouchers = await db_service.list_pfms_vouchers(farmer_id=farmer_id, limit=limit)
    return PFMSVoucherListResponse(
        vouchers=[PFMSVoucherResponse(**v) for v in vouchers],
        total=len(vouchers),
    )


# ── Uvicorn entry-point ──────────────────────────────────────────────────

if __name__ == "__main__":
    logging.basicConfig(
        level=(logging.DEBUG if settings.DEBUG else logging.INFO),
        format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    )
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        workers=settings.WORKERS,
        log_level="debug" if settings.DEBUG else settings.LOG_LEVEL,
        # Reload is a development convenience; it must never be active in
        # production deployments. Tied to DEBUG so it stays OFF by default.
        reload=settings.DEBUG,
    )