# Data Model: Wallpaper Detail, Download & Favorites

**Feature**: 004-detail-download-favorites
**Date**: 2026-03-24

## Existing Entities (Reused, Not Modified)

### WallpaperEntity (from `features/wallpapers/domain/entities/`)

```
WallpaperEntity
├── id: String (unique identifier)
├── title: String
├── imageUrl: String
├── thumbnailUrl: String
├── videoUrl: String? (null for image wallpapers)
├── isPremium: bool
├── categoryId: String
└── classificationIds: List<String>
```

Used by: Detail carousel, favorites grid, downloads grid, similar wallpapers sheet.

### UserEntity (from `features/auth/domain/entities/`)

```
UserEntity
├── id: String
├── displayName: String
├── email: String
└── isPremium: bool
```

Used by: Determining authenticated vs guest state for favorites sync.

---

## New Entities

### FavoriteEntity (domain — `features/favorites/domain/entities/`)

```
FavoriteEntity
├── wallpaperId: String (unique key — matches WallpaperEntity.id)
├── wallpaper: WallpaperEntity (embedded snapshot for offline display)
├── userId: String? (null for guest users)
├── favoritedAt: DateTime
└── syncStatus: FavoriteSyncStatus (enum)
```

**FavoriteSyncStatus enum**:
- `synced` — persisted locally and confirmed on server
- `pending` — persisted locally, server sync failed or in progress
- `localOnly` — guest user, no server sync attempted

**Validation rules**:
- `wallpaperId` must be non-empty
- `favoritedAt` must be a valid timestamp
- Only one favorite record per `wallpaperId` (enforced by Hive box key)

**State transitions**:
```
[Not Favorited] → tap favorite → [localOnly] (guest) or [pending] (authenticated)
[pending] → sync success → [synced]
[pending] → sync failure → [pending] (retry queued)
[localOnly] → user logs in → [pending] → sync → [synced]
[synced/pending/localOnly] → tap unfavorite → [Not Favorited] (entry deleted)
```

### DownloadRecordEntity (domain — `features/downloads/domain/entities/`)

```
DownloadRecordEntity
├── wallpaperId: String (unique key — no duplicates)
├── thumbnailUrl: String (for grid display)
├── title: String
├── downloadedAt: DateTime (updated on re-download)
└── fileType: WallpaperFileType (enum)
```

**WallpaperFileType enum**:
- `image`
- `video`

**Validation rules**:
- `wallpaperId` must be non-empty
- `thumbnailUrl` must be a valid URL
- `downloadedAt` must be a valid timestamp
- Re-download of same wallpaper updates `downloadedAt` (upsert behavior)

---

## Data Models (Freezed — Data Layer)

### FavoriteModel (`features/favorites/data/models/`)

```dart
@freezed
class FavoriteModel with _$FavoriteModel {
  const factory FavoriteModel({
    required String wallpaperId,
    required WallpaperModel wallpaper,
    String? userId,
    required DateTime favoritedAt,
    @Default(FavoriteSyncStatus.localOnly) FavoriteSyncStatus syncStatus,
  }) = _FavoriteModel;

  factory FavoriteModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteModelFromJson(json);
}
```

Mapping: `FavoriteModel.toEntity()` → `FavoriteEntity`, `FavoriteModel.fromEntity()`.

### DownloadRecordModel (`features/downloads/data/models/`)

```dart
@freezed
class DownloadRecordModel with _$DownloadRecordModel {
  const factory DownloadRecordModel({
    required String wallpaperId,
    required String thumbnailUrl,
    required String title,
    required DateTime downloadedAt,
    required WallpaperFileType fileType,
  }) = _DownloadRecordModel;

  factory DownloadRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadRecordModelFromJson(json);
}
```

Mapping: `DownloadRecordModel.toEntity()` → `DownloadRecordEntity`, `DownloadRecordModel.fromEntity()`.

### FavoriteRequestModel (for server sync)

```dart
@freezed
class FavoriteRequestModel with _$FavoriteRequestModel {
  const factory FavoriteRequestModel({
    required String wallpaperId,
  }) = _FavoriteRequestModel;

  factory FavoriteRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteRequestModelFromJson(json);
}
```

---

## Hive Storage Schema

### Box: `favorites`

- **Key**: wallpaperId (String)
- **Value**: JSON string of `FavoriteModel`
- **Initialization**: Opened in `main.dart` alongside existing boxes

### Box: `downloads`

- **Key**: wallpaperId (String)
- **Value**: JSON string of `DownloadRecordModel`
- **Initialization**: Opened in `main.dart` alongside existing boxes

---

## Relationships

```
WallpaperEntity (1) ←→ (0..1) FavoriteEntity
  via FavoriteEntity.wallpaperId = WallpaperEntity.id

WallpaperEntity (1) ←→ (0..1) DownloadRecordEntity
  via DownloadRecordEntity.wallpaperId = WallpaperEntity.id

WallpaperEntity (1) ←→ (0..*) WallpaperEntity [similar]
  via server endpoint /wallpapers/{id}/similar

UserEntity (1) ←→ (0..*) FavoriteEntity
  via FavoriteEntity.userId = UserEntity.id (null for guests)
```

---

## Repository Contracts

### SimilarWallpaperRepository (`wallpaper_detail/domain/repositories/`)

```dart
abstract class SimilarWallpaperRepository {
  Future<Either<Failure, List<WallpaperEntity>>> getSimilarWallpapers(String wallpaperId);
}
```

### FavoriteRepository (`favorites/domain/repositories/`)

```dart
abstract class FavoriteRepository {
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(WallpaperEntity wallpaper);
  Future<Either<Failure, void>> removeFavorite(String wallpaperId);
  Future<Either<Failure, bool>> isFavorite(String wallpaperId);
  Future<Either<Failure, void>> syncPendingFavorites();
  Future<Either<Failure, void>> mergeGuestFavorites(String userId);
  Future<Either<Failure, List<FavoriteEntity>>> refreshFromServer();
}
```

### DownloadRepository (`downloads/domain/repositories/`)

```dart
abstract class DownloadRepository {
  Future<Either<Failure, void>> downloadWallpaper(WallpaperEntity wallpaper, {void Function(int, int)? onProgress});
  Future<Either<Failure, List<DownloadRecordEntity>>> getDownloadHistory();
  Future<Either<Failure, bool>> isDownloaded(String wallpaperId);
}
```
