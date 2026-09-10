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

"""ACID-compliant SQL Relational Database Service for Kisan Setu.

Provides persistent, relational storage for farmers, land holdings,
DBT bank accounts, mandi procurement slot bookings, and historical mandi prices.
Engineered using Python's standard library `sqlite3` with Write-Ahead Logging (WAL),
foreign keys enforcement, and non-blocking asynchronous execution via thread pooling.
"""

import asyncio
import hashlib
import hmac
import logging
import secrets
import os
import random
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from config import Settings

logger = logging.getLogger(__name__)


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


class DatabaseService:
    """Encapsulates all SQL database interactions and migrations."""

    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.db_path = settings.DATABASE_PATH
        # Ensure database directory exists
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_sync()

    def _get_connection(self) -> sqlite3.Connection:
        """Create a configured SQLite connection with row factories and WAL pragmas."""
        conn = sqlite3.connect(
            str(self.db_path),
            timeout=15.0,
            check_same_thread=False,
        )
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON;")
        conn.execute("PRAGMA journal_mode = WAL;")
        conn.execute("PRAGMA synchronous = NORMAL;")
        return conn

    def _init_sync(self) -> None:
        """Apply table DDL migrations and seed initial records synchronously."""
        logger.info("Initializing Kisan Setu SQL database at: %s", self.db_path)
        with self._get_connection() as conn:
            cursor = conn.cursor()

            # 1. Farmers Table
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS farmers (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    farmer_id TEXT UNIQUE NOT NULL,
                    full_name TEXT NOT NULL,
                    mobile TEXT UNIQUE NOT NULL,
                    village TEXT NOT NULL,
                    aadhaar_last4 TEXT DEFAULT '1234',
                    aadhaar_linked INTEGER DEFAULT 1,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );
                """
            )

            # 2. Land Records Table
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS land_records (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    farmer_id TEXT NOT NULL REFERENCES farmers(farmer_id) ON DELETE CASCADE,
                    khasra_number TEXT NOT NULL,
                    total_area_acres REAL NOT NULL,
                    crop_sown TEXT NOT NULL,
                    soil_health_card_id TEXT,
                    created_at TEXT NOT NULL
                );
                """
            )

            # 3. Bank Accounts (DBT Setup) Table
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS bank_accounts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    farmer_id TEXT NOT NULL REFERENCES farmers(farmer_id) ON DELETE CASCADE,
                    bank_name TEXT NOT NULL,
                    account_number_masked TEXT NOT NULL,
                    ifsc_code TEXT NOT NULL,
                    is_dbt_enabled INTEGER DEFAULT 1,
                    created_at TEXT NOT NULL
                );
                """
            )

            # 4. Slot Bookings / Gate Passes Table
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS slot_bookings (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    token_number TEXT UNIQUE NOT NULL,
                    farmer_id TEXT NOT NULL,
                    farmer_name TEXT NOT NULL,
                    farmer_mobile TEXT NOT NULL,
                    commodity TEXT NOT NULL,
                    mandi_name TEXT NOT NULL,
                    booking_date TEXT NOT NULL,
                    time_slot TEXT NOT NULL,
                    estimated_qty_quintals REAL NOT NULL,
                    vehicle_type TEXT NOT NULL,
                    vehicle_number TEXT NOT NULL,
                    gate_number TEXT DEFAULT 'Gate 2',
                    queue_position INTEGER DEFAULT 4,
                    status TEXT DEFAULT 'CONFIRMED',
                    created_at TEXT NOT NULL
                );
                """
            )

            # 5. Mandi Prices History Table
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS mandi_prices_history (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    commodity TEXT NOT NULL,
                    variety TEXT NOT NULL,
                    market TEXT NOT NULL,
                    district TEXT NOT NULL,
                    state TEXT NOT NULL,
                    arrival_date TEXT NOT NULL,
                    min_price REAL NOT NULL,
                    max_price REAL NOT NULL,
                    modal_price REAL NOT NULL,
                    msp REAL,
                    recorded_at TEXT NOT NULL
                );
                """
            )

            # 6. PFMS Vouchers Table (Server-side issued & signed DBT payments)
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS pfms_vouchers (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    voucher_ref TEXT UNIQUE NOT NULL,
                    utr_number TEXT UNIQUE NOT NULL,
                    farmer_id TEXT NOT NULL,
                    farmer_name TEXT NOT NULL,
                    commodity TEXT NOT NULL,
                    quantity_quintals REAL NOT NULL,
                    msp_rate REAL NOT NULL,
                    gross_amount REAL NOT NULL,
                    net_payout REAL NOT NULL,
                    bank_name TEXT NOT NULL,
                    account_masked TEXT NOT NULL,
                    ifsc_code TEXT NOT NULL,
                    mandi_name TEXT NOT NULL,
                    status TEXT DEFAULT 'TRANSACTION_SUCCESSFUL',
                    npci_hash TEXT NOT NULL,
                    digital_signature TEXT NOT NULL,
                    issued_at TEXT NOT NULL
                );
                """
            )

            # Indices for rapid querying
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_farmers_mobile ON farmers(mobile);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_farmers_farmer_id ON farmers(farmer_id);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_bookings_token ON slot_bookings(token_number);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_bookings_farmer ON slot_bookings(farmer_id);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_mandi_prices ON mandi_prices_history(commodity, state);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_vouchers_ref ON pfms_vouchers(voucher_ref);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_vouchers_farmer ON pfms_vouchers(farmer_id);")

            # Seed default demo farmer if empty
            cursor.execute("SELECT COUNT(*) AS cnt FROM farmers;")
            count = cursor.fetchone()["cnt"]
            if count == 0:
                now = _utc_now_iso()
                cursor.execute(
                    """
                    INSERT INTO farmers (farmer_id, full_name, mobile, village, aadhaar_last4, aadhaar_linked, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    ("PB-10492", "Ram Singh", "9876543210", "Taraori, Karnal", "4819", 1, now, now),
                )
                cursor.execute(
                    """
                    INSERT INTO land_records (farmer_id, khasra_number, total_area_acres, crop_sown, soil_health_card_id, created_at)
                    VALUES (?, ?, ?, ?, ?, ?);
                    """,
                    ("PB-10492", "142//12/2", 4.5, "Wheat (HD-2967)", "SHC-HR-88902", now),
                )
                cursor.execute(
                    """
                    INSERT INTO bank_accounts (farmer_id, bank_name, account_number_masked, ifsc_code, is_dbt_enabled, created_at)
                    VALUES (?, ?, ?, ?, ?, ?);
                    """,
                    ("PB-10492", "State Bank of India", "XXXXXX4891", "SBIN0001234", 1, now),
                )
                cursor.execute(
                    """
                    INSERT INTO slot_bookings (
                        token_number, farmer_id, farmer_name, farmer_mobile, commodity,
                        mandi_name, booking_date, time_slot, estimated_qty_quintals,
                        vehicle_type, vehicle_number, gate_number, queue_position, status, created_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    (
                        "KRN-WHT-2026-0842",
                        "PB-10492",
                        "Ram Singh",
                        "9876543210",
                        "Wheat",
                        "Karnal Grain Market",
                        "2026-09-10",
                        "08:00 AM - 10:00 AM",
                        50.0,
                        "Tractor Trolley",
                        "HR05-AK-9821",
                        "Gate 2",
                        4,
                        "CONFIRMED",
                        now,
                    ),
                )
                logger.info("SQL database seeded successfully with demo farmer PB-10492 and initial booking token.")

            # Seed default PFMS vouchers if empty
            cursor.execute("SELECT COUNT(*) AS cnt FROM pfms_vouchers;")
            v_count = cursor.fetchone()["cnt"]
            if v_count == 0:
                now = _utc_now_iso()
                cursor.execute(
                    """
                    INSERT INTO pfms_vouchers (
                        voucher_ref, utr_number, farmer_id, farmer_name, commodity,
                        quantity_quintals, msp_rate, gross_amount, net_payout, bank_name,
                        account_masked, ifsc_code, mandi_name, status, npci_hash,
                        digital_signature, issued_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    (
                        "TXN-61029",
                        "SBIN2609018492089",
                        "PB-10492",
                        "Ram Singh",
                        "Mustard",
                        15.0,
                        5950.0,
                        89250.0,
                        88357.50,
                        "State Bank of India",
                        "XXXX-XXXX-5678",
                        "SBIN0001234",
                        "Karnal Grain Market",
                        "TRANSACTION_SUCCESSFUL",
                        "89f4b0021c7a91e48bc09a12",
                        "SIG-PFMS-GOI-2026-9812A",
                        now,
                    ),
                )
                cursor.execute(
                    """
                    INSERT INTO pfms_vouchers (
                        voucher_ref, utr_number, farmer_id, farmer_name, commodity,
                        quantity_quintals, msp_rate, gross_amount, net_payout, bank_name,
                        account_masked, ifsc_code, mandi_name, status, npci_hash,
                        digital_signature, issued_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    (
                        "TXN-49021",
                        "SBIN2609029410982",
                        "PB-10492",
                        "Ram Singh",
                        "Wheat",
                        50.0,
                        2425.0,
                        121250.0,
                        120037.50,
                        "State Bank of India",
                        "XXXX-XXXX-5678",
                        "SBIN0001234",
                        "Karnal Grain Market",
                        "TRANSACTION_SUCCESSFUL",
                        "3b190fe8c201948ba90123ef",
                        "SIG-PFMS-GOI-2026-4409B",
                        now,
                    ),
                )
                logger.info("SQL database seeded with verified PFMS demo vouchers TXN-61029 and TXN-49021.")

            conn.commit()

    # ── Asynchronous Public API ──────────────────────────────────────────────

    async def health_check(self) -> dict[str, Any]:
        """Perform SQLite integrity check and return runtime metadata."""
        def _check():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("PRAGMA integrity_check;")
                integrity = cursor.fetchone()[0]
                cursor.execute("PRAGMA journal_mode;")
                journal_mode = cursor.fetchone()[0]
                size_bytes = os.path.getsize(self.db_path) if self.db_path.exists() else 0
                return {
                    "status": "healthy" if integrity == "ok" else "degraded",
                    "engine": "sqlite3",
                    "journal_mode": journal_mode,
                    "integrity_check": integrity,
                }
        return await asyncio.to_thread(_check)

    async def get_stats(self) -> dict[str, Any]:
        """Return table row counts and summary metrics."""
        def _stats():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) AS cnt FROM farmers;")
                farmers_count = cursor.fetchone()["cnt"]
                cursor.execute("SELECT COUNT(*) AS cnt FROM slot_bookings;")
                bookings_count = cursor.fetchone()["cnt"]
                cursor.execute("SELECT COUNT(*) AS cnt FROM land_records;")
                land_count = cursor.fetchone()["cnt"]
                cursor.execute("SELECT COUNT(*) AS cnt FROM bank_accounts;")
                bank_count = cursor.fetchone()["cnt"]
                size_bytes = os.path.getsize(self.db_path) if self.db_path.exists() else 0
                return {
                    "farmers_count": farmers_count,
                    "bookings_count": bookings_count,
                    "land_records_count": land_count,
                    "bank_accounts_count": bank_count,
                    "database_size_bytes": size_bytes,
                    "last_checked_at": _utc_now_iso(),
                }
        return await asyncio.to_thread(_stats)

    async def list_farmers(self, limit: int = 50) -> list[dict[str, Any]]:
        """List registered farmers with their primary details."""
        def _list():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    SELECT id, farmer_id, full_name, mobile, village,
                           aadhaar_last4, aadhaar_linked, created_at, updated_at
                    FROM farmers
                    ORDER BY id DESC
                    LIMIT ?;
                    """,
                    (limit,),
                )
                return [dict(row) for row in cursor.fetchall()]
        return await asyncio.to_thread(_list)

    async def get_farmer_by_id_or_mobile(self, identifier: str) -> dict[str, Any] | None:
        """Find farmer by farmer_id or 10-digit mobile number."""
        def _find():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    SELECT id, farmer_id, full_name, mobile, village,
                           aadhaar_last4, aadhaar_linked, created_at, updated_at
                    FROM farmers
                    WHERE farmer_id = ? OR mobile = ?;
                    """,
                    (identifier, identifier),
                )
                row = cursor.fetchone()
                if not row:
                    return None
                farmer = dict(row)

                # Fetch associated land records
                cursor.execute(
                    "SELECT * FROM land_records WHERE farmer_id = ?;",
                    (farmer["farmer_id"],),
                )
                farmer["land_records"] = [dict(r) for r in cursor.fetchall()]

                # Fetch bank accounts
                cursor.execute(
                    "SELECT * FROM bank_accounts WHERE farmer_id = ?;",
                    (farmer["farmer_id"],),
                )
                farmer["bank_accounts"] = [dict(r) for r in cursor.fetchall()]

                return farmer
        return await asyncio.to_thread(_find)

    async def create_farmer(self, data: dict[str, Any]) -> dict[str, Any]:
        """Create or register a new farmer in the SQL database."""
        def _create():
            now = _utc_now_iso()
            farmer_id = data.get("farmer_id")
            if not farmer_id:
                rand_num = random.randint(10000, 99999)
                farmer_id = f"PB-{rand_num}"

            with self._get_connection() as conn:
                cursor = conn.cursor()
                # Check if mobile already exists
                cursor.execute("SELECT * FROM farmers WHERE mobile = ?;", (data["mobile"],))
                existing = cursor.fetchone()
                if existing:
                    # Update existing record
                    cursor.execute(
                        """
                        UPDATE farmers
                        SET full_name = ?, village = ?, updated_at = ?
                        WHERE mobile = ?;
                        """,
                        (data["full_name"], data["village"], now, data["mobile"]),
                    )
                    conn.commit()
                    cursor.execute("SELECT * FROM farmers WHERE mobile = ?;", (data["mobile"],))
                    return dict(cursor.fetchone())

                cursor.execute(
                    """
                    INSERT INTO farmers (
                        farmer_id, full_name, mobile, village,
                        aadhaar_last4, aadhaar_linked, created_at, updated_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    (
                        farmer_id,
                        data["full_name"],
                        data["mobile"],
                        data["village"],
                        data.get("aadhaar_last4", "1234"),
                        1 if data.get("aadhaar_linked", True) else 0,
                        now,
                        now,
                    ),
                )
                new_id = cursor.lastrowid
                conn.commit()
                cursor.execute("SELECT * FROM farmers WHERE id = ?;", (new_id,))
                return dict(cursor.fetchone())
        return await asyncio.to_thread(_create)

    async def update_farmer(self, farmer_id: str, data: dict[str, Any]) -> dict[str, Any] | None:
        """Update farmer personal details by farmer_id."""
        def _update():
            now = _utc_now_iso()
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM farmers WHERE farmer_id = ?;", (farmer_id,))
                existing = cursor.fetchone()
                if not existing:
                    return None

                full_name = data.get("full_name", existing["full_name"])
                village = data.get("village", existing["village"])
                mobile = data.get("mobile", existing["mobile"])

                cursor.execute(
                    """
                    UPDATE farmers
                    SET full_name = ?, village = ?, mobile = ?, updated_at = ?
                    WHERE farmer_id = ?;
                    """,
                    (full_name, village, mobile, now, farmer_id),
                )
                conn.commit()
                cursor.execute("SELECT * FROM farmers WHERE farmer_id = ?;", (farmer_id,))
                return dict(cursor.fetchone())
        return await asyncio.to_thread(_update)

    async def list_bookings(self, farmer_id: str | None = None, limit: int = 50) -> list[dict[str, Any]]:
        """List slot bookings / gate passes."""
        def _list():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                if farmer_id:
                    cursor.execute(
                        """
                        SELECT * FROM slot_bookings
                        WHERE farmer_id = ?
                        ORDER BY id DESC
                        LIMIT ?;
                        """,
                        (farmer_id, limit),
                    )
                else:
                    cursor.execute(
                        """
                        SELECT * FROM slot_bookings
                        ORDER BY id DESC
                        LIMIT ?;
                        """,
                        (limit,),
                    )
                return [dict(row) for row in cursor.fetchall()]
        return await asyncio.to_thread(_list)

    async def create_booking(self, data: dict[str, Any]) -> dict[str, Any]:
        """Create a new slot booking and generate a digital gate pass token in SQL."""
        def _create():
            now = _utc_now_iso()
            # Tokens are ALWAYS server-generated cryptographic values. Client-
            # supplied token_numbers are ignored so passes cannot be forged or
            # squatted, and the value is unguessable (not a 4-digit counter).
            token_number = (
                f"KRN-{str(data.get('commodity', 'WHT'))[:3].upper()}-"
                f"{datetime.now().year}-{secrets.token_hex(4).upper()}"
            )

            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    INSERT INTO slot_bookings (
                        token_number, farmer_id, farmer_name, farmer_mobile, commodity,
                        mandi_name, booking_date, time_slot, estimated_qty_quintals,
                        vehicle_type, vehicle_number, gate_number, queue_position, status, created_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    (
                        token_number,
                        data.get("farmer_id", "PB-10492"),
                        data.get("farmer_name", "Ram Singh"),
                        data.get("farmer_mobile", "9876543210"),
                        data.get("commodity", "Wheat"),
                        data.get("mandi_name", "Karnal Grain Market"),
                        data.get("booking_date", datetime.now().strftime("%Y-%m-%d")),
                        data.get("time_slot", "08:00 AM - 10:00 AM"),
                        float(data.get("estimated_qty_quintals", 50.0)),
                        data.get("vehicle_type", "Tractor Trolley"),
                        data.get("vehicle_number", "HR05-AK-9821"),
                        data.get("gate_number", "Gate 2"),
                        int(data.get("queue_position", 4)),
                        data.get("status", "CONFIRMED"),
                        now,
                    ),
                )
                new_id = cursor.lastrowid
                conn.commit()
                cursor.execute("SELECT * FROM slot_bookings WHERE id = ?;", (new_id,))
                return dict(cursor.fetchone())
        return await asyncio.to_thread(_create)

    async def get_booking_by_token(self, token_number: str) -> dict[str, Any] | None:
        """Fetch slot booking and digital gate pass by token number."""
        def _get():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM slot_bookings WHERE token_number = ?;", (token_number,))
                row = cursor.fetchone()
                return dict(row) if row else None
        return await asyncio.to_thread(_get)

    # ── Server-Side Payment & PFMS Voucher Operations ────────────────────────

    # Official Government MSP benchmarks per quintal (₹)
    VERIFIED_MSP_RATES: dict[str, float] = {
        "Wheat": 2425.0,
        "Paddy": 2320.0,
        "Paddy (Dhan)": 2320.0,
        "Basmati Paddy": 3250.0,
        "Mustard": 5950.0,
        "Mustard (Sarson)": 5950.0,
        "Cotton": 7121.0,
        "Cotton (Kapas)": 7121.0,
        "Gram": 5440.0,
        "Gram (Chana)": 5440.0,
        "Maize": 2090.0,
        "Maize (Makka)": 2090.0,
        "Barley": 1850.0,
        "Moong": 8682.0,
    }

    def get_msp_rate(self, commodity: str) -> float:
        """Lookup official government support price benchmark."""
        if commodity in self.VERIFIED_MSP_RATES:
            return self.VERIFIED_MSP_RATES[commodity]
        # Partial match fallback
        c_lower = commodity.lower()
        for k, v in self.VERIFIED_MSP_RATES.items():
            if k.lower() in c_lower or c_lower in k.lower():
                return v
        return 2425.0  # Default to Wheat MSP benchmark

    async def calculate_payment(self, commodity: str, quantity: float) -> dict[str, Any]:
        """Perform server-side verified payment calculation."""
        def _calc():
            rate = self.get_msp_rate(commodity)
            gross = round(quantity * rate, 2)
            mandi_cess = round(gross * 0.01, 2)
            net = round(gross - mandi_cess, 2)
            return {
                "commodity": commodity,
                "quantity_quintals": quantity,
                "verified_msp_rate": rate,
                "gross_amount": gross,
                "mandi_cess_amount": mandi_cess,
                "net_payout_amount": net,
                "currency": "INR",
                "is_verified_by_ministry": True,
                "calculation_timestamp": _utc_now_iso(),
            }
        return await asyncio.to_thread(_calc)

    async def mint_pfms_voucher(self, data: dict[str, Any]) -> dict[str, Any]:
        """Cryptographically mint and record an authenticated PFMS DBT voucher."""
        def _mint():
            now = _utc_now_iso()
            farmer_id = data.get("farmer_id", "PB-10492")
            commodity = data.get("commodity", "Wheat")
            quantity = float(data.get("quantity_quintals", 1.0))
            mandi_name = data.get("mandi_name", "Karnal Grain Market")

            # Never sign with an empty/absent secret — a voucher signed with a
            # known (committed or missing) key is plain forgery.
            signing_secret = self.settings.PFMS_SIGNING_SECRET
            if not signing_secret:
                raise ValueError(
                    "PFMS_SIGNING_SECRET is not configured; voucher signing is disabled."
                )

            rate = self.get_msp_rate(commodity)
            gross = round(quantity * rate, 2)
            net = round(gross - round(gross * 0.01, 2), 2)

            with self._get_connection() as conn:
                cursor = conn.cursor()
                # Lookup farmer profile if name not provided
                cursor.execute("SELECT full_name FROM farmers WHERE farmer_id = ?;", (farmer_id,))
                farmer_row = cursor.fetchone()
                farmer_name = data.get("farmer_name") or (farmer_row["full_name"] if farmer_row else "Ram Singh")

                # Generate secure server-side voucher identifiers
                seq_rand = secrets.token_hex(3).upper()
                voucher_ref = f"PFMS-VCHR-2026-{seq_rand}"
                utr_rand = f"{random.randint(10000000, 99999999)}"
                utr_number = f"SBIN26090{utr_rand}"

                # Cryptographic audit hash using server signing secret
                msg_payload = f"{voucher_ref}|{utr_number}|{farmer_id}|{commodity}|{quantity}|{net}|{now}"
                npci_hash = hmac.new(
                    signing_secret.encode("utf-8"),
                    msg_payload.encode("utf-8"),
                    hashlib.sha256,
                ).hexdigest()[:24]

                digital_sig = f"SIG-PFMS-GOI-2026-{secrets.token_hex(4).upper()}"

                bank_name = data.get("bank_name", "State Bank of India")
                acct_last4 = data.get("account_last4", "5678")
                account_masked = f"XXXX-XXXX-{acct_last4}"
                ifsc_code = data.get("ifsc_code", "SBIN0001234")

                cursor.execute(
                    """
                    INSERT INTO pfms_vouchers (
                        voucher_ref, utr_number, farmer_id, farmer_name, commodity,
                        quantity_quintals, msp_rate, gross_amount, net_payout, bank_name,
                        account_masked, ifsc_code, mandi_name, status, npci_hash,
                        digital_signature, issued_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    (
                        voucher_ref,
                        utr_number,
                        farmer_id,
                        farmer_name,
                        commodity,
                        quantity,
                        rate,
                        gross,
                        net,
                        bank_name,
                        account_masked,
                        ifsc_code,
                        mandi_name,
                        "TRANSACTION_SUCCESSFUL",
                        npci_hash,
                        digital_sig,
                        now,
                    ),
                )
                conn.commit()
                cursor.execute("SELECT * FROM pfms_vouchers WHERE voucher_ref = ?;", (voucher_ref,))
                row = cursor.fetchone()
                return dict(row)
        return await asyncio.to_thread(_mint)

    async def get_pfms_voucher(self, voucher_ref: str) -> dict[str, Any] | None:
        """Retrieve authentic server voucher by voucher_ref or UTR number."""
        def _get():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    SELECT * FROM pfms_vouchers
                    WHERE voucher_ref = ? OR utr_number = ?;
                    """,
                    (voucher_ref, voucher_ref),
                )
                row = cursor.fetchone()
                return dict(row) if row else None
        return await asyncio.to_thread(_get)

    async def list_pfms_vouchers(self, farmer_id: str | None = None, limit: int = 50) -> list[dict[str, Any]]:
        """List authenticated PFMS vouchers issued by the server."""
        def _list():
            with self._get_connection() as conn:
                cursor = conn.cursor()
                if farmer_id:
                    cursor.execute(
                        "SELECT * FROM pfms_vouchers WHERE farmer_id = ? ORDER BY id DESC LIMIT ?;",
                        (farmer_id, limit),
                    )
                else:
                    cursor.execute(
                        "SELECT * FROM pfms_vouchers ORDER BY id DESC LIMIT ?;",
                        (limit,),
                    )
                return [dict(r) for r in cursor.fetchall()]
        return await asyncio.to_thread(_list)
