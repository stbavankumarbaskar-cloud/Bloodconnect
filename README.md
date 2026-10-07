# 🩸 BloodConnect - Production-Ready Blood Donor Search App

**BloodConnect** is a healthcare mobile application designed to connect voluntary blood donors and emergency patients in real-time.

---

## 🛠️ Technology Stack

| Layer | Technology | Details |
|---|---|---|
| **Mobile Frontend** | **Flutter** (Dart 3) | Material 3, Clean Architecture, Healthcare Design System |
| **Backend** | **PHP 8.1 REST API** | PDO Prepared Statements, JSON Responses, CORS, Token Authentication |
| **Database** | **MySQL** (XAMPP) | Database: `bloodconnect_db` (Port: 3305 / 3306) |
| **Local Web Server** | **Apache** (XAMPP) | Running on Port 80 (`http://localhost/bloodconnect/`) |
| **Live Map** | **OpenStreetMap + Leaflet** | Keyless OpenStreetMap tiles with `flutter_map` & `latlong2` |

---

## 📁 Project Architecture

```text
New-app/
├── backend/                              # PHP REST API Backend
│   ├── api/
│   │   ├── auth/
│   │   │   ├── check-mobile.php          # Verify existing or new donor
│   │   │   ├── login.php                 # Authenticate & issue bearer session token
│   │   │   ├── register.php              # Multi-field donor registration
│   │   │   └── logout.php                # Revoke session token
│   │   ├── donors/
│   │   │   ├── list.php                  # Filtered list of donors with eligibility & distance
│   │   │   ├── details.php               # Single donor profile & donation history
│   │   │   ├── nearby.php                # Coordinate radius calculation (5 KM default)
│   │   │   └── update-status.php         # Update availability (Available, Busy, Unavailable)
│   │   ├── search/
│   │   │   ├── manual.php                # Hierarchical location search (India -> State -> District -> Area -> Pincode)
│   │   │   └── live-location.php         # Live GPS search using Haversine distance
│   │   ├── profile/
│   │   │   ├── get.php                   # Get authenticated user profile
│   │   │   ├── update.php                # Edit profile details
│   │   │   └── upload-photo.php          # Profile picture upload
│   │   ├── requests/
│   │   │   ├── list.php                  # Emergency blood requests list (Active / My Requests)
│   │   │   ├── create.php                # Post new emergency request & alert matching donors
│   │   │   └── update.php                # Update request status (Fulfilled / Cancelled)
│   │   ├── notifications/
│   │   │   ├── list.php                  # Fetch unread notifications
│   │   │   └── read.php                  # Mark as read
│   │   └── history/
│   │       ├── list.php                  # Donor history log
│   │       └── add.php                   # Add donation & auto-update last donation date
│   ├── config/
│   │   └── database.php                  # PDO connection with automatic port fallback (3305/3306)
│   ├── helpers/
│   │   ├── response.php                  # JSON standard response, CORS headers, Haversine formula
│   │   └── auth.php                      # Bearer token validation
│   ├── uploads/profiles/                 # Uploaded avatar images
│   └── .htaccess                         # Apache routing & CORS headers
│
├── database/
│   └── bloodconnect.sql                  # Complete MySQL schema & realistic seed data
│
├── donor_search/                         # Flutter Mobile Application
│   ├── lib/
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # Healthcare Red palette & status colors
│   │   │   ├── app_constants.dart        # Blood groups, Indian states & districts, 6-month threshold
│   │   │   └── api_endpoints.dart        # Multi-platform base URL resolver
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── donor_model.dart
│   │   │   ├── request_model.dart
│   │   │   ├── notification_model.dart
│   │   │   └── history_model.dart
│   │   ├── services/
│   │   │   ├── api_service.dart          # HTTP Client with Bearer token authentication
│   │   │   └── storage_service.dart      # SharedPreferences session persistence
│   │   ├── components/
│   │   │   ├── blood_drop_logo.dart      # Animated blood drop & heartbeat icon
│   │   │   ├── custom_button.dart        # Rounded healthcare buttons
│   │   │   ├── custom_text_field.dart    # Medical styled text inputs
│   │   │   ├── donor_card.dart           # Donor card with Call & WhatsApp CTAs
│   │   │   ├── blood_request_card.dart   # Urgency-colored emergency request card
│   │   │   └── donor_map_popup.dart      # Map marker bottom sheet popup
│   │   ├── screens/
│   │   │   ├── splash/splash_screen.dart
│   │   │   ├── login/login_screen.dart
│   │   │   ├── register/register_screen.dart
│   │   │   ├── home/home_screen.dart
│   │   │   ├── search/search_screen.dart
│   │   │   ├── map/map_screen.dart
│   │   │   ├── requests/requests_screen.dart
│   │   │   ├── requests/create_request_screen.dart
│   │   │   ├── profile/profile_screen.dart
│   │   │   ├── profile/edit_profile_screen.dart
│   │   │   ├── settings/settings_screen.dart
│   │   │   └── settings/donation_history_screen.dart
│   │   ├── navigation/
│   │   │   └── main_navigation_screen.dart  # 5-Tab Bottom Navigation
│   │   └── main.dart                     # Theme & Entrypoint
│   └── test/widget_test.dart
│
├── .env.example                          # Environment template
└── README.md
```

---

## 🗄️ Database Setup (XAMPP MySQL)

1. **Start Apache and MySQL in the XAMPP Control Panel.**
   - Note: In this XAMPP installation, MySQL is configured on port **3305**.
2. **Import the SQL database** by running the following in PowerShell:

```powershell
# Automated import script
Get-Content "e:\Bavan\Company-project\New-app\database\bloodconnect.sql" | & "C:\xampp\mysql\bin\mysql.exe" -u root -P 3305
```

> The database `bloodconnect_db` is created and populated with 10 sample donors in Madurai, Tamil Nadu.

---

## 🚀 Backend Deployment (XAMPP Apache)

The backend is deployed to:

```text
C:\xampp\htdocs\bloodconnect\backend
```

### Base URLs by Client

```text
Web Browser / Chrome        : http://127.0.0.1/bloodconnect/backend
Android Emulator            : http://10.0.2.2/bloodconnect/backend
Physical Android (Wi-Fi)    : http://192.168.1.49/bloodconnect/backend
```

### Test Endpoints

```bash
# Donors List
curl http://127.0.0.1/bloodconnect/backend/api/donors/list.php

# Nearby Donors (5 KM radius around Madurai center 9.9252, 78.1198)
curl "http://127.0.0.1/bloodconnect/backend/api/donors/nearby.php?latitude=9.9252&longitude=78.1198&radius=5"

# Check Mobile
curl -X POST http://127.0.0.1/bloodconnect/backend/api/auth/check-mobile.php -d "{\"mobile_number\":\"9876543210\"}"
```

---

## 📱 Running the Flutter Application

Navigate to the Flutter directory:

```bash
cd e:\Bavan\Company-project\New-app\donor_search
```

```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on connected physical Android device (SM M315F)
flutter run -d RZ8N70NAP5D

# Run on Edge
flutter run -d edge
```

---

## 🩸 Core Features Implemented

### 1. Authentication Flow
- `+91` Indian mobile number validation.
- Automatically checks `/api/auth/check-mobile.php`.
- **Existing user** → instantly logged in with a session token.
- **New user** → phone pre-filled, full registration form opens.
- Pre-seeded test accounts:

```text
9876543210  ->  Karthik Raja       (O+)
9876543211  ->  Priya Dharshini    (A+)
9876543212  ->  Senthil Kumar      (B+)
```

### 2. Dashboard (Home)
- Greeting, unread notifications badge, blood group avatar.
- Quick blood group filter chips: `A+`, `A-`, `B+`, `B-`, `O+`, `O-`, `AB+`, `AB-`.
- Live donor count & impact statistics.
- Emergency blood request carousel with contact-family action.
- Nearby donor cards with direct **Call** (`tel:`) and **WhatsApp** (`wa.me`) links.

### 3. Manual Hierarchical Search
- India → State (`Tamil Nadu`, `Kerala`, `Karnataka`, etc.) → District (`Madurai`, `Chennai`, `Coimbatore`, etc.) → Area → Pincode.
- Filter by Blood Group, Gender, Availability.

### 4. Live GPS Radius Search
- Real-time Haversine distance calculation.
- Interactive slider from 2 KM to 25 KM (5 KM default).
- Results sorted ascending by distance (e.g., `0.2 km away`, `1.4 km away`).

### 5. Interactive Live Map
- Built with **OpenStreetMap** (keyless, free, reliable).
- 5 KM translucent circular search zone overlay.
- 🔴 **Red marker**: last donation < 6 months ago (recently donated).
- 🟢 **Green marker**: last donation ≥ 6 months ago (potentially available).
- 📍 **Blue pin**: current user location.
- Tapping a pin opens the donor popup with photo, name, verified badge, blood group, distance, last donation date, Call and WhatsApp buttons.

### 6. Emergency Blood Requests
- Active Requests and My Requests tabs.
- "Post Emergency Request" form: Patient Name, Blood Group, Units, Hospital, Address, Urgency (Critical / Urgent / Standard), Description.
- Automatically broadcasts notifications to matching blood group donors in the district.

### 7. Donation History
- Log past donations with hospital name, date, location, and notes.
- Automatically recalculates eligibility date (`+3 months`) and updates the donor's status in MySQL.

### 8. Settings & Dynamic Server Config
- In-app modal to change the Backend API URL on the fly (useful when switching between Chrome, Android Emulator, and physical phones on Wi-Fi).

---

## 📄 License

This project is for educational and demonstration purposes.
