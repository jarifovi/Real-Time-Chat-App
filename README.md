# 💬 Real-Time 1-to-1 Chat Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![State Management](https://img.shields.io/badge/State--Management-Provider-7952B3?style=for-the-badge)](https://pub.dev/packages/provider)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Windows-4285F4?style=for-the-badge)](https://flutter.dev/)

A production-ready, ultra-modern **1-to-1 Real-Time Chat Application** built using **Flutter**, **Firebase Authentication**, and **Cloud Firestore**. Features deterministic unique chat room creation, real-time message streaming, state management powered by Provider, and an ultra-smooth bouncing physics glassmorphism design system.

---

## 🌟 Key Features

- **🔐 Secure Firebase Authentication**:
  - Email & Password registration and login.
  - Secure profile management (passwords are never stored in plain text).
- **💬 Deterministic 1-to-1 Room Management**:
  - Automatically generates unique room IDs using sorted participant UIDs: `[uid1, uid2]..sort().join('_')`.
  - Ensures two users always share exactly **one** conversation thread.
- **⚡ Real-Time Message Streaming**:
  - Real-time updates via Cloud Firestore `snapshots()`.
  - Instant message delivery with automatic smooth scroll-to-bottom.
- **📱 3-Tab Modern Navigation Bar**:
  - **Users**: Discover registered users with live search filtering and online status badges.
  - **Chats**: View active conversation threads, last message preview, and timestamps.
  - **Profile**: View user information, member duration, settings, and secure logout.
- **🎨 Ultra-Modern Glassmorphism UI**:
  - Vibrant Indigo & Violet gradient theme (`#6366F1` / `#8B5CF6`).
  - Fluid `BouncingScrollPhysics()` across all list views for ultra-smooth scrolling.
  - Dark mode glassmorphism card components on Auth screens.
- **🔄 Local Fallback Mode**:
  - Gracefully falls back to local session testing when Firebase Web API keys are unconfigured.

---

## 🛠️ Technology Stack & Architecture

| Layer | Technology |
|---|---|
| **Frontend Framework** | [Flutter](https://flutter.dev/) (Dart) |
| **Backend & Database** | [Firebase Authentication](https://firebase.google.com/docs/auth) & [Cloud Firestore](https://firebase.google.com/docs/firestore) |
| **State Management** | [Provider](https://pub.dev/packages/provider) (`AuthProvider`, `UserProvider`, `ChatProvider`, `MessageProvider`) |
| **Security** | SHA-256 Hashing (`crypto` package) |
| **Formatting** | `intl` Date & Timestamp Formatter |

---

## 📁 Project Structure

```
lib/
├── firebase_options.dart      # Platform-specific Firebase credentials
├── main.dart                  # Application entry point & MultiProvider setup
├── models/
│   ├── user_model.dart        # User profile data model & Firestore mapping
│   ├── chat_room_model.dart   # Chat room model with deterministic ID generator
│   └── message_model.dart     # Individual message model
├── providers/
│   ├── auth_provider.dart     # Registration, user state, and logout lifecycle
│   ├── user_provider.dart     # Registered user list loading & search filtering
│   ├── chat_provider.dart     # Active room loading & room creation state
│   └── message_provider.dart  # Live message streaming & dispatch state
├── screens/
│   ├── login_screen.dart      # Glassmorphic login view
│   ├── register_screen.dart   # Glassmorphic registration view
│   ├── main_navigation_screen.dart # Floating bottom tab navigation bar
│   ├── chat_room_screen.dart  # Real-time chat interface with gradient bubbles
│   └── tabs/
│       ├── users_tab.dart     # User discovery tab with live search
│       ├── chats_tab.dart     # Active conversation threads list
│       └── profile_tab.dart   # User profile and account management
├── services/
│   ├── auth_service.dart      # Firebase Auth & local fallback logic
│   └── firestore_service.dart # Firestore CRUD, batch writes & real-time streams
├── theme/
│   └── app_theme.dart         # Design system tokens, gradients & Material 3 styling
└── utils/
    └── date_formatter.dart    # Human-readable timestamp utility
```

---

## 🗄️ Firestore Database Structure

```
/users
   ├── {userId}
   │     ├── name: string
   │     ├── email: string
   │     └── createdAt: timestamp

/chats
   ├── {chatRoomId} (e.g. "uid1_uid2")
   │     ├── participants: array ["uid1", "uid2"]
   │     ├── lastMessage: string
   │     ├── lastMessageAt: timestamp
   │     └── createdAt: timestamp
   │
   └── /messages (Subcollection)
          └── {messageId}
                ├── senderId: string
                ├── receiverId: string
                ├── message: string
                └── timestamp: timestamp
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-started/sdk)
- A Firebase project configured in the [Firebase Console](https://console.firebase.google.com/)

### 1. Clone the Repository
```bash
git clone https://github.com/jarifovi/Real-Time-Chat-App.git
cd Real-Time-Chat-App
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
Update `lib/firebase_options.dart` with your actual project credentials from your Firebase Console, or run:
```bash
flutterfire configure
```

### 4. Run the Application
```bash
# Run on Web (Chrome)
flutter run -d chrome

# Run on Desktop (Windows)
flutter run -d windows
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
