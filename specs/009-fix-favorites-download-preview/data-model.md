# Data Model: Fix Favorites, Download & Preview

**Branch**: `009-fix-favorites-download-preview` | **Date**: 2026-03-26

## Entities

### WallpaperEntity (existing — no changes)

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| id | String | No | UUID from API |
| url | String | No | Full-resolution media URL |
| thumbUrl | String | No | Thumbnail URL for grids |
| isTopRated | bool | No | Badge flag |
| mediaType | MediaType (enum) | No | `image` or `video` |
| classificationId | String | Yes | For classification categories |
| classificationName | String | Yes | Display label |
| classificationThumbnailUrl | String | Yes | Classification card image |
| createdAt | DateTime | No | ISO 8601 from API |

### FavoriteEntity (existing — no changes)

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| wallpaperId | String | No | References WallpaperEntity.id |
| wallpaper | WallpaperEntity | No | Full wallpaper data snapshot |
| userId | String | Yes | Null for guest/local-only |
| favoritedAt | DateTime | No | Timestamp of favorite action |
| syncStatus | FavoriteSyncStatus (enum) | No | `synced`, `pending`, `localOnly` |

### FavoriteModel (existing — no changes)

| Field | JSON Key | Type | Default | Notes |
|-------|----------|------|---------|-------|
| wallpaperId | wallpaper_id | String | required | |
| wallpaper | wallpaper | WallpaperModel | required | Nested, serialized |
| userId | user_id | String? | null | |
| favoritedAt | favorited_at | DateTime | required | |
| syncStatus | sync_status | String | 'synced' | Parsed to enum in toEntity() |

### DownloadRecordEntity (existing — no changes)

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| wallpaperId | String | No | References WallpaperEntity.id |
| imageUrl | String | No | Full-resolution media URL |
| thumbnailUrl | String | No | Thumbnail for grid display |
| title | String | No | Display name |
| downloadedAt | DateTime | No | Timestamp of download |
| fileType | WallpaperFileType (enum) | No | `image` or `video` |

### DownloadRecordModel (existing — no changes)

| Field | JSON Key | Type | Default | Notes |
|-------|----------|------|---------|-------|
| wallpaperId | wallpaper_id | String | required | |
| imageUrl | image_url | String | '' | Full URL, empty default |
| thumbnailUrl | thumbnail_url | String | required | |
| title | title | String | required | |
| downloadedAt | downloaded_at | DateTime | required | |
| fileType | file_type | String | 'image' | Parsed to enum in toEntity() |

## Enums

| Enum | Values | Location |
|------|--------|----------|
| MediaType | `image`, `video` | wallpapers/domain/entities/ |
| WallpaperFileType | `image`, `video` | downloads/domain/entities/ |
| FavoriteSyncStatus | `synced`, `pending`, `localOnly` | favorites/domain/entities/ |

## Storage

| Box Name | Key Pattern | Value | Used By |
|----------|-------------|-------|---------|
| `favorites` | wallpaperId | FavoriteModel JSON | FavoriteLocalDataSource |
| `downloads` | wallpaperId | DownloadRecordModel JSON | DownloadLocalDataSource |

## Relationships

```
WallpaperEntity
  ├── 1:0..1 FavoriteEntity  (via wallpaperId, stored in Hive 'favorites' box)
  └── 1:0..N DownloadRecordEntity  (via wallpaperId, stored in Hive 'downloads' box)
```

## State Transitions

### Favorite Toggle
```
NOT_FAVORITED ──[tap]──► FAVORITED (optimistic) ──[Hive write]──► PERSISTED
FAVORITED ──[tap]──► NOT_FAVORITED (optimistic) ──[Hive delete]──► REMOVED
```

### Download
```
IDLE ──[tap]──► PERMISSION_CHECK ──[granted]──► DOWNLOADING (progress 0→1) ──[complete]──► SAVED_TO_GALLERY + RECORD_PERSISTED
                                  ──[denied]──► PERMISSION_ERROR
DOWNLOADING ──[network error]──► DOWNLOAD_ERROR
```

## Navigation Data Contract

### From Favorites → WallpaperDetail
```
extra: {
  'wallpapers': List<WallpaperEntity>,  // All favorites converted to WallpaperEntity
  'initialIndex': int,                   // Tapped item index
  'categoryType': CategoryType.image,    // Default (no category context)
  'classificationId': null,              // No classification context
}
```

### From Downloads → WallpaperDetail
```
extra: {
  'wallpapers': List<WallpaperEntity>,  // All downloads converted to WallpaperEntity
  'initialIndex': int,                   // Tapped item index
  'categoryType': CategoryType.image,    // Default (inferred from fileType)
  'classificationId': null,              // No classification context
}
```
