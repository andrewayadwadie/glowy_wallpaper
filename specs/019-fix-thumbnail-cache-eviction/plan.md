# Implementation Plan: Fix Cached Wallpaper Thumbnails Re-Downloading on Scroll-Back

**Branch**: `019-fix-thumbnail-cache-eviction` | **Date**: 2026-07-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/019-fix-thumbnail-cache-eviction/spec.md`

## Summary

Home and Classification Detail grids re-download thumbnails on scroll-back because
`AppCachedImage` never supplies a custom `CacheManager` (falls back to
`cached_network_image`'s `DefaultCacheManager`: 200-object cap, short stale period),
Flutter's global in-memory `imageCache` is never raised at bootstrap, and grid
`itemBuilder`s don't assign stable `ValueKey`s per item. Fix: one shared, app-wide
`CacheManager` singleton (1000+ objects, 30-day stale period) registered via GetIt and
defaulted into `AppCachedImage`; raise `PaintingBinding.instance.imageCache` limits once
at bootstrap; add `ValueKey(wallpaper.id)` to the grid item builders that lack one.
Research also surfaced that `StaggeredWallpaperCard`'s aspect-ratio probe
(`CachedNetworkImageProvider`) independently hits the *old* default cache manager —
it must be pointed at the same shared instance or the fix only half-works (see research.md).

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: `cached_network_image ^3.4.1` (existing), `flutter_cache_manager` (already a transitive dependency of `cached_network_image`; made an explicit direct dependency), `get_it` (manual registration — no injectable codegen in this repo), `hive`/`hive_flutter` (existing boxes, unchanged), `path_provider` (existing)
**Storage**: On-device file cache via a dedicated `flutter_cache_manager` `CacheManager` (new cache-folder key, isolated from the package's `DefaultCacheManager`), plus Flutter's in-memory `PaintingBinding.instance.imageCache`. No Hive schema changes; no new persisted entities.
**Testing**: `flutter_test` + `mocktail` (existing pattern, see `test/core/widgets/staggered_wallpaper_card_test.dart`); widget tests for `AppCachedImage` cache-manager wiring and grid key presence.
**Target Platform**: Android + iOS (existing app, unchanged)
**Project Type**: Mobile app — single Flutter project, Clean Architecture feature-first (existing `lib/` + `test/` layout, not the generic `src/`/`tests/` scaffold)
**Performance Goals**: Previously-viewed thumbnail re-renders in <100ms from cache with no shimmer replay (SC-001); near-zero repeat network fetches for the same thumbnail URL within 30 days (SC-003)
**Constraints**: Must not alter `memCacheWidth`/`memCacheHeight` resize logic, `Hero` tags, semantics, pagination/Cubit logic, or `AppCachedImage`'s public API surface beyond one new optional constructor parameter (default-wired, fully backward compatible); new cache manager's key/folder must not collide with any existing cache manager in the app (there is currently only the package default)
**Scale/Scope**: 2 primary screens (Home, Classification Detail) + the similar-wallpapers picker sheet, all of which route through the same three touched widgets — `lib/core/widgets/app_cached_image.dart`, `lib/core/widgets/staggered_wallpaper_card.dart`, and the two grid call sites (`lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart`, `lib/features/wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart`) — plus one new `core/services/wallpaper_cache_manager.dart`, one `main.dart` bootstrap edit, and one DI registration in `lib/core/di/injection_container.dart`. Confirmed out of scope: `favorites_grid.dart` and `downloads_grid.dart` are separate grid implementations that do not route through `StaggeredWallpaperGrid`/`StaggeredWallpaperCard`, so they are unaffected by (and not required for) this fix.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|---|---|---|
| I. Clean Architecture — Feature-First | New `WallpaperImageCacheManager` is cross-cutting infrastructure, not a feature; lives in `core/services/` alongside the existing `DeviceIdService`, registered in `core/di`. No feature-layer boundary is crossed. | PASS |
| II. SOLID & DRY, no hardcoded values | Cache-tuning numbers (max objects, stale period, in-memory limits) MUST live in a dedicated constants location (extend `AppDimens` or a new small `AppCacheConfig`), not inlined as magic numbers at call sites. | PASS (enforced as a design requirement below) |
| III. Responsive-First (ScreenUtil) | No new UI sizing introduced. | N/A |
| IV. Theming | No new colors/text styles introduced. | N/A |
| V. Error Handling — dartz Either | No new repository methods; `flutter_cache_manager` failures already fall back to `AppCachedImage`'s existing `errorWidget`, unchanged. | N/A |
| VI. Performance — no main-thread heavy work, no leaks | This feature directly serves this principle's intent (eliminates redundant re-downloads/re-decodes). `CachedNetworkImage` usage remains mandatory and unchanged; no new isolate/thread work required (cache I/O is already handled inside `flutter_cache_manager`). | PASS |
| VII. Testing — unit tests required | Widget tests needed for: `AppCachedImage` passes/defaults the `cacheManager` param; grid item builders carry a stable `ValueKey`. `flutter analyze` must stay at zero warnings. | PASS (tracked as tasks in Phase 2) |
| VIII. Monetization & Firebase | Untouched. | N/A |

No violations. Complexity Tracking table is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/019-fix-thumbnail-cache-eviction/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart         # MODIFIED: register shared CacheManager
│   ├── services/
│   │   ├── device_id_service.dart           # existing precedent for a core/services singleton
│   │   └── wallpaper_cache_manager.dart     # NEW: shared CacheManager config
│   ├── utils/
│   │   └── app_dimens.dart                  # MODIFIED (or new AppCacheConfig): cache-size constants
│   └── widgets/
│       ├── app_cached_image.dart            # MODIFIED: optional cacheManager param, defaults to shared instance
│       └── staggered_wallpaper_card.dart    # MODIFIED: aspect-ratio probe uses shared CacheManager too
├── features/
│   ├── wallpapers/presentation/widgets/
│   │   └── wallpaper_grid.dart              # MODIFIED: add ValueKey(wallpaper.id)
│   └── wallpaper_detail/presentation/widgets/
│       └── similar_wallpapers_sheet.dart    # MODIFIED: add ValueKey(wallpaper.id)
└── main.dart                                # MODIFIED: raise PaintingBinding.instance.imageCache limits

test/
├── core/
│   ├── services/
│   │   └── wallpaper_cache_manager_test.dart   # NEW
│   └── widgets/
│       ├── app_cached_image_test.dart          # NEW or extended
│       └── staggered_wallpaper_card_test.dart  # existing — extend for key/cache-manager wiring
└── features/
    └── wallpapers/presentation/widgets/
        └── wallpaper_grid_test.dart             # NEW or extended
```

**Structure Decision**: Existing single-project Flutter app (`lib/` + `test/`), Clean
Architecture feature-first per the constitution. This fix is infrastructure/core-layer
only (`core/services`, `core/widgets`, `core/di`, `main.dart`) plus two presentation-layer
call sites that need a stable key; no new feature folder, no domain/data layer changes,
no new Hive box. `favorites_grid.dart` and `downloads_grid.dart` are confirmed to use a
different grid implementation (not `StaggeredWallpaperGrid`) and are out of scope.

## Complexity Tracking

*No Constitution Check violations — this section is not applicable.*
