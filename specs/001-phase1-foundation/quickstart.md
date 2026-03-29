# Quickstart: Phase 1 — Foundation & Scaffolding

## Prerequisites

- Flutter 3.41.5+ / Dart 3.11.3+
- Android Studio or Xcode
- `google-services.json` at `android/app/google-services.json`

## Setup

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, injectable, envied, retrofit)
dart run build_runner build --delete-conflicting-outputs

# Generate native splash
dart run flutter_native_splash:create

# Generate launcher icons (when assets ready)
dart run flutter_launcher_icons
```

## Environment Files

Create `.env.dev` at project root:
```
API_BASE_URL=https://dev-api.glowywallpapers.com
ADMOB_APP_ID=ca-app-pub-2083776520196762~1431087691
STRIPE_PUBLISHABLE_KEY=pk_test_placeholder
```

## Run

```bash
flutter run --dart-define=ENV=dev
```

## Verify Phase 1

1. App cold-starts with #121212 native splash
2. Navigates to empty Home screen
3. Light/dark theme switches with system
4. No overflow warnings on 360dp–1024dp screens
5. `flutter analyze` reports zero warnings
