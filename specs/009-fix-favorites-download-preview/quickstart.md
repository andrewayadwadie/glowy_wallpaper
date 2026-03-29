# Quickstart: Fix Favorites, Download & Preview

**Branch**: `009-fix-favorites-download-preview` | **Date**: 2026-03-26

## Overview

This feature fixes existing but broken/incomplete favorites, download, and preview functionality in the wallpaper detail page. Most code already exists — this is primarily a bug-fix and enhancement pass.

## What Already Works

- Hive boxes (`favorites`, `downloads`) are initialized in `main.dart`
- DI registration for all cubits, repositories, data sources, and use cases
- FavoriteCubit with optimistic toggle, check, and load methods
- DownloadCubit with progress tracking and gallery save
- PhoneFramePreview widget (images only)
- GoRouter route `/wallpaper/:id` with `extra` parameter extraction
- FavoritesPage and DownloadsPage with grid widgets

## What Needs Fixing

### Fix 1: Navigation Params (Favorites → Detail)
**File**: `lib/features/favorites/presentation/pages/favorites_page.dart`
**Problem**: Missing `categoryType` and `classificationId` in navigation `extra` map.
**Fix**: Add `'categoryType': CategoryType.image` and `'classificationId': null` to the extra map when calling `context.push()`.

### Fix 2: Navigation Params (Downloads → Detail)
**File**: `lib/features/downloads/presentation/pages/downloads_page.dart`
**Problem**: Same as Fix 1 — missing navigation params.
**Fix**: Add `categoryType` (infer from `fileType`) and `classificationId: null` to the extra map.

### Fix 3: Video Playback in PhoneFramePreview
**File**: `lib/features/wallpaper_detail/presentation/widgets/phone_frame_preview.dart`
**Problem**: Only renders static images via `AppCachedImage`. No video support.
**Fix**: Accept `mediaType` param. When video, initialize `VideoPlayerController.networkUrl()`, play looping + muted inside the frame. Dispose on close.

### Fix 4: Favorite State Check on Page Swipe
**File**: `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart`
**Problem**: Verify the BlocListener that calls `checkIsFavorite` on page change works correctly.
**Fix**: Ensure `FavoriteCubit.checkIsFavorite(wallpaperId)` is called every time `currentIndex` changes.

### Fix 5: Debounce Favorite Toggle in UI
**File**: `lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart`
**Problem**: Rapid taps can cause inconsistent state.
**Fix**: Read `isToggling` from `FavoriteCubit` state to disable the button during operations.

### Fix 6: Clean Up Unused State Fields
**File**: `lib/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart`
**Problem**: `isFavorite` and `isDownloading` fields are never read (separate cubits own those states).
**Fix**: Remove dead fields to prevent confusion.

## Key Files to Modify

| File | Changes |
|------|---------|
| `favorites/presentation/pages/favorites_page.dart` | Fix navigation params |
| `downloads/presentation/pages/downloads_page.dart` | Fix navigation params |
| `wallpaper_detail/presentation/widgets/phone_frame_preview.dart` | Add video playback |
| `wallpaper_detail/presentation/widgets/detail_action_bar.dart` | Wire isToggling guard |
| `wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart` | Remove unused fields |
| `wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` | Verify swipe→favorite sync |

## How to Test

```bash
# Run all tests
flutter test

# Run specific feature tests
flutter test test/features/favorites/
flutter test test/features/downloads/
flutter test test/features/wallpaper_detail/

# Analyze for warnings
flutter analyze
```

## Manual Testing Checklist

1. Favorite a wallpaper from home grid → verify heart icon fills
2. Open favorites screen → verify wallpaper appears
3. Tap wallpaper in favorites → verify detail opens with filled heart + swipeable
4. Unfavorite from detail (opened via favorites) → go back → verify removed
5. Download an image wallpaper → check device gallery
6. Download a video wallpaper → check device gallery (playable)
7. Open downloads screen → verify records appear, most recent first
8. Tap download item → verify detail opens + swipeable
9. Preview image wallpaper → verify phone frame renders image
10. Preview video wallpaper → verify phone frame plays video looping
11. Dismiss preview → verify returns to detail, video stops
