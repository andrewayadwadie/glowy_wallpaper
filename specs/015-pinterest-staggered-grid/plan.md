# Implementation Plan: Pinterest-Style Staggered Grid

**Branch**: `015-pinterest-staggered-grid` | **Date**: 2026-04-09 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/015-pinterest-staggered-grid/spec.md`

## Summary

Replace every fixed-aspect-ratio `GridView` / `SliverGrid` in the app with a two-column Pinterest-style masonry layout using `flutter_staggered_grid_view ^0.7.0`. Each card decodes its image aspect ratio on-device after download, shows a shimmer skeleton at the 3:4 fallback height while loading, then animates (resize + fade-in, ≤300 ms) to the correct height. The change is confined to the **presentation layer** — no domain entities, use cases, repositories, or API contracts change.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5  
**Primary Dependencies**: `flutter_staggered_grid_view ^0.7.0` (new), `cached_network_image` (existing), `shimmer` (existing), `flutter_screenutil` (existing), `flutter_bloc` (existing)  
**Storage**: No new storage — aspect ratios are decoded in-memory per card widget lifetime; no persistence needed  
**Testing**: `flutter_test`, `mocktail`, `bloc_test` (existing)  
**Target Platform**: Android (primary), iOS  
**Project Type**: Mobile app — pure presentation layer change  
**Performance Goals**: Smooth scroll at 60 fps through a 50+ item grid on a mid-range Android device; height-transition animation completes in ≤300 ms  
**Constraints**: 2 columns fixed regardless of orientation; no API or data model changes; `CachedNetworkImage` mandatory (raw `Image.network` forbidden); all sizes via ScreenUtil  
**Scale/Scope**: 6 GridSurfaces — WallpaperGrid, VideoGrid, FavoritesGrid, DownloadsGrid, SimilarWallpapersSheet, AdaptiveGrid (fallback)

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture | ✅ Pass | Change confined to presentation layer widgets only. No domain/data imports added to presentation. |
| II. SOLID & DRY | ✅ Pass | Single `StaggeredWallpaperCard` handles all decode/shimmer/animate logic. Single `StaggeredWallpaperGrid` sliver adapter consumed by all 6 surfaces. No duplication. |
| III. ScreenUtil | ✅ Pass | All padding, radius, spacing values use `.w`/`.h`/`.r`. Card width is layout-derived (MasonryGrid column width), not hardcoded. |
| IV. Theming | ✅ Pass | No new colors or text styles. Shimmer colors pulled from `Theme.of(context)`. |
| V. Error Handling | ✅ Pass | Cards handle loading (shimmer), decode failure (stays at fallback 3:4), and image load error via `CachedNetworkImage` error builder. |
| VI. Performance | ✅ Pass | `CachedNetworkImageProvider` used for decode (forbidden raw `Image.network`). Items recycled by SliverMasonryGrid viewport. Streams cancelled on dispose. Animation duration 300 ms, serves UX purpose (masking reflow). |
| VII. Testing | ✅ Pass | Unit tests for `StaggeredWallpaperCard` decode logic; widget tests for grid layout. |
| VIII. Monetization/Firebase | ✅ N/A | No ad or Firebase surfaces changed. |

**Gate result: PASS — proceed to research and design.**

## Project Structure

### Documentation (this feature)

```text
specs/015-pinterest-staggered-grid/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
└── tasks.md             ← Phase 2 output (/speckit.tasks)
```

### Source Code — files changed / created

```text
pubspec.yaml                                               ← add flutter_staggered_grid_view ^0.7.0

lib/core/widgets/
├── adaptive_grid.dart                                     ← UPDATE  (replace SliverGrid → SliverMasonryGrid)
├── staggered_wallpaper_grid.dart                          ← NEW     (SliverMasonryGrid wrapper with pagination)
└── staggered_wallpaper_card.dart                          ← NEW     (shimmer → decode → animate card)

lib/features/wallpapers/presentation/widgets/
├── wallpaper_grid.dart                                    ← UPDATE  (use SliverMasonryGrid via staggered_wallpaper_grid)
└── video_grid.dart                                        ← UPDATE  (use SliverMasonryGrid, preserve visibility logic)

lib/features/favorites/presentation/widgets/
└── favorites_grid.dart                                    ← UPDATE  (replace GridView → MasonryGridView)

lib/features/downloads/presentation/widgets/
└── downloads_grid.dart                                    ← UPDATE  (replace GridView → MasonryGridView)

lib/features/wallpaper_detail/presentation/widgets/
└── similar_wallpapers_sheet.dart                          ← UPDATE  (replace grid section → MasonryGridView)

test/core/widgets/
└── staggered_wallpaper_card_test.dart                     ← NEW     (unit + widget tests)
```

**Structure Decision**: Single Flutter project (lib/ + test/). This is a presentation-only change; no new feature folder is needed. New widgets live in `lib/core/widgets/` since they are shared across all 6 GridSurfaces.

## Complexity Tracking

No constitution violations requiring justification.

## Implementation Phases

### Phase 1 — Package + Core Card Widget

**Goal**: Add the new dependency and build the single reusable `StaggeredWallpaperCard` widget that owns the shimmer → decode → animate lifecycle. All other phases depend on this.

**Tasks**:
1. Add `flutter_staggered_grid_view: ^0.7.0` to `pubspec.yaml`, run `flutter pub get`.
2. Create `lib/core/widgets/staggered_wallpaper_card.dart`:
   - `StatefulWidget` accepting `imageUrl`, `onTap`, and an optional `child` overlay (for badges, play icon).
   - `initState`: resolve `CachedNetworkImageProvider(imageUrl)` via `ImageStream` + `ImageStreamListener`; store completer; cancel on `dispose`.
   - State: `double? _aspectRatio` (null = not yet decoded), `bool _imageLoaded`.
   - Build: `TweenAnimationBuilder<double>` on `_aspectRatio ?? (3/4)` with 300 ms duration → `AspectRatio` wrapper. Inner content is `AnimatedSwitcher` between shimmer (loading) and `AppCachedImage` (loaded).
   - Shimmer: `Shimmer.fromColors` using `Theme.of(context).colorScheme.surfaceContainerHighest` / `surface` — no hardcoded colors.
   - All corner radii via `AppDimens.radiusS.r`; never hardcoded.

### Phase 2 — StaggeredWallpaperGrid Sliver Adapter

**Goal**: Build the shared `SliverMasonryGrid`-based grid widget that `WallpaperGrid` and `VideoGrid` can drop in.

**Tasks**:
1. Create `lib/core/widgets/staggered_wallpaper_grid.dart`:
   - `StaggeredWallpaperGrid<T>` — generic `StatelessWidget` accepting `items`, `itemBuilder`, `isLoadingMore`, `hasReachedEnd`, `onLoadMore`.
   - Internally uses `CustomScrollView` → `SliverPadding` → `SliverMasonryGrid.count(crossAxisCount: 2, crossAxisSpacing: AppDimens.gridSpacing, mainAxisSpacing: AppDimens.gridSpacing)`.
   - Appends `SliverToBoxAdapter` with `AppLoading` when `isLoadingMore` is true.
   - Triggers `onLoadMore` via `NotificationListener<ScrollEndNotification>` at `AppDimens.paginationThreshold` from end.

### Phase 3 — WallpaperGrid & VideoGrid

**Goal**: Replace `SliverGrid` with `StaggeredWallpaperGrid` in the two main browse surfaces.

**Tasks**:
1. `wallpaper_grid.dart`: Replace `CustomScrollView` body with `StaggeredWallpaperGrid`, each item wrapped in `StaggeredWallpaperCard`.
2. `video_grid.dart`: Same replacement. Preserve `VisibilityDetector` wrapping — it goes inside the `itemBuilder`, outside `StaggeredWallpaperCard`. `VideoThumbnail` becomes the overlay child.

### Phase 4 — FavoritesGrid & DownloadsGrid

**Goal**: Replace `GridView.builder` in the two collection screens.

**Tasks**:
1. `favorites_grid.dart`: Replace `GridView.builder` with `MasonryGridView.count(crossAxisCount: 2, ...)`, each item a `StaggeredWallpaperCard` wrapping `WallpaperThumbnail` content.
2. `downloads_grid.dart`: Same. Preserve Hero tag, `ExclusiveBadge`, and `Semantics` wrapper inside the card child.

### Phase 5 — SimilarWallpapersSheet

**Goal**: Replace the grid inside the draggable sheet.

**Tasks**:
1. Identify the grid section in `similar_wallpapers_sheet.dart` and replace with `MasonryGridView.count(crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), ...)` — the sheet's `scrollController` stays on the outer `DraggableScrollableSheet`.
2. Each item rendered via `StaggeredWallpaperCard`.

### Phase 6 — AdaptiveGrid Fallback

**Goal**: Update `AdaptiveGrid` (used for edge-case non-wallpaper content) to also use MasonryGridView, removing the fixed `childAspectRatio`.

**Tasks**:
1. Replace `GridView.builder` in `adaptive_grid.dart` with `MasonryGridView.count`. Remove `childAspectRatio` parameter entirely — children now self-size.

### Phase 7 — Tests & Quality Gate

**Tasks**:
1. Write `test/core/widgets/staggered_wallpaper_card_test.dart`:
   - Test shimmer renders at 3:4 ratio before decode.
   - Test card height reflects decoded ratio after stream emits.
   - Test dispose cancels image stream listener.
2. Run `flutter analyze` — zero warnings required.
3. Run `dart format .`.
4. Run all existing tests — no regressions.
