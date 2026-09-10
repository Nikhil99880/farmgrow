# Kisan Setu

Rural connect app for Indian farmers — mandi (market) procurement, live queue
tracking, slot booking, payment receipts, and multi-language UI (English, हिन्दी,
ਪੰਜਾਬੀ, मराठी).

## Repository layout

| Path | Contents |
| --- | --- |
| `index.html` | Single-file client-side UI prototype (mock data, offline-capable). |
| `stitch_kisan_rural_connect/` | Figma/HTML screen prototypes for each workflow (login, booking, tokens, payments, etc.). |
| `app_build/` | Production FastAPI backend — async file storage (chunked uploads, streaming downloads, path-traversal-safe). |

## Setup

1. Copy the env template and fill in real values:

   ```
   cp .env.example .env
   ```

2. Install backend dependencies and run:

   ```
   cd app_build
   pip install -r requirements.txt          # (or activate app_build/.venv)
   python -m uvicorn main:app --host $HOST --port $PORT
   ```

3. Open the frontend prototype (`index.html`) in a browser.

## Environment variables

See `.env.example` for the full list. In short:

| Variable | Mandatory | Verdict |
| --- | --- | --- |
| `STORAGE_ROOT` | optional | Path to upload directory |
| `HOST`, `PORT`, `WORKERS`, `LOG_LEVEL` | optional | Server bindings |
| `CORS_ORIGINS` | optional | Comma-separated allowed origins (never `*` in production) |
| `OPENWEATHER_API_KEY` | optional | Server-side only |
| `DATAGOV_API_KEY` | optional | Server-side only |
| `ENABLE_DOCS`, `DEBUG` | optional | Must be `false` in production (default) |
| `TRUST_PROXY` | optional | `true` only behind a trusted reverse proxy |
| `REQUIRED_ENV` | optional | Comma-separated vars that must be set or startup aborts |
| `RATE_LIMIT_*` | optional | Per-IP rate limits (defaults: 120/min, login 5/min, OTP 10/min, reset 3/hour) |
| `DATABASE_PATH` | optional | SQLite file path (default: `app_build/data/kisan_setu.db`) |
| `ADMIN_API_KEY` | required for prod | Bearer key protecting `/api/v1/db/*` (empty = open demo mode) |
| `STORAGE_API_KEY` | required for prod | Bearer key protecting `/api/v1/files/*` (empty = open demo mode) |
| `PFMS_SIGNING_SECRET` | required for prod | HMAC secret for PFMS voucher signing; empty value disables minting |

All secrets must be read from the environment at runtime. **No secret should ever
be hard-coded, committed, or logged.**

## Secret handling rules

- **Client vs server:** any key reachable from the browser must be public-safe. A
  Supabase anon key is only safe to ship to the client if **Row Level Security is
  enabled on every table**; without RLS it exposes the entire database. Service-role
  keys, Stripe secret keys, database connection strings, OAuth client secrets, and
  JWT signing secrets are **server-side only**.
- **Prefix hygiene (React/Next.js):** `NEXT_PUBLIC_` / `REACT_APP_` variables are
  bundled into the browser. Never give a secret one of these prefixes.
- **Logs & responses:** error handlers, `console.log`, and API responses must not
  echo tokens, credential headers, or connection strings.

> ### ⚠️ SECRET ROTATION WARNING
>
> Git history never forgets. Any secret that was ever committed — even if later
> removed from the working tree — remains recoverable from past commits. If you
> previously hard-coded an API key, password, token, or connection string, **rotate
> it immediately**: revoke the old value in the provider dashboards and issue a new
> one before deploying. The audit below found no live secrets in current history,
> but rotate anything that was ever present.

## Privacy & personal-data handling

### Where personal data enters (and where it stops)

| Screen | Data collected | What happens to it |
| --- | --- | --- |
| Login (`index.html`) | 10-digit mobile | Held only in the DOM during the session. Displayed in a toast + OTP screen. **Not stored.** |
| OTP verify | 6-digit code | Used only to demo-navigate. **Not stored, not validated server-side (prototype).** |
| Registration | Full name, farmer ID, mobile, village/district | Name is copied into the in-memory `bookingState` object for receipt rendering. **Cleared on page reload. Not persisted.** |
| Link Aadhaar | 12-digit Aadhaar | Only a masked suffix (`**3942`) is ever shown. **No plaintext Aadhaar is stored anywhere.** |
| Land details | State, district, tehsil, village, khasra, area, unit, ownership | Copied into in-memory `bookingState.landDetails`. **Cleared on reload. Not persisted.** |
| DBT / bank setup | Bank account (masked `XXXX-…`), IFSC | Fields displayed only; mask is `XXXX-XXXX-5678`. **Not stored.** |
| Sahayak chat | Free-text message | Rendered in the chat thread only; replies are simulated client-side. **Not stored, not sent to any AI API.** |
| File uploads (backend) | User-uploaded files | Stored on disk under `app_build/uploads/` (git-ignored). Metadata (filename, size, MIME, timestamps) returned via API. |

**Client-side storage state:**
- `localStorage` holds exactly one key, `kisan_setu_lang` (UI language). **No PII is ever written to `localStorage` or `sessionStorage`.**
- No cookies are set by the app.
- `bookingState` (farmer name + land details) lives only in page memory and is lost on unload.

**External data sent:**
- Google Fonts / Tailwind CDN / Google-hosted images receive only standard HTTP metadata (IP, User-Agent, Referrer) from the browser. No app data.
- The backend sends coordinates (`lat`/`lon`) and farm weather queries to OpenWeatherMap, and (when wired) commodity/state queries to data.gov.in — server-side only, never via the browser. No name, mobile, or account data leaves the backend.

### Data deletion

- The prototype persists **no** accounts, profiles, or PII — there is nothing to delete client-side beyond clearing the language preference.
- Uploaded files are deleted with `DELETE /api/v1/files/{path}` (path must be inside the storage root; traversal is blocked).
- Before production, require: (a) authentication on all upload/download endpoints, (b) a per-user "delete my data" flow that purges both the user record and their uploads, and (c) a short retention policy / scheduled sweep for orphaned files.

### Pre-production privacy checklist

- Add real auth + RLS before any real PII flows exist (Supabase RLS **on every table**).
- Never store plaintext Aadhaar / bank numbers; store hashes or rely on verified-but-masked values only.
- If passwords are ever introduced, hash with **argon2id or bcrypt** (never MD5/SHA-256 alone) and never echo them in logs or responses.
- Self-host the font files instead of Google Fonts if offline-first is a requirement.
- Encrypt uploads at rest; reject files whose MIME does not match the declared type.

## Pre-deployment production-hardening audit

Status of the seven-checks audit (all enforced in code; see `app_build/`):

| # | Check | Status | Enforcement |
| --- | --- | --- | --- |
| 1 | Environment variables | ✅ | Every value read from env (`app_build/config.py`); malformed `PORT`/`WORKERS` **refuse to start** with a clear error; `REQUIRED_ENV=` lists variables that must be set or startup aborts. |
| 2 | Debug code removed / debug off | ✅ | `DEBUG=false` and `ENABLE_DOCS=false` by default; Swagger/ReDoc and uvicorn `--reload` only activate when explicitly enabled; no `console.log`, TODO/FIXME, test endpoints, or hardcoded credentials remain. |
| 3 | Safe error handling | ✅ | Clients get only generic messages with `error_type` (e.g. `file_not_found`, `path_traversal`) + a `request_id` correlation ID (`X-Request-ID` header); stack traces, absolute paths, and internal detail go to server logs only. `health` no longer exposes the storage path. |
| 4 | Security headers | ✅ | `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Strict-Transport-Security` (HSTS), `Content-Security-Policy` (`default-src 'self'`; the landing page also pins its Tailwind/Google CDN origins), `Referrer-Policy: no-referrer` on **every** response. |
| 5 | Rate limiting | ✅ | In-process per-IP sliding window (`app_build/rate_limit.py`): login/signup **5/min**, OTP **10/min**, password reset **3/hour**, default **120/min**, all tunable via env. Returns `429` + `Retry-After`. |
| 6 | CORS restricted | ✅ | `allow_origins` comes from `CORS_ORIGINS` (env) — **never `*`** for credentialed requests; methods restricted; credentials enabled only for exact trusted origins. |
| 7 | Database security | ✅ | SQLite (`app_build/data/kisan_setu.db`, WAL) with parameterized queries only (no SQL injection). Database/storage APIs are bearer-gated by `ADMIN_API_KEY` / `STORAGE_API_KEY` (empty = open demo mode + startup warning; set via env for production). `/openapi.json`, Swagger and ReDoc are disabled unless `ENABLE_DOCS=true`. `health`/`stats` no longer leak engine/version/paths; list `limit` is bounded and booking quantities are range-checked. |

### Safer deployment reminders

- Set `CORS_ORIGINS` to the exact production frontend origin(s).
- Set `ADMIN_API_KEY` / `STORAGE_API_KEY` / `PFMS_SIGNING_SECRET` and list the first two in `REQUIRED_ENV` so a blank-key deployment refuses to start.
- Put the service behind HTTPS-terminating infra so HSTS applies end-to-end.
- The rate limiter is per-process: run exactly one worker behind the load balancer, or add upstream (e.g. Cloud CDN / API-gateway) rate limiting on `/api/v1/**`.
- Never ship `ENABLE_DOCS=true` or `DEBUG=true` to production.