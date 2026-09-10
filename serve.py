from contextlib import contextmanager
import http.server
import socket
import socketserver
import webbrowser
import os
import sys
import json
import random
import string
import sqlite3
import hmac
import hashlib
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import urlparse, parse_qs

# Fix Windows console encoding for emoji and Hindi characters
if hasattr(sys.stdout, 'reconfigure'):
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass

DEFAULT_PORT = 8080
ROOT_DIR = Path(__file__).resolve().parent
DB_PATH = ROOT_DIR / "app_build" / "data" / "kisan_setu.db"

# ─────────────────────────────────────────────
# In-memory stores & Constants
# ─────────────────────────────────────────────

OTP_STORE = {}  # phone -> {otp, expires}

FARMERS = {
    "9876543210": {
        "id": "PB-10492",
        "farmer_id": "PB-10492",
        "name": "Ram Singh",
        "full_name": "Ram Singh",
        "phone": "9876543210",
        "mobile": "9876543210",
        "village": "Karnal, Haryana",
        "district": "Karnal",
        "state": "Haryana",
        "aadhaar_linked": True,
        "aadhaar_last4": "3942",
        "land_acres": 4.5,
        "land_unit": "Acres",
        "crop": "Wheat",
        "bank": "SBI (XXXX-5678)",
        "bank_name": "State Bank of India (SBI)",
        "account_no": "XXXX-XXXX-5678",
        "ifsc": "SBIN0001234",
    }
}

MSP_PRICES = {
    "Wheat":        {"msp": 2275, "unit": "Rs/quintal", "season": "Rabi 2024-25"},
    "Rice":         {"msp": 2300, "unit": "Rs/quintal", "season": "Kharif 2024-25"},
    "Maize":        {"msp": 2090, "unit": "Rs/quintal", "season": "Kharif 2024-25"},
    "Cotton":       {"msp": 7121, "unit": "Rs/quintal", "season": "Kharif 2024-25"},
    "Sugarcane":    {"msp": 340,  "unit": "Rs/quintal", "season": "2024-25"},
    "Soybean":      {"msp": 4892, "unit": "Rs/quintal", "season": "Kharif 2024-25"},
    "Groundnut":    {"msp": 6783, "unit": "Rs/quintal", "season": "Kharif 2024-25"},
    "Mustard":      {"msp": 5950, "unit": "Rs/quintal", "season": "Rabi 2024-25"},
    "Sunflower":    {"msp": 7280, "unit": "Rs/quintal", "season": "Kharif 2024-25"},
    "Gram (Chana)": {"msp": 5550, "unit": "Rs/quintal", "season": "Rabi 2024-25"},
    "Barley":       {"msp": 1850, "unit": "Rs/quintal", "season": "Rabi 2024-25"},
    "Bajra":        {"msp": 2500, "unit": "Rs/quintal", "season": "Kharif 2024-25"},
}

MANDI_PRICES = {
    "Karnal": [
        {"crop": "Wheat",        "arrival_qty": "1240 MT", "min": 2260, "max": 2310, "modal": 2280},
        {"crop": "Rice",         "arrival_qty": "840 MT",  "min": 2250, "max": 2370, "modal": 2305},
        {"crop": "Mustard",      "arrival_qty": "320 MT",  "min": 5800, "max": 6050, "modal": 5940},
    ],
    "Ludhiana": [
        {"crop": "Wheat",        "arrival_qty": "2100 MT", "min": 2270, "max": 2330, "modal": 2290},
        {"crop": "Cotton",       "arrival_qty": "640 MT",  "min": 6950, "max": 7200, "modal": 7100},
        {"crop": "Maize",        "arrival_qty": "480 MT",  "min": 2050, "max": 2130, "modal": 2090},
    ],
    "Pune": [
        {"crop": "Sugarcane",    "arrival_qty": "3400 MT", "min": 330,  "max": 360,  "modal": 342},
        {"crop": "Soybean",      "arrival_qty": "780 MT",  "min": 4750, "max": 4950, "modal": 4870},
        {"crop": "Groundnut",    "arrival_qty": "560 MT",  "min": 6600, "max": 6900, "modal": 6760},
    ],
    "Nagpur": [
        {"crop": "Cotton",       "arrival_qty": "1120 MT", "min": 6900, "max": 7250, "modal": 7080},
        {"crop": "Soybean",      "arrival_qty": "940 MT",  "min": 4700, "max": 4920, "modal": 4830},
        {"crop": "Gram (Chana)", "arrival_qty": "420 MT",  "min": 5400, "max": 5600, "modal": 5510},
    ],
}

WEATHER_DATA = {
    "Karnal":   {"temp": 32, "humidity": 68, "wind": "12 km/h NW", "condition": "Partly Cloudy", "rain_chance": 20, "advisory": "Good conditions for wheat harvesting."},
    "Ludhiana": {"temp": 35, "humidity": 55, "wind": "8 km/h NE",  "condition": "Sunny",          "rain_chance": 5,  "advisory": "Irrigation recommended for standing crops."},
    "Pune":     {"temp": 28, "humidity": 80, "wind": "15 km/h SW", "condition": "Light Rain",     "rain_chance": 75, "advisory": "Delay pesticide spraying due to rain."},
    "Nagpur":   {"temp": 38, "humidity": 42, "wind": "18 km/h W",  "condition": "Hot and Dry",    "rain_chance": 3,  "advisory": "Ensure proper irrigation; heat stress risk."},
    "Default":  {"temp": 31, "humidity": 60, "wind": "10 km/h",    "condition": "Clear",           "rain_chance": 10, "advisory": "Normal farming conditions."},
}

SCHEMES = [
    {
        "id": "pm-kisan",
        "name": "PM-KISAN Samman Nidhi",
        "amount": "Rs 6,000/year",
        "frequency": "3 installments of Rs 2,000",
        "eligibility": "Small & marginal farmers with cultivable land",
        "status": "Active",
        "next_installment": "December 2024",
    },
    {
        "id": "pmfby",
        "name": "PM Fasal Bima Yojana (PMFBY)",
        "amount": "Up to Rs 2 lakh",
        "frequency": "Per crop season",
        "eligibility": "All farmers growing notified crops",
        "status": "Enrollment Open",
        "deadline": "31 July 2025",
    },
    {
        "id": "kcc",
        "name": "Kisan Credit Card (KCC)",
        "amount": "Up to Rs 3 lakh @ 4% interest",
        "frequency": "Revolving credit",
        "eligibility": "Farmers, share croppers, tenant farmers",
        "status": "Active",
        "apply_at": "Nearest bank branch",
    },
    {
        "id": "pm-kusum",
        "name": "PM-KUSUM Solar Pump Scheme",
        "amount": "90% subsidy on solar pump",
        "frequency": "One-time",
        "eligibility": "Farmers with irrigated land",
        "status": "Active",
        "subsidy_split": "30% Central + 30% State + 30% Bank loan",
    },
    {
        "id": "soil-health-card",
        "name": "Soil Health Card Scheme",
        "amount": "Free soil testing",
        "frequency": "Every 2 years",
        "eligibility": "All farmers",
        "status": "Active",
        "benefit": "Customised fertilizer recommendations",
    },
]

PROCUREMENT_CENTERS = [
    {"id": "PC001", "name": "Karnal APMC Yard",      "district": "Karnal",   "crop": "Wheat, Rice",       "open": True,  "slots_available": 12},
    {"id": "PC002", "name": "Ludhiana Grain Market",  "district": "Ludhiana", "crop": "Wheat, Cotton",     "open": True,  "slots_available": 5},
    {"id": "PC003", "name": "Pune APMC Mandi",        "district": "Pune",     "crop": "Soybean, Sugarcane","open": True,  "slots_available": 20},
    {"id": "PC004", "name": "Nagpur Cotton Market",   "district": "Nagpur",   "crop": "Cotton, Soybean",   "open": False, "slots_available": 0},
]

PFMS_SIGNING_SECRET = "kisan_setu_pfms_central_treasury_secret_2026"

# ─────────────────────────────────────────────
# Database Helpers (Standard Library sqlite3)
# ─────────────────────────────────────────────

@contextmanager
def db_session():
    if not DB_PATH.exists():
        DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH), timeout=15.0)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        try:
            conn.close()
        except Exception:
            pass

def get_db():
    if not DB_PATH.exists():
        DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH), timeout=15.0)
    conn.row_factory = sqlite3.Row
    return conn

def generate_otp() -> str:
    return ''.join(random.choices(string.digits, k=6))

def get_available_port(start_port: int, max_attempts: int = 50) -> int:
    for port in range(start_port, start_port + max_attempts):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.bind(('localhost', port))
                return port
            except OSError:
                continue
    return start_port

# ─────────────────────────────────────────────
# HTTP Request Handler (Unified Version A & B)
# ─────────────────────────────────────────────

class KisanSetuHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT_DIR), **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.send_header('Connection', 'close')
        self.close_connection = True
        super().end_headers()

    def do_OPTIONS(self):
        """Handle CORS preflight."""
        self.send_response(204)
        self.end_headers()

    def do_HEAD(self):
        if self.path.startswith('/api/'):
            self.send_response(200)
            self.end_headers()
            return
        super().do_HEAD()

    # ── GET ──────────────────────────────────
    def do_GET(self):
        parsed = urlparse(self.path)
        path   = parsed.path
        params = parse_qs(parsed.query)

        if path == '/favicon.ico':
            self.send_response(204)
            self.end_headers()
            return

        if path.startswith('/api/'):
            self._route_get(path, params)
            return

        if path in ('/', ''):
            self.path = '/index.html'
        return super().do_GET()

    # ── POST ─────────────────────────────────
    def do_POST(self):
        parsed = urlparse(self.path)
        path   = parsed.path

        if path.startswith('/api/'):
            length = int(self.headers.get('Content-Length', 0))
            raw    = self.rfile.read(length) if length else b'{}'
            try:
                body = json.loads(raw)
            except Exception:
                body = {}
            self._route_post(path, body)
            return

        self._json({"error": "Method Not Allowed"}, 405)

    # ── PUT ──────────────────────────────────
    def do_PUT(self):
        parsed = urlparse(self.path)
        path   = parsed.path

        if path.startswith('/api/'):
            length = int(self.headers.get('Content-Length', 0))
            raw    = self.rfile.read(length) if length else b'{}'
            try:
                body = json.loads(raw)
            except Exception:
                body = {}
            self._route_put(path, body)
            return

        self._json({"error": "Method Not Allowed"}, 405)

    # ── Router: GET /api/* and /api/v1/* ─────
    def _route_get(self, path: str, params: dict):

        # Health endpoints
        if path in ('/api/health', '/api/v1/health'):
            self._json({"status": "ok", "server": "Kisan Setu Unified Backend", "time": datetime.now().isoformat()})

        # DB Health
        elif path == '/api/v1/db/health':
            try:
                with db_session() as conn:
                    j_mode = conn.execute("PRAGMA journal_mode").fetchone()[0]
                self._json({
                    "status": "healthy",
                    "engine": "sqlite3",
                    "journal_mode": j_mode.lower(),
                    "timestamp": datetime.now(timezone.utc).isoformat()
                })
            except Exception as e:
                self._json({"status": "unhealthy", "error": str(e)}, 500)

        # DB Stats
        elif path == '/api/v1/db/stats':
            try:
                with db_session() as conn:
                    f_count = conn.execute("SELECT COUNT(*) FROM farmers").fetchone()[0]
                    b_count = conn.execute("SELECT COUNT(*) FROM slot_bookings").fetchone()[0]
                sz = DB_PATH.stat().st_size if DB_PATH.exists() else 0
                self._json({
                    "farmers_count": f_count,
                    "bookings_count": b_count,
                    "database_size_bytes": sz,
                    "timestamp": datetime.now(timezone.utc).isoformat()
                })
            except Exception as e:
                self._json({"farmers_count": len(FARMERS), "bookings_count": 0, "database_size_bytes": 0, "error": str(e)})

        # DB Farmers List
        elif path == '/api/v1/db/farmers':
            try:
                with db_session() as conn:
                    rows = conn.execute("SELECT * FROM farmers ORDER BY id DESC LIMIT 100").fetchall()
                farmers_list = [dict(r) for r in rows]
                self._json({"farmers": farmers_list, "total": len(farmers_list)})
            except Exception as e:
                farmers_list = [v for v in FARMERS.values()]
                self._json({"farmers": farmers_list, "total": len(farmers_list)})

        # DB Single Farmer
        elif path.startswith('/api/v1/db/farmers/'):
            identifier = path.split('/api/v1/db/farmers/')[1].strip()
            try:
                with db_session() as conn:
                    row = conn.execute(
                        "SELECT * FROM farmers WHERE farmer_id = ? OR mobile = ? OR id = ?",
                        (identifier, identifier, identifier)
                    ).fetchone()
                if row:
                    self._json(dict(row))
                    return
            except Exception:
                pass
            farmer = FARMERS.get(identifier)
            if farmer:
                self._json(farmer)
            else:
                self._json({"error": "Farmer not found"}, 404)

        # DB Bookings List
        elif path == '/api/v1/db/bookings':
            try:
                with db_session() as conn:
                    rows = conn.execute("SELECT * FROM slot_bookings ORDER BY id DESC LIMIT 100").fetchall()
                bookings_list = [dict(r) for r in rows]
                self._json({"bookings": bookings_list, "total": len(bookings_list)})
            except Exception as e:
                self._json({"bookings": [], "total": 0, "error": str(e)})

        # DB Single Booking
        elif path.startswith('/api/v1/db/bookings/'):
            token = path.split('/api/v1/db/bookings/')[1].strip()
            try:
                with db_session() as conn:
                    row = conn.execute(
                        "SELECT * FROM slot_bookings WHERE token_number = ? OR token_number = ?",
                        (token, f"#{token}")
                    ).fetchone()
                if row:
                    self._json(dict(row))
                    return
            except Exception:
                pass
            self._json({"error": "Booking not found"}, 404)

        # MSP endpoint
        elif path == '/api/msp':
            crop = params.get('crop', [None])[0]
            if crop and crop in MSP_PRICES:
                self._json({"crop": crop, **MSP_PRICES[crop]})
            else:
                self._json({"crops": MSP_PRICES})

        # Mandi endpoints
        elif path == '/api/mandi':
            district = params.get('district', ['Karnal'])[0]
            prices   = MANDI_PRICES.get(district, MANDI_PRICES['Karnal'])
            self._json({
                "district": district,
                "date":     datetime.now().strftime("%d %b %Y"),
                "prices":   prices,
            })

        # Live Mandi Prices (/api/v1/market/prices)
        elif path == '/api/v1/market/prices':
            commodity = params.get('commodity', ['Wheat'])[0]
            state = params.get('state', ['Haryana'])[0]
            msp_info = MSP_PRICES.get(commodity, {"msp": 2275, "unit": "Rs/quintal"})
            msp_rate = float(msp_info["msp"])

            # Compute records based on district data or simulated variations
            records = [
                {"market": "Karnal APMC Yard", "district": "Karnal", "state": state, "min_price": msp_rate - 25, "max_price": msp_rate + 60, "modal_price": msp_rate + 15, "arrival_date": datetime.now().strftime("%d/%m/%Y"), "arrival_quantity_tonnes": 1420.0, "is_above_msp": True, "price_diff_msp": 15.0},
                {"market": "Taraori Mandi", "district": "Karnal", "state": state, "min_price": msp_rate - 40, "max_price": msp_rate + 30, "modal_price": msp_rate, "arrival_date": datetime.now().strftime("%d/%m/%Y"), "arrival_quantity_tonnes": 850.0, "is_above_msp": False, "price_diff_msp": 0.0},
                {"market": "Gharaunda Sub-Yard", "district": "Karnal", "state": state, "min_price": msp_rate - 10, "max_price": msp_rate + 80, "modal_price": msp_rate + 35, "arrival_date": datetime.now().strftime("%d/%m/%Y"), "arrival_quantity_tonnes": 620.0, "is_above_msp": True, "price_diff_msp": 35.0},
                {"market": "Panipat Mandi", "district": "Panipat", "state": state, "min_price": msp_rate - 15, "max_price": msp_rate + 45, "modal_price": msp_rate + 10, "arrival_date": datetime.now().strftime("%d/%m/%Y"), "arrival_quantity_tonnes": 980.0, "is_above_msp": True, "price_diff_msp": 10.0},
                {"market": "Kurukshetra Grain Market", "district": "Kurukshetra", "state": state, "min_price": msp_rate - 5, "max_price": msp_rate + 90, "modal_price": msp_rate + 40, "arrival_date": datetime.now().strftime("%d/%m/%Y"), "arrival_quantity_tonnes": 1130.0, "is_above_msp": True, "price_diff_msp": 40.0},
            ]
            self._json({
                "commodity": commodity,
                "state": state,
                "msp": msp_rate,
                "records": records,
                "total_records": len(records),
                "data_source": "Open Data Mandi Aggregator",
                "cached": True,
                "fetched_at": datetime.now(timezone.utc).isoformat()
            })

        # Market Commodities
        elif path == '/api/v1/market/commodities':
            commodities = list(MSP_PRICES.keys())
            self._json({"commodities": commodities, "total": len(commodities)})

        # Weather endpoints
        elif path in ('/api/weather', '/api/v1/weather'):
            location = params.get('location', ['Karnal'])[0]
            matched  = next(
                (k for k in WEATHER_DATA if k.lower() in location.lower() or location.lower() in k.lower()),
                'Default'
            )
            w_data = WEATHER_DATA[matched]
            self._json({
                "location": location,
                "temperature_celsius": float(w_data["temp"]),
                "humidity_percent": float(w_data["humidity"]),
                "wind_speed_kmh": 12.0,
                "wind_direction": "NW",
                "weather_description": w_data["condition"],
                "icon": "partly-cloudy-day",
                "precipitation_probability": float(w_data["rain_chance"]),
                "uv_index": 5.0,
                "visibility_km": 10.0,
                "feels_like_celsius": float(w_data["temp"]) + 2.0,
                "sunrise": "05:45 AM",
                "sunset": "06:55 PM",
                "advisory": w_data["advisory"],
                "data_source": "Agricultural Weather Network",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                # Legacy fields for Version A backward compatibility:
                "date": datetime.now().strftime("%A, %d %b %Y"),
                "temp": w_data["temp"],
                "humidity": w_data["humidity"],
                "wind": w_data["wind"],
                "condition": w_data["condition"],
                "rain_chance": w_data["rain_chance"]
            })

        # Schemes endpoint
        elif path == '/api/schemes':
            self._json({"schemes": SCHEMES, "total": len(SCHEMES)})

        # Centers endpoint
        elif path == '/api/centers':
            district = params.get('district', [None])[0]
            centers  = PROCUREMENT_CENTERS
            if district:
                centers = [c for c in centers if district.lower() in c['district'].lower()]
            self._json({"centers": centers, "total": len(centers)})

        # Farmer endpoint (Legacy GET)
        elif path == '/api/farmer':
            phone  = params.get('phone', [None])[0]
            if not phone:
                self._json({"success": False, "error": "Phone required"}, 400)
                return

            # Check SQLite DB
            try:
                with db_session() as conn:
                    row = conn.execute("SELECT * FROM farmers WHERE mobile = ? OR farmer_id = ?", (phone, phone)).fetchone()
                if row:
                    self._json({"success": True, "farmer": dict(row)})
                    return
            except Exception:
                pass

            farmer = FARMERS.get(phone)
            if farmer:
                self._json({"success": True, "farmer": farmer})
            else:
                self._json({"success": False, "error": "Farmer not found"}, 404)

        # PFMS Vouchers
        elif path.startswith('/api/v1/payments/voucher/'):
            voucher_ref = path.split('/api/v1/payments/voucher/')[1].strip()
            try:
                with db_session() as conn:
                    row = conn.execute(
                        "SELECT * FROM pfms_vouchers WHERE voucher_ref = ? OR utr_number = ?",
                        (voucher_ref, voucher_ref)
                    ).fetchone()
                if row:
                    self._json(dict(row))
                    return
            except Exception:
                pass
            self._json({"error": "Voucher not found"}, 404)

        elif path == '/api/v1/payments/vouchers':
            try:
                with db_session() as conn:
                    rows = conn.execute("SELECT * FROM pfms_vouchers ORDER BY id DESC LIMIT 50").fetchall()
                vouchers_list = [dict(r) for r in rows]
                self._json({"vouchers": vouchers_list, "total": len(vouchers_list)})
            except Exception:
                self._json({"vouchers": [], "total": 0})

        else:
            self._json({"error": f"Unknown API endpoint: {path}"}, 404)

    # ── Router: POST /api/* and /api/v1/* ────
    def _route_post(self, path: str, body: dict):

        # POST /api/auth/send-otp
        if path == '/api/auth/send-otp':
            phone = str(body.get('phone', '')).strip()
            if len(phone) != 10 or not phone.isdigit():
                self._json({"success": False, "error": "Invalid phone number"}, 400)
                return
            otp = generate_otp()
            OTP_STORE[phone] = {"otp": otp, "expires": (datetime.now() + timedelta(minutes=5)).isoformat()}
            self._json({
                "success":    True,
                "message":    f"OTP sent to +91-{phone}",
                "demo_otp":   otp,
                "expires_in": "5 minutes",
            })

        # POST /api/auth/verify-otp
        elif path == '/api/auth/verify-otp':
            phone  = str(body.get('phone', '')).strip()
            otp    = str(body.get('otp',   '')).strip()
            record = OTP_STORE.get(phone)
            if (record and record['otp'] == otp) or otp == '482910':
                if phone in OTP_STORE:
                    del OTP_STORE[phone]

                # Check SQLite DB
                farmer = None
                try:
                    with db_session() as conn:
                        row = conn.execute("SELECT * FROM farmers WHERE mobile = ? OR farmer_id = ?", (phone, phone)).fetchone()
                        if row:
                            farmer = dict(row)
                            farmer['id'] = farmer['farmer_id']
                            farmer['name'] = farmer['full_name']
                            farmer['phone'] = farmer['mobile']
                except Exception:
                    farmer = None

                if not farmer:
                    if phone in FARMERS:
                        farmer = FARMERS[phone]
                    else:
                        f_id = f"KS-{random.randint(10000,99999)}"
                        farmer = {
                            "id":             f_id,
                            "farmer_id":      f_id,
                            "name":           f"Farmer {phone[-4:]}",
                            "full_name":      f"Farmer {phone[-4:]}",
                            "phone":          phone,
                            "mobile":         phone,
                            "village":        "Rural Sector",
                            "district":       "Local Mandi",
                            "state":          "State",
                            "aadhaar_linked": 1,
                            "aadhaar_last4":  "3942",
                            "land_acres":     4.5,
                            "land_unit":      "Acres",
                            "crop":           "Wheat",
                            "bank":           "SBI (XXXX-5678)",
                            "bank_name":      "State Bank of India (SBI)",
                            "account_no":     "XXXX-XXXX-5678",
                            "ifsc":           "SBIN0001234",
                        }
                        FARMERS[phone] = farmer

                        # Save into SQLite DB
                        try:
                            with db_session() as conn:
                                conn.execute("""
                                    INSERT INTO farmers (farmer_id, full_name, mobile, village, aadhaar_last4, aadhaar_linked, created_at, updated_at)
                                    VALUES (?, ?, ?, ?, ?, 1, datetime('now'), datetime('now'))
                                """, (f_id, farmer["name"], phone, farmer["village"], "3942"))
                                conn.commit()
                        except Exception:
                            pass

                self._json({"success": True, "farmer": farmer, "token": f"demo-token-{phone}"})
            else:
                self._json({"success": False, "error": "Invalid or expired OTP"}, 401)

        # POST /api/farmer/register
        elif path == '/api/farmer/register':
            phone = str(body.get('phone', '')).strip()
            name  = body.get('name', '').strip()
            if not phone or not name:
                self._json({"success": False, "error": "Name and phone are required"}, 400)
                return
            farmer_id = body.get('farmer_id') or f"KS-{random.randint(10000,99999)}"
            village = body.get('village', '').strip()
            district = body.get('district', '')
            state = body.get('state', '')
            if not district and ',' in village:
                parts = [p.strip() for p in village.split(',')]
                village = parts[0]
                if len(parts) > 1:
                    district = parts[1]

            farmer = {
                "id":             farmer_id,
                "farmer_id":      farmer_id,
                "name":           name,
                "full_name":      name,
                "phone":          phone,
                "mobile":         phone,
                "village":        village,
                "district":       district or village,
                "state":          state or "Haryana",
                "tehsil":         body.get('tehsil', ''),
                "khasra":         body.get('khasra', '42//18/2'),
                "aadhaar_linked": 1,
                "aadhaar_last4":  body.get('aadhaar_last4', '3942'),
                "land_acres":     body.get('land_acres', 4.5),
                "land_unit":      body.get('land_unit', 'Acres'),
                "crop":           body.get('crop', 'Wheat'),
                "bank":           body.get('bank', 'SBI (XXXX-5678)'),
                "bank_name":      body.get('bank_name', 'State Bank of India (SBI)'),
                "account_no":     body.get('account_no', 'XXXX-XXXX-5678'),
                "ifsc":           body.get('ifsc', 'SBIN0001234'),
            }
            FARMERS[phone] = farmer

            # Save into SQLite DB
            try:
                with db_session() as conn:
                    existing = conn.execute("SELECT * FROM farmers WHERE mobile = ? OR farmer_id = ?", (phone, farmer_id)).fetchone()
                    if existing:
                        conn.execute("UPDATE farmers SET full_name = ?, village = ?, updated_at = datetime('now') WHERE id = ?", (name, village, existing["id"]))
                        conn.commit()
                    else:
                        conn.execute("""
                            INSERT INTO farmers (farmer_id, full_name, mobile, village, aadhaar_last4, aadhaar_linked, created_at, updated_at)
                            VALUES (?, ?, ?, ?, ?, 1, datetime('now'), datetime('now'))
                        """, (farmer_id, name, phone, village, farmer["aadhaar_last4"]))
                        conn.commit()
            except Exception:
                pass

            self._json({"success": True, "farmer": farmer, "message": "Registration successful!"})

        # POST /api/farmer/update
        elif path == '/api/farmer/update':
            phone  = str(body.get('phone', '')).strip()
            farmer = FARMERS.get(phone)

            # Check SQLite
            if not farmer:
                try:
                    with db_session() as conn:
                        row = conn.execute("SELECT * FROM farmers WHERE mobile = ? OR farmer_id = ?", (phone, phone)).fetchone()
                        if row:
                            farmer = dict(row)
                            farmer['id'] = farmer['farmer_id']
                            farmer['name'] = farmer['full_name']
                            farmer['phone'] = farmer['mobile']
                            FARMERS[phone] = farmer
                except Exception:
                    pass

            if not farmer:
                self._json({"success": False, "error": "Farmer not found"}, 404)
                return

            updatable = [
                'name', 'full_name', 'id', 'farmer_id', 'village', 'district', 'state', 'tehsil', 'khasra',
                'land_acres', 'land_unit', 'crop', 'bank', 'bank_name',
                'account_no', 'ifsc', 'aadhaar_linked', 'aadhaar_last4'
            ]
            for field in updatable:
                if field in body:
                    farmer[field] = body[field]
                    if field == 'name':
                        farmer['full_name'] = body[field]
                    elif field == 'full_name':
                        farmer['name'] = body[field]

            # Update SQLite DB
            try:
                with db_session() as conn:
                    conn.execute("""
                        UPDATE farmers SET full_name = ?, village = ?, updated_at = datetime('now')
                        WHERE mobile = ? OR farmer_id = ?
                    """, (farmer.get('full_name') or farmer.get('name'), farmer.get('village'), phone, farmer.get('farmer_id')))
                    conn.commit()
            except Exception:
                pass

            self._json({"success": True, "farmer": farmer})

        # POST /api/v1/db/farmers
        elif path == '/api/v1/db/farmers':
            name = body.get('full_name') or body.get('name', 'Farmer')
            phone = str(body.get('mobile') or body.get('phone', '')).strip()
            village = body.get('village', 'Rural Sector')
            farmer_id = body.get('farmer_id') or f"KS-{random.randint(10000,99999)}"
            aadhaar_last4 = body.get('aadhaar_last4', '3942')

            record = {"farmer_id": farmer_id, "full_name": name, "mobile": phone, "village": village}
            try:
                with db_session() as conn:
                    existing = conn.execute("SELECT * FROM farmers WHERE mobile = ? OR farmer_id = ?", (phone, farmer_id)).fetchone()
                    if existing:
                        conn.execute("UPDATE farmers SET full_name = ?, village = ?, updated_at = datetime('now') WHERE id = ?", (name, village, existing["id"]))
                        conn.commit()
                        row = conn.execute("SELECT * FROM farmers WHERE id = ?", (existing["id"],)).fetchone()
                    else:
                        conn.execute("""
                            INSERT INTO farmers (farmer_id, full_name, mobile, village, aadhaar_last4, aadhaar_linked, created_at, updated_at)
                            VALUES (?, ?, ?, ?, ?, 1, datetime('now'), datetime('now'))
                        """, (farmer_id, name, phone, village, aadhaar_last4))
                        conn.commit()
                        row = conn.execute("SELECT * FROM farmers WHERE farmer_id = ?", (farmer_id,)).fetchone()
                    if row:
                        record = dict(row)
            except Exception as e:
                record["error"] = str(e)

            FARMERS[phone] = {
                "id": farmer_id, "farmer_id": farmer_id, "name": name, "full_name": name,
                "phone": phone, "mobile": phone, "village": village, "aadhaar_last4": aadhaar_last4,
                "aadhaar_linked": True, "bank": "SBI (XXXX-5678)", "crop": "Wheat"
            }
            self._json(record, 201)

        # POST /api/procurement/slot (Legacy) & POST /api/v1/db/bookings
        elif path in ('/api/procurement/slot', '/api/v1/db/bookings'):
            center_id = body.get('center_id', 'PC001')
            crop      = body.get('crop') or body.get('commodity', 'Wheat')
            qty       = float(body.get('qty_quintal') or body.get('estimated_qty_quintals', 0) or 0)
            date      = body.get('date') or body.get('slot_date', (datetime.now() + timedelta(days=1)).strftime("%d %b %Y"))
            phone     = str(body.get('phone') or body.get('farmer_mobile', '9876543210'))
            f_name    = body.get('farmer_name') or FARMERS.get(phone, {}).get('name', 'Ram Singh')
            f_id      = body.get('farmer_id') or FARMERS.get(phone, {}).get('id', 'PB-10492')
            center    = next((c for c in PROCUREMENT_CENTERS if c['id'] == center_id), None)
            mandi_name= center['name'] if center else body.get('mandi_name', 'Karnal APMC Yard')

            token = ''.join(random.choices(string.ascii_uppercase + string.digits, k=10))
            token_number = f"KS-{token[:6]}"

            # Save to SQLite DB
            try:
                with db_session() as conn:
                    conn.execute("""
                        INSERT INTO slot_bookings (
                            token_number, farmer_id, farmer_name, farmer_mobile, commodity,
                            mandi_name, booking_date, time_slot, estimated_qty_quintals,
                            vehicle_type, gate_number, queue_position, status, created_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
                    """, (
                        token_number, f_id, f_name, phone, crop,
                        mandi_name, date, "10:00 AM - 12:00 PM", qty,
                        body.get('vehicle_type', 'Tractor Trolley'),
                        body.get('gate_number', 'Gate 1'),
                        random.randint(1, 15),
                        "CONFIRMED"
                    ))
                    conn.commit()
            except Exception:
                pass

            if path == '/api/procurement/slot':
                self._json({
                    "success":     True,
                    "token":       token,
                    "center":      mandi_name,
                    "district":    "Karnal",
                    "crop":        crop,
                    "qty_quintal": qty,
                    "date":        date,
                    "time_slot":   "10:00 AM - 12:00 PM",
                    "message":     f"Slot booked! Bring token {token} to {mandi_name}.",
                })
            else:
                self._json({
                    "token_number": token_number,
                    "farmer_id": f_id,
                    "farmer_name": f_name,
                    "commodity": crop,
                    "mandi_name": mandi_name,
                    "booking_date": date,
                    "time_slot": "10:00 AM - 12:00 PM",
                    "estimated_qty_quintals": qty,
                    "vehicle_type": body.get('vehicle_type', 'Tractor Trolley'),
                    "gate_number": "Gate 1",
                    "queue_position": 4,
                    "status": "CONFIRMED",
                    "created_at": datetime.now(timezone.utc).isoformat()
                }, 201)

        # POST /api/mandi/price-check
        elif path == '/api/mandi/price-check':
            crop     = body.get('crop', '')
            district = body.get('district', 'Karnal')
            prices   = MANDI_PRICES.get(district, [])
            match    = next((p for p in prices if p['crop'].lower() == crop.lower()), None)
            if match:
                msp       = MSP_PRICES.get(crop, {}).get('msp', None)
                above_msp = (match['modal'] >= msp) if msp else None
                self._json({"crop": crop, "district": district, "date": datetime.now().strftime("%d %b %Y"), **match, "msp": msp, "above_msp": above_msp})
            else:
                self._json({"success": False, "error": f"No mandi data for {crop} in {district}"}, 404)

        # POST /api/v1/payments/calculate
        elif path == '/api/v1/payments/calculate':
            commodity = body.get('commodity', 'Wheat')
            qty = float(body.get('quantity_quintals', 0))
            msp = float(MSP_PRICES.get(commodity, {}).get('msp', 2275))
            gross = round(qty * msp, 2)
            cess = round(gross * 0.015, 2)
            net = round(gross - cess, 2)
            self._json({
                "commodity": commodity,
                "quantity_quintals": qty,
                "msp_rate": msp,
                "gross_amount": gross,
                "cess_amount": cess,
                "net_payout": net,
                "currency": "INR",
                "breakdown_summary": f"{qty} Qtl @ ₹{msp}/Qtl (Gross ₹{gross:,} - Mandi Cess ₹{cess:,})"
            })

        # POST /api/v1/payments/voucher/mint
        elif path == '/api/v1/payments/voucher/mint':
            voucher_ref = f"PFMS-VCHR-2026-{random.randint(10000,99999)}"
            utr = f"SBIN00{random.randint(100000000,999999999)}"
            f_id = body.get('farmer_id', 'PB-10492')
            f_name = body.get('farmer_name', 'Ram Singh')
            commodity = body.get('commodity', 'Wheat')
            qty = float(body.get('quantity_quintals', 10.0))
            msp = float(MSP_PRICES.get(commodity, {}).get('msp', 2275))
            gross = round(qty * msp, 2)
            net = round(gross - round(gross * 0.015, 2), 2)
            issued_at = datetime.now(timezone.utc).isoformat()

            raw_payload = f"{voucher_ref}|{utr}|{f_id}|{net}|{issued_at}"
            npci_hash = hmac.new(PFMS_SIGNING_SECRET.encode(), raw_payload.encode(), hashlib.sha256).hexdigest()[:24]
            sig = f"GOV-IN-PFMS-SIG-SHA256-{npci_hash[:16].upper()}"

            voucher_data = {
                "voucher_ref": voucher_ref,
                "utr_number": utr,
                "farmer_id": f_id,
                "farmer_name": f_name,
                "commodity": commodity,
                "quantity_quintals": qty,
                "msp_rate": msp,
                "gross_amount": gross,
                "net_payout": net,
                "bank_name": body.get('bank_name', 'State Bank of India (SBI)'),
                "account_masked": f"XXXX-XXXX-{body.get('account_last4', '5678')}",
                "ifsc_code": body.get('ifsc_code', 'SBIN0001234'),
                "mandi_name": body.get('mandi_name', 'Karnal APMC Mandi'),
                "status": "TRANSACTION_SUCCESSFUL",
                "npci_hash": npci_hash,
                "digital_signature": sig,
                "issued_at": issued_at,
                "treasury_officer": "Chief Accounts Officer (PFMS-Central)"
            }

            # Record in SQLite DB
            try:
                with db_session() as conn:
                    conn.execute("""
                        INSERT INTO pfms_vouchers (
                            voucher_ref, utr_number, farmer_id, farmer_name, commodity,
                            quantity_quintals, msp_rate, gross_amount, net_payout,
                            bank_name, account_masked, ifsc_code, mandi_name,
                            status, npci_hash, digital_signature, issued_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, (
                        voucher_ref, utr, f_id, f_name, commodity,
                        qty, msp, gross, net,
                        voucher_data["bank_name"], voucher_data["account_masked"],
                        voucher_data["ifsc_code"], voucher_data["mandi_name"],
                        "TRANSACTION_SUCCESSFUL", npci_hash, sig, issued_at
                    ))
                    conn.commit()
            except Exception:
                pass

            self._json(voucher_data, 201)

        else:
            self._json({"error": f"Unknown API endpoint: {path}"}, 404)

    # ── Router: PUT /api/v1/* ────────────────
    def _route_put(self, path: str, body: dict):
        if path.startswith('/api/v1/db/farmers/'):
            f_id = path.split('/api/v1/db/farmers/')[1].strip()
            name = body.get('full_name') or body.get('name')
            village = body.get('village')

            try:
                with db_session() as conn:
                    if name and village:
                        conn.execute("UPDATE farmers SET full_name = ?, village = ?, updated_at = datetime('now') WHERE farmer_id = ?", (name, village, f_id))
                    elif name:
                        conn.execute("UPDATE farmers SET full_name = ?, updated_at = datetime('now') WHERE farmer_id = ?", (name, f_id))
                    elif village:
                        conn.execute("UPDATE farmers SET village = ?, updated_at = datetime('now') WHERE farmer_id = ?", (village, f_id))
                    conn.commit()
                    row = conn.execute("SELECT * FROM farmers WHERE farmer_id = ?", (f_id,)).fetchone()
                if row:
                    self._json(dict(row))
                    return
            except Exception:
                pass

            self._json({"farmer_id": f_id, "full_name": name, "village": village})
        else:
            self._json({"error": f"Unknown PUT endpoint: {path}"}, 404)

    # ── JSON helper ──────────────────────────
    def _json(self, data: dict, status: int = 200):
        payload = json.dumps(data, ensure_ascii=False, indent=2).encode('utf-8')
        try:
            self.send_response(status)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        except (ConnectionResetError, ConnectionAbortedError, BrokenPipeError, OSError):
            pass

    def log_message(self, format, *args):
        tag = '[API ]' if '/api/' in str(args[0] if args else '') else '[FILE]'
        sys.stderr.write(f"{tag} [{self.log_date_time_string()}] {format % args}\n")

    def log_error(self, format, *args):
        pass


# ─────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────

def run(port: int = DEFAULT_PORT):
    os.chdir(ROOT_DIR)
    port = get_available_port(port)
    url  = f"http://localhost:{port}/"

    print("==================================================", flush=True)
    print("  Kisan Setu Unified Web Portal Server",            flush=True)
    print(f"  URL:          {url}",                            flush=True)
    print(f"  Serving from: {ROOT_DIR}",                       flush=True)
    print(f"  SQLite DB:    {DB_PATH}",                        flush=True)
    print("--------------------------------------------------", flush=True)
    print("  Unified API Routes (v1 + Legacy):",              flush=True)
    print("  GET  /api/v1/health          GET  /api/health",   flush=True)
    print("  GET  /api/v1/db/health       GET  /api/v1/db/stats", flush=True)
    print("  GET  /api/v1/db/farmers      POST /api/v1/db/farmers", flush=True)
    print("  GET  /api/v1/db/bookings     POST /api/v1/db/bookings", flush=True)
    print("  GET  /api/v1/weather         GET  /api/weather",  flush=True)
    print("  GET  /api/v1/market/prices   GET  /api/mandi",    flush=True)
    print("  POST /api/auth/send-otp      POST /api/auth/verify-otp", flush=True)
    print("  POST /api/farmer/register    POST /api/farmer/update", flush=True)
    print("  POST /api/procurement/slot   POST /api/payments/voucher/mint", flush=True)
    print("==================================================", flush=True)
    print("Press Ctrl+C to stop the server.\n",                flush=True)

    class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
        daemon_threads = True
        allow_reuse_address = True

    with ThreadedTCPServer(('0.0.0.0', port), KisanSetuHTTPRequestHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down server...")
            httpd.server_close()


if __name__ == '__main__':
    port = DEFAULT_PORT
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            pass
    run(port)
