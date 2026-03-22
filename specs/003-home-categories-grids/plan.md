# Implementation Plan: Home, Categories & Content Grids

**Branch**: `003-home-categories-grids` | **Date**: 2026-03-22 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-home-categories-grids/spec.md`

## Summary

Build the Home screen with a horizontal category selector, navigation drawer, and three dynamic content grid types (image, video, classification bento). Uses the existing `categories` and `wallpapers` feature scaffolding. Categories are cached locally via Hive with stale-while-revalidate. Wallpapers are fetched per-category with page-based infinite scroll pagination. Video cells use `video_player` with a 2-3 concurrent auto-play limit. Classification detail is a full sub-feature with its own cubit and page. Premium wallpapers are filtered client-side based on `SubscriptionCubit` state.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: flutter_bloc, freezed, injectable + get_it, dio + retrofit, go_router, hive + hive_flutter, cached_network_image, auto_size_text, flutter_screenutil, dartz, equatable, video_player (NEW), visibility_detector (NEW)
**Storage**: Hive (category cache, wallpaper page cache)
**Testing**: flutter_test, mocktail, bloc_test
**Target Platform**: Android (API 23+) / iOS (13+)
**Project Type**: Mobile app (cross-platform Flutter)
**Performance Goals**: Categories load <2s, category switch <1s (cached instant), video auto-play <1s visible, pagination pre-fetch before end
**Constraints**: Max 2-3 concurrent video players, offline-capable for cached categories, cancel in-flight requests on category switch
**Scale/Scope**: 2 new screens (Home rewrite, ClassificationDetail), 3 grid types, 3 domain entities, 5+ use cases, drawer with 9 menu items

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture — Feature-First | PASS | Categories and wallpapers use existing feature scaffolding with domain/data/presentation layers. ClassificationDetail lives under categories feature. Home presentation updated in-place. |
| II. SOLID & DRY — No Duplication | PASS | All strings in AppStrings, all dimensions in AppDimens. AutoSizeText used throughout. Repository contracts in domain, implementations in data. Shared AdaptiveGrid widget reused for image/classification grids. |
| III. Responsive-First with ScreenUtil | PASS | All sizes use .w/.h/.sp/.r. AdaptiveGrid already handles 2/3/4 columns. Category chips use ScreenUtil for padding/radius. |
| IV. Theming — Light & Dark via ThemeData | PASS | All colors from Theme.of(context). Gradient overlays use theme-aware colors. Category chip selected/unselected states from colorScheme. |
| V. Error Handling — dartz Either | PASS | All repository methods return Either<Failure, T>. Four-state pattern (loading/error/empty/success) on Home grid and ClassificationDetail. |
| VI. Performance | PASS | CachedNetworkImage for all thumbnails. Video players limited to 2-3 concurrent. Visibility detection pauses off-screen videos. Request cancellation on category switch via CancelToken. |
| VII. Testing — Unit Tests Required | PASS | Unit tests for all use cases, repository implementations, and cubits using mocktail + bloc_test. |
| VIII. Monetization & Firebase | PASS | Premium filtering uses SubscriptionCubit state. Banner ad placeholder at Home bottom for guest users. Premium wallpapers hidden (not badged) for guests. |

**Gate Result**: ALL PASS — proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/003-home-categories-grids/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API + UI contracts)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── api/server_strings.dart          # UPDATE: add category/wallpaper/classification endpoints
│   ├── di/injection_container.dart       # UPDATE: register categories/wallpapers DI
│   ├── routes/routes.dart               # UPDATE: add classification detail route
│   ├── routes/router.dart               # UPDATE: add ClassificationDetail GoRoute
│   ├── utils/app_strings.dart           # UPDATE: add all Phase 3 strings
│   ├── utils/app_dimens.dart            # UPDATE: add category chip, bento card dimensions
│   └── widgets/adaptive_grid.dart       # EXISTING: reuse for image/classification grids
│
├── features/
│   ├── categories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── category_entity.dart         # CategoryEntity with CategoryType enum
│   │   │   │   └── classification_entity.dart   # ClassificationEntity
│   │   │   ├── repositories/
│   │   │   │   └── category_repository.dart     # CategoryRepository contract
│   │   │   └── usecases/
│   │   │       ├── get_categories.dart           # Fetch all categories
│   │   │       └── get_classifications.dart      # Fetch classifications for a category
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── category_model.dart           # Freezed model + toEntity()
│   │   │   │   ├── category_model.freezed.dart
│   │   │   │   ├── category_model.g.dart
│   │   │   │   ├── classification_model.dart     # Freezed model + toEntity()
│   │   │   │   ├── classification_model.freezed.dart
│   │   │   │   └── classification_model.g.dart
│   │   │   ├── datasources/
│   │   │   │   ├── category_remote_data_source.dart   # Retrofit: GET /categories, GET /categories/:id/classifications
│   │   │   │   └── category_local_data_source.dart    # Hive: cache categories
│   │   │   └── repositories/
│   │   │       └── category_repository_impl.dart      # Stale-while-revalidate pattern
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── classification_detail_cubit.dart   # ClassificationDetail page state
│   │       │   └── classification_detail_state.dart   # Freezed states
│   │       ├── pages/
│   │       │   └── classification_detail_page.dart    # Full classification detail screen
│   │       └── widgets/
│   │           ├── classification_bento_grid.dart      # Bento layout widget
│   │           └── classification_card.dart            # Single bento card widget
│   │
│   ├── wallpapers/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── wallpaper_entity.dart              # WallpaperEntity
│   │   │   ├── repositories/
│   │   │   │   └── wallpaper_repository.dart          # WallpaperRepository contract
│   │   │   └── usecases/
│   │   │       ├── get_wallpapers_by_category.dart    # Paginated wallpapers for a category
│   │   │       └── get_wallpapers_by_classification.dart  # Paginated wallpapers for a classification
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── wallpaper_model.dart               # Freezed model + toEntity()
│   │   │   │   ├── wallpaper_model.freezed.dart
│   │   │   │   ├── wallpaper_model.g.dart
│   │   │   │   └── paginated_response.dart            # Generic paginated wrapper
│   │   │   ├── datasources/
│   │   │   │   └── wallpaper_remote_data_source.dart  # Retrofit: GET /wallpapers?category_id=&page=
│   │   │   └── repositories/
│   │   │       └── wallpaper_repository_impl.dart     # With NetworkInfo check
│   │   └── presentation/
│   │       └── widgets/
│   │           ├── wallpaper_grid.dart                 # Image grid with pagination
│   │           ├── wallpaper_thumbnail.dart            # Single image thumbnail card
│   │           ├── video_grid.dart                     # Video grid with pagination
│   │           └── video_thumbnail.dart                # Single video cell with auto-play
│   │
│   └── home/
│       └── presentation/
│           ├── cubit/
│           │   ├── home_cubit.dart                     # Categories + content state management
│           │   └── home_state.dart                     # Freezed states
│           ├── pages/
│           │   └── home_page.dart                      # UPDATE: full Home screen rewrite
│           └── widgets/
│               ├── category_selector.dart              # Horizontal text chip selector
│               ├── content_switcher.dart               # Dynamic grid type switcher
│               └── home_drawer.dart                    # Navigation drawer
│
test/
├── features/
│   ├── categories/
│   │   ├── domain/usecases/                           # GetCategories, GetClassifications tests
│   │   ├── data/repositories/                         # CategoryRepositoryImpl tests
│   │   └── presentation/cubit/                        # ClassificationDetailCubit tests
│   ├── wallpapers/
│   │   ├── domain/usecases/                           # GetWallpapersByCategory, ByClassification tests
│   │   ├── data/repositories/                         # WallpaperRepositoryImpl tests
│   │   └── presentation/                              # (widget tests optional)
│   └── home/
│       └── presentation/cubit/                        # HomeCubit tests
```

**Structure Decision**: Feature-first Clean Architecture. Categories and wallpapers are separate features because they have distinct domain logic and will be consumed by multiple screens (Home, ClassificationDetail, and later Detail/Favorites in Phase 4). Home feature owns the presentation orchestration (HomeCubit combines categories + wallpapers). This matches the existing Phase 1 scaffolding exactly.
