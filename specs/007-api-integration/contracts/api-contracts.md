# API Contracts: Real API Integration

**Branch**: `007-api-integration` | **Date**: 2026-03-25

These contracts document the exact HTTP request/response shapes that the Flutter data sources must implement. All responses follow the envelope: `{ "success": bool, "data": {...}, "message": string }`.

---

## Public Dio Client

All three endpoints below are **public** (no Authorization header). The `publicDio` instance registered in `InjectionContainer` does NOT include `AuthInterceptor`.

**Base URL**: configured per environment via `AppConfig.baseUrl` (envied)
**App ID**: `AppConfig.appId` — injected into all route templates below

---

## Contract 1: Bootstrap (API-1)

### Request

```
GET /api/v1/mobile/apps/{appId}
Headers:
  Content-Type: application/json
  (no Authorization header)
```

### Success Response (200)

```json
{
  "success": true,
  "data": {
    "app": {
      "name": "Glowy Wallpaper",
      "description": "High-quality glowing and neon wallpapers",
      "about": "Glowy Wallpapers is a curated collection...",
      "privacyPolicy": "Your privacy is important to us...",
      "termsOfUse": "By using Glowy Wallpapers, you agree...",
      "androidShareLink": "https://play.google.com/store/apps/details?id=com.glowy.wallpaper",
      "iphoneShareLink": "https://apps.apple.com/app/id123456789",
      "contactEmail": "support@glowywallpapers.com",
      "categories": [
        {
          "id": "cat-uuid-1",
          "name": "Neon",
          "type": "IMAGES",
          "displayOrder": 1,
          "imageCount": 142
        },
        {
          "id": "cat-uuid-2",
          "name": "Live Wallpapers",
          "type": "VIDEOS",
          "displayOrder": 2,
          "imageCount": 38
        },
        {
          "id": "cat-uuid-3",
          "name": "By Style",
          "type": "IMAGE_CLASSIFICATION",
          "displayOrder": 3,
          "imageCount": 0
        }
      ]
    }
  },
  "message": "App data retrieved successfully"
}
```

### Error Responses

```json
// 404 — App ID not found
{ "success": false, "data": null, "message": "App not found" }

// 500 — Server error
{ "success": false, "data": null, "message": "Internal server error" }
```

### Data Source Mapping

| API Field | Model Field | Notes |
|-----------|-------------|-------|
| `data.app.name` | `AppMetadataModel.name` | |
| `data.app.description` | `AppMetadataModel.description` | |
| `data.app.about` | `AppMetadataModel.about` | Replaces hardcoded string |
| `data.app.privacyPolicy` | `AppMetadataModel.privacyPolicy` | Replaces hardcoded string |
| `data.app.termsOfUse` | `AppMetadataModel.termsOfUse` | Replaces hardcoded string |
| `data.app.androidShareLink` | `AppMetadataModel.androidShareLink` | |
| `data.app.iphoneShareLink` | `AppMetadataModel.iphoneShareLink` | |
| `data.app.contactEmail` | `AppMetadataModel.contactEmail` | |
| `data.app.categories[]` | `AppMetadataModel.categories` | Parsed as `List<CategoryModel>` |
| `categories[].id` | `CategoryModel.id` | |
| `categories[].name` | `CategoryModel.name` | |
| `categories[].type` | `CategoryModel.type` | String → CategoryType enum |
| `categories[].displayOrder` | `CategoryModel.displayOrder` | |
| `categories[].imageCount` | `CategoryModel.imageCount` | NEW field |

---

## Contract 2: Category Content (API-2)

### Request

```
GET /api/v1/mobile/apps/{appId}/categories/{categoryId}/content
Query params:
  page={page}              — required, 1-based integer
  limit={limit}            — required, default 20
  classificationId={id}    — optional, filters to classification
Headers:
  Content-Type: application/json
  (no Authorization header)
```

### Success Response (200)

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "wp-uuid-1",
        "url": "https://cdn.example.com/wallpapers/neon-city-full.jpg",
        "thumbUrl": "https://cdn.example.com/wallpapers/neon-city-thumb.jpg",
        "isTopRated": true,
        "mediaType": "IMAGE",
        "classificationId": null,
        "classificationName": null,
        "classificationThumbnailUrl": null,
        "createdAt": "2025-11-15T08:30:00.000Z"
      },
      {
        "id": "wp-uuid-2",
        "url": "https://cdn.example.com/wallpapers/glow-loop.mp4",
        "thumbUrl": "https://cdn.example.com/wallpapers/glow-loop-thumb.jpg",
        "isTopRated": false,
        "mediaType": "VIDEO",
        "classificationId": null,
        "classificationName": null,
        "classificationThumbnailUrl": null,
        "createdAt": "2025-12-01T10:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 142,
      "totalPages": 8
    }
  },
  "message": "Content retrieved successfully"
}
```

### Error Responses

```json
// 404 — Category not found
{ "success": false, "data": null, "message": "Category not found" }

// 500 — Server error
{ "success": false, "data": null, "message": "Internal server error" }
```

### Data Source Mapping

| API Field | Model Field | Notes |
|-----------|-------------|-------|
| `data.items[].id` | `WallpaperModel.id` | |
| `data.items[].url` | `WallpaperModel.url` | Replaces `imageUrl` |
| `data.items[].thumbUrl` | `WallpaperModel.thumbUrl` | Replaces `thumbnailUrl` |
| `data.items[].isTopRated` | `WallpaperModel.isTopRated` | Replaces `isPremium` |
| `data.items[].mediaType` | `WallpaperModel.mediaType` | String → MediaType enum |
| `data.items[].classificationId` | `WallpaperModel.classificationId` | nullable |
| `data.items[].classificationName` | `WallpaperModel.classificationName` | nullable |
| `data.items[].classificationThumbnailUrl` | `WallpaperModel.classificationThumbnailUrl` | nullable |
| `data.items[].createdAt` | `WallpaperModel.createdAt` | ISO 8601 → DateTime |
| `data.pagination.page` | `PaginatedResponse.page` | |
| `data.pagination.limit` | `PaginatedResponse.limit` | Replaces `perPage` |
| `data.pagination.total` | `PaginatedResponse.total` | |
| `data.pagination.totalPages` | `PaginatedResponse.totalPages` | NEW — drives `hasReachedEnd` |

### `hasReachedEnd` Logic

```
hasReachedEnd = currentPage >= totalPages
```

Evaluated in `HomeCubit.loadMore()` before firing a new request.

---

## Contract 3: Classifications List (API-3)

### Request

```
GET /api/v1/mobile/apps/{appId}/categories/{categoryId}/classifications
Headers:
  Content-Type: application/json
  (no Authorization header)
```

### Success Response (200)

```json
{
  "success": true,
  "data": {
    "classifications": [
      {
        "id": "cls-uuid-1",
        "name": "Cyberpunk",
        "thumbnailUrl": "https://cdn.example.com/cls/cyberpunk-thumb.jpg",
        "itemCount": 47
      },
      {
        "id": "cls-uuid-2",
        "name": "Minimal",
        "thumbnailUrl": "https://cdn.example.com/cls/minimal-thumb.jpg",
        "itemCount": 23
      }
    ]
  },
  "message": "Classifications retrieved successfully"
}
```

### Error Responses

```json
// 404 — Category not found
{ "success": false, "data": null, "message": "Category not found" }

// 500 — Server error
{ "success": false, "data": null, "message": "Internal server error" }
```

### Data Source Mapping

| API Field | Model Field | Notes |
|-----------|-------------|-------|
| `data.classifications[].id` | `ClassificationModel.id` | |
| `data.classifications[].name` | `ClassificationModel.name` | |
| `data.classifications[].thumbnailUrl` | `ClassificationModel.thumbnailUrl` | |
| `data.classifications[].itemCount` | `ClassificationModel.itemCount` | Renamed from `wallpaperCount` |

---

## Repository Contracts (Domain Layer)

### AppRepository

```dart
abstract class AppRepository {
  /// Fetch bootstrap data with stale-while-revalidate.
  /// Returns cached data immediately if available, then refreshes in background.
  Future<Either<Failure, AppMetadataEntity>> getAppData();
}
```

### WallpaperRepository (updated)

```dart
abstract class WallpaperRepository {
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> getWallpapersByCategory({
    required String categoryId,
    required int page,
    int limit = 20,                    // renamed from perPage
    String? classificationId,          // NEW optional filter
    CancelToken? cancelToken,
  });
  // getWallpapersByClassification() REMOVED — merged into getWallpapersByCategory
}
```

### CategoryRepository (updated)

```dart
abstract class CategoryRepository {
  // getCategories() REMOVED — categories now sourced from AppRepository.getAppData()

  Future<Either<Failure, List<ClassificationEntity>>> getClassifications(
    String categoryId,
  );
}
```

---

## Test Fixture Files

Required JSON fixture files under `test/fixtures/`:

| File | Contents |
|------|----------|
| `test/fixtures/bootstrap_success.json` | Full API-1 success response |
| `test/fixtures/bootstrap_empty_categories.json` | API-1 with `categories: []` |
| `test/fixtures/content_page1_success.json` | API-2 page 1, total 3 pages |
| `test/fixtures/content_page3_success.json` | API-2 last page (page == totalPages) |
| `test/fixtures/content_classified_success.json` | API-2 with classificationId filter |
| `test/fixtures/classifications_success.json` | API-3 success with 3 classifications |
| `test/fixtures/server_error.json` | Generic 500 `{ success: false }` |
