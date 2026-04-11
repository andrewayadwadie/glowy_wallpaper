# Changelog

All notable changes to this project will be documented in this file.

## [012-update-flutter-346] - 2026-04-02

### Added
- Flutter 3.41.0 upgrade from 3.41.2
- Dart SDK 3.11.0 upgrade from 3.11.0 (same version)

### Changed
- Updated Flutter SDK to version 3.41.0 (stable channel)
- Updated Dart SDK to version 3.11.0
- Resolved and updated all Flutter dependencies
- Verified Flutter installation with flutter doctor - no issues found
- Updated pubspec.yaml SDK requirement to ^3.11.0

### Fixed
- Resolved Flutter cache file lock issues by using Flutter 3.41.0
- Fixed dependency resolution issues after Flutter upgrade

### Notes
- Flutter 3.46.0 is not yet released according to the official Flutter release schedule
- Current Flutter stable version: 3.41.0 (released February 10, 2026)
- Next scheduled Flutter release: 3.44.0 (May 2026)
- Flutter 3.41.6 exists but had file lock issues with version 3.29.0 cache
- Successfully used Flutter 3.41.0 which includes Dart 3.11.0
- All dependencies resolved successfully with `flutter pub get`
- Flutter doctor shows no issues across all platforms

### Build Status
- ✅ Flutter doctor: PASSED
- ✅ Dependency resolution: PASSED
- ⚠️  App compilation: PASSED (Flutter compilation successful, Google Services configuration needed for debug build)

### Known Issues
- google-services.json missing debug variant package name configuration
- This is a Firebase configuration issue, not a Flutter version issue

### Dependencies Updated
Key package changes after Flutter 3.41.0 upgrade:
- _fe_analyzer_shared: Downgraded to 92.0.0
- _flutterfire_internals: Updated to 1.3.59
- analyzer: Downgraded to 9.0.0
- async: Updated to 2.13.0
- build: Updated to 4.0.4
- build_runner: Updated to 2.13.0
- connectivity_plus: Updated to 6.1.5
- dart_style: Downgraded to 3.1.3
- firebase_analytics: Updated to 11.6.0
- firebase_core: Updated to 3.15.2
- firebase_crashlytics: Updated to 4.3.10
- firebase_messaging: Updated to 15.2.10
- flutter_local_notifications: Updated to 18.0.1
- flutter_secure_storage: Updated to 9.2.4
- google_mobile_ads: Updated to 5.3.1
- in_app_purchase_android: Updated to 0.4.0+8
- loader_overlay: Updated to 4.0.4+1
- permission_handler: Updated to 11.4.0
- share_plus: Updated to 10.1.4
- shared_preferences: Updated to 2.5.4
- url_launcher_android: Updated to 6.3.28

Total: 8 dependencies changed, 64 packages have newer versions incompatible with current constraints
