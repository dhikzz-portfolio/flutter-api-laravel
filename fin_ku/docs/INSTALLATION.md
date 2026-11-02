# Installation Guide

## Prerequisites

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.4.0
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- VS Code or Android Studio with Flutter extensions

## Setup Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd fin_ku
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will install all required packages listed in `pubspec.yaml`:
- `flutter`
- `cupertino_icons`
- `http` (^1.6.0)
- `provider` (^6.1.5+1)
- `flutter_secure_storage` (^11.2.0)
- `intl` (^0.20.3)

### 3. Configure API Backend

This project connects to a Laravel backend API. Ensure the following:

- Laravel server is running (typically at `http://localhost:8000`)
- CORS is configured to allow requests from the Flutter app
- Laravel Sanctum or JWT auth is set up for authentication

### 4. Platform-Specific API Configuration

The app uses platform-aware API URLs. Update `lib/core/config/api_config.dart`:

#### Android Emulator
- Base URL: `http://10.0.2.2:8000` (routes to host's 127.0.0.1)

#### iOS Simulator
- Base URL: `http://localhost:8000`

#### Web
- Base URL: `http://127.0.0.1:8000`

### 5. Run the Application

```bash
flutter run
```

Or build for specific platforms:
- `flutter build apk` - Android
- `flutter build ios` - iOS
- `flutter build web` - Web

### 6. Running Tests

```bash
flutter test
```

## Environment Variables

No specific environment variables are required for basic operation. The API configuration is handled platform-aware within the Dart code.

---

**Note**: Ensure your Laravel backend is running and accessible before running the Flutter app. The app features (laporan, user management) depend on the API endpoints being available.