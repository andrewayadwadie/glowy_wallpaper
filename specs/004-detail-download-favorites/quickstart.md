# Quickstart: Wallpaper Detail, Download & Favorites

**Feature**: 004-detail-download-favorites
**Branch**: `004-detail-download-favorites`

## Prerequisites

- Flutter 3.41.5 / Dart 3.11.3 installed
- Phases 1-3 implemented and compiling
- Android/iOS simulators or devices available (for gallery save testing)

## Setup

### 1. Install new dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  gal: ^2.3.0
  permission_handler: ^11.3.1
```

Run:

```bash
flutter pub get
```

### 2. Platform configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save wallpapers to your photo library.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save wallpapers to your photo library.</string>
```

### 3. Initialize Hive boxes

In `main.dart`, add alongside existing box initializations:

```dart
await Hive.openBox('favorites');
await Hive.openBox('downloads');
```

### 4. Add phone frame asset

Place the phone frame PNG at:

```
assets/images/phone_frame.png
```

Register in `pubspec.yaml` under `flutter.assets` (if not already covered by `assets/images/`).

### 5. Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Register DI

Add new registrations to `injection_container.dart`:
- Data sources: `FavoriteLocalDataSource`, `FavoriteRemoteDataSource`, `SimilarWallpaperRemoteDataSource`, `DownloadLocalDataSource`, `GalleryDataSource`
- Repositories: `FavoriteRepository`, `DownloadRepository`, `SimilarWallpaperRepository`
- Use cases: `GetFavorites`, `ToggleFavorite`, `IsFavorite`, `MergeGuestFavorites`, `GetSimilarWallpapers`, `DownloadWallpaper`, `GetDownloadHistory`
- Cubits: `WallpaperDetailCubit`, `FavoriteCubit`, `DownloadCubit`

### 7. Update routes

Wire the stub routes in `app_router.dart`:
- `/wallpaper/:id` → `WallpaperDetailPage`
- `/favorites` → `FavoritesPage`
- `/downloads` → `DownloadsPage`

## Verification

```bash
flutter analyze          # Zero warnings
flutter test             # All tests pass
flutter run              # Test on device/simulator
```

Test flow:
1. Home → tap wallpaper thumbnail → detail screen opens with Hero animation
2. Swipe left/right in carousel
3. Tap download → grant permissions → verify wallpaper in device gallery
4. Tap favorite heart → verify fills immediately
5. Navigate to Favorites page → verify grid shows favorited wallpapers
6. Navigate to Downloads page → verify grid shows downloaded wallpapers
7. Tap preview → verify phone frame overlay
8. Pull up similar wallpapers sheet → tap one → verify carousel switches

## Key Files to Implement

| Priority | File | Description |
|----------|------|-------------|
| 1 | `wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` | Full-screen carousel with Hero |
| 2 | `wallpaper_detail/presentation/widgets/detail_action_bar.dart` | Download, favorite, preview buttons |
| 3 | `downloads/domain/repositories/download_repository.dart` | Download contract |
| 4 | `downloads/data/repositories/download_repository_impl.dart` | Dio download + gal save + Hive record |
| 5 | `favorites/domain/repositories/favorite_repository.dart` | Favorite contract |
| 6 | `favorites/data/repositories/favorite_repository_impl.dart` | Local-first + server sync |
| 7 | `favorites/presentation/pages/favorites_page.dart` | Favorites grid |
| 8 | `downloads/presentation/pages/downloads_page.dart` | Downloads grid |
| 9 | `wallpaper_detail/presentation/widgets/phone_frame_preview.dart` | Phone frame overlay |
| 10 | `wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart` | Bottom sheet |
