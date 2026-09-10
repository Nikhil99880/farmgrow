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
    free_disk_bytes: int = Field(..., ge=0)


class ErrorResponse(BaseModel):
    """Standardised error envelope.

    ``detail`` is intentionally generic and never leaks internal paths or
    stack traces to the client. ``request_id`` lets operators correlate a
    client-visible error with the matching server-side log entry.
    """

    model_config = ConfigDict(strict=True, frozen=True)

    detail: str
    status_code: int
    error_type: str
    request_id: str | None = Field(
        default=None,
        description="Correlation ID for this request (also echoed as the X-Request-ID header).",
    )


# ── Weather API Models ───────────────────────────────────────────────────


class WeatherResponse(BaseModel):
    """Real-time weather data for a geographic location."""

    model_config = ConfigDict(frozen=True)

    location: str = Field(..., description="City / location name.")
    country: str = Field(..., description="ISO country code (e.g. 'IN').")
    latitude: float = Field(..., description="Query latitude.")
    longitude: float = Field(..., description="Query longitude.")

    temperature_c: float = Field(..., description="Temperature in °C.")
    feels_like_c: float = Field(..., description="Feels-like temperature in °C.")
    temp_min_c: float = Field(..., description="Minimum temperature today in °C.")
    temp_max_c: float = Field(..., description="Maximum temperature today in °C.")

    humidity_pct: int = Field(..., ge=0, le=100, description="Relative humidity (%).")
    wind_speed_kmh: float = Field(..., description="Wind speed in km/h.")
    wind_direction_deg: int = Field(..., description="Wind direction in degrees.")
    visibility_km: float = Field(..., description="Visibility in km.")
    cloud_cover_pct: int = Field(..., ge=0, le=100, description="Cloud cover (%).")

    description: str = Field(..., description="Short weather description.")
    icon_code: str = Field(..., description="OpenWeatherMap icon code.")
    icon_url: str = Field(..., description="Full URL to weather icon image.")

    sunrise_utc: str = Field(..., description="Sunrise time (HH:MM UTC).")
    sunset_utc: str = Field(..., description="Sunset time (HH:MM UTC).")

    farm_advisory: str = Field(
        ...,
        description="Short farm-relevant advisory derived from conditions.",
    )

    is_demo: bool = Field(
        False,
        description="True when live API key is not configured and demo data is returned.",
    )
    fetched_at: datetime = Field(..., description="Timestamp of the data fetch (UTC).")


# ── Market / Crop Price Models ───────────────────────────────────────────


class CropPriceEntry(BaseModel):
    """A single crop price record from a mandi."""

    model_config = ConfigDict(frozen=True)

    commodity: str = Field(..., description="Commodity name (e.g. 'Wheat').")
    variety: str = Field(..., description="Variety / grade (e.g. 'FAQ').")
    market: str = Field(..., description="Mandi / market name.")
    district: str = Field(..., description="District where the mandi is located.")
    state: str = Field(..., description="State name.")
    arrival_date: str = Field(..., description="Date of price record (DD/MM/YYYY).")
    min_price: float = Field(..., ge=0, description="Minimum price (₹ / quintal).")
    max_price: float = Field(..., ge=0, description="Maximum price (₹ / quintal).")
    modal_price: float = Field(..., ge=0, description="Modal (most common) price (₹ / quintal).")
    msp: float | None = Field(
        None,
        description="Government MSP for this commodity (₹ / quintal), if available.",
    )
    above_msp: bool | None = Field(
        None,
        description="True if modal_price >= MSP.",
    )


class MarketPricesResponse(BaseModel):
    """Aggregated mandi crop price data."""

    model_config = ConfigDict(frozen=True)

    commodity: str = Field(..., description="Queried commodity.")
    state: str = Field(..., description="Queried state.")
    records: list[CropPriceEntry] = Field(
        default_factory=list,
        description="List of mandi price records.",
    )
    total_records: int = Field(..., ge=0, description="Total number of records returned.")
    source: str = Field(..., description="Data source name.")
    is_demo: bool = Field(
        False,
        description="True when API key is not configured and demo data is returned.",
    )
    fetched_at: datetime = Field(..., description="Timestamp of the data fetch (UTC).")


class CommoditiesResponse(BaseModel):
    """List of commodity names supported by the market price endpoint."""

    model_config = ConfigDict(frozen=True)

    commodities: list[str] = Field(..., description="Supported commodity names.")
    total: int = Field(..., ge=0)


# ── SQL Database Models ──────────────────────────────────────────────────


class FarmerCreateRequest(BaseModel):
    """Payload to create or register a farmer in SQL DB."""

    full_name: str = Field(..., min_length=2, description="Farmer's full name.")
    mobile: str = Field(..., min_length=10, max_length=10, description="10-digit mobile number.")
    village: str = Field(..., min_length=1, description="Village or district.")
    farmer_id: str | None = Field(None, description="Optional custom farmer ID (e.g. 'PB-10492').")
    aadhaar_last4: str | None = Field("1234", description="Last 4 digits of Aadhaar.")
    aadhaar_linked: bool = Field(True, description="Whether Aadhaar is verified/linked.")


class FarmerUpdateRequest(BaseModel):
    """Payload to update an existing farmer."""

    full_name: str | None = None
    mobile: str | None = None
    village: str | None = None


class FarmerResponse(BaseModel):
    """Farmer model returned from SQL DB."""

    id: int
    farmer_id: str
    full_name: str
    mobile: str
    village: str
    aadhaar_last4: str = "1234"
    aadhaar_linked: int = 1
    created_at: str
    updated_at: str
    land_records: list[dict] | None = None
    bank_accounts: list[dict] | None = None


class FarmerListResponse(BaseModel):
    """List of farmers in the SQL DB."""

    farmers: list[FarmerResponse]
    total: int


class SlotBookingCreateRequest(BaseModel):
    """Payload to record a mandi slot booking in SQL DB."""

    farmer_id: str = "PB-10492"
    farmer_name: str = "Ram Singh"
    farmer_mobile: str = "9876543210"
    commodity: str = "Wheat"
    mandi_name: str = "Karnal Grain Market"
    booking_date: str = "2026-09-10"
    time_slot: str = "08:00 AM - 10:00 AM"
    estimated_qty_quintals: float = Field(50.0, ge=0, le=10000)
    vehicle_type: str = "Tractor Trolley"
    vehicle_number: str = "HR05-AK-9821"
    token_number: str | None = None


class SlotBookingResponse(BaseModel):
    """Slot booking token model returned from SQL DB."""

    id: int
    token_number: str
    farmer_id: str
    farmer_name: str
    farmer_mobile: str
    commodity: str
    mandi_name: str
    booking_date: str
    time_slot: str
    estimated_qty_quintals: float
    vehicle_type: str
    vehicle_number: str
    gate_number: str = "Gate 2"
    queue_position: int = 4
    status: str = "CONFIRMED"
    created_at: str


class SlotBookingListResponse(BaseModel):
    """List of bookings in the SQL DB."""

    bookings: list[SlotBookingResponse]
    total: int


class DatabaseHealthResponse(BaseModel):
    """SQL database runtime and integrity health status."""

    status: str
    engine: str = "sqlite3"
    journal_mode: str
    integrity_check: str


class DatabaseStatsResponse(BaseModel):
    """SQL database metrics and record counters."""

    farmers_count: int
    bookings_count: int
    land_records_count: int
    bank_accounts_count: int
    database_size_bytes: int
    last_checked_at: str


# ── Server-Side Payment & PFMS Voucher Models ────────────────────────────


class PaymentCalculationRequest(BaseModel):
    """Secure server-side payment calculation input."""

    commodity: str = Field(..., description="Crop name (e.g. 'Wheat', 'Mustard', 'Paddy').")
    quantity_quintals: float = Field(..., gt=0, le=5000, description="Quantity in quintals.")
    mandi_name: str | None = Field(None, description="Destination mandi center.")


class PaymentCalculationResponse(BaseModel):
    """Server-calculated, verified agricultural payment and MSP breakdown."""

    commodity: str
    quantity_quintals: float
    verified_msp_rate: float = Field(..., description="Official Ministry MSP rate per quintal in ₹.")
    gross_amount: float = Field(..., description="Gross crop procurement value before deductions.")
    mandi_cess_amount: float = Field(..., description="Statutory 1% market committee mandi cess.")
    net_payout_amount: float = Field(..., description="Net electronic bank transfer payable to farmer.")
    currency: str = "INR"
    is_verified_by_ministry: bool = True
    calculation_timestamp: str


class PFMSVoucherMintRequest(BaseModel):
    """Secure server-side PFMS DBT voucher issuance request."""

    farmer_id: str = Field(..., description="Registered farmer ID.")
    commodity: str = Field(..., description="Crop commodity.")
    quantity_quintals: float = Field(..., gt=0, le=5000, description="Quantity in quintals.")
    farmer_name: str | None = Field(None, description="Farmer name (defaults from DB profile if empty).")
    bank_name: str | None = Field("State Bank of India", description="Aadhaar linked bank.")
    account_last4: str | None = Field("5678", description="Last 4 digits of bank account.")
    ifsc_code: str | None = Field("SBIN0001234", description="Bank IFSC code.")
    mandi_name: str | None = Field("Karnal Grain Market", description="Procuring APMC mandi.")


class PFMSVoucherResponse(BaseModel):
    """Authentic, server-signed PFMS Direct Benefit Transfer voucher."""

    voucher_ref: str = Field(..., description="Official server sequence (e.g. 'PFMS-VCHR-2026-89412').")
    utr_number: str = Field(..., description="Electronic bank UTR transaction number.")
    farmer_id: str
    farmer_name: str
    commodity: str
    quantity_quintals: float
    msp_rate: float
    gross_amount: float
    net_payout: float
    bank_name: str
    account_masked: str
    ifsc_code: str
    mandi_name: str
    status: str = "TRANSACTION_SUCCESSFUL"
    npci_hash: str = Field(..., description="HMAC-SHA256 tamper-proof cryptographic audit hash.")
    digital_signature: str = Field(..., description="Treasury digital certificate signature.")
    issued_at: str
    treasury_officer: str = "Chief Accounts Officer (PFMS-Central)"


class PFMSVoucherListResponse(BaseModel):
    """List of issued PFMS vouchers."""

    vouchers: list[PFMSVoucherResponse]
    total: int


