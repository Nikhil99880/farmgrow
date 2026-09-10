# Kisan Setu (किसान सेतु) — Unified Agricultural Mandi & Direct Procurement Gateway

> **Unified Codebase (Version A + Version B Integrated)**  
> High-performance digital gateway empowering Indian farmers with official e-NAM mandi slot booking, real-time APMC market prices, agro-meteorological advisories, Direct Benefit Transfer (DBT) verification, PFMS voucher minting, and dual-backend execution.

---

## Architecture & Unified Server Execution

The codebase provides **two complementary execution runtimes** that share the exact same SQLite database (`app_build/data/kisan_setu.db`), seed data, and data models:

```
                          ┌─────────────────────────────┐
                          │   Frontend: index.html      │
                          │   Single-Page App (SPA)     │
                          │   Tailwind CSS / Vanilla JS │
                          └──────────────┬──────────────┘
                                         │
                 ┌───────────────────────┴───────────────────────┐
                 ▼                                               ▼
┌─────────────────────────────────┐             ┌─────────────────────────────────┐
│     serve.py (Port 8080)        │             │   app_build/main.py (Port 8000) │
│  • Standalone Zero-Dependency   │             │  • Production ASGI (FastAPI)   │
│  • Standard Python 3.10+        │             │  • Asynchronous (uvicorn)       │
│  • Built-in sqlite3 + WAL       │             │  • In-Memory Sliding-Window RL  │
│  • Handles /api/* & /api/v1/*   │             │  • Security Headers Middleware  │
└────────────────┬────────────────┘             └────────────────┬────────────────┘
                 │                                               │
                 └───────────────────────┬───────────────────────┘
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │   app_build/data/kisan_setu.db (SQLite WAL)   │
                 │   Farmers, Bookings, Prices, PFMS Vouchers    │
                 └───────────────────────────────────────────────┘
```

### Option 1: Standalone Zero-Dependency Runner (`serve.py`)
No `pip install` required! Runs immediately using Python's built-in standard library:
```bash
cd "farmgrow-main/Kisan Setu"
python serve.py
```
- **Port:** `8080` (or next free port)
- **Features:**
  - Serves `index.html` and all static web assets with proper MIME types.
  - Native support for all `/api/*` endpoints (OTP, MSP, Mandi, Schemes, Centers, Farmer profile).
  - Native support for all `/api/v1/*` endpoints (SQL DB health, statistics, farmers, slot bookings, market prices, weather, PFMS vouchers) connected to `kisan_setu.db`.

### Option 2: Production ASGI Backend (`app_build/main.py`)
For production deployments requiring high-concurrency async I/O, rate limiting, and security headers:
```bash
cd "farmgrow-main/Kisan Setu/app_build"
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```
- **Port:** `8000`
- **Features:**
  - Full FastAPI framework with Swagger documentation (`/docs`, disabled by default for security).
  - Sliding-window per-IP rate limiting (login/signup 5/min, default 120/min).
  - Full suite of security response headers (HSTS, CSP, X-Frame-Options, X-Content-Type-Options).
  - Mounts both `/api/v1/*` and `/api/*` endpoints.

---

## Key Features Retained & Merged

### 1. Zero-Regression Authentication & Session Engine
- **SMS OTP Verification:** Request OTP via `POST /api/auth/send-otp` and verify via `POST /api/auth/verify-otp`.
- **Demo Mode:** Instant login button (`Quick Demo Login (Ram Singh)`) and autofill OTP `482910` for testing.
- **Client Session Persistence:** Session stored in `localStorage` (`kisan_setu_user_session`) and automatically restored across page refreshes.
- **Dynamic UI Personalization (`applyFarmerToUI`):**
  - Personalizes dashboard greeting ("Namaste, [Farmer Name] Ji! 🙏") and farmer subtitle.
  - Dynamically updates the navigation drawer initials avatar, farmer name, and ID.
  - Updates profile modal with active land holding, Aadhaar status, and bank account.
  - Pre-fills DBT card summaries and Sahayak AI chat greeting.

### 2. Relational SQLite Database & Real-Time Inspector
- **Engine:** SQLite 3 in WAL (Write-Ahead Logging) mode.
- **Database Path:** `app_build/data/kisan_setu.db`.
- **Inspector Modal (`sql-db-modal`):** Click the database status button in the header to view:
  - SQLite WAL mode and engine health.
  - Total registered farmers count and live records table.
  - Total procurement slot bookings count and live bookings table.
  - Database disk file size in KB.

### 3. Live Mandi Market Prices & MSP Comparisons
- **Live Mandi Ticker:** Displays real-time modal prices and price difference relative to the Government Minimum Support Price (MSP).
- **Commodity Switcher:** Select from Wheat, Rice, Mustard, Cotton, Maize, Sugarcane, Soybean, Groundnut, Sunflower, Gram (Chana), Barley, or Bajra.
- **APMC Mandi Yard Coverage:** Real-time data across Karnal, Ludhiana, Pune, Nagpur, Taraori, Gharaunda, and Kurukshetra markets.

### 4. Real-Time Agro-Weather & Advisory
- **Weather Detail Modal:** Detailed forecast including temperature, humidity, wind velocity/direction, precipitation probability, feels-like temperature, sunrise/sunset, and farm-specific harvest advisories.
- **Open-Meteo Integration:** Live coordinate-based queries with graceful fallback.

### 5. PFMS Direct Benefit Transfer & Official Voucher Minting
- **Calculation:** Automated gross payout, mandi cess (1.5%), and net DBT payout calculations.
- **Voucher Minting (`/api/v1/payments/voucher/mint`):** Generates server-signed PFMS vouchers with HMAC-SHA256 audit hashes and electronic UTR numbers.
- **Receipt Verification:** Authentic receipts with tamper-proof signatures, printable download, and QR code inspection.

---

## API Reference

### 1. Legacy & Convenience API Routes (`/api/*`)
| Method | Path | Description |
| :--- | :--- | :--- |
| `GET` | `/api/health` | Service health and timestamp |
| `GET` | `/api/msp` | MSP rates for all crops or specific crop (`?crop=Wheat`) |
| `GET` | `/api/mandi` | Mandi arrivals and modal prices by district (`?district=Karnal`) |
| `GET` | `/api/weather` | Current weather and advisory (`?location=Karnal`) |
| `GET` | `/api/schemes` | Central & state welfare schemes catalog |
| `GET` | `/api/centers` | APMC procurement centers directory |
| `GET` | `/api/farmer` | Query farmer record by phone (`?phone=9876543210`) |
| `POST` | `/api/auth/send-otp` | Generate and dispatch 6-digit OTP |
| `POST` | `/api/auth/verify-otp` | Verify OTP and authenticate farmer |
| `POST` | `/api/farmer/register` | Register new farmer and persist to SQL database |
| `POST` | `/api/farmer/update` | Update farmer land/bank details and persist to SQL database |
| `POST` | `/api/procurement/slot` | Book mandi gate slot and generate entry pass token |
| `POST` | `/api/mandi/price-check` | Check crop market price against official MSP |

### 2. Enterprise RESTful API Routes (`/api/v1/*`)
| Method | Path | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/health` | High-performance operational health check |
| `GET` | `/api/v1/db/health` | SQLite database engine status and WAL journal mode |
| `GET` | `/api/v1/db/stats` | Record counts for farmers, bookings, and file size |
| `GET` | `/api/v1/db/farmers` | List registered farmers from SQLite database |
| `POST` | `/api/v1/db/farmers` | Insert new farmer into SQLite database |
| `GET` | `/api/v1/db/farmers/{id}` | Query farmer by ID or mobile number |
| `PUT` | `/api/v1/db/farmers/{id}` | Update farmer information in SQLite database |
| `GET` | `/api/v1/db/bookings` | List slot bookings from SQLite database |
| `POST` | `/api/v1/db/bookings` | Create new slot booking in SQLite database |
| `GET` | `/api/v1/db/bookings/{token}`| Query slot booking details by token number |
| `GET` | `/api/v1/weather` | Live Open-Meteo weather with agricultural advisory |
| `GET` | `/api/v1/market/prices` | Live mandi rates with MSP comparison |
| `GET` | `/api/v1/market/commodities`| List supported agricultural commodities |
| `POST` | `/api/v1/payments/calculate` | Calculate gross, mandi cess, and net DBT payout |
| `POST` | `/api/v1/payments/voucher/mint` | Mint tamper-proof HMAC-SHA256 signed PFMS voucher |
| `GET` | `/api/v1/payments/voucher/{ref}` | Retrieve and verify authenticated PFMS voucher |
| `GET` | `/api/v1/payments/vouchers` | List all minted PFMS vouchers |

---

## Pre-Deployment Production Hardening

All security recommendations from the production audit have been integrated:
1. **Parameterized Queries:** Parameterized SQL prevents SQL injection across all database interactions.
2. **Security Headers:** `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Strict-Transport-Security`, `Content-Security-Policy`, and `Referrer-Policy: no-referrer`.
3. **Sliding-Window Rate Limiting:** In-memory sliding window rate limiter protects against brute-force and DDoS attempts.
4. **CORS Hardening:** Configurable allowed origins; never wildcard with credentials.
5. **No PII Leaks:** Masked Aadhaar (`**3942`) and masked bank accounts (`XXXX-XXXX-5678`) only. Plaintext sensitive identifiers are never logged or echoed.
