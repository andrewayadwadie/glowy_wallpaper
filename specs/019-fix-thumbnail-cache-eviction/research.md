# Phase 0 Research: Fix Cached Wallpaper Thumbnails Re-Downloading on Scroll-Back

## 1. Cache manager implementation approach

**Decision**: Use `flutter_cache_manager`'s `CacheManager(Config(...))` directly (no
`BaseCacheManager` subclass), instantiated once and registered as a `registerLazySingleton`
in `lib/core/di/injection_container.dart`. `AppCachedImage` gains an optional
`CacheManager? cacheManager` constructor parameter that defaults to this shared instance
when not supplied by the caller.

**Rationale**: `flutter_cache_manager` is already a transitive dependency of
`cached_network_image` (confirmed in `pubspec.lock`); adding it as an explicit direct
dependency in `pubspec.yaml` is zero new external-package risk. GetIt already provides
singleton semantics, so the classic `flutter_cache_manager` "subclass + static
`getInstance()`" singleton pattern is unnecessary ceremony — constitution Principle II
("no over-engineering... add complexity only when required") favors the plain
`CacheManager` instance.

**Alternatives considered**:
- Subclassing `BaseCacheManager` with a static singleton accessor — rejected, redundant
  with GetIt's own singleton lifecycle; adds a second way to reach the same instance.
- Swapping `cached_network_image` for another package — explicitly forbidden by the
  request ("Don't replace `cached_network_image`").

## 2. Cache capacity & retention values

**Decision**: `maxNrOfCacheObjects: 1000`, `stalePeriod: Duration(days: 30)`, cache key
`"glowyWallpaperThumbnailCache"`.

**Rationale**: Matches the floor explicitly requested ("raise to at least 1000") and the
explicit 30-day retention ask. The key is distinct from `cached_network_image`'s own
`DefaultCacheManager` key (`"libCachedImageData"`), so the new cache gets its own file
folder and does not fight the default manager's 200-object/short-stale-period eviction
for space. No other `CacheManager` currently exists in the app (confirmed by search), so
no other collision risk.

**Alternatives considered**: A dynamic/device-tier-based cache size — rejected as
over-engineering for a bug fix; nothing in the spec calls for adaptive sizing, and it
adds a new failure surface (device-capability detection) for no required benefit.

## 3. In-memory `ImageCache` limits

**Decision**: At bootstrap (`main.dart`, right after `WidgetsFlutterBinding.ensureInitialized()`),
set `PaintingBinding.instance.imageCache.maximumSize = 400` and
`PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20` (200MB). Both values
live in a named constant (extending `AppDimens` or a small new `AppCacheConfig` class) per
constitution Principle II — no inline magic numbers.

**Rationale**: The user's own suggested ranges were ~300–500 images / 150–250MB; 400/200MB
sits at the midpoint of both ranges, giving headroom for a long scroll session without
being unbounded (explicitly disallowed).

**Alternatives considered**: Leaving Flutter's defaults (1000 images / 100MB) — rejected,
that's the status quo causing the bug's secondary contributor (decoded-image eviction
during long sessions even when the disk cache already has the file).

## 4. Grid item identity (`ValueKey`)

**Decision**: Add `key: ValueKey(wallpaper.id)` at the two caller sites that build
`StaggeredWallpaperCard` — `lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart`
and `lib/features/wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart`.
`lib/core/widgets/staggered_wallpaper_grid.dart` itself stays generic/unkeyed — it only
forwards whatever widget the caller's `itemBuilder` returns, and only the caller knows the
item's stable id.

**Rationale**: Confirmed by reading both files — neither currently passes a `key` to
`StaggeredWallpaperCard`, so Flutter has no stable identity to preserve `State`
(`_aspectRatio`, image stream listener) across scroll-driven recycling, risking a
wrong-image flash on a recycled cell and unnecessary aspect-ratio re-resolution.

**Alternatives considered**: Keying inside `StaggeredWallpaperGrid<T>` generically using
`identityHashCode` or list index — rejected; index-based keys don't survive
insertion/reordering, and the generic grid has no reliable notion of "id" for type `T`
without introducing an interface/constraint, which would be unnecessary coupling for a
widget meant to stay generic.

## 5. Aspect-ratio probe also bypasses the shared cache (new finding)

**Decision**: `StaggeredWallpaperCard._resolveAspectRatio()` currently resolves a
**raw** `CachedNetworkImageProvider(widget.imageUrl)` (see
`lib/core/widgets/staggered_wallpaper_card.dart:94`) — this does **not** go through
`AppCachedImage` and therefore does not pick up the new shared `CacheManager` unless it
is also passed explicitly: `CachedNetworkImageProvider(widget.imageUrl, cacheManager: sharedCacheManager)`.

**Rationale**: Left unfixed, every thumbnail would still have two independent cache
entries — one under the new shared manager (for display, via `AppCachedImage`) and one
under `cached_network_image`'s `DefaultCacheManager` (for aspect-ratio decoding, via this
provider). The `DefaultCacheManager` still has its 200-object cap, so the aspect-ratio
probe would keep re-fetching over the network on scroll-back even after the visual fix
lands — directly undermining spec FR-002/SC-003 (near-zero repeat network fetches). This
widget is already inside the ticket's stated blast radius (`staggered_wallpaper_card.dart`
is the concrete implementation backing `wallpaper_grid.dart`'s cards), so wiring it to the
same shared instance is treated as in-scope, not scope creep.

**Alternatives considered**: Leave the probe on the default manager — rejected, it would
silently reintroduce a partial version of the exact bug being fixed.

## 6. Confirmed out-of-scope grids

**Decision**: `lib/features/favorites/presentation/widgets/favorites_grid.dart` and
`lib/features/downloads/presentation/widgets/downloads_grid.dart` were checked and do
**not** route through `StaggeredWallpaperGrid`/`StaggeredWallpaperCard` — they are separate
grid implementations. No changes needed there for this fix; flagged in plan.md so a future
contributor doesn't assume they're silently covered.

## 7. Backend cache-friendliness headers (FR-009 — report only)

**Decision**: Deferred to a manual check during task execution (e.g., inspect response
headers for a representative `thumbUrl`) and reported as a follow-up note — per explicit
instruction, this is investigate-and-report, not a code change, and does not block this
plan.
