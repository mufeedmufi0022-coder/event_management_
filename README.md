# Event Management MVP

A premium, all-in-one Event Management platform built with **Flutter** and **Firebase**. This application connects event organizers (Users) with service providers (Vendors) under a unified **Admin** oversight.

## 🚀 Tech Stack
- **Frontend**: Flutter (v3.9.2 sdk)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Maps & Location**: FlutterMap + Nominatim Search API
- **Networking**: Http (for Geocoding)
- **Media**: Image Picker + Firebase Storage

---

## 🎭 User Roles & Features

### 👤 User (Organizer)
- **Authentication**: Secure Login/Registration with real-time error feedback (styled SnackBars).
- **Dashboard**: Overview of all created events.
- **Event Management**: 
  - Create new events with name, type, and date.
  - **Searchable Location Picker**: Search for venues using a real map or drop pins to auto-grab addresses.
- **Discover Vendors**: 
  - Browse a curated list of approved vendors.
  - View **Detailed Profiles**: Branded headers, descriptions, and full product galleries.
  - **Product/Service List**: See individual pricing for every item a vendor offers.
- **Real-time Communication**: 
  - Direct Chat with vendors to negotiate and discuss details.
  - Persistent message history in the dedicated "Chats" tab.
- **Booking System**: Select an event and send booking requests to preferred vendors.
- **Profile**: Account management and secure Logout confirmation.

### 🏪 Vendor (Service Provider)
- **Business Setup**: Step-by-step onboarding for new vendors.
- **Profile Branding**: 
  - Upload an official **Company Logo**.
  - Set business name, service category (Catering, Photography, DJ, etc.), and contact info.
- **Location Precision**: Use the searchable map to set the exact business physical location.
- **Product Gallery**: 
  - Add specific products or services with photos.
  - **Individual Pricing**: Set a clear price tag for every photo in your gallery.
- **Request Management**: Receive, Review, and **Approve/Reject** booking requests from users.
- **Real-time Chat**: Reply to user inquiries instantly via the "Chats" navigation tab.
- **Profile Tab**: View public appearance and manage settings.

### 🛡️ Admin (System Oversight)
- **Approval System**: Review pending vendor applications to ensure quality and authenticity.
- **Dashboard Summary**: Real-time counts of total users, vendors, and events.
- **Event Oversight**: Comprehensive list of all events happening on the platform.
- **Admin Console**: dedicated secure entry point for system administrators.
- **Logout/Exit Security**: Specialized exit dialogs to prevent accidental session termination.

---

## ✨ Premium UI/UX Highlights
- **Modern Aesthetics**: A curated palette using deep purples (`#904CC1`), soft greys, and vibrant status colors.
- **Dynamic Feedback**: Custom **Floating SnackBars** for error handling and success notifications.
- **Smooth Navigation**: High-performance `BottomNavigationBar` and `Sliver` effects for fluid transitions.
- **Searchable Map**: Integrated search bar on maps to avoid manual typing of long addresses.
- **Security First**: `PopScope` protection on all dashboards to prevent accidental app exits via the back gesture.

---

## 🛠️ Project Structure
- `lib/models`: Data structures (Event, Vendor, Booking, Chat, Message).
- `lib/providers`: State management logic for Auth, Admin, User, Vendor, and Chat.
- `lib/services`: Firebase interaction layers (Firestore queries, Storage uploads, Auth logic).
- `lib/views`: 
  - `admin/`: Admin specific screens.
  - `auth/`: Login, Register, and Onboarding.
  - `user/`: Organizer tools and Vendor discovery.
  - `vendor/`: Business management screens.
  - `common/`: Shared components (Chat, Searchable Map, Splash).

---

## ⚙️ How to Run
1. Ensure Flutter is installed.
2. Clone the repository.
3. Run `flutter pub get` to fetch dependencies.
4. (Optional) Run `flutter run` on your preferred emulator or device.
# event_management
