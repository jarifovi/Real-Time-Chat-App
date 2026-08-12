# 🐼 BAO CHAT — Real-Time Community 🌿

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![State Management](https://img.shields.io/badge/State--Management-Provider-7952B3?style=for-the-badge)](https://pub.dev/packages/provider)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Windows-4285F4?style=for-the-badge)](https://flutter.dev/)

**BAO CHAT** is a next-generation, high-contrast 3D social messaging platform featuring a playful panda mascot concept (**PanPan** 🐾), **Bamboo Emerald** color palette (`#34A853`), unique `@username` handles, real-time message streaming, and dynamic 3D glassmorphic card interaction.

---

## 🌟 Key Features

- **🐼 BAO CHAT Brand & PanPan Mascot Concept**:
  - Playful panda mascot identity with glowing emerald rings, speech bubble tails, and paw print badges (`Icons.pets_rounded`).
- **🌿 Bamboo Emerald Color Palette**:
  - Bamboo Emerald Green (`#34A853`), Midnight Obsidian Background (`#141720`), Vibe Sky Blue (`#4285F4`), and Sunny Amber (`#FFBB00`).
- **🏷️ Unique `@username` Handle System**:
  - Every user has a unique handle (e.g., `@jarifovi`, `@panpan_wave`).
  - Search people instantly by `@username`, display name, or email.
- **✏️ Self-Profile Editing**:
  - Customize display name and `@username` handle dynamically via an interactive glass dialog.
- **🔮 3D Glassmorphic Card Interaction**:
  - `Gravity3DCard` container with real-time `Matrix4` tilt rotation and glowing rim lighting on hover.
- **🔐 Secure Firebase Authentication & Firestore**:
  - Deterministic 1-to-1 chat room creation: `[uid1, uid2]..sort().join('_')`.
  - Live message streaming with reactions, replies, pinning, and message editing.
- **📱 Ultra-Smooth Bouncing Scroll Physics**:
  - Custom spring physics engine (`UltraSmoothGravityScrollPhysics`) for tactile, fluid scrolling.

---

## 🛠️ Technology Stack & Architecture

| Layer | Technology |
|---|---|
| **Frontend Framework** | [Flutter](https://flutter.dev/) (Dart) |
| **Brand Concept** | **BAO CHAT** (Bamboo Emerald `#34A853` & Midnight Obsidian `#141720`) |
| **Backend & Database** | [Firebase Authentication](https://firebase.google.com/docs/auth) & [Cloud Firestore](https://firebase.google.com/docs/firestore) |
| **State Management** | [Provider](https://pub.dev/packages/provider) (`AuthProvider`, `UserProvider`, `ChatProvider`, `MessageProvider`) |
| **Security** | SHA-256 Hashing (`crypto` package) |
| **Formatting** | `intl` Date & Timestamp Formatter |

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/jarifovi/Real-Time-Chat-App.git
cd Real-Time-Chat-App
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the Application
```bash
# Run on Web (Chrome)
flutter run -d chrome

# Run on Desktop (Windows)
flutter run -d windows
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
