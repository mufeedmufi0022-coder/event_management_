# Event Management MVP (Stage-2)

A premium, production-ready Event Management platform built with **Flutter** and **Firebase**. This stage introduces advanced lifecycles, stability controls, and professional scale features.

## 🚀 Tech Stack
- **Frontend**: Flutter (v3.9.2 sdk)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Maps & Location**: FlutterMap + Nominatim Search API
- **Calendar**: Table Calendar (for Vendor Availability)
- **Media**: Image Picker + Firebase Storage

---

## 🎭 Advanced Lifecycle & Roles

### 👤 User (Organizer)
- **Enhanced Event Tracking**:
    - **Draft → Active → Completed → Archived**: Manage the full journey of an event.
    - **Status Badges**: Real-time visual indicators of event progress.
    - **Timeline View**: Separate 'Active' and 'Past' segments for clutter-free management.
- **Dynamic Booking Flow**:
    - **Request → Quote → Transact**: Request services and receive formal quotations.
    - **Quotation Review**: Accept or Reject vendor quotes with one-tap actions.
- **Smart Discovery**:
    - **Availability Awareness**: Only book vendors who are not "Blocked" on your event date.
- **Communication Controls**:
    - **Booking-Locked Chat**: Messaging only enables once a booking request is initiated.

### 🏪 Vendor (Service Provider)
- **Availability Management**:
    - **Calendar Control**: Integrated Table-Calendar to mark dates as 'Available' or 'Blocked'.
    - **Validation**: System automatically prevents booking requests on blocked dates.
- **Professional Quotation System**:
    - **Submit Quotes**: Send formal pricing and detailed notes to users.
    - **Quotation Immutability**: Once accepted, quotes are fixed to ensure trust.
- **Lifecycle Management**:
    - **Accepted → Completed**: Update booking status as the service is delivered.
    - **Automated Archive**: Completed bookings move to a dedicated history section.
- **Smart Communication**:
    - **Read-Only Mode**: Chats automatically lock after a booking is finalized or cancelled.

### 🛡️ Admin (System Governance)
- **Global Audit Logs**:
    - **Real-time Feed**: A centralized stream of every status change, approval, and cancellation.
    - **Transparency**: Every action logs the Actor ID and precise timestamp.
- **Conflict & Error Resolution**:
    - **Manual Override**: Admins can force-update any booking status for dispute resolution.
    - **Visibility**: Access to a global registry of all events and bookings.
- **Data Integrity**:
    - **Soft Delete System**: Implemented `isActive: false` across Users, Vendors, and Events to preserve audit trails while cleaning the UI.

---

## 🏗️ System Architecture (Stage-2)

### 📂 Models & Schema
- **EventModel**: Extended with `status` and `isActive` flags.
- **BookingModel**: Enhanced with `expiresAt`, `quotePrice`, `quoteNote`, and multi-stage status.
- **VendorModel**: Integrated `availability` map (Date string to status).
- **LogModel**: New schema for system-wide audit logging.

### ⚡ Services & Providers
- **NotificationService**: Architecture ready for FCM (Push Notifications).
- **Audit Logging**: Integrated into all services (`UserService`, `VendorService`, `AdminService`).
- **Access Control**: Logic in `ChatService` to enforce communication boundaries.

---

## ✨ Design & Experience
- **Branding**: Consistent deep purple (#904CC1) accentuation throughout the app.
- **Micro-interactions**: Smooth transitions between dashboard tabs and custom floating notifications.
- **Stability**: `PopScope` integration guards against accidental app exits.

---

## ⚙️ Development Setup
1.  **Dependencies**: Run `flutter pub get` to install `table_calendar`, `provider`, and Firebase plugins.
2.  **Firebase**: Ensure `google-services.json` is in `android/app/`.
3.  **Run**: Execute `flutter run` for live testing.

---
*Developed for Lifecycle, Stability & Scale.*
