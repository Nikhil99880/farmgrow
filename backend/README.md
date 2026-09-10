# Backend — Python Servers & APIs

This folder contains the Kisan Setu backend infrastructure.

## Contents
- `serve.py` — Zero-dependency standalone runner (Python 3.10+, no pip install needed)
- `app_build/` — Production FastAPI backend

## Quick Start

### Option 1: Standalone Runner
```bash
python serve.py
```
Server runs on `http://localhost:8080`

### Option 2: Production Backend
```bash
cd app_build
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```
Server runs on `http://localhost:8000`

## API Routes
- `/api/*` — Legacy & convenience endpoints
- `/api/v1/*` — Enterprise RESTful endpoints
- `/api/auth/*` — Authentication (OTP, login)
- `/api/farmer/*` — Farmer management
- `/api/procurement/*` — Slot booking
- `/api/v1/db/*` — Database operations
- `/api/v1/payments/*` — Payment & voucher handling
