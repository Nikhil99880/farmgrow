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

"""In-process, per-client-IP rate limiting.

Uses a sliding-window counter keyed by ``(client IP, rule bucket)`` with
**no external dependencies** so it works behind any deployment model.

Limits are intentionally strict on authentication endpoints:

* login / signup / register: ``RATE_LIMIT_LOGIN_PER_MIN`` (default 5) / minute
* OTP verification:           ``RATE_LIMIT_OTP_PER_MIN``  (default 10) / minute
* password reset:             ``RATE_LIMIT_RESET_PER_HOUR`` (default 3) / hour
* every other /api route:     ``RATE_LIMIT_DEFAULT_PER_MIN`` (default 120) / minute

This is an in-process limiter: it is per-worker, not global. Behind multiple
workers or a load balancer upstream rate limiting is still recommended.
"""

from __future__ import annotations

import time
from collections import defaultdict, deque

from config import Settings


class RateLimiter:
    """Sliding-window rate limiter keyed by client IP and route bucket."""

    #: Hard cap on tracked keys; protects against unbounded memory growth
    #: from many distinct IPs (e.g. distributed scans).
    MAX_KEYS = 100_000

    def __init__(self, settings: Settings) -> None:
        self._default_per_min = settings.RATE_LIMIT_DEFAULT_PER_MIN
        # bucket name -> (window_seconds, limit)
        self._rules: dict[str, tuple[float, int]] = {
            "login": (60.0, settings.RATE_LIMIT_LOGIN_PER_MIN),
            "otp": (60.0, settings.RATE_LIMIT_OTP_PER_MIN),
            "reset": (3600.0, settings.RATE_LIMIT_RESET_PER_HOUR),
        }
        self._hits: defaultdict[tuple[str, str], deque[float]] = defaultdict(deque)

    def _bucket_for(self, path: str) -> str:
        """Map a request path to its rate-limit bucket."""
        p = path.rstrip("/")
        if "password/reset" in p or p.endswith("/reset-password"):
            return "reset"
        if (
            p.endswith("/login")
            or p.endswith("/signup")
            or p.endswith("/register")
            or "auth/" in p
        ):
            return "login"
        if p.endswith("/otp") or "otp/" in p or p.endswith("/verify-otp"):
            return "otp"
        return "default"

    def enforce(self, client_ip: str, path: str) -> tuple[bool, int]:
        """Record a hit and decide whether the request may proceed.

        Returns ``(allowed, retry_after_seconds)``.  When ``allowed`` is
        ``False`` the caller should reject with HTTP 429 and a
        ``Retry-After`` header of ``retry_after_seconds``.
        """
        bucket = self._bucket_for(path)
        window, limit = self._rules.get(bucket, (60.0, self._default_per_min))
        key = (client_ip, bucket)
        now = time.monotonic()
        hits = self._hits[key]

        while hits and now - hits[0] >= window:
            hits.popleft()

        if len(hits) >= limit:
            retry_after = max(1, int(window - (now - hits[0])) + 1)
            return False, retry_after

        hits.append(now)

        if len(self._hits) > self.MAX_KEYS:
            self._prune(now)
        return True, 0

    def _prune(self, now: float) -> None:
        """Drop buckets that have no hits inside any active window."""
        # The largest configured window is the hourly reset bucket; anything
        # with no hits in the last hour is reclaimable.
        max_window = max(window for window, _ in self._rules.values())
        stale = [
            key
            for key, hits in self._hits.items()
            if not hits or now - hits[-1] > max_window
        ]
        for key in stale:
            del self._hits[key]