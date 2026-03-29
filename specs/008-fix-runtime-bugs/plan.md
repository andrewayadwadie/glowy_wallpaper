# Implementation Plan: Fix Runtime Bugs

**Branch**: `008-fix-runtime-bugs` | **Date**: 2026-03-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-fix-runtime-bugs/spec.md`

## Summary

Fix 5 runtime bugs blocking core app functionality: (1) setState rendering error when switching categories in the video grid's visibility callback, (2) classification categories showing network error due to wrong Dio instance or API path issue, (3) invalid navigation parameters when tapping wallpapers from classification detail and home grids, (4) remove unimplemented Settings item from drawer, (5) wire drawer content pages (About, Privacy Policy, Terms of Use) and actions (Share, Rate, Feedback) to bootstrap API data instead of hardcoded text.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: flutter_bloc (Cubit + Freezed), go_router, dio, hive, injectable + get_it, cached_network_image, auto_size_text, flutter_screenutil, share_plus, url_launcher
**Storage**: Hive (app_bootstrap box for AppMetadataModel cache)
**Testing**: mocktail, bloc_test, flutter_test
**Target Platform**: Android (min SDK 21) + iOS (15+)
**Project Type**: Mobile app (Flutter cross-platform)
**Performance Goals**: 60 fps during category switching, no jank on grid transitions
**Constraints**: No memory leaks from disposed widgets, no stale callbacks after category switch
**Scale/Scope**: Bug-fix scope — 8 files modified, 0 new files, ~150 lines changed

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture — Feature-First | PASS | All fixes stay within existing feature boundaries; no cross-layer violations |
| II. SOLID & DRY — No Duplication | PASS | Navigation parameter format will be standardized across all callers |
| III. Responsive-First with ScreenUtil | N/A | No UI layout changes |
| IV. Theming — Light & Dark | N/A | No styling changes |
| V. Error Handling — dartz Either | PASS | Existing error handling preserved; classification fix restores proper data flow |
| VI. Performance — No Memory Leaks | PASS | Bug 1 fix specifically prevents setState on disposed widgets |
| VII. Testing — Unit Tests Required | PASS | Affected cubits already have tests; navigation fix is structural |
| VIII. Monetization & Firebase | N/A | No ad or Firebase changes |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/008-fix-runtime-bugs/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (files to modify)

```text
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart          # Bug 2: verify Dio instance for classifications
│   └── routes/
│       └── app_router.dart                   # Bug 4: remove settings route
├── features/
│   ├── wallpapers/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── video_grid.dart           # Bug 1: guard setState in visibility callback
│   ├── categories/
│   │   ├── data/
│   │   │   └── datasources/
│   │   │       └── category_remote_data_source.dart  # Bug 2: verify API path
│   │   └── presentation/
│   │       └── pages/
│   │           └── classification_detail_page.dart   # Bug 3: fix navigation params
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── home_page.dart             # Bug 3: fix navigation params
│   │       │   └── content_page.dart          # Bug 5: use API data instead of hardcoded
│   │       └── widgets/
│   │           └── home_drawer.dart           # Bug 4+5: remove settings, pass API data
```

**Structure Decision**: Existing feature-first Clean Architecture structure. No new files needed — all fixes modify existing files within their respective feature directories.

## Bug Fix Details

### Bug 1: setState Rendering Error on Category Switch

**Root cause**: `video_grid.dart` — `_onVisibilityChanged()` calls `setState()` on visibility detection. When the user switches categories, the old `VideoGrid` widget is being disposed while visibility callbacks are still firing, causing a "setState() called after dispose()" error.

**Fix**: Add a `mounted` check before `setState()` in `_onVisibilityChanged`. This is the standard Flutter pattern for async/callback-driven state updates.

**File**: `lib/features/wallpapers/presentation/widgets/video_grid.dart`
**Lines**: ~50-54 (setState block in `_onVisibilityChanged`)

### Bug 2: Classification Category Shows Network Error

**Root cause**: The classification API endpoint may require authenticated access, but `CategoryRemoteDataSource` is injected with `publicDio` (unauthenticated). Alternatively, the response parsing may not match the actual API envelope.

**Fix**: Verify the Dio instance used and the API response parsing. If authentication is required, switch to the authenticated Dio instance. If the response envelope differs, update the parsing.

**Files**:
- `lib/core/di/injection_container.dart` (line ~182)
- `lib/features/categories/data/datasources/category_remote_data_source.dart` (lines ~21-32)

### Bug 3: Invalid Navigation Parameters

**Root cause**: `classification_detail_page.dart` line 75 and `home_page.dart` lines 57-60 pass `extra: wallpaper` (a single `WallpaperEntity`), but `app_router.dart` lines 96-101 expect `extra` to be `Map<String, dynamic>` with keys `wallpapers` (List) and `initialIndex` (int).

**Fix**: Update all navigation callers to pass the correct Map format with the full wallpaper list and tapped index.

**Files**:
- `lib/features/categories/presentation/pages/classification_detail_page.dart` (line 75)
- `lib/features/home/presentation/pages/home_page.dart` (lines 57-60)

### Bug 4: Remove Settings from Drawer

**Root cause**: `home_drawer.dart` lines 94-102 contain a Settings menu item that navigates to a placeholder route.

**Fix**: Remove the Settings `_buildMenuItem` block from the drawer. Optionally remove the placeholder route from `app_router.dart` and the constant from `AppRoutes`.

**Files**:
- `lib/features/home/presentation/widgets/home_drawer.dart` (lines 94-102)
- `lib/core/routes/app_router.dart` (lines 157-159, settings route)

### Bug 5: Drawer Content from Bootstrap API

**Root cause**: `content_page.dart` lines 22-31 use hardcoded strings for About, Privacy Policy, and Terms of Use. The bootstrap API already provides these fields in `AppMetadataEntity` (about, privacyPolicy, termsOfUse), and `HomeCubit` state already carries `appMetadata`.

**Fix**: Modify `ContentPage` to accept the content string as a constructor parameter instead of generating it from a switch statement. Update the drawer navigation calls to pass the appropriate `appMetadata` field value. Similarly ensure Rate App uses the platform share link for store URL.

**Files**:
- `lib/features/home/presentation/pages/content_page.dart` (lines 22-31)
- `lib/features/home/presentation/widgets/home_drawer.dart` (lines 103-124, content navigation)

## Complexity Tracking

> No constitution violations — this section is intentionally empty.
