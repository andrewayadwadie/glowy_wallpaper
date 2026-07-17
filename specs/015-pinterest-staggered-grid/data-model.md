# Data Model: Pinterest-Style Staggered Grid

**Feature**: 015-pinterest-staggered-grid  
**Date**: 2026-04-09

> This feature is **presentation-layer only**. No new Hive boxes, no new API endpoints, no new domain entities or use cases. The data model described here covers the widget contracts and in-memory state introduced by the new card widget.

---

## Widget State: StaggeredWallpaperCard

Manages the per-card lifecycle (shimmer → decode → animate).

| State Field | Type | Initial Value | Description |
|-------------|------|---------------|-------------|
| `_aspectRatio` | `double?` | `null` | Decoded width/height ratio. `null` = not yet decoded. |
| `_imageLoaded` | `bool` | `false` | True once `ImageStreamListener` fires successfully. |
| `_imageStream` | `ImageStream?` | `null` | Reference held so listener can be removed on `dispose`. |
| `_listener` | `ImageStreamListener?` | `null` | Reference held for `removeListener` on `dispose`. |

**Validation rules**:
- `_aspectRatio` must be `> 0` if set; any zero/negative value from decode is discarded and fallback (0.75) is used.
- If `_imageLoaded` is true, shimmer is hidden and `TweenAnimationBuilder` targets `_aspectRatio`.

**State transitions**:
```
[initial]
  → shimmer visible, aspectRatio = null → TweenAnimationBuilder targets 0.75 (3/4)
  
[ImageStream fires successfully]
  → _aspectRatio = width/height, _imageLoaded = true
  → TweenAnimationBuilder animates 0.75 → decoded ratio (300ms, easeOutCubic)
  → Shimmer replaced by AppCachedImage via AnimatedSwitcher
  
[ImageStream fires error OR widget disposed before decode]
  → _aspectRatio stays null, stays at 0.75 permanently
  → CachedNetworkImage error builder shown in place of shimmer
```

---

## Widget Interface: StaggeredWallpaperCard

Public API consumed by all 6 GridSurfaces.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `imageUrl` | `String` | Yes | URL of the wallpaper image. Used for both decode and display. |
| `onTap` | `VoidCallback` | Yes | Called when user taps the card. |
| `heroTag` | `Object?` | No | If provided, wraps the card in a `Hero` widget with this tag. |
| `overlay` | `Widget?` | No | Positioned at top-left of the card (e.g., `ExclusiveBadge`, play icon). |
| `semanticLabel` | `String?` | No | Accessibility label for `Semantics` wrapper. |

---

## Widget Interface: StaggeredWallpaperGrid\<T\>

Generic sliver-based grid adapter for `CustomScrollView` surfaces (WallpaperGrid, VideoGrid).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `items` | `List<T>` | Yes | Items to display. |
| `itemBuilder` | `Widget Function(BuildContext, T, int)` | Yes | Builds each card widget. |
| `isLoadingMore` | `bool` | Yes | Shows `AppLoading` sliver at bottom when true. |
| `hasReachedEnd` | `bool` | Yes | Suppresses `onLoadMore` trigger when true. |
| `onLoadMore` | `VoidCallback` | Yes | Called when scroll reaches `paginationThreshold` from end. |
| `padding` | `EdgeInsetsGeometry?` | No | Defaults to `EdgeInsets.all(AppDimens.paddingM)`. |

---

## Existing Entities (unchanged)

These domain entities are referenced by the presentation layer but are **not modified**.

| Entity | Location | Relevant Fields |
|--------|----------|----------------|
| `WallpaperEntity` | `lib/features/wallpapers/domain/entities/` | `id`, `url`, `thumbUrl`, `mediaType` |
| `FavoriteEntity` | `lib/features/favorites/domain/entities/` | `wallpaper` (WallpaperEntity) |
| `DownloadRecordEntity` | `lib/features/downloads/domain/entities/` | `wallpaperId`, `imageUrl`, `thumbnailUrl`, `isTopRated` |

---

## Aspect Ratio Reference Values

| Content Type | Typical Ratio (w/h) | Card Behavior |
|---|---|---|
| Portrait wallpaper (most common) | 0.56 – 0.75 | Tall card |
| Square | 1.0 | Equal width/height |
| Landscape wallpaper | 1.33 – 1.78 | Short, wide card |
| Fallback (decode pending/failed) | 0.75 (3/4) | Default portrait-ish height |
