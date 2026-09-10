# Agent Instructions — Farmer Procurement Platform (SIH26032)

This file guides any AI coding agent working in this repository.

## Project Context
Read `handover.md` first for the problem statement, solution overview, and architecture. Read `todo.md` for the current build plan and task order.

## Tech Stack
- Mobile app: **Flutter**
- Backend: **Node.js** (REST API)
- Database: **MongoDB**
- SMS / IVR: **Twilio**
- Push notifications: **Firebase Cloud Messaging**
- Payments: **Razorpay** (demo)
- Hosting: **AWS**

## Conventions
- Keep the queue/token logic in the server as the single source of truth
- All farmer-identifying data (Aadhaar, mobile number) must be masked in logs
- Every notification trigger should go through one notification service module
- Write API changes consistently with states defined in `handover.md`
