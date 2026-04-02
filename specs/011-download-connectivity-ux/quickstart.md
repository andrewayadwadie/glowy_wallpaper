# Quickstart: 011-download-connectivity-ux

**Date**: 2026-04-02

## Prerequisites

- Flutter 3.41.5+ / Dart 3.11.3+
- Android device or emulator (gallery save testing)
- iOS simulator or device (gallery save testing)

## Setup

```bash
# Switch to feature branch
git checkout 011-download-connectivity-ux

# Add image_gallery_saver_plus, remove gal
flutter pub remove gal
flutter pub add image_gallery_saver_plus

# Get dependencies
flutter pub get

# Regenerate Freezed files (if download_state changes)
dart run build_runner build --delete-conflicting-outputs
```

## Key Files to Modify

| File | Change |
|------|--------|
| `lib/features/downloads/presentation/cubit/download_cubit.dart` | Add connectivity check, restructure ad gate + download flow, add failure analytics |
| `lib/core/widgets/ad_gate_placeholder.dart` | Make ad errors non-blocking (return true on failure) |
| `lib/features/downloads/data/datasources/gallery_data_source.dart` | Swap `gal` → `image_gallery_saver_plus` in implementation |
| `lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart` | Enhance download button progress indicator (percentage text, no raw CircularProgressIndicator) |
| `lib/core/di/injection_container.dart` | Inject `NetworkInfo` into `DownloadCubit` |
| `pubspec.yaml` | Remove `gal`, add `image_gallery_saver_plus` |

## Verification

```bash
# Analyze
flutter analyze

# Run unit tests
flutter test test/features/downloads/

# Manual testing checklist
# 1. Airplane mode → tap download → "Network unavailable" snackbar
# 2. Online, ad fails → download proceeds automatically
# 3. Online, ad succeeds → download proceeds after ad
# 4. Download completes → wallpaper visible in device gallery
# 5. Download in progress → button shows progress, screen is interactive
# 6. Deny gallery permission → error message shown
# 7. Permanently deny → settings dialog appears
```
