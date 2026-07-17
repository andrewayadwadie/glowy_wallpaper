# Research: Fix Favorites, Download & Preview

**Branch**: `009-fix-favorites-download-preview` | **Date**: 2026-03-26

## Current State Analysis

### What Already Exists (Working)

| Component | Status | Files |
|-----------|--------|-------|
| FavoriteCubit (toggle, check, load) | Working | `favorites/presentation/cubit/favorite_cubit.dart` |
| Hive local storage (favorites box) | Working | `favorites/data/datasources/favorite_local_data_source.dart` |
| FavoritesPage with grid | Working | `favorites/presentation/pages/favorites_page.dart` |
| DownloadCubit (download, history) | Working | `downloads/presentation/cubit/download_cubit.dart` |
| Gallery save via gal | Working | `downloads/data/datasources/gallery_data_source.dart` |
| DownloadsPage with grid | Working | `downloads/presentation/pages/downloads_page.dart` |
| PhoneFramePreview (image only) | Partial | `wallpaper_detail/presentation/widgets/phone_frame_preview.dart` |
| DetailActionBar (3 buttons) | Working | `wallpaper_detail/presentation/widgets/detail_action_bar.dart` |
| WallpaperDetailPage (PageView) | Working | `wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` |
| GoRouter with wallpaper/:id route | Working | `core/routes/app_router.dart` |

### Bugs Identified

**BUG-1 (HIGH): Missing navigation params from favorites/downloads**
- `favorites_page.dart` and `downloads_page.dart` both navigate to wallpaper detail without passing `categoryType` and `classificationId` in the `extra` map.
- `app_router.dart` expects these: `extra['categoryType']` and `extra['classificationId']`.
- Defaults to `CategoryType.image` and empty string, which silently breaks similar wallpapers loading.

**BUG-2 (HIGH): Incomplete WallpaperEntity reconstruction in downloads**
- `downloads_page.dart` creates `WallpaperEntity` from `DownloadRecordEntity` but doesn't include classification fields (they're nullable, so no crash, but data is incomplete).

**BUG-3 (MEDIUM): PhoneFramePreview lacks video support**
- Current preview uses `AppCachedImage` only — static images work, but video wallpapers show just the thumbnail, not a playing video. Spec requires video playback inside the phone frame.

**BUG-4 (LOW): Unused state fields in WallpaperDetailState**
- `isFavorite` and `isDownloading` fields exist but are never read — separate cubits manage those states. Dead code.

## Research Decisions

### Decision 1: Navigation Data Strategy for Favorites/Downloads → Detail

- **Decision**: Pass full wallpaper list + initialIndex + default categoryType/classificationId from favorites and downloads screens.
- **Rationale**: The `app_router.dart` already extracts these params with safe defaults. Passing `categoryType: CategoryType.image` (or the wallpaper's actual type) and `classificationId: null` makes the navigation consistent with home grid navigation. The similar wallpapers feature won't work without a real classificationId, but that's acceptable — favorites/downloads don't have category context.
- **Alternatives considered**: (1) Store categoryId/classificationId in FavoriteModel — rejected because it adds complexity and the data may be stale. (2) Disable similar wallpapers when opened from favorites/downloads — acceptable as a follow-up enhancement.

### Decision 2: Video Playback in Phone Frame Preview

- **Decision**: Initialize a `VideoPlayerController` inside `PhoneFramePreview` when `mediaType == video`, play the video looping and muted inside the phone frame area. For images, keep current `AppCachedImage` approach.
- **Rationale**: Spec explicitly requires "video playing inside the frame area, simulating a live wallpaper." The `video_player` package is already a project dependency and used in `WallpaperDetailPage`.
- **Alternatives considered**: (1) Use the existing detail page's video controller — rejected because the preview is a separate overlay/route with its own lifecycle. (2) Use a GIF/thumbnail — rejected because spec says "live wallpaper" simulation.

### Decision 3: Favorite Toggle Debouncing

- **Decision**: Use the existing `isToggling` state flag in `FavoriteCubit` to prevent concurrent operations. The cubit already sets `isToggling: true` before the operation and `false` after. The UI should disable the button when `isToggling` is true.
- **Rationale**: The cubit already has this mechanism; it just needs to be wired to the UI button's enabled state.
- **Alternatives considered**: (1) Time-based debounce — rejected because state-based gating is simpler and already exists.

### Decision 4: Download Permission Flow

- **Decision**: Use existing `GalleryDataSource.requestPermission()` and `checkPermission()` flow. Add `openAppSettings()` fallback when permission is permanently denied.
- **Rationale**: Already implemented in `gallery_data_source.dart`. The `DownloadCubit.download()` method calls permission checks. Need to verify the permanently-denied flow guides users to settings.
- **Alternatives considered**: None — existing implementation covers the spec requirements.

### Decision 5: DownloadRecordModel Enhancement

- **Decision**: Add `mediaType` field to `DownloadRecordModel` to preserve the wallpaper's media type. Currently the model has `fileType` (image/video string) which serves this purpose. Also ensure the `imageUrl` field reliably stores the full-resolution URL (not just thumbnail).
- **Rationale**: When reconstructing `WallpaperEntity` from `DownloadRecordEntity` for navigation, the mediaType mapping already exists (`r.fileType == WallpaperFileType.video ? MediaType.video : MediaType.image`). The current model is sufficient.
- **Alternatives considered**: Store the entire `WallpaperModel` JSON in the download record — rejected as over-engineering; current fields are enough for navigation.
