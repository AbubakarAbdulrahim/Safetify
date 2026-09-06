# Safetify — Mobile App

The resident-facing mobile client for **Safetify**, a real-time crowdsourced incident reporting and safety alert system built as a final year project at Bayero University, Kano (Case Study: Kano State, Nigeria). This is the app residents use to report incidents, see what's happening nearby, and receive safety alerts. The companion admin dashboard used by administrators to verify reports and push alerts lives in a [separate repo](https://github.com/AbubakarAbdulrahim/safetify2).

Built with Flutter, backed by Firebase.

## What it does

- **Report an incident** — submit a categorized, geo-tagged report with a photo, description, and location
- **Live incident map** — see nearby reports plotted on a map
- **Incident history** — browse past reports and their resolution status
- **Alerts & community updates** — receive push notifications for safety alerts and general community updates (safety, events, maintenance, info) in the area
- **AI assistant** — an in-app chat assistant (Gemini) that can answer questions about current incident activity, using live counts and stats pulled from Firestore
- **Account & profile** — registration, login, password recovery, profile and account settings
- **Support & legal** — help/support, privacy policy, and terms & conditions pages
- **Emergency contacts** — quick access to emergency numbers, with direct-call support

## Architecture

```
lib/
├── constants.dart          # App-wide constants
├── firebase_options.dart   # Firebase project configuration
├── initialization.dart     # App startup/init logic
├── main.dart
├── models/                 # Incident, Alert, CommunityUpdate, User
├── services/
│   ├── auth_service.dart          # Firebase Authentication
│   ├── firestore_service.dart     # Firestore reads/writes (incidents, alerts, updates)
│   ├── cloudinary_service.dart    # Image upload/hosting for incident photos
│   ├── gemini_service.dart        # AI assistant, backed by Google Gemini
│   ├── location_service.dart      # Device location + geocoding
│   ├── notification_service.dart  # Push notifications (FCM + local)
│   ├── theme_service.dart         # Light/dark theme handling
│   └── url_launcher_service.dart
├── pages/                  # Screens: startup, welcome, login, register, home,
│                            # report, details, map, incident_history, alerts,
│                            # community_updates, analytics, ai, profile,
│                            # account_settings, change_password, notification,
│                            # emergency_contacts, help_support, privacy,
│                            # terms_conditions, settings, about
└── widgets/                 # Shared UI: incident_card, alert_card, bottom_nav
```

Firestore is the backend of record for incidents, alerts, community updates, and user profiles. Incident photos are uploaded to Cloudinary rather than Firebase Storage directly, and push notifications are delivered through Firebase Cloud Messaging, with local notification handling on-device.

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter |
| Backend | Firebase (Auth, Cloud Firestore, Cloud Messaging, Storage) |
| Media | Cloudinary (incident photo upload/hosting) |
| Maps & location | Google Maps / flutter_map, geolocator, geocoding |
| AI | Google Gemini (`google_generative_ai`), grounded on live Firestore incident data |
| Notifications | firebase_messaging + flutter_local_notifications |
| Charts | fl_chart |

## Running locally

1. Clone the repo and check out this branch:
   ```
   git clone https://github.com/AbubakarAbdulrahim/Safetify.git
   cd Safetify
   git checkout backend
   cd users
   flutter pub get
   ```
2. Set up your own Firebase project (Authentication, Firestore, Cloud Messaging, Storage) and generate your own `firebase_options.dart` via `flutterfire configure` — do not reuse the credentials committed in this repo.
3. Provide your own Cloudinary and Gemini API credentials via environment variables or `--dart-define` rather than hardcoding them (see security note below).
4. Run the app:
   ```
   flutter run
   ```

> **Security note:** earlier commits on this branch had a Gemini API key hardcoded in `lib/services/gemini_service.dart`. If you're setting this up from a fork or clone, rotate that key and load it from a secure source (environment variable, `--dart-define`, or a backend proxy) instead of committing it to source control.

## Related repo

- Admin dashboard (used by administrators to verify reports and broadcast alerts): [safetify2](https://github.com/AbubakarAbdulrahim/safetify2)

## Project background

Safetify was developed as a final year project in the Faculty of Computing, Bayero University, Kano, evaluated through unit, integration, system, and usability testing — scoring 4.4/5.0 in usability testing with an average alert delivery latency of approximately 2.1 seconds. It's currently being extended into a research paper and forms the basis of ongoing graduate research proposals in mobile crowdsensing.
