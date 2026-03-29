# Implementation Plan: Fix Favorites, Download & Preview

**Branch**: `009-fix-favorites-download-preview` | **Date**: 2026-03-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-fix-favorites-download-preview/spec.md`

## Summary

Fix broken favorites toggle, download-to-gallery, and phone frame preview functionality on the wallpaper detail page. Most infrastructure already exists (Hive storage, cubits, data sources, gallery access, UI pages). The primary issues are: (1) missing navigation parameters when opening wallpaper detail from favorites/downloads screens, (2) no video playback support in the phone frame preview, and (3) minor UI wiring gaps (favorite button debounce guard). This is a targeted bug-fix and enhancement pass on existing code — no new architectural components needed.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: flutter_bloc (Cubit + Freezed), go_router, dio, hive + hive_flutter, cached_network_image, video_player, gal, permission_handler, injectable + get_it, dartz, flutter_screenutil, auto_size_text
**Storage**: Hive (favorites box, downloads box) — local device storage
**Testing**: mocktail + bloc_test, flutter test
**Target Platform**: Android + iOS mobile
**Project Type**: Mobile app (cross-platform Flutter)
**Performance Goals**: Favorite toggle < 1s, download with progress, preview render < 2s
**Constraints**: Offline-capable local storage, gallery permissions required for download
**Scale/Scope**: 6 files to modify, 0 new files to create, ~150 lines of changes

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture Feature-First | PASS | All changes stay within existing feature boundaries (favorites, downloads, wallpaper_detail). No cross-feature imports added. |
| II. SOLID & DRY — No Duplication | PASS | Removing unused dead fields. No new duplication. AutoSizeText used throughout. |
| III. Responsive-First with ScreenUtil | PASS | All existing ScreenUtil usage preserved. Phone frame preview already uses `.r`, `.w`, `.h`. |
| IV. Theming — Light & Dark | PASS | No new colors or styles introduced. Using existing theme constants. |
| V. Error Handling — dartz Either | PASS | Existing Either-based repo methods unchanged. Four-state pattern maintained. |
| VI. Performance — No Leaks | PASS | VideoPlayerController in preview will be properly disposed. CachedNetworkImage used. |
| VII. Testing — Unit Tests | PASS | Will verify existing tests pass after changes. |
| VIII. Monetization & Firebase | PASS | No ad or payment logic modified. Firebase analytics events already logged. |

**Gate Result**: ALL PASS — proceed to implementation.

## Post-Design Constitution Re-Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture | PASS | No new cross-feature dependencies. |
| II. SOLID & DRY | PASS | Removed dead code. Navigation param pattern consistent across favorites/downloads. |
| III. ScreenUtil | PASS | Video player in preview uses existing ScreenUtil sizing. |
| V. Error Handling | PASS | Video initialization errors caught and handled. |
| VI. Performance | PASS | VideoPlayerController disposed on preview dismiss. |

**Gate Result**: ALL PASS.

## Project Structure

### Documentation (this feature)

```text
specs/009-fix-favorites-download-preview/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0: bug analysis and research decisions
├── data-model.md        # Phase 1: entity/model reference (no changes needed)
├── quickstart.md        # Phase 1: fix summary and testing guide
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (files to modify)

```text
lib/features/
├── favorites/
│   └── presentation/
│       └── pages/
│           └── favorites_page.dart          # Fix: navigation params + swipeable list
├── downloads/
│   └── presentation/
│       └── pages/
│           └── downloads_page.dart          # Fix: navigation params + swipeable list
└── wallpaper_detail/
    └── presentation/
        ├── cubit/
        │   └── wallpaper_detail_state.dart  # Fix: remove unused fields
        ├── pages/
        │   └── wallpaper_detail_page.dart   # Fix: verify favorite state on swipe
        └── widgets/
            ├── detail_action_bar.dart       # Fix: wire isToggling guard
            └── phone_frame_preview.dart     # Fix: add video playback support
```

**Structure Decision**: No new files or directories. All changes within existing Clean Architecture feature folders.

## Implementation Approach

### Phase A: Fix Navigation (Favorites + Downloads → Detail)

1. **favorites_page.dart**: Add `categoryType` and `classificationId` to the `extra` map in `context.push()`. Pass full favorites list as wallpapers for swipeable PageView.
2. **downloads_page.dart**: Same fix — add missing navigation params. Infer `categoryType` from the download record's `fileType`.

### Phase B: Fix Favorite Toggle UX

3. **detail_action_bar.dart**: Read `isToggling` from `FavoriteCubit` state to disable the favorite button during async operations, preventing rapid-tap inconsistencies.
4. **wallpaper_detail_page.dart**: Verify the BlocListener that calls `checkIsFavorite` on `currentIndex` change works correctly for all navigation sources (home, favorites, downloads).

### Phase C: Enhance Phone Frame Preview with Video

5. **phone_frame_preview.dart**: Accept `mediaType` and `videoUrl` parameters. When `mediaType == video`, initialize `VideoPlayerController.networkUrl()`, set looping + muted, play inside the frame area. Dispose controller on widget dispose. Show loading indicator while video initializes.

### Phase D: Clean Up Dead Code

6. **wallpaper_detail_state.dart**: Remove unused `isFavorite` and `isDownloading` fields from the Freezed state class (they duplicate state managed by separate cubits).

## Complexity Tracking

> No constitution violations — table not applicable.
