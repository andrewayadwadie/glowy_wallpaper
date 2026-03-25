# Data Model: Real API Integration

**Branch**: `007-api-integration` | **Date**: 2026-03-25

---

## New Entities

### AppMetadataEntity

Represents the full bootstrap response from API-1. Cached locally and refreshed in the background on every launch.

```
AppMetadataEntity {
  name:              String        — App display name (e.g. "Glowy Wallpaper")
  description:       String        — Short app description
  about:             String        — Full about text (replaces hardcoded ContentPage body)
  privacyPolicy:     String        — Full privacy policy text
  termsOfUse:        String        — Full terms of use text
  androidShareLink:  String        — Google Play store URL for Share App (Android)
  iphoneShareLink:   String        — App Store URL for Share App (iOS)
  contactEmail:      String        — Support email for Send Feedback action
  categories:        List<CategoryEntity>  — Sorted category list (by displayOrder)
}
```

**Validation rules**:
- `name` must not be empty
- `categories` may be empty (edge case: app with no active categories)
- `androidShareLink` and `iphoneShareLink` must be valid URLs

**Lifecycle**:
- Created on first successful bootstrap fetch
- Cached to Hive box `app_bootstrap`
- Stale-while-revalidate: served from cache immediately, refreshed in background on every launch
- No TTL — cache is always valid; background fetch always runs

**Cache key**: `'app_metadata'` in Hive box `'app_bootstrap'`

---

## Updated Entities

### CategoryEntity *(updated)*

Previously lacked `imageCount`. Field `thumbnailUrl` removed (API-1 does not return it).

```
CategoryEntity {
  id:           String        — UUID, used as categoryId in content and classification APIs
  name:         String        — Display label in carousel chip
  type:         CategoryType  — IMAGES | VIDEOS | IMAGE_CLASSIFICATION
  displayOrder: int           — Sort order for carousel (ascending)
  imageCount:   int           — Badge / subtitle count (NEW)
}
```

**Note**: `thumbnailUrl` was a placeholder — removed from model as it is not part of the API contract.

---

### WallpaperEntity *(fully updated)*

Previous model had placeholder fields (`title`, `imageUrl`, `videoUrl`, `isPremium`). Replaced entirely to match API-2.

```
WallpaperEntity {
  id:                          String    — UUID
  url:                         String    — Full-resolution media URL
  thumbUrl:                    String    — Thumbnail URL for grid display
  isTopRated:                  bool      — Top-rated badge / sort signal
  mediaType:                   MediaType — IMAGE | VIDEO
  classificationId:            String?   — null for non-classification categories
  classificationName:          String?   — null for non-classification categories
  classificationThumbnailUrl:  String?   — null for non-classification categories
  createdAt:                   DateTime  — ISO 8601 creation date
}
```

**Validation rules**:
- `url` and `thumbUrl` must be non-empty strings
- `classificationId` / `classificationName` / `classificationThumbnailUrl` are all null or all non-null (consistent triple)

**MediaType enum** (new):
```
enum MediaType { image, video }
```
Maps from API string: `"IMAGE"` → `MediaType.image`, `"VIDEO"` → `MediaType.video`

---

### ClassificationEntity *(updated)*

Field rename: `wallpaperCount` → `itemCount` to match API-3.

```
ClassificationEntity {
  id:           String    — UUID, used as classificationId in content API filter
  name:         String    — Display label on bento card
  thumbnailUrl: String    — Bento card background image URL
  itemCount:    int       — Badge count on card (renamed from wallpaperCount)
}
```

---

### PaginatedResponse *(updated)*

```
PaginatedResponse<T> {
  items:       List<T>   — Current page items
  page:        int       — Current page number (1-based)
  limit:       int       — Items per page (default 20)
  total:       int       — Total item count across all pages
  totalPages:  int       — Total number of pages (NEW — replaces hasMore: bool)
}
```

**Computed property** (in domain layer, not in model):
```
bool get hasReachedEnd => page >= totalPages;
```

**Breaking change**: `hasMore: bool` field removed. All consumers updated to use `page >= totalPages` comparison.

---

## New Data Models (Data Layer)

### AppMetadataModel

Freezed + JSON serializable model. Maps API-1 envelope → `AppMetadataEntity`.

```
AppMetadataModel {
  name:             String
  description:      String
  about:            String
  privacyPolicy:    String
  termsOfUse:       String
  androidShareLink: String
  iphoneShareLink:  String
  contactEmail:     String
  categories:       List<CategoryModel>
}
```

**JSON source path**: `data.app` in the bootstrap response envelope.

**Hive storage**: serialized via `toJson()` / `fromJson()` — no generated HiveType adapter needed.

---

## State Changes (Presentation Layer)

### HomeState *(updated)*

New field added:

```
HomeState {
  ...existing fields...
  appMetadata:       AppMetadataEntity?   — null until bootstrap completes (NEW)
}
```

**Impact on widgets**:
- `HomeDrawer`: reads `context.watch<HomeCubit>().state.appMetadata` for share links, email, app name
- `ContentPage`: reads `appMetadata?.about`, `appMetadata?.privacyPolicy`, `appMetadata?.termsOfUse`

---

## Hive Storage Map

| Box Name          | Key                | Value Type         | Feature      |
|-------------------|--------------------|--------------------|--------------|
| `app_bootstrap`   | `'app_metadata'`   | JSON Map           | app (new)    |
| `categories_cache`| `'categories_cache'`| JSON List         | categories   |
| `categories_cache`| `'categories_timestamp'` | int (ms) | categories   |

**Note**: The `categories_cache` Hive box is now superseded by `app_bootstrap` for categories storage. During migration, the old box can remain but new writes go to `app_bootstrap`. Categories are extracted from `AppMetadataEntity.categories` rather than fetched from the old `/categories` endpoint.

---

## AppConfig Changes

```
AppConfig {
  // Existing constants (unchanged)
  appName:            String  — Compile-time fallback only (real name from API)
  appVersion:         String  — Not from API (compile-time)
  buildNumber:        String  — Not from API (compile-time)
  androidPackageName: String  — Still needed for store URL construction fallback
  iosAppId:           String  — Still needed for store URL construction fallback

  // Updated
  feedbackEmail:      String  — REMOVED as source-of-truth (now from API); kept as fallback default

  // New
  appId:              String  — Backend app identifier for all API routes (REQUIRED)
}
```

---

## Dependency Flow

```
Bootstrap API (API-1)
  └─► BootstrapRemoteDataSource
        └─► AppRepositoryImpl
              ├─► (cache) BootstrapLocalDataSource → Hive 'app_bootstrap'
              └─► AppMetadataEntity
                    ├─► HomeState.appMetadata
                    │     ├─► HomeDrawer (share links, email, app name)
                    │     └─► ContentPage (about, privacy, terms)
                    └─► HomeState.categories (extracted List<CategoryEntity>)
                          └─► HomeCubit → auto-selects first category

Content API (API-2)
  └─► WallpaperRemoteDataSource.getWallpapersByCategory(
        categoryId, page, limit, classificationId?)
        └─► WallpaperRepositoryImpl
              └─► PaginatedResponse<WallpaperEntity>
                    └─► HomeCubit → appended to HomeState.wallpapers

Classifications API (API-3)
  └─► CategoryRemoteDataSource.getClassifications(categoryId)
        └─► CategoryRepositoryImpl
              └─► List<ClassificationEntity>
                    └─► HomeCubit → HomeState.classifications
```
