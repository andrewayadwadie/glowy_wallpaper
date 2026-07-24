# Data Model: Fix Cached Wallpaper Thumbnails Re-Downloading on Scroll-Back

This feature adds no domain entities, no repository methods, and no Hive schema changes.
It touches only the caching/infrastructure layer and two presentation-layer call sites.
The "entities" below are configuration/runtime shapes, not persisted domain data.

## Wallpaper Thumbnail (existing — unchanged)

Already modeled by `WallpaperEntity` (`lib/features/wallpapers/domain/entities/wallpaper_entity.dart`).
Relevant existing fields for this feature:

| Field | Type | Relevance here |
|---|---|---|
| `id` | `String`/`int` (existing) | Becomes the `ValueKey` for grid item identity |
| `thumbUrl` | `String` | The URL cached by both `AppCachedImage` and the aspect-ratio probe |

No changes to this entity.

## Cache Manager Configuration (new — not persisted, in-memory config object)

Represents the tuning of the shared, app-wide `CacheManager` used by `AppCachedImage` and
`StaggeredWallpaperCard`'s aspect-ratio probe.

| Attribute | Value | Notes |
|---|---|---|
| `key` | `"glowyWallpaperThumbnailCache"` | Distinct cache folder; must never collide with `cached_network_image`'s `DefaultCacheManager` key (`"libCachedImageData"`) or any future manager |
| `stalePeriod` | 30 days | Entries older than this are treated as stale and re-fetched (spec FR-003) |
| `maxNrOfCacheObjects` | 1000 (floor) | Oldest/least-recently-used entries evicted first once exceeded (spec FR-001) |

Lives in code as a constant/config (e.g., extending `AppDimens` or a new small
`AppCacheConfig`), not as inline magic numbers, per constitution Principle II.

## In-Memory Image Cache Limits (new — runtime tuning, not persisted)

| Attribute | Value | Notes |
|---|---|---|
| `maximumSize` | 400 (image count) | Set once at bootstrap on `PaintingBinding.instance.imageCache` |
| `maximumSizeBytes` | 200 MB (`200 << 20`) | Same bootstrap call; bounded, never unbounded (spec FR-004) |

## Grid Item Identity (new — widget-tree concept, not persisted)

Represents the stable mapping between a wallpaper's `id` and its on-screen grid cell.

| Concept | Shape | Notes |
|---|---|---|
| Grid item key | `ValueKey(wallpaper.id)` | Assigned at the `StaggeredWallpaperCard` call site inside `wallpaper_grid.dart` and `similar_wallpapers_sheet.dart` |
| Scope | Per-`itemBuilder` call | `StaggeredWallpaperGrid<T>` stays generic and does not assign keys itself (spec FR-005) |

## Relationships

```
WallpaperEntity.id ──assigns──> ValueKey (Grid Item Identity)
WallpaperEntity.thumbUrl ──fetched via──> Cache Manager Configuration (shared instance)
                                          │
                                          ├── AppCachedImage (display)
                                          └── StaggeredWallpaperCard aspect-ratio probe (decode)
```

Both consumers of `thumbUrl` (display and aspect-ratio probe) MUST resolve through the
same `CacheManager` instance so a thumbnail is downloaded and stored on disk exactly once,
not twice under two different cache namespaces.
