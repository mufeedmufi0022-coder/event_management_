# Entity-Relationship (ER) Diagram - Complete Details

This diagram provides a comprehensive view of the database structure, including all properties, data types, and complex relationships.

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

## Detailed Data Structures

### 1. User/Vendor Hybrid Model
The platform uses a unified `UserModel` where roles are distinguished by the `role` field.
- **Users**: Focus on `uid`, `name`, `email`, and `role`.
- **Vendors**: Utilize extended fields like `businessName`, `products`, and `latitude/longitude`.

### 2. Product Architecture
Vendors don't just exist; they offer specific **Products** (Services).
- Each product maintains its own `blockedDates` and `bookedDates` to ensure no double-booking.
- Ratings are nested within products but aggregated at the Vendor level for `averageRating`.

### 3. Booking Lifecycle
The `BOOKING` entity is the most dynamic:
1. **Requested**: User sends a request for a Date + Occasion + Product.
2. **Quoted**: Vendor attaches `quotePrice` and `quoteNote`.
3. **Accepted/Completed**: Transitions based on user confirmation and service delivery.

### 4. Governance & Integrity
- **LogModel**: Captures every critical state change for audit trails.
- **isActive**: Every major entity supports soft-deletion to maintain database history while cleaning the user interface.
