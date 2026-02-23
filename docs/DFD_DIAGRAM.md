# Data Flow Diagram (DFD) - Process Logic & Details

This documentation details the flow of data through the Event Management system across all logical layers.

## Level 0: Global Context
The highest level of abstraction showing interactions with external entities.

```mermaid
graph TD
    U((User/Client))
    V((Vendor/Service))
    A((Admin/Gov))
    FS[(Firebase Cloud)]
    MAP[[OpenStreetMap/Nominatim]]

    U <-->|Events/Bookings| FS
    V <-->|Quotes/Availability| FS
    A <-->|Audit/Overrides| FS
    FS <-->|Reverse Geocoding| MAP
```

---

## Level 1: Core Process Breakdown
A detailed look at the functional modules and data movement.

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

## Level 2: Detailed Process Logic

### 1.0 Authentication & Role Resolution
- **Input**: Email, Password, Social Auth.
- **Processing**: Firebase Auth verifies credentials. `auth_provider.dart` fetches Firestore document to determine if the user is a `user`, `vendor`, or `admin`.
- **Output**: Role-based routing (e.g., `UserHomeScreen` vs `VendorDashboard`).

### 2.0 Spatial Discovery (Vendor Search)
- **Input**: User's search term or current GPS.
- **Processing**: 
    1. `location_helper.dart` calls Nominatim (OpenStreetMap) for reverse geocoding.
    2. Coordinates are matched against `VendorModel.latitude/longitude`.
    3. Results filtered by `categoryType` and `availability`.
- **Data Flow**: `Map API` → `Search Service` → `UI List`.

### 3.0 Booking & Negotiation Protocol
- **The "Request" Flow**: 
    - User checks Date. System validates `VendorModel.availability[date] != 'blocked'`.
- **The "Quotation" Flow**:
    - Vendor receives request. Attaches `quotePrice`. 
    - Data flow: `UI` → `VendorService.submitQuote()` → `Booking Ledger`.
- **Completion Flow**:
    - Vendor marks `completed`. 
    - System triggers `LogModel` entry and updates `Event Registry` status.

### 4.0 Secure Communication (Chat)
- **Data Guard**: `ChatService` checks `Booking Ledger` before allowing message writes.
- **Persistence**: Messages stored in sub-collections.
- **Flow**: `Sender` → `Validation Logic` → `Firestore` → `StreamBuilder` → `Receiver`.

### 5.0 Audit Trailing (The Logger)
- **Trigger**: Every `update`, `delete`, or `statusChange`.
- **Execution**: Logic in `AdminService` and `LogProvider` creates a `LogModel` with `ActorID` and `Timestamp`. 
- **Privacy**: Only accessible by users with `role == 'admin'`.
