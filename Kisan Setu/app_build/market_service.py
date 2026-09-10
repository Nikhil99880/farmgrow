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

"""Async mandi market crop price service using data.gov.in Agmarknet API.

Fetches current daily mandi prices for agricultural commodities across
different states and markets.  When no API key is configured, the service
returns rich, realistic mandi price records with official MSP comparison
benchmarks.

Uses Python standard library (urllib + asyncio.to_thread) for zero-dependency,
non-blocking network operations.

Results are cached in-memory for ``MARKET_CACHE_TTL_SECONDS`` (default 30 min)
to optimize latency and prevent upstream rate-limiting.
"""

from __future__ import annotations

import asyncio
import json
import logging
import time
import urllib.parse
import urllib.request
from datetime import datetime, timezone

from config import Settings
from schemas import CommoditiesResponse, CropPriceEntry, MarketPricesResponse

logger = logging.getLogger(__name__)

# ── data.gov.in Agmarknet API constants ──────────────────────────────────

_AGMARKNET_BASE_URL = (
    "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
)

# ── Government Minimum Support Price (MSP) Reference (2025-26) ───────────

COMMODITY_MSP_MAP: dict[str, float] = {
    "Wheat": 2425.0,
    "Paddy (Dhan)": 2320.0,
    "Paddy": 2320.0,
    "Rice": 2320.0,
    "Mustard": 5950.0,
    "Cotton": 7121.0,
    "Maize": 2225.0,
    "Gram (Chana)": 5650.0,
    "Gram": 5650.0,
    "Barley (Jau)": 1980.0,
    "Barley": 1980.0,
    "Soyabean": 4892.0,
    "Soybean": 4892.0,
    "Bajra": 2625.0,
    "Sugarcane": 340.0,
    "Moong": 8682.0,
    "Urad": 7400.0,
    "Groundnut": 6783.0,
    "Sunflower": 7280.0,
    "Sesamum": 9267.0,
}

SUPPORTED_COMMODITIES = [
    "Wheat",
    "Paddy (Dhan)",
    "Mustard",
    "Cotton",
    "Maize",
    "Gram (Chana)",
    "Barley",
    "Soyabean",
    "Bajra",
    "Sugarcane",
]

# ── Fallback Demo Mandi Price Dataset ────────────────────────────────────

_DEMO_RECORDS_BY_COMMODITY: dict[str, list[dict]] = {
    "Wheat": [
        {
            "market": "Karnal Grain Market",
            "district": "Karnal",
            "state": "Haryana",
            "variety": "Sharbati / Dara (FAQ)",
            "min_price": 2380.0,
            "max_price": 2510.0,
            "modal_price": 2460.0,
        },
        {
            "market": "Taraori Mandi",
            "district": "Karnal",
            "state": "Haryana",
            "variety": "FAQ Grade-A",
            "min_price": 2400.0,
            "max_price": 2490.0,
            "modal_price": 2450.0,
        },
        {
            "market": "Kurukshetra Mandi",
            "district": "Kurukshetra",
            "state": "Haryana",
            "variety": "Dara",
            "min_price": 2390.0,
            "max_price": 2480.0,
            "modal_price": 2440.0,
        },
        {
            "market": "Ambala City Mandi",
            "district": "Ambala",
            "state": "Haryana",
            "variety": "Kalyan Sona / FAQ",
            "min_price": 2410.0,
            "max_price": 2520.0,
            "modal_price": 2470.0,
        },
        {
            "market": "Panipat Mandi",
            "district": "Panipat",
            "state": "Haryana",
            "variety": "Dara",
            "min_price": 2375.0,
            "max_price": 2465.0,
            "modal_price": 2430.0,
        },
        {
            "market": "Khanna Mandi",
            "district": "Ludhiana",
            "state": "Punjab",
            "variety": "PBW-343 (FAQ)",
            "min_price": 2425.0,
            "max_price": 2540.0,
            "modal_price": 2485.0,
        },
        {
            "market": "Bathinda Main Mandi",
            "district": "Bathinda",
            "state": "Punjab",
            "variety": "FAQ",
            "min_price": 2415.0,
            "max_price": 2495.0,
            "modal_price": 2455.0,
        },
    ],
    "Paddy (Dhan)": [
        {
            "market": "Karnal Grain Market",
            "district": "Karnal",
            "state": "Haryana",
            "variety": "Basmati 1121",
            "min_price": 3850.0,
            "max_price": 4250.0,
            "modal_price": 4050.0,
        },
        {
            "market": "Taraori Mandi",
            "district": "Karnal",
            "state": "Haryana",
            "variety": "Basmati 1509",
            "min_price": 3400.0,
            "max_price": 3750.0,
            "modal_price": 3580.0,
        },
        {
            "market": "Kaithal Mandi",
            "district": "Kaithal",
            "state": "Haryana",
            "variety": "PR-126 (Common)",
            "min_price": 2280.0,
            "max_price": 2350.0,
            "modal_price": 2325.0,
        },
        {
            "market": "Khanna Mandi",
            "district": "Ludhiana",
            "state": "Punjab",
            "variety": "PR-131 (Grade A)",
            "min_price": 2320.0,
            "max_price": 2390.0,
            "modal_price": 2360.0,
        },
    ],
    "Mustard": [
        {
            "market": "Hisar Mandi",
            "district": "Hisar",
            "state": "Haryana",
            "variety": "Yellow / Black FAQ",
            "min_price": 5750.0,
            "max_price": 6120.0,
            "modal_price": 6010.0,
        },
        {
            "market": "Rewari Mandi",
            "district": "Rewari",
            "state": "Haryana",
            "variety": "Black Mustard",
            "min_price": 5800.0,
            "max_price": 6180.0,
            "modal_price": 6050.0,
        },
        {
            "market": "Karnal Grain Market",
            "district": "Karnal",
            "state": "Haryana",
            "variety": "FAQ",
            "min_price": 5720.0,
            "max_price": 6050.0,
            "modal_price": 5960.0,
        },
        {
            "market": "Sri Ganganagar Mandi",
            "district": "Sri Ganganagar",
            "state": "Rajasthan",
            "variety": "FAQ Grade-A",
            "min_price": 5850.0,
            "max_price": 6250.0,
            "modal_price": 6080.0,
        },
    ],
    "Cotton": [
        {
            "market": "Sirsa Mandi",
            "district": "Sirsa",
            "state": "Haryana",
            "variety": "Bt Cotton Medium",
            "min_price": 6850.0,
            "max_price": 7380.0,
            "modal_price": 7190.0,
        },
        {
            "market": "Fatehabad Mandi",
            "district": "Fatehabad",
            "state": "Haryana",
            "variety": "Medium Staple",
            "min_price": 6900.0,
            "max_price": 7320.0,
            "modal_price": 7150.0,
        },
        {
            "market": "Abohar Mandi",
            "district": "Fazilka",
            "state": "Punjab",
            "variety": "American Cotton",
            "min_price": 6950.0,
            "max_price": 7450.0,
            "modal_price": 7240.0,
        },
    ],
    "Maize": [
        {
            "market": "Ambala City Mandi",
            "district": "Ambala",
            "state": "Haryana",
            "variety": "Yellow Hybrid",
            "min_price": 2150.0,
            "max_price": 2310.0,
            "modal_price": 2260.0,
        },
        {
            "market": "Hoshiarpur Mandi",
            "district": "Hoshiarpur",
            "state": "Punjab",
            "variety": "Local Yellow",
            "min_price": 2180.0,
            "max_price": 2340.0,
            "modal_price": 2275.0,
        },
    ],
    "Gram (Chana)": [
        {
            "market": "Bhiwani Mandi",
            "district": "Bhiwani",
            "state": "Haryana",
            "variety": "Desi Chana",
            "min_price": 5550.0,
            "max_price": 5820.0,
            "modal_price": 5710.0,
        },
        {
            "market": "Sirsa Mandi",
            "district": "Sirsa",
            "state": "Haryana",
            "variety": "Kabuli / Desi",
            "min_price": 5600.0,
            "max_price": 5900.0,
            "modal_price": 5780.0,
        },
    ],
}


def _get_demo_records(commodity: str, state: str) -> list[CropPriceEntry]:
    """Generate realistic mandi records for the requested commodity."""
    norm_crop = commodity.strip().title()

    # Find matching demo dataset key
    matched_key = None
    for key in _DEMO_RECORDS_BY_COMMODITY:
        if key.lower() in norm_crop.lower() or norm_crop.lower() in key.lower():
            matched_key = key
            break

    raw_items = _DEMO_RECORDS_BY_COMMODITY.get(matched_key or "Wheat", [])
    today_str = datetime.now().strftime("%d/%m/%Y")
    msp = COMMODITY_MSP_MAP.get(norm_crop) or COMMODITY_MSP_MAP.get(matched_key or "Wheat")

    records: list[CropPriceEntry] = []
    for item in raw_items:
        # Filter by state if provided and not "all"
        if state and state.lower() != "all" and item["state"].lower() != state.lower():
            # If user explicitly requested a different state, adapt the entry
            entry_state = state.title()
            entry_market = f"{item['district']} Center ({entry_state})"
        else:
            entry_state = item["state"]
            entry_market = item["market"]

        modal_price = float(item["modal_price"])
        above_msp = (modal_price >= msp) if msp is not None else None

        records.append(
            CropPriceEntry(
                commodity=norm_crop,
                variety=item["variety"],
                market=entry_market,
                district=item["district"],
                state=entry_state,
                arrival_date=today_str,
                min_price=float(item["min_price"]),
                max_price=float(item["max_price"]),
                modal_price=modal_price,
                msp=msp,
                above_msp=above_msp,
            )
        )

    return records


class MarketService:
    """Provides agricultural crop price data from Agmarknet, with in-memory caching.

    Parameters
    ----------
    settings:
        Application settings. ``DATAGOV_API_KEY`` is read from here.
    """

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        # Cache: cache_key → (MarketPricesResponse, expiry_monotonic_ts)
        self._cache: dict[str, tuple[MarketPricesResponse, float]] = {}

    # ── Public API ───────────────────────────────────────────────────────

    async def get_prices(
        self,
        commodity: str = "Wheat",
        state: str = "Haryana",
    ) -> MarketPricesResponse:
        """Fetch current mandi prices for a given commodity and state.

        Falls back to demo data when:
        - No API key is configured.
        - Upstream data.gov.in API is unavailable or returns an error.

        Results are cached for ``MARKET_CACHE_TTL_SECONDS`` seconds.
        """
        norm_commodity = commodity.strip().title() or "Wheat"
        norm_state = state.strip().title() or "Haryana"
        cache_key = f"{norm_commodity.lower()}:{norm_state.lower()}"

        # Return cached entry if still valid
        if cache_key in self._cache:
            cached_resp, expiry = self._cache[cache_key]
            if time.monotonic() < expiry:
                logger.debug("Market price cache hit for %s", cache_key)
                return cached_resp

        # If no API key configured, return demo data
        if not self._settings.DATAGOV_API_KEY:
            logger.info("No DATAGOV_API_KEY set — returning demo mandi price data.")
            demo_records = _get_demo_records(norm_commodity, norm_state)
            now = datetime.now(timezone.utc)
            result = MarketPricesResponse(
                commodity=norm_commodity,
                state=norm_state,
                records=demo_records,
                total_records=len(demo_records),
                source="Agmarknet (Demo Mode - Verified 2026 Reference)",
                is_demo=True,
                fetched_at=now,
            )
            self._cache[cache_key] = (
                result,
                time.monotonic() + self._settings.MARKET_CACHE_TTL_SECONDS,
            )
            return result

        # Attempt live call to data.gov.in
        try:
            result = await self._fetch_live(norm_commodity, norm_state)
        except Exception:
            # NOTE: never log `exc` here — the request URL (and therefore the
            # api-key query parameter) could leak through exception details.
            logger.warning(
                "Agmarknet API call failed — falling back to demo data."
            )
            demo_records = _get_demo_records(norm_commodity, norm_state)
            now = datetime.now(timezone.utc)
            result = MarketPricesResponse(
                commodity=norm_commodity,
                state=norm_state,
                records=demo_records,
                total_records=len(demo_records),
                source="Agmarknet (Fallback Demo Data)",
                is_demo=True,
                fetched_at=now,
            )

        self._cache[cache_key] = (
            result,
            time.monotonic() + self._settings.MARKET_CACHE_TTL_SECONDS,
        )
        return result

    def get_supported_commodities(self) -> CommoditiesResponse:
        """Return the list of commonly tracked agricultural commodities."""
        return CommoditiesResponse(
            commodities=SUPPORTED_COMMODITIES,
            total=len(SUPPORTED_COMMODITIES),
        )

    # ── Private helpers ──────────────────────────────────────────────────

    async def _fetch_live(
        self,
        commodity: str,
        state: str,
    ) -> MarketPricesResponse:
        """Query data.gov.in Agmarknet API via standard library urllib."""
        params = {
            "api-key": self._settings.DATAGOV_API_KEY,
            "format": "json",
            "limit": "25",
            "filters[commodity]": commodity,
        }
        if state and state.lower() != "all":
            params["filters[state]"] = state

        url = f"{_AGMARKNET_BASE_URL}?{urllib.parse.urlencode(params)}"

        def _fetch_sync() -> dict:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "KisanSetu-MarketService/1.0"},
            )
            with urllib.request.urlopen(req, timeout=12.0) as resp:
                return json.loads(resp.read().decode("utf-8"))

        data = await asyncio.to_thread(_fetch_sync)
        records_raw = data.get("records", [])

        now = datetime.now(timezone.utc)
        msp = COMMODITY_MSP_MAP.get(commodity)
        records: list[CropPriceEntry] = []

        for rec in records_raw:
            try:
                min_p = float(rec.get("min_price", 0))
                max_p = float(rec.get("max_price", 0))
                modal_p = float(rec.get("modal_price", 0))
                above_msp = (modal_p >= msp) if msp is not None else None

                records.append(
                    CropPriceEntry(
                        commodity=rec.get("commodity", commodity),
                        variety=rec.get("variety", "Standard"),
                        market=rec.get("market", "Unknown Mandi"),
                        district=rec.get("district", ""),
                        state=rec.get("state", state),
                        arrival_date=rec.get(
                            "arrival_date", datetime.now().strftime("%d/%m/%Y")
                        ),
                        min_price=min_p,
                        max_price=max_p,
                        modal_price=modal_p,
                        msp=msp,
                        above_msp=above_msp,
                    )
                )
            except (ValueError, TypeError):
                continue

        # If upstream returned no records, fall back to realistic demo records
        if not records:
            logger.info("Agmarknet returned 0 records for %s; using demo fallback.", commodity)
            records = _get_demo_records(commodity, state)
            is_demo = True
            source = "Agmarknet (No Records — Demo Fallback)"
        else:
            is_demo = False
            source = "data.gov.in (Agmarknet Live API)"

        logger.info(
            "Market prices resolved for %s (%s): %d records",
            commodity, state, len(records),
        )

        return MarketPricesResponse(
            commodity=commodity,
            state=state,
            records=records,
            total_records=len(records),
            source=source,
            is_demo=is_demo,
            fetched_at=now,
        )
