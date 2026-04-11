# Tasks: Pinterest-Style Staggered Grid

**Input**: Design documents from `/specs/015-pinterest-staggered-grid/`  
**Prerequisites**: plan.md ✅ spec.md ✅ research.md ✅ data-model.md ✅ quickstart.md ✅

**Tests**: Widget tests included for the foundational `StaggeredWallpaperCard` only (no TDD flag set; other story tasks do not include test tasks).

**Organization**: Tasks grouped by user story — each story is independently implementable and testable.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: User story this task belongs to (US1/US2/US3)

## Path Conventions

Flutter mobile project — all source under `lib/`, tests under `test/`.

---

## Phase 1: Setup

**Purpose**: Add the new package dependency so all subsequent phases can compile.

- [X] T001 Add `flutter_staggered_grid_view: ^0.7.0` to `pubspec.yaml` dependencies section and run `flutter pub get`

**Checkpoint**: `flutter pub get` completes with no resolution errors; `flutter analyze` still passes.

---

## Phase 2: Foundational (Blocking Prerequisite)

**Purpose**: Build the single reusable `StaggeredWallpaperCard` widget. Every user story depends on this widget — no story phase can begin until T002 is complete.

**⚠️ CRITICAL**: All three user story phases depend on T002. Do not start US1/US2/US3 until T002 is done.

- [X] T002 Create `lib/core/widgets/staggered_wallpaper_card.dart` — `StatefulWidget` that: (1) resolves `CachedNetworkImageProvider(imageUrl)` via `ImageStream` + `ImageStreamListener` in `initState`; (2) stores `double? _aspectRatio` and `bool _imageLoaded`; (3) cancels stream listener in `dispose`; (4) renders `Shimmer.fromColors` skeleton at `AspectRatio(aspectRatio: 3/4)` while loading; (5) wraps content in `TweenAnimationBuilder<double>(tween: Tween(begin: 0.75, end: _aspectRatio ?? 0.75), duration: 300ms, curve: Curves.easeOutCubic)` → `AspectRatio`; (6) uses `AnimatedSwitcher` to fade-in `AppCachedImage` once loaded; (7) accepts `imageUrl`, `onTap`, optional `heroTag` (`Hero` wrapper), `overlay` (`Positioned` top-left), `semanticLabel` (`Semantics` wrapper); (8) all sizes via ScreenUtil (`.r`, `.w`, `.h`)
- [X] T003 [P] Create `test/core/widgets/staggered_wallpaper_card_test.dart` — widget tests: (1) shimmer visible and height = `width * (4/3)` before decode; (2) card transitions to decoded aspect ratio after `ImageStream` callback; (3) overlay widget appears at top-left when provided; (4) `dispose` removes `ImageStreamListener` without error; use `mocktail` for `CachedNetworkImageProvider`

**Checkpoint**: `flutter test test/core/widgets/staggered_wallpaper_card_test.dart` passes. `StaggeredWallpaperCard` is fully functional in isolation.

---

## Phase 3: User Story 1 — Browse Wallpapers in Staggered Layout (Priority: P1) 🎯 MVP

**Goal**: Replace the fixed-aspect-ratio `SliverGrid` in all main browse surfaces (Home, Category, Classification Detail) with a two-column masonry layout using `StaggeredWallpaperCard`.

**Independent Test**: Launch the app → tap any category → verify items render in two staggered columns with variable heights after images decode. Shimmer placeholders show at 3:4 ratio while loading.

### Implementation for User Story 1

- [X] T004 [US1] Create `lib/core/widgets/staggered_wallpaper_grid.dart` — generic `StaggeredWallpaperGrid<T>` `StatelessWidget`: (1) wraps `CustomScrollView` with `SliverPadding` → `SliverMasonryGrid.count(crossAxisCount: 2, crossAxisSpacing: AppDimens.gridSpacing, mainAxisSpacing: AppDimens.gridSpacing)`; (2) accepts `items`, `itemBuilder`, `isLoadingMore`, `hasReachedEnd`, `onLoadMore`, optional `padding`; (3) appends `SliverToBoxAdapter` with `AppLoading` when `isLoadingMore` is true; (4) triggers `onLoadMore` via `NotificationListener<ScrollEndNotification>` at `AppDimens.paginationThreshold` from scroll end
- [X] T005 [US1] Update `lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart` — replace `CustomScrollView` + `SliverGrid` body with `StaggeredWallpaperGrid<WallpaperEntity>`; each `itemBuilder` returns `StaggeredWallpaperCard(imageUrl: wallpaper.thumbUrl, onTap: () => onWallpaperTapped(wallpaper), heroTag: 'wallpaper_${wallpaper.id}')`; remove `SliverGridDelegateWithFixedCrossAxisCount` and `childAspectRatio: 0.75`
- [X] T006 [US1] Update `lib/features/wallpapers/presentation/widgets/video_grid.dart` — replace `SliverGrid` with `StaggeredWallpaperGrid<WallpaperEntity>`; in `itemBuilder` preserve `VisibilityDetector(key: Key('video_\${wallpaper.id}'), ...)` wrapping the `StaggeredWallpaperCard`; pass `VideoThumbnail` as `overlay` child inside `StaggeredWallpaperCard`; `_autoPlayIndices` visibility logic in `_VideoGridState` is unchanged
- [X] T007 [P] [US1] Update `lib/features/categories/presentation/pages/classification_detail_page.dart` — locate any `SliverGrid` or `GridView` usage; replace with `SliverMasonryGrid.count(crossAxisCount: 2, crossAxisSpacing: AppDimens.gridSpacing, mainAxisSpacing: AppDimens.gridSpacing)`; each child is `StaggeredWallpaperCard` with appropriate `imageUrl`, `onTap`, `heroTag`
- [X] T008 [P] [US1] Inspect `lib/features/home/presentation/widgets/content_switcher.dart` — if it contains its own `GridView`/`SliverGrid` instantiation, replace with `StaggeredWallpaperGrid` or `MasonryGridView.count`; if it purely renders `WallpaperGrid`/`VideoGrid` as child widgets (already updated in T005/T006), verify no layout changes are needed and leave unchanged

**Checkpoint**: All main browse grids show Pinterest-style staggered layout. User Story 1 is fully functional — test by navigating to Home, any Category, and Classification Detail screens.

---

## Phase 4: User Story 2 — Favorites & Downloads Staggered Grids (Priority: P2)

**Goal**: Apply the staggered layout to the Favorites and Downloads collection screens.

**Independent Test**: Save 4+ wallpapers with different aspect ratios → open Favorites → verify staggered two-column layout. Open Downloads → verify same. Empty state shows correctly when no items present.

### Implementation for User Story 2

- [X] T009 [P] [US2] Update `lib/features/favorites/presentation/widgets/favorites_grid.dart` — replace `GridView.builder` with `MasonryGridView.count(crossAxisCount: 2, crossAxisSpacing: AppDimens.gridSpacing, mainAxisSpacing: AppDimens.gridSpacing, padding: EdgeInsets.all(AppDimens.paddingM), ...)`; each `itemBuilder` returns `StaggeredWallpaperCard(imageUrl: fav.wallpaper.thumbUrl, onTap: () => onTap(fav), heroTag: 'wallpaper_\${fav.wallpaper.id}')`; remove `SliverGridDelegateWithFixedCrossAxisCount` and `childAspectRatio`; add `import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'`
- [X] T010 [P] [US2] Update `lib/features/downloads/presentation/widgets/downloads_grid.dart` — replace `GridView.builder` with `MasonryGridView.count(crossAxisCount: 2, ...)`; each `itemBuilder` returns `StaggeredWallpaperCard(imageUrl: record.thumbnailUrl, onTap: () => onTap(record), heroTag: 'wallpaper_\${record.wallpaperId}', overlay: record.isTopRated ? const ExclusiveBadge() : null, semanticLabel: AppStrings.wallpaperDetail)`; preserve `Semantics` wrapper and `Hero` by passing `heroTag` to card; remove old `Hero`/`ClipRRect`/`Stack` manual nesting (now handled inside `StaggeredWallpaperCard`)

**Checkpoint**: Favorites and Downloads screens both show Pinterest-style staggered layout independently of browse grids. Empty states unchanged and functional.

---

## Phase 5: User Story 3 — Similar Wallpapers Sheet Staggered Layout (Priority: P3)

**Goal**: Apply the staggered layout to the Similar Wallpapers section inside the wallpaper detail draggable sheet.

**Independent Test**: Open any wallpaper detail → scroll to Similar Wallpapers section → verify staggered two-column layout with variable heights.

### Implementation for User Story 3

- [X] T011 [US3] Update `lib/features/wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart` — locate the grid section inside `DraggableScrollableSheet`; replace `GridView` or `SliverGrid` with `MasonryGridView.count(crossAxisCount: 2, crossAxisSpacing: AppDimens.gridSpacing, mainAxisSpacing: AppDimens.gridSpacing, shrinkWrap: true, physics: const NeverScrollableScrollPhysics())`; the outer `DraggableScrollableSheet`'s `scrollController` drives scrolling — the inner `MasonryGridView` must be non-scrolling; each item renders `StaggeredWallpaperCard(imageUrl: wallpaper.thumbUrl, onTap: () => onTap(wallpaper), heroTag: 'similar_\${wallpaper.id}')`

**Checkpoint**: Similar Wallpapers sheet shows staggered layout. Loading, error, and empty states inside the sheet are unchanged. All three user stories are now independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Update the shared fallback widget, clean up, and run the quality gate.

- [X] T012 [P] Update `lib/core/widgets/adaptive_grid.dart` — replace `GridView.builder` with `MasonryGridView.count(crossAxisCount: 2, crossAxisSpacing: spacing.w, mainAxisSpacing: spacing.h)`; remove `childAspectRatio` parameter entirely (children now self-size); `shrinkWrap: true` and `physics: NeverScrollableScrollPhysics()` preserved; add `import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'`
- [X] T013 Run `flutter analyze` from repo root — must report **zero warnings or errors**; fix any issues before proceeding
- [X] T014 [P] Run `dart format .` from repo root — commit all formatting changes
- [X] T015 Run `flutter test` — full test suite must pass with no regressions; fix any failures before marking complete

**Checkpoint**: `flutter analyze` clean, `dart format .` clean, all tests green. Feature is shippable.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1 — T001)**: No dependencies — start immediately
- **Foundational (Phase 2 — T002, T003)**: Depends on T001 — **BLOCKS all user story phases**
- **User Story 1 (Phase 3 — T004–T008)**: Depends on T002 — T004 must complete before T005/T006/T007/T008
- **User Story 2 (Phase 4 — T009, T010)**: Depends on T002 only — can run in **parallel with Phase 3**
- **User Story 3 (Phase 5 — T011)**: Depends on T002 only — can run in **parallel with Phases 3 & 4**
- **Polish (Phase 6 — T012–T015)**: Depends on all story phases complete

### User Story Dependencies

- **US1**: Needs T001 + T002 + T004 (sequential within story) → T005, T006, T007, T008 (parallel after T004)
- **US2**: Needs T001 + T002 → T009, T010 (parallel with each other, parallel with US1)
- **US3**: Needs T001 + T002 → T011 (parallel with US1 & US2)

### Within User Story 1

```text
T001 → T002 → T004 → T005
                   → T006
                   → T007 [P]
                   → T008 [P]
```

### Parallel Opportunities

```bash
# After T002 completes, launch all three story phases simultaneously:
[US1] T004 → T005, T006, T007, T008
[US2] T009, T010        # parallel with US1
[US3] T011              # parallel with US1 & US2

# Within US1, after T004:
T005  # wallpaper_grid.dart
T006  # video_grid.dart
T007  # classification_detail_page.dart  [P]
T008  # content_switcher.dart            [P]

# Within US2 (fully parallel with each other):
T009  # favorites_grid.dart              [P]
T010  # downloads_grid.dart              [P]
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. T001 — Add package
2. T002 — Build `StaggeredWallpaperCard`
3. T003 — Write widget tests
4. T004 — Build `StaggeredWallpaperGrid`
5. T005, T006, T007, T008 — Update all US1 browse surfaces
6. **STOP AND VALIDATE**: Browse grids show Pinterest-style layout
7. Run `flutter analyze` + `dart format .`

### Full Incremental Delivery

1. Phase 1 + Phase 2 → Core card ready
2. Phase 3 (US1) → Browse grids staggered — **demo-able MVP**
3. Phase 4 (US2) → Favorites & Downloads staggered
4. Phase 5 (US3) → Similar Wallpapers staggered
5. Phase 6 → Polish + quality gate

---

## Notes

- `classification_bento_grid.dart` is **explicitly out of scope** — do not modify
- `WallpaperThumbnail` widget internals are **unchanged** — `StaggeredWallpaperCard` wraps or replaces its usage at the grid level, not inside the thumbnail itself
- All `AppDimens.gridSpacing`, `AppDimens.paddingM`, `AppDimens.paginationThreshold` constants remain unchanged
- Hero tags must be unique per surface: use `'wallpaper_\${id}'` for browse/favorites/downloads and `'similar_\${id}'` for similar wallpapers sheet
- `[P]` tasks operate on different files — safe to execute simultaneously
