# ApnaSolar — Firebase Setup Guide

This document explains how to connect the ApnaSolar Flutter app to a real Firebase project.

---

## Prerequisites

| Tool | How to install |
|---|---|
| Node.js 18+ | https://nodejs.org |
| Firebase CLI | `npm install -g firebase-tools` ✅ already done |
| FlutterFire CLI | `dart pub global activate flutterfire_cli` ✅ already done |
| Flutter SDK | `C:\flutter_windows_3.44.6-stable\flutter` |

---

## Step 1 — Create the Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project** → Name it **apnasolar**
3. Disable Google Analytics (optional for MVP)
4. Click **Create project**

---

## Step 2 — Enable Firebase Services

Inside your new project:

### Authentication
1. Build → **Authentication** → Get started
2. Sign-in method → **Email/Password** → Enable → Save
3. Sign-in method → **Anonymous** → Enable → Save

### Cloud Firestore
1. Build → **Firestore Database** → Create database
2. Choose **Start in production mode** (rules are in `firestore.rules`)
3. Select a region close to India (e.g., `asia-south1`)

### Firebase Storage
1. Build → **Storage** → Get started
2. Start in production mode (rules are in `storage.rules`)
3. Same region as Firestore

---

## Step 3 — Configure the Flutter App

Run in the project root:

```powershell
# Login to Firebase
firebase login

# Configure Flutter app (adds google-services.json automatically)
C:\Users\htrip\AppData\Local\Pub\Cache\bin\flutterfire.bat configure --project=<your-project-id>
```

> Replace `<your-project-id>` with your Firebase project ID (visible in the Firebase Console URL or Project Settings).

This command will:
- Download `google-services.json` → `android/app/google-services.json`
- Regenerate `lib/firebase_options.dart` with real credentials
- Configure iOS/web if applicable

---

## Step 4 — Deploy Security Rules

```powershell
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

---

## Step 5 — Verify

```powershell
C:\flutter_windows_3.44.6-stable\flutter\bin\flutter.bat run
```

The app should:
1. Show the login screen (new users)
2. Allow registration / guest sign-in
3. Navigate through the full solar assessment flow
4. Save data to Firestore after each step
5. Load saved analysis on next app open

---

## Firestore Data Schema

```
users/
  {userId}/                       ← User profile doc
    properties/
      {propertyId}/               ← Location + property type
        rooftops/
          {rooftopId}/            ← Rooftop analysis + image URL
    analyses/
      {analysisId}/               ← Solar estimate + financial breakdown
```

---

## Storage Path

```
users/{userId}/properties/{propertyId}/rooftops/{rooftopId}/images/{timestamp}.jpg
```

---

## Feature Status

| Feature | Status |
|---|---|
| Email/Password Auth | ✅ Implemented |
| Anonymous Guest Auth | ✅ Implemented |
| Password Reset | ✅ Implemented |
| Session Persistence | ✅ Implemented (SharedPreferences + Firebase) |
| Property → Firestore | ✅ Implemented |
| Rooftop Analysis → Firestore | ✅ Implemented |
| Solar Estimate → Firestore | ✅ Implemented |
| Rooftop Image Upload | ✅ Implemented (Firebase Storage) |
| Load Last Analysis on Startup | ✅ Implemented |
| Firestore Security Rules | ✅ Written (deploy required) |
| Storage Security Rules | ✅ Written (deploy required) |
| Cloud Functions (Solar Engine) | 📋 Coming Soon (Phase 2) |
| Push Notifications | 📋 Coming Soon |
| Map / GPS Location | 📋 Coming Soon |
| Installer Booking | 📋 Coming Soon |
