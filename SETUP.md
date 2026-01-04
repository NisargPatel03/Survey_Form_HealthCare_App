# Setup Guide

## Quick Start

1. **Install Flutter** (if not already installed)
   - Download from https://flutter.dev/docs/get-started/install
   - Follow platform-specific instructions for your OS

2. **Verify Flutter Installation**
   ```bash
   flutter doctor
   ```

3. **Get Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## First Time Setup

If this is a fresh Flutter project, you may need to initialize platform-specific files:

```bash
# This will create android/ and ios/ directories if they don't exist
flutter create .
```

Then run:
```bash
flutter pub get
flutter run
```

## Platform-Specific Notes

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 33 or higher
- Ensure Android Studio is set up with Android SDK

### iOS
- Requires macOS and Xcode
- Minimum iOS version: 11.0
- Run `pod install` in ios/ directory if needed

## Troubleshooting

### Common Issues

1. **"No devices found"**
   - Start an Android emulator or connect a physical device
   - For Android: `flutter emulators --launch <emulator_id>`
   - Enable USB debugging on physical devices

2. **"Pub get failed"**
   - Check internet connection
   - Run `flutter clean` then `flutter pub get`

3. **Build errors**
   - Run `flutter clean`
   - Delete `pubspec.lock`
   - Run `flutter pub get` again

## Testing

Run tests (if any):
```bash
flutter test
```

## Building Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

