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

"""Async weather data service using OpenWeatherMap API.

Fetches real-time weather for a given latitude/longitude.  When no API key
is configured the service returns rich demo data so the app remains fully
functional out-of-the-box.

Uses Python standard library (urllib + asyncio.to_thread) for zero-dependency,
non-blocking network operations.

Results are cached in-memory for ``WEATHER_CACHE_TTL_SECONDS`` (default 10 min)
to avoid hammering the upstream API on every dashboard refresh.
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
from schemas import WeatherResponse

logger = logging.getLogger(__name__)

# ── OpenWeatherMap endpoints & constants ─────────────────────────────────

_OPENWEATHER_BASE = "https://api.openweathermap.org/data/2.5/weather"
_ICON_URL_TMPL = "https://openweathermap.org/img/wn/{code}@2x.png"


def _build_advisory(
    temp_c: float,
    humidity_pct: int,
    wind_speed_kmh: float,
    description: str,
) -> str:
    """Generate a concise farm-relevant advisory from weather conditions."""
    desc_lower = description.lower()
    tips: list[str] = []

    # Rain / thunderstorm
    if any(kw in desc_lower for kw in ("rain", "drizzle", "thunder", "storm")):
        tips.append("Avoid spraying pesticides or fertilisers today — rain expected.")
        tips.append("Ensure field drainage channels are clear.")
    # Clear / sunny and hot
    elif "clear" in desc_lower and temp_c > 35:
        tips.append("High heat — water crops in the early morning or evening only.")
        tips.append("Protect livestock from heat stress.")
    # Haze / fog
    elif any(kw in desc_lower for kw in ("haze", "fog", "mist", "smoke")):
        tips.append("Poor visibility — drive farm machinery cautiously.")
        tips.append("Watch for fungal disease risk in humid haze conditions.")
    # Strong wind
    elif wind_speed_kmh > 30:
        tips.append("High winds — delay any aerial or overhead irrigation.")
        tips.append("Secure loose covers and temporary shelters on the farm.")
    # General high humidity
    elif humidity_pct > 80:
        tips.append("High humidity — monitor crops for fungal/blight risk.")
    # Comfortable
    else:
        tips.append("Good conditions for field work and harvesting operations.")

    # Temperature extremes
    if temp_c < 5:
        tips.append("Near-frost risk — cover sensitive seedlings overnight.")
    elif temp_c > 40:
        tips.append("Extreme heat — irrigate immediately to avoid crop stress.")

    return " ".join(tips) if tips else "Conditions look suitable for routine farm activities."


def _demo_weather(lat: float, lon: float, location: str) -> WeatherResponse:
    """Return realistic demo weather for Karnal, Haryana."""
    now = datetime.now(timezone.utc)
    return WeatherResponse(
        location=location or "Karnal",
        country="IN",
        latitude=lat,
        longitude=lon,
        temperature_c=32.4,
        feels_like_c=36.1,
        temp_min_c=27.0,
        temp_max_c=36.5,
        humidity_pct=72,
        wind_speed_kmh=14.4,
        wind_direction_deg=210,
        visibility_km=7.0,
        cloud_cover_pct=45,
        description="Partly cloudy",
        icon_code="02d",
        icon_url=_ICON_URL_TMPL.format(code="02d"),
        sunrise_utc="01:04",
        sunset_utc="13:20",
        farm_advisory=(
            "Good conditions for field work and harvesting operations. "
            "Moderate humidity — monitor crops for fungal risk."
        ),
        is_demo=True,
        fetched_at=now,
    )


class WeatherService:
    """Fetches weather data from OpenWeatherMap, with in-memory TTL caching.

    Parameters
    ----------
    settings:
        Application settings.  ``OPENWEATHER_API_KEY`` is read from here.
    """

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        # Cache: key → (WeatherResponse, expiry_monotonic_ts)
        self._cache: dict[str, tuple[WeatherResponse, float]] = {}

    # ── Public API ───────────────────────────────────────────────────────

    async def get_weather(
        self,
        lat: float,
        lon: float,
        location: str = "",
    ) -> WeatherResponse:
        """Return weather data for the given coordinates.

        Falls back to demo data when:
        - No API key is configured.
        - The upstream API returns an error or is unreachable.

        Results are cached for ``WEATHER_CACHE_TTL_SECONDS`` seconds.
        """
        cache_key = f"{lat:.4f},{lon:.4f}"

        # Return cached result if still valid
        if cache_key in self._cache:
            cached_result, expiry = self._cache[cache_key]
            if time.monotonic() < expiry:
                logger.debug("Weather cache hit for %s", cache_key)
                return cached_result

        if not self._settings.OPENWEATHER_API_KEY:
            logger.info("No OPENWEATHER_API_KEY set — returning demo weather data.")
            result = _demo_weather(lat, lon, location)
            self._cache[cache_key] = (
                result,
                time.monotonic() + self._settings.WEATHER_CACHE_TTL_SECONDS,
            )
            return result

        try:
            result = await self._fetch_live(lat, lon, location)
        except Exception as exc:
            logger.warning("Weather API error (%s) — falling back to demo data.", exc)
            result = _demo_weather(lat, lon, location)

        self._cache[cache_key] = (
            result,
            time.monotonic() + self._settings.WEATHER_CACHE_TTL_SECONDS,
        )
        return result

    # ── Private helpers ──────────────────────────────────────────────────

    async def _fetch_live(
        self,
        lat: float,
        lon: float,
        location: str,
    ) -> WeatherResponse:
        """Call OpenWeatherMap via standard library urllib in thread pool."""
        params = {
            "lat": lat,
            "lon": lon,
            "appid": self._settings.OPENWEATHER_API_KEY,
            "units": "metric",
        }
        url = f"{_OPENWEATHER_BASE}?{urllib.parse.urlencode(params)}"

        def _fetch_sync() -> dict:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "KisanSetu-WeatherService/1.0"},
            )
            with urllib.request.urlopen(req, timeout=10.0) as resp:
                return json.loads(resp.read().decode("utf-8"))

        data = await asyncio.to_thread(_fetch_sync)
        now = datetime.now(timezone.utc)

        # Parse core fields
        main = data.get("main", {})
        wind = data.get("wind", {})
        weather_list = data.get("weather", [{}])
        weather_info = weather_list[0] if weather_list else {}
        sys_info = data.get("sys", {})
        clouds = data.get("clouds", {})

        temp_c: float = round(float(main.get("temp", 0.0)), 1)
        feels_like: float = round(float(main.get("feels_like", temp_c)), 1)
        temp_min: float = round(float(main.get("temp_min", temp_c)), 1)
        temp_max: float = round(float(main.get("temp_max", temp_c)), 1)
        humidity: int = int(main.get("humidity", 0))
        wind_speed_ms: float = float(wind.get("speed", 0.0))
        wind_speed_kmh: float = round(wind_speed_ms * 3.6, 1)
        wind_dir: int = int(wind.get("deg", 0))
        visibility_m: int = int(data.get("visibility", 10000))
        visibility_km: float = round(visibility_m / 1000, 1)
        cloud_pct: int = int(clouds.get("all", 0))
        description: str = str(weather_info.get("description", "")).capitalize()
        icon_code: str = str(weather_info.get("icon", "01d"))

        def _fmt_ts(unix_ts: int) -> str:
            if not unix_ts:
                return "00:00"
            return datetime.fromtimestamp(unix_ts, tz=timezone.utc).strftime("%H:%M")

        sunrise_str = _fmt_ts(sys_info.get("sunrise", 0))
        sunset_str = _fmt_ts(sys_info.get("sunset", 0))

        resolved_location = data.get("name") or location or "Unknown"
        country = sys_info.get("country", "IN")
        advisory = _build_advisory(temp_c, humidity, wind_speed_kmh, description)

        logger.info(
            "Live weather fetched: %s, %.1f°C, %s",
            resolved_location, temp_c, description,
        )

        return WeatherResponse(
            location=resolved_location,
            country=country,
            latitude=lat,
            longitude=lon,
            temperature_c=temp_c,
            feels_like_c=feels_like,
            temp_min_c=temp_min,
            temp_max_c=temp_max,
            humidity_pct=humidity,
            wind_speed_kmh=wind_speed_kmh,
            wind_direction_deg=wind_dir,
            visibility_km=visibility_km,
            cloud_cover_pct=cloud_pct,
            description=description,
            icon_code=icon_code,
            icon_url=_ICON_URL_TMPL.format(code=icon_code),
            sunrise_utc=sunrise_str,
            sunset_utc=sunset_str,
            farm_advisory=advisory,
            is_demo=False,
            fetched_at=now,
        )
