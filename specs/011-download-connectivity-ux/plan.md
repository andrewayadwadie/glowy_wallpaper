# Implementation Plan: Improve Download Connectivity Check and UX

**Branch**: `011-download-connectivity-ux` | **Date**: 2026-04-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/011-download-connectivity-ux/spec.md`

## Summary

Overhaul the wallpaper download flow to: (1) verify real internet reachability before downloading, (2) gracefully bypass the ad gate on ad errors so downloads are never blocked by ads, (3) replace the `gal` gallery saver with `image_gallery_saver_plus`, (4) remove the blocking full-screen overlay / `CircularProgressIndicator` and replace with non-blocking inline button progress, and (5) log failure events to Firebase Analytics.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5  
**Primary Dependencies**: flutter_bloc (Cubit + Freezed), dio, dartz, get_it, permission_handler, internet_connection_checker, connectivity_plus, google_mobile_ads, firebase_analytics, image_gallery_saver_plus (NEW), flutter_screenutil  
**Storage**: Hive (downloads box, app_bootstrap), flutter_secure_storage (auth tokens)  
**Testing**: mocktail, bloc_test  
**Target Platform**: Android & iOS  
**Project Type**: Mobile app (wallpaper gallery)  
**Performance Goals**: Connectivity check < 2s, download button responsive at 60fps during progress  
**Constraints**: Offline-capable gallery history, no full-screen blocking overlays during download  
**Scale/Scope**: Single feature (downloads), ~8 files modified

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture — Feature-First | PASS | All changes follow domain→data→presentation layers. `NetworkInfo` is in core, `GalleryDataSource` in data layer, `DownloadCubit` in presentation. No cross-layer violations. |
| II. SOLID & DRY — No God Classes | PASS | `DownloadCubit` gains one new dependency (`NetworkInfo`); no duplication introduced. Strings use `AppStrings`. |
| III. Responsive-First with ScreenUtil | PASS | All UI sizes in `DetailActionBar` already use `.w`, `.h`, `.sp`. New progress text will also use `.sp`. |
| IV. Theming — Light & Dark via ThemeData | PASS | Colors in `DetailActionBar` use theme-aware constants. Progress indicator will follow the same pattern. |
| V. Error Handling — dartz Either | PASS | Repository returns `Either<Failure, T>`. New connectivity check is a guard before the Either path. Download button progress is inline, not a full-screen `loader_overlay`. The existing raw `CircularProgressIndicator` in the download button will be replaced. |
| VI. Performance | PASS | No main-thread blocking. Dio download is streamed. Connectivity check is async. |
| VII. Testing | PASS | Unit tests required for: `DownloadCubit` (connectivity guard, ad gate fallback), `GalleryDataSourceImpl` (image_gallery_saver_plus calls), `DownloadRepositoryImpl`. |
| VIII. Monetization & Firebase | PASS | Ad gate remains for free users via centralized `AdHelper`. Failure events logged to Firebase Analytics. Premium users skip ad gate (existing behavior preserved). |

**Post-Phase 1 re-check**: All principles still PASS. No new violations introduced by data model or contracts.

## Project Structure

### Documentation (this feature)

```text
specs/011-download-connectivity-ux/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── network/
│   │   └── network_info.dart              # Existing — inject into DownloadCubit
│   ├── widgets/
│   │   └── ad_gate_placeholder.dart       # MODIFY — make ad errors non-blocking
│   ├── di/
│   │   └── injection_container.dart       # MODIFY — add NetworkInfo to DownloadCubit
│   ├── utils/
│   │   └── app_strings.dart               # MODIFY — add "Network unavailable" string
│   └── errors/
│       └── failure.dart                   # Existing — NetworkFailure already defined
├── features/
│   └── downloads/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── gallery_data_source.dart   # MODIFY — swap gal → image_gallery_saver_plus
│       │   └── repositories/
│       │       └── download_repository_impl.dart  # MODIFY — add settings dialog for permanent denial
│       ├── domain/                            # No changes — abstractions unchanged
│       └── presentation/
│           └── cubit/
│               └── download_cubit.dart        # MODIFY — connectivity check, ad gate fallback, analytics
└── features/
    └── wallpaper_detail/
        └── presentation/
            └── widgets/
                └── detail_action_bar.dart     # MODIFY — animated progress button

test/
└── features/
    └── downloads/
        ├── presentation/
        │   └── cubit/
        │       └── download_cubit_test.dart   # NEW — unit tests
        └── data/
            └── datasources/
                └── gallery_data_source_test.dart  # NEW — unit tests
```

**Structure Decision**: No new directories or modules. All changes fit within the existing Clean Architecture feature-first layout. The `core/network/` and `core/widgets/` directories already exist.
