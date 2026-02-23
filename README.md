# 🌟 Event Management MVP - Stage 2

A premium, production-ready Event Management platform built with **Flutter** and **Firebase**. This stage introduces advanced lifecycles, stability controls, professional-scale features, and comprehensive documentation.

---

## 📖 Table of Contents
- [🚀 Tech Stack](#-tech-stack)
- [📊 System Architecture](#-system-architecture)
- [🎭 User Roles & Lifecycles](#-user-roles--lifecycles)
- [🏗️ Schema & Models](#️-schema--models)
- [✨ Design & Experience](#-design--experience)
- [⚙️ Development Setup](#️-development-setup)
- [📜 Project Documentation](#-project-documentation)

---

## 🚀 Tech Stack
- **Frontend**: Flutter (v3.9.2 sdk)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider (Clean Architecture approach)
- **Maps & Location**: FlutterMap + Nominatim Search API
- **Calendar**: Table Calendar (for Vendor Availability)
- **Media**: Image Picker + Firebase Storage

---

## 📊 System Architecture & Diagrams

### 1. Entity-Relationship (ER) Diagram
The following diagram illustrates the complete database schema, including all properties, data types, and complex relationships.

```mermaid
erDiagram
    %% Core Entities
    USER ||--o{ EVENT : "organizes"
    USER ||--o{ BOOKING : "requests"
    USER ||--o{ CHAT : "participates"
    USER ||--o{ LOG : "triggers"
    
    VENDOR ||--o{ PRODUCT : "manages"
    VENDOR ||--o{ BOOKING : "fulfills"
    VENDOR ||--o{ CHAT : "participates"
    
    EVENT ||--o{ BOOKING : "contains"
    
    PRODUCT ||--o{ RATING : "receives"
    
    CHAT ||--o{ MESSAGE : "contains"

    %% Attribute Definitions
    USER {
        string uid PK
        string name "Full name"
        string email "Unique email"
        string role "'user', 'vendor', 'admin'"
        string status "'pending', 'approved', 'blocked'"
        boolean isActive "Soft delete flag"
        string businessName "Vendor only"
        string location "Vendor only"
        string priceRange "Vendor only"
        string description "Vendor only"
        string contactNumber "Phone"
        list images "Gallery URLs"
        string logoUrl "Profile/Brand image"
        string currentAddress "Geocoded address"
        double latitude
        double longitude
    }

    VENDOR {
        string vendorId PK
        string businessName
        string location
        string priceRange
        string description
        string contactNumber
        list images
        string logoUrl
        string status "'pending', 'approved'"
        map availability "YYYY-MM-DD -> status"
        boolean isActive
    }

    PRODUCT {
        string name PK
        string price
        list images
        int capacity "Person limit"
        string mobileNumber
        string location
        string priceType "'fixed', 'per_person'"
        string categoryType "'car', 'catering', etc."
        string subType "'premium', 'buffet', etc."
        list blockedDates "Exclusion dates"
        list bookedDates "Confirmed dates"
        double latitude
        double longitude
    }

    EVENT {
        string eventId PK
        string userId FK
        string eventName
        string eventType "Wedding, Birthday, etc."
        string date "ISO String"
        string location
        string status "'draft', 'active', 'completed', 'archived'"
        boolean isActive
    }

    BOOKING {
        string bookingId PK
        string userId FK
        string vendorId FK
        string eventId FK "Optional"
        string status "'requested', 'quoted', 'accepted', 'completed'"
        datetime bookingDate
        string occasion
        datetime expiresAt "Quote expiry"
        string quotePrice
        string quoteNote
        string productName
        string productImage
        boolean hasFeedback
        boolean isActive
    }

    RATING {
        string userName
        string comment
        double stars "1.0 - 5.0"
        datetime timestamp
    }

    CHAT {
        string chatId PK
        list participants "List of user UIDs"
        string lastMessage
        datetime lastTimestamp
    }

    MESSAGE {
        string senderId FK
        string content
        datetime timestamp
    }

    LOG {
        string id PK
        string type "'event', 'booking', 'system'"
        string action "Description of event"
        string actorId FK
        datetime timestamp
    }
```

---

### 2. Data Flow Diagram (DFD)
This diagram details the flow of data through the Event Management system across all logical layers.

#### Level 1: Core Process Breakdown
```mermaid
graph TD
    subgraph "External Entities"
        User(User)
        Vendor(Vendor)
        Admin(Admin)
    end

    subgraph "Logic Layer"
        P1[1.0 Auth & Persona]
        P2[2.0 Geocoding & Discovery]
        P3[3.0 Booking & Negotiation]
        P4[4.0 Chat & Notify]
        P5[5.0 Audit & Analytics]
    end

    subgraph "Data Persistence"
        D1[(User/Vendor Profile)]
        D2[(Event Registry)]
        D3[(Booking Ledger)]
        D4[(Chat Logs)]
        D5[(System Audit Log)]
    end

    %% Auth & Persona
    User -->|Reg Info| P1
    Vendor -->|Business Docs| P1
    P1 -->|Store| D1
    D1 -->|Role Permissions| P2 & P3 & P5

    %% Discovery
    User -->|Location/Category Query| P2
    P2 -->|External API| MAP((OSM API))
    MAP -->|Lat/Lng| P2
    P2 -->|Indexed Search| D1
    D1 -->|Vendor List| User

    %% Booking Negotiation
    User -->|Booking Request| P3
    P3 -->|Check Availability| D1
    P3 -->|Commit| D3
    D3 -->|Signal| Vendor
    Vendor -->|Quote & Price| P3
    P3 -->|Update| D3
    D3 -->|Decision| User

    %% Communication
    User & Vendor -->|Locked Messaging| P4
    P4 -->|Constraint Check| D3
    P4 -->|Persistent Store| D4

    %% Governance
    P1 & P3 & P4 -->|Action Metadata| P5
    P5 -->|Write| D5
    Admin -->|Query Logs| D5
    Admin -->|Manual State Change| P3
```

---

## 🎭 User Roles & Lifecycles

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

### 🛡️ Admin (System Governance)
- **Global Audit Logs**:
    - **Real-time Feed**: A centralized stream of every status change, approval, and cancellation.
    - **Transparency**: Every action logs the Actor ID and precise timestamp.
- **Conflict & Error Resolution**:
    - **Manual Override**: Admins can force-update any booking status for dispute resolution.
- **Data Integrity**:
    - **Soft Delete System**: Implemented `isActive: false` across Users, Vendors, and Events to preserve audit trails.

---

## 🏗️ Schema & Models
- **EventModel**: Extended with `status` and `isActive` flags.
- **BookingModel**: Enhanced with `expiresAt`, `quotePrice`, `quoteNote`, and multi-stage status.
- **VendorModel**: Integrated `availability` map (Date string to status).
- **LogModel**: New schema for system-wide audit logging.
- **Audit Logging**: Integrated into all services (`UserService`, `VendorService`, `AdminService`).

---

## ✨ Design & Experience
- **Branding**: Consistent deep purple (#904CC1) accentuation throughout the app.
- **Micro-interactions**: Smooth transitions between dashboard tabs and custom floating notifications.
- **UI/UX Stability**: `PopScope` integration guards against accidental app exits.

---

## ⚙️ Development Setup
1.  **Dependencies**: Run `flutter pub get`.
2.  **Firebase**: Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is correctly placed.
3.  **Run**: Execute `flutter run`.

---
*Developed for Lifecycle, Stability & Scale.*

