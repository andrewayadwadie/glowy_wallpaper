# Quickstart: Fix Runtime Bugs

**Branch**: `008-fix-runtime-bugs` | **Date**: 2026-03-26

## Prerequisites

- Flutter 3.41.5 / Dart 3.11.3 installed
- Android emulator or iOS simulator running
- Backend API accessible at configured base URL

## Files to Modify (8 total)

| # | File | Bug | Change Summary |
|---|------|-----|----------------|
| 1 | `lib/features/wallpapers/presentation/widgets/video_grid.dart` | setState error | Add `mounted` check before `setState()` in visibility callback |
| 2 | `lib/core/di/injection_container.dart` | Classification error | Verify/fix Dio instance for CategoryRemoteDataSource |
| 3 | `lib/features/categories/data/datasources/category_remote_data_source.dart` | Classification error | Verify API path and response parsing for classifications |
| 4 | `lib/features/categories/presentation/pages/classification_detail_page.dart` | Navigation error | Fix wallpaper tap to pass Map with wallpapers list + index |
| 5 | `lib/features/home/presentation/pages/home_page.dart` | Navigation error | Fix wallpaper tap to pass Map with wallpapers list + index |
| 6 | `lib/features/home/presentation/widgets/home_drawer.dart` | Settings + drawer data | Remove Settings item, pass API content to ContentPage |
| 7 | `lib/features/home/presentation/pages/content_page.dart` | Drawer data | Accept content as parameter, remove hardcoded strings |
| 8 | `lib/core/routes/app_router.dart` | Settings route | Remove settings route definition |

## Verification

```bash
# Run analysis
flutter analyze

# Run tests
flutter test

# Test on device
flutter run
```

### Manual Test Checklist

1. Switch rapidly between categories (images → videos → classifications) — no red error screen
2. Tap a classification category — bento grid of cards appears (no network error)
3. Tap any wallpaper in any grid — detail carousel opens correctly
4. Open drawer — no Settings item visible
5. Tap About / Privacy Policy / Terms of Use — shows API content, not placeholder text
6. Tap Share App — share sheet opens with correct store link
7. Tap Send Feedback — email client opens with correct email
