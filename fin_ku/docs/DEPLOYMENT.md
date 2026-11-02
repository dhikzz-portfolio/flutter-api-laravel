# Deployment Guide

## Build Commands

### 1. Debug Build (for testing)
```bash
flutter build apk --debug
```
- Includes Dart dev tools and symbols
- Useful for debugging and development
- Output: `app/build/outputs/flutter-apk/app-debug.apk`

### 2 Release Build (for production)
```bash
flutter build apk --release
```
- Optimized and minified
- Smaller APK size
- Output: `app/build/outputs/flutter-apk/app-release.apk`

### 3. Build for iOS (macOS only)
```bash
flutter build ipa --release
```
- Creates iOS archive for App Store submission

### 4. Build for Web
```bash
flutter build web --release
```
- Outputs to `build/web/` directory
- Can be hosted on any web server

### 5. Run on Specific Device
```bash
# Android
flutter run -d android

# iOS (macOS)
flutter run -d ios

# Web
flutter run -d web
```

## Environment Configuration

### Platform-Aware API URLs

The app automatically configures the API base URL based on the deployment platform:

| Platform | API Base URL | Configuration Location |
|----------|-------------|----------------------|
| Android Emulator | `http://10.0.2.2:8000` | `lib/core/config/api_config.dart` |
| iOS Simulator | `http://localhost:8000` | `lib/core/config/api_config.dart` |
| Web | `http://127.0.0.1:8000` | `lib/core/config/api_config.dart` |
| Physical Device | Use `ip_address:8000` | Update `api_config.dart` manually |

### Updating API Configuration

Edit `lib/core/config/api_config.dart`:

```dart
static String url(String path) {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'http://10.0.2.2:$port$path',
    TargetPlatform.iOS => 'http://localhost:$port$path',
    TargetPlatform.web => 'http://127.0.0.1:$port$path',
    _ => 'http://localhost:$port$path',
  };
}
```

Replace `$port` with your Laravel server port (default: 8000).

## Firebase/Backend Services

### Authentication
- Uses Laravel Sanctum or JWT for session management
- `AuthController` handles: login, logout, session restore
- User data stored in Laravel `users` table

### Secure Storage
- `flutter_secure_storage` for sensitive data
- Tokens and user preferences stored securely

## Testing Before Deployment

```bash
# Run all tests
flutter test

# Analyze code for errors
flutter analyze

# Check widget tree
flutter pub run build_runner build
```

## Common Deployment Issues

### 1. Connection Refused (Android)
- Ensure Laravel server is running
- Use `10.0.2.2` for emulator (routes to host localhost)
- Check firewall settings

### 2. CORS Errors
- Add Flutter app domain to Laravel CORS config
- Or use wildcard `*` for development

### 3. Build Failures
- Run `flutter clean` then `flutter pub get`
- Ensure Flutter and Dart versions are compatible
- Check for any analyzer errors (`flutter analyze`)

### 4. Shared Preferences/Data Loss
- On fresh installs, SharedPreferences data is empty
- Users need to reconfigure settings (like selected year)

## Release Checklist

- [ ] `flutter analyze` passes with no errors
- [ ] `flutter test` runs successfully
- [ ] API endpoints tested on target platform
- [ ] UI reviewed on actual device (not just emulator)
- [ ] La export functionality (Excel/PDF) tested
- [ ] Role-based access verified (kasir/admin/owner)
- [ ] API base URL configured for target platform
- [ ] App icon and splash screen customized
- [ ] Version code/name updated in pubspec.yaml