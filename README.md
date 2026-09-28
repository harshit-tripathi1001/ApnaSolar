# ApnaSolar — AI-Powered Rooftop Solar Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.29.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFA611?logo=firebase)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-29%20Passed-brightgreen)](test/)
[![Analysis](https://img.shields.io/badge/flutter%20analyze-0%20issues-brightgreen)](lib/)

ApnaSolar is a state-of-the-art Flutter mobile application powered by Google Stitch visual designs and Firebase backend infrastructure. It provides end-to-end rooftop solar estimation, satellite boundary detection, AI irradiance simulation, PM Surya Ghar subsidy calculations, installer marketplace matching, and grid synchronization lifecycle tracking.

---

## Key Highlights

- **Stitch Design Fidelity**: Pixel-accurate implementation of all approved design tokens, Plus Jakarta Sans typography, card hierarchies, and micro-interactions.
- **Firebase Authentication**: Full email/password authentication and seamless anonymous guest onboarding.
- **Cloud Firestore**: Real-time write-through data persistence for user profiles, properties, rooftops, and solar analysis sessions.
- **Firebase Storage**: Secure cloud storage for satellite captures and mobile camera rooftop photos.
- **Responsive Layout**: Validated across small phones (360x640), standard phones (390x844), large phones (428x926), and tablets (768x1024) with zero overflows.
- **Comprehensive Quality Assurance**: 100% test pass rate across 29 unit, widget, and end-to-end integration tests.

---

## Complete End-to-End User Journey

```text
Welcome & Auth Gate
  ├── Register / Login / Anonymous Guest
  ↓
Home Dashboard
  ├── Property Selection & Active Metrics
  ↓
Location Confirmation
  ├── Map Pinning & Reverse Geocoding
  ↓
Property Details
  ├── Monthly Electricity Bill & Preset Tiers
  ↓
Rooftop Capture
  ├── Interactive Satellite Canvas / Camera Photo
  ↓
AI Rooftop Analysis
  ├── 3-Stage Scanning HUD & Obstacle Isolation
  ↓
Rooftop Result
  ├── Usable Area & Panel Layout Metrics
  ↓
Solar Recommendation & Financials
  ├── System Sizing Customizer (3.5 - 7.5 kW)
  ├── 25-Year Cash Flow & Payback Timeline
  ↓
Cost Breakdown & Subsidies
  ├── PM Surya Ghar Muft Bijli Yojana Central Subsidies
  ↓
Installer Marketplace & Official Audit Report
  ├── Verified Local Vendors & PDF Report Export
  ↓
Installation Lifecycle Tracker
  ├── DISCOM Net Metering Approval & Commissioning
  ↓
System Activation & Telemetry
```

---

## Project Structure

```text
lib/
├── app/
│   ├── apnasolar_app.dart          # MaterialApp configuration & named routes
│   └── auth_gate.dart               # Auth state router (Authenticated vs Welcome)
├── constants/
│   ├── app_colors.dart              # Stitch color palette tokens
│   ├── app_routes.dart              # Unified route registry
│   ├── app_spacing.dart             # Padding, margins & radii
│   └── app_typography.dart          # Plus Jakarta Sans type styles
├── models/                          # Data models (Property, Rooftop, Analysis, etc.)
├── screens/                         # All 20+ feature screens
│   ├── auth/                        # Login & Registration screens
│   ├── welcome/                     # Onboarding & Guest sign-in
│   ├── home/                        # Main dashboard
│   ├── location/                    # Map pin confirmation
│   ├── property/                    # Electricity consumption details
│   ├── roof_drawing/                # Satellite canvas polygon editor
│   ├── roof_photo/                  # Camera upload
│   ├── analysis/                    # AI vision pipeline scanner
│   ├── roof_result/                 # Area calibration & bifacial capacity
│   ├── recommendation/              # Financial analysis & system sizing
│   ├── cost_breakdown/              # Subsidies & DISCOM net metering
│   ├── equipment/                   # Tier-1 bifacial mono-PERC specs
│   ├── installers/                  # Vendor marketplace
│   ├── quotation/                   # Quotation analyzer & payment terms
│   ├── timeline/                    # Project milestone tracker
│   ├── solar_report/                # Technical audit PDF viewer
│   ├── project_dashboard/           # Active installations
│   └── activated/                   # Grid sync celebration
├── services/
│   ├── auth_service.dart            # FirebaseAuth singleton wrapper
│   ├── firestore_service.dart       # Typed Firestore collections & queries
│   ├── storage_service.dart         # Rooftop photo upload service
│   ├── solar_session_service.dart   # Firestore write-through + local cache
│   └── rooftop_analysis_service.dart# Photovoltaic & solar physics engine
└── widgets/                         # Reusable design components (cards, buttons, HUD)
```

---

## Verification & Testing

To run the complete verification suite:

```bash
# Check code hygiene and zero warnings
flutter analyze

# Run all 29 unit, widget, and responsiveness tests
flutter test

# Format all Dart source files
dart format .
```

---

## Firebase Setup

For production deployment to a physical Android device or iOS simulator:

1. Follow the steps in [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md).
2. Download your `google-services.json` from the Firebase Console and place it in `android/app/google-services.json`.
3. Deploy Firestore and Storage security rules:
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```
4. Run the application:
   ```bash
   flutter run
   ```
