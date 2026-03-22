# Research: Home, Categories & Content Grids

## Decision 1: Video Player Package

**Decision**: Use `video_player` (Flutter team official package) for video grid cells.
**Rationale**: Official Flutter team package, well-maintained, supports both Android (ExoPlayer) and iOS (AVPlayer). Lightweight enough for grid cells. `chewie` is unnecessary since we only need muted looping auto-play without controls.
**Alternatives considered**:
- `chewie`: Adds UI controls we don't need, extra dependency overhead.
- `better_player`: More features but heavier, overkill for silent thumbnail loops.
- `media_kit`: Powerful but adds native complexity and larger binary size.

## Decision 2: Visibility Detection for Video Auto-Play

**Decision**: Use `visibility_detector` package to detect when video cells enter/exit the viewport.
**Rationale**: Official Google package, lightweight, provides `VisibilityChangedCallback` with `visibleFraction`. Used to start/pause video controllers. Works with any scrollable widget. Combine with a `VideoAutoPlayManager` that tracks the 2-3 most visible cells and manages concurrent player limit.
**Alternatives considered**:
- Manual scroll position calculation: Error-prone, doesn't handle edge cases well.
- `inview_notifier_list`: Less maintained, tighter coupling to specific list types.

## Decision 3: Concurrent Video Player Management

**Decision**: Create a `VideoAutoPlayManager` class that limits active video controllers to 2-3 maximum. When a new video enters the viewport and the limit is reached, the least-visible (or oldest) active player is paused and its thumbnail fallback is shown.
**Rationale**: Each `VideoPlayerController` holds native resources (texture, decoder). On low-end devices, 6+ concurrent players cause frame drops and OOM. The 2-3 limit balances visual richness with performance.
**Implementation approach**:
- `VideoAutoPlayManager` holds a priority queue of active controllers sorted by visibility fraction.
- On visibility change: if fraction > 0.5 and under limit → play. If over limit → pause the least-visible.
- On visibility = 0 → always pause and release from the active queue.

## Decision 4: Stale-While-Revalidate Caching for Categories

**Decision**: Implement stale-while-revalidate in `CategoryRepositoryImpl` using Hive for local cache and Retrofit for remote fetch.
**Rationale**: Categories change infrequently. Show cached categories instantly on Home load, then fetch fresh data in background. If fresh data differs, emit updated state. This gives instant perceived load time while keeping data fresh.
**Implementation approach**:
1. On `getCategories()` call:
   - Read from Hive cache immediately → emit cached data if available.
   - Fetch from server in parallel.
   - If server response differs from cache → update Hive, emit fresh data.
   - If server fails → keep using cached data, no error shown.
2. If no cache exists → show loading state, fetch from server, cache result.

## Decision 5: Pagination Pattern

**Decision**: Page-based pagination using `page` (1-indexed) and `per_page` (default 20) query parameters. Server response includes `has_more` boolean.
**Rationale**: Simple, predictable, and the server API is assumed to support this. Cursor-based would be better for real-time feeds but adds complexity not needed for a wallpaper catalog.
**Implementation approach**:
- `HomeCubit` tracks `currentPage`, `hasReachedEnd`, and `isLoadingMore` per category.
- `ScrollController` listener triggers `loadMore()` when position is within 200px of `maxScrollExtent`.
- `loadMore()` increments page, fetches next page, appends to existing list.
- On category switch: reset page to 1, clear wallpapers, fetch fresh.

## Decision 6: Bento Grid Layout Pattern

**Decision**: Repeating pattern — 1 large card (spans 2 columns) + 2 small cards (1 column each), then repeat. Use `SliverGrid` with custom `SliverGridDelegate` or `StaggeredGrid` from `flutter_staggered_grid_view`.
**Rationale**: User chose this pattern in clarification. Creates visual rhythm and highlights featured classifications. Using a custom `SliverGridDelegate` keeps dependencies minimal (avoid adding `flutter_staggered_grid_view` just for this).
**Implementation approach**:
- Build manually using `Column` + `Row` combinations within a `ListView`:
  - Row 1: 1 large card (full width or 2-col span).
  - Row 2: 2 small cards side by side.
  - Repeat pattern.
- Each card: `ClipRRect` → `Stack` → `AppCachedImage` + gradient overlay + `AutoSizeText` name.
- This avoids adding another dependency while keeping the layout clean.

## Decision 7: Request Cancellation on Category Switch

**Decision**: Use Dio `CancelToken` to cancel in-flight requests when the user switches categories.
**Rationale**: Without cancellation, rapid category switching can cause response ordering issues (old category response arriving after new one) and wasted bandwidth.
**Implementation approach**:
- `HomeCubit` holds a `CancelToken? _activeCancelToken`.
- On `selectCategory(category)`:
  1. Cancel previous token: `_activeCancelToken?.cancel()`.
  2. Create new token: `_activeCancelToken = CancelToken()`.
  3. Pass token to repository/data source methods.
  4. Catch `DioException` with `CancelToken.isCancel(e)` and silently ignore.

## Decision 8: Home Feature Architecture — HomeCubit Design

**Decision**: Single `HomeCubit` manages both category selection and content loading. It depends on `GetCategories`, `GetWallpapersByCategory`, and `GetClassifications` use cases. Content state is nested within Home state.
**Rationale**: Categories and content are tightly coupled on the Home screen — selecting a category immediately triggers content fetch. Splitting into separate cubits would require complex inter-cubit communication. A single cubit keeps the state machine simple.
**State design**:
- `HomeState` (Freezed): `categoriesStatus` (loading/success/error), `categories` list, `selectedCategoryIndex`, `contentStatus` (loading/loadingMore/success/error/empty), `contentItems` (wallpapers or classifications), `currentPage`, `hasReachedEnd`.
- On init: fetch categories → auto-select first → fetch content.
- On category tap: update selectedIndex → reset content → fetch content for new category.
- On scroll end: if not hasReachedEnd → fetch next page → append.

## Decision 9: Drawer Navigation

**Decision**: Custom `Drawer` widget (`HomeDrawer`) with `ListTile` items. Items that navigate to unimplemented screens (Favorites, Downloads, Settings, About, Premium) will use `GoRouter.go()` to placeholder pages or show a "Coming Soon" snackbar.
**Rationale**: Drawer structure must be in place now even though some destinations are Phase 4-6. Using GoRouter ensures proper deep-linking when those features are built.
**Implementation approach**:
- Drawer header: App logo + "Glowy Wallpapers" text.
- Menu items: Icon + AutoSizeText label for each of the 9 sections.
- Home navigates to `/`, others to their respective AppRoutes constants.
- Rate App: launches store URL via `url_launcher` (already in pubspec).
- Share App: uses `share_plus` (needs to be added to pubspec, or show snackbar for now).
- Send Feedback: launches `mailto:` via `url_launcher`.

## Decision 10: New Dependencies Required

**Decision**: Add `video_player` and `visibility_detector` to pubspec.yaml.
**Rationale**: Required for video grid cells (FR-007, FR-008). Both are official Flutter/Google packages with strong maintenance.
**Versions**: Latest stable at time of implementation.
- `video_player`: ^2.9.2 (or latest)
- `visibility_detector`: ^0.4.0+2 (or latest)
- Note: `share_plus` may also be needed for drawer Share App action, but can be deferred to Phase 6 (show snackbar placeholder for now).
