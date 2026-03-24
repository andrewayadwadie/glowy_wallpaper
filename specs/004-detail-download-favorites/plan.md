# Implementation Plan: Wallpaper Detail, Download & Favorites

**Branch**: `004-detail-download-favorites` | **Date**: 2026-03-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-detail-download-favorites/spec.md`

## Summary

Implement the wallpaper detail carousel, download-to-gallery flow, favorites (local-first with server sync), phone frame preview, my downloads history, and similar wallpapers bottom sheet. This phase builds on the existing wallpapers/categories domain from Phase 3, adding three new features (`wallpaper_detail`, `favorites`, `downloads`) plus extending the existing `wallpapers` feature with new repository methods and data sources.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: flutter_bloc (Cubit), freezed, injectable + get_it, dio + retrofit, go_router, hive + hive_flutter, cached_network_image, video_player, visibility_detector, dartz, equatable, flutter_screenutil, auto_size_text, gal (NEW — gallery saver), permission_handler (NEW), lottie (existing — for empty state animations)
**Storage**: Hive (favorites local box, downloads local box), flutter_secure_storage (auth tokens — existing)
**Testing**: mocktail, bloc_test
**Target Platform**: Android (min SDK 21) + iOS 15+
**Project Type**: Mobile app (Flutter cross-platform)
**Performance Goals**: Carousel swipe at 60fps, optimistic favorite toggle <200ms, download completion <5s on standard connection
**Constraints**: Downloads must not block UI thread (isolate/stream), video playback pauses off-screen, offline-capable for favorites and downloads history
**Scale/Scope**: 5 new screens/overlays (detail page, favorites page, downloads page, phone frame preview overlay, similar wallpapers sheet), 3 new features, ~32 functional requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture — Feature-First | PASS | Three new features (`wallpaper_detail`, `favorites`, `downloads`) each with domain/data/presentation layers. Extends existing `wallpapers` feature. |
| II. SOLID & DRY | PASS | Reuses existing `WallpaperEntity`, `AdaptiveGrid`, `AppCachedImage`, `Status` enum. New abstractions only where needed (FavoriteRepository, DownloadRepository). AutoSizeText for all text. |
| III. Responsive-First with ScreenUtil | PASS | All new screens use ScreenUtil extensions. Favorites/Downloads grids reuse `AdaptiveGrid`. |
| IV. Theming — Light & Dark | PASS | All new UI uses `Theme.of(context)` and centralized AppColors/AppTextStyles. No inlined styles. |
| V. Error Handling — dartz Either | PASS | All new repo methods return `Either<Failure, T>`. Four-state pattern on all screens (FR-031). loader_overlay + flutter_spinkit for loading. |
| VI. Performance | PASS | CachedNetworkImage for all images. Video pauses off-screen. Download bytes via stream (not blocking UI thread). Cubits dispose subscriptions. |
| VII. Testing | PASS | Unit tests for all use cases, repo impls, and cubits. mocktail for mocking. |
| VIII. Monetization & Firebase | PASS | Ad gate placeholder for free users (FR-028). SubscriptionCubit checked for premium status. Firebase Analytics events for download, favorite, preview actions. |

**All gates PASS. Proceeding to Phase 0.**

## Project Structure

### Documentation (this feature)

```text
specs/004-detail-download-favorites/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contracts)
│   ├── favorites-api.md
│   ├── similar-api.md
│   └── download-api.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/features/
├── wallpaper_detail/                    # NEW — Detail screen feature
│   ├── domain/
│   │   ├── entities/                    # (reuses WallpaperEntity from wallpapers)
│   │   ├── repositories/
│   │   │   └── similar_wallpaper_repository.dart
│   │   └── usecases/
│   │       └── get_similar_wallpapers.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   └── similar_wallpaper_remote_data_source.dart
│   │   ├── models/                      # (reuses WallpaperModel)
│   │   └── repositories/
│   │       └── similar_wallpaper_repository_impl.dart
│   └── presentation/
│       ├── cubit/
│       │   ├── wallpaper_detail_cubit.dart
│       │   └── wallpaper_detail_state.dart
│       ├── pages/
│       │   └── wallpaper_detail_page.dart
│       └── widgets/
│           ├── detail_action_bar.dart
│           ├── similar_wallpapers_sheet.dart
│           └── phone_frame_preview.dart
├── favorites/                           # NEW — Favorites feature
│   ├── domain/
│   │   ├── entities/
│   │   │   └── favorite_entity.dart
│   │   ├── repositories/
│   │   │   └── favorite_repository.dart
│   │   └── usecases/
│   │       ├── get_favorites.dart
│   │       ├── toggle_favorite.dart
│   │       ├── is_favorite.dart
│   │       └── merge_guest_favorites.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── favorite_local_data_source.dart
│   │   │   └── favorite_remote_data_source.dart
│   │   ├── models/
│   │   │   └── favorite_model.dart
│   │   └── repositories/
│   │       └── favorite_repository_impl.dart
│   └── presentation/
│       ├── cubit/
│       │   ├── favorite_cubit.dart
│       │   └── favorite_state.dart
│       ├── pages/
│       │   └── favorites_page.dart
│       └── widgets/
│           └── favorites_grid.dart
├── downloads/                           # NEW — Downloads feature
│   ├── domain/
│   │   ├── entities/
│   │   │   └── download_record_entity.dart
│   │   ├── repositories/
│   │   │   └── download_repository.dart
│   │   └── usecases/
│   │       ├── download_wallpaper.dart
│   │       ├── get_download_history.dart
│   │       └── is_downloading.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── download_local_data_source.dart
│   │   │   └── gallery_data_source.dart
│   │   ├── models/
│   │   │   └── download_record_model.dart
│   │   └── repositories/
│   │       └── download_repository_impl.dart
│   └── presentation/
│       ├── cubit/
│       │   ├── download_cubit.dart
│       │   └── download_state.dart
│       ├── pages/
│       │   └── downloads_page.dart
│       └── widgets/
│           └── downloads_grid.dart
└── wallpapers/                          # EXISTING — Extended
    └── (existing files unchanged)

lib/core/
├── utils/
│   ├── app_strings.dart                 # UPDATED — new strings for detail/favorites/downloads
│   ├── app_assets.dart                  # UPDATED — phone frame asset path
│   └── constants.dart                   # UPDATED — new Hive box names, storage keys
└── widgets/
    └── ad_gate_placeholder.dart         # NEW — placeholder rewarded ad gate widget
```

**Structure Decision**: Three new feature-first modules following the same Clean Architecture pattern established in Phases 1-3. The `wallpaper_detail` feature owns the detail screen, similar wallpapers, and phone frame preview. Favorites and downloads are separate features with their own full domain/data/presentation stacks. Existing `wallpapers` feature is unchanged — new features consume its entity and models.

## Complexity Tracking

> No violations detected. All structures follow established patterns.
