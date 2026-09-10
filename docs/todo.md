# TODO — Real-Time Procurement Information System for Farmers (SIH26032)

## Phase 0: Setup
- [ ] Initialize repo structure: `/mobile` (Flutter), `/server` (Node.js), `/admin` (web dashboard)
- [ ] Set up MongoDB Atlas cluster (dev + prod)
- [ ] Provision AWS environment (EC2/ECS + S3 + basic VPC)
- [ ] Set up Firebase project (push notifications + auth option)
- [ ] Create Twilio account, get SMS + IVR sandbox numbers
- [ ] Create Razorpay test account
- [ ] Set up CI basics (lint + build on push)

## Phase 1: Farmer Registration & Auth
- [ ] Design farmer schema: name, mobile, Aadhaar (masked), village, crop type, land records ref
- [ ] Mobile OTP-based registration/login (Firebase Auth or custom + Twilio)
- [ ] Farmer profile screen (view/edit details, crop info)
- [ ] Admin-side farmer verification flow (optional, if manual approval needed)

## Phase 2: Procurement Schedule & Slot Booking
- [ ] Define procurement centre schema: location, capacity/hour, operating hours, crop types accepted
- [ ] API: list available centres + upcoming slots
- [ ] Slot allocation logic (based on centre capacity, avoid overbooking)
- [ ] Farmer UI: browse centres, pick date/time slot, confirm booking
- [ ] Reschedule / cancel booking flow with waitlist auto-fill

## Phase 3: Digital Token & Queue Management
- [ ] Generate QR/token on slot confirmation
- [ ] Check-in flow at centre (QR scan → token activated)
- [ ] Real-time queue state (Redis or MongoDB change streams)
- [ ] Live "current token being served" + estimated wait time
- [ ] Centre staff UI: call next token, mark served/no-show

## Phase 4: Notifications
- [ ] SMS integration (Twilio): booking confirmation, T-1 reminder, "your turn approaching"
- [ ] IVR flow for feature-phone farmers (status check-in by call)
- [ ] WhatsApp Business API or Twilio WhatsApp sandbox for notifications
- [ ] Push notifications via Firebase Cloud Messaging (app users)

## Phase 5: Procurement & Payment Tracking
- [ ] Record procurement transaction: quantity, quality grade, rate (MSP-linked), centre, timestamp
- [ ] Payment status states: Pending → Processing → Paid
- [ ] Razorpay/DBT integration for payment initiation + webhook for status updates
- [ ] Farmer-facing procurement + payment history screen
- [ ] Digital receipt generation (PDF or in-app)

## Phase 6: Admin / Department Dashboard
- [ ] Centre-wise live queue + booking overview
- [ ] Reports: daily/weekly procurement volume, avg wait time, no-show rate
- [ ] Payment delay tracking across centres
- [ ] Export reports (CSV/PDF)

## Phase 7: Testing & Deployment
- [ ] Unit tests for booking + queue logic
- [ ] Load test slot booking under concurrent requests
- [ ] Staging deployment on AWS
- [ ] Basic security review (OTP flow, data masking for Aadhaar, API auth)

## Phase 8: Demo Prep
- [ ] Seed demo data (sample centres, farmers, bookings)
- [ ] Record demo video / prepare live walkthrough
- [ ] Polish farmer app UI screens shown in prototype deck
