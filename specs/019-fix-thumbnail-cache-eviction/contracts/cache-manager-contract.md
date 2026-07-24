# Internal Contracts: Shared Cache Manager & `AppCachedImage`

This app exposes no external API for this feature — the "contracts" here are the
internal widget/DI contracts other code and tests rely on.

## 1. DI registration contract

**Provider**: `lib/core/services/wallpaper_cache_manager.dart`
**Registered in**: `lib/core/di/injection_container.dart`

```dart
sl.registerLazySingleton<CacheManager>(
  () => CacheManager(
    Config(
      AppCacheConfig.thumbnailCacheKey,        // "glowyWallpaperThumbnailCache"
      stalePeriod: AppCacheConfig.thumbnailStalePeriod,   // 30 days
      maxNrOfCacheObjects: AppCacheConfig.thumbnailMaxObjects, // 1000
    ),
  ),
  instanceName: 'wallpaperThumbnailCacheManager',
);
```

**Contract**:
- Exactly one instance exists for the lifetime of the app (GetIt lazy singleton).
- The instance name (or type, if kept unique) MUST be stable so `AppCachedImage` and
  `StaggeredWallpaperCard` resolve the *same* object.
- Registration MUST NOT throw — `CacheManager` construction is synchronous and
  side-effect-free until first disk access.

## 2. `AppCachedImage` public API contract

**File**: `lib/core/widgets/app_cached_image.dart`

**Before** (current):

```dart
const AppCachedImage({
  super.key,
  required this.imageUrl,
  this.width,
  this.height,
  this.fit = BoxFit.cover,
  this.memCacheWidth,
  this.memCacheHeight,
  this.semanticLabel,
});
```

**After** (additive, backward compatible):

```dart
const AppCachedImage({
  super.key,
  required this.imageUrl,
  this.width,
  this.height,
  this.fit = BoxFit.cover,
  this.memCacheWidth,
  this.memCacheHeight,
  this.semanticLabel,
  this.cacheManager,   // NEW — CacheManager?, defaults to shared instance when null
});
```

**Contract**:
- All existing call sites that omit `cacheManager` continue to compile and behave
  identically except that images now persist in the shared, larger, longer-lived cache
  instead of `cached_network_image`'s `DefaultCacheManager`.
- Passing an explicit `cacheManager` overrides the default (escape hatch for any future
  caller that needs isolation — not required by any current call site).
- `memCacheWidth`/`memCacheHeight` auto-calculation logic is untouched.
- `Hero`/`Semantics` wrapping behavior is untouched.

## 3. `StaggeredWallpaperCard` aspect-ratio probe contract

**File**: `lib/core/widgets/staggered_wallpaper_card.dart`

**Before**:

```dart
final provider = CachedNetworkImageProvider(widget.imageUrl);
```

**After**:

```dart
final provider = CachedNetworkImageProvider(
  widget.imageUrl,
  cacheManager: sl<CacheManager>(instanceName: 'wallpaperThumbnailCacheManager'),
);
```

**Contract**:
- The provider used to decode aspect ratio MUST resolve through the same `CacheManager`
  instance as `AppCachedImage`, so a given `imageUrl` has exactly one on-disk cache entry
  regardless of whether it's being probed for aspect ratio or rendered for display.
- No change to the widget's public constructor or its `key`/`onTap`/`heroTag`/`overlay`/
  `semanticLabel`/`child` parameters.

## 4. Grid item identity contract

**Files**: `lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart`,
`lib/features/wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart`

**Contract**:
- Every `StaggeredWallpaperCard` built inside a grid `itemBuilder` MUST carry
  `key: ValueKey(wallpaper.id)`.
- `wallpaper.id` MUST be unique within the list passed to `StaggeredWallpaperGrid`/
  `MasonryGridView` at any given time (already guaranteed by existing pagination logic,
  which appends distinct pages without duplication).
- `StaggeredWallpaperGrid<T>`'s own public API (`items`, `itemBuilder`, `isLoadingMore`,
  `hasReachedEnd`, `onLoadMore`, `padding`) is unchanged — it remains the caller's
  responsibility to key the widget it returns.
