# Data Model: Home, Categories & Content Grids

## Domain Entities (Pure Dart, no Flutter imports)

### CategoryType Enum

```dart
enum CategoryType { image, video, classification }
```

### CategoryEntity

```dart
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final String? thumbnailUrl;  // nullable — not used in text-only chips but available
  final int displayOrder;

  // props: [id, name, type, thumbnailUrl, displayOrder]
}
```

### WallpaperEntity

```dart
class WallpaperEntity extends Equatable {
  final String id;
  final String title;
  final String imageUrl;           // full-size image URL
  final String thumbnailUrl;       // grid thumbnail URL
  final String? videoUrl;          // only for video wallpapers, null for images
  final bool isPremium;
  final String categoryId;
  final List<String> classificationIds;  // which classifications this belongs to

  // props: [id, title, imageUrl, thumbnailUrl, videoUrl, isPremium, categoryId, classificationIds]
}
```

### ClassificationEntity

```dart
class ClassificationEntity extends Equatable {
  final String id;
  final String name;
  final String thumbnailUrl;
  final int wallpaperCount;

  // props: [id, name, thumbnailUrl, wallpaperCount]
}
```

## Data Models (Freezed, JSON serializable)

### CategoryModel

```dart
@freezed
abstract class CategoryModel with _$CategoryModel {
  const CategoryModel._();

  const factory CategoryModel({
    required String id,
    required String name,
    required String type,                           // "image" | "video" | "classification"
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'display_order') required int displayOrder,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    name: name,
    type: CategoryType.values.firstWhere((e) => e.name == type, orElse: () => CategoryType.image),
    thumbnailUrl: thumbnailUrl,
    displayOrder: displayOrder,
  );
}
```

### WallpaperModel

```dart
@freezed
abstract class WallpaperModel with _$WallpaperModel {
  const WallpaperModel._();

  const factory WallpaperModel({
    required String id,
    required String title,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'is_premium') required bool isPremium,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'classification_ids') @Default([]) List<String> classificationIds,
  }) = _WallpaperModel;

  factory WallpaperModel.fromJson(Map<String, dynamic> json) => _$WallpaperModelFromJson(json);

  WallpaperEntity toEntity() => WallpaperEntity(
    id: id,
    title: title,
    imageUrl: imageUrl,
    thumbnailUrl: thumbnailUrl,
    videoUrl: videoUrl,
    isPremium: isPremium,
    categoryId: categoryId,
    classificationIds: classificationIds,
  );
}
```

### ClassificationModel

```dart
@freezed
abstract class ClassificationModel with _$ClassificationModel {
  const ClassificationModel._();

  const factory ClassificationModel({
    required String id,
    required String name,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'wallpaper_count') required int wallpaperCount,
  }) = _ClassificationModel;

  factory ClassificationModel.fromJson(Map<String, dynamic> json) => _$ClassificationModelFromJson(json);

  ClassificationEntity toEntity() => ClassificationEntity(
    id: id,
    name: name,
    thumbnailUrl: thumbnailUrl,
    wallpaperCount: wallpaperCount,
  );
}
```

### PaginatedResponse (Generic wrapper)

```dart
@freezed
abstract class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> items,
    required int page,
    @JsonKey(name: 'per_page') required int perPage,
    @JsonKey(name: 'has_more') required bool hasMore,
    @JsonKey(name: 'total_count') int? totalCount,
  }) = _PaginatedResponse<T>;
}
```

Note: Since Freezed generic factories with `fromJson` are complex, implement `PaginatedResponse` as a plain Dart class with a manual `fromJson` that takes a `T Function(Map<String, dynamic>)` itemFactory parameter. This is simpler and more maintainable.

```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int perPage;
  final bool hasMore;
  final int? totalCount;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.perPage,
    required this.hasMore,
    this.totalCount,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      hasMore: json['has_more'] as bool,
      totalCount: json['total_count'] as int?,
    );
  }
}
```

## Repository Contracts (Domain Layer)

### CategoryRepository

```dart
abstract class CategoryRepository {
  /// Fetch all categories. Returns cached first if available (stale-while-revalidate).
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Fetch classifications for a specific category.
  Future<Either<Failure, List<ClassificationEntity>>> getClassifications(String categoryId);
}
```

### WallpaperRepository

```dart
abstract class WallpaperRepository {
  /// Fetch paginated wallpapers for a category.
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> getWallpapersByCategory({
    required String categoryId,
    required int page,
    int perPage = 20,
    CancelToken? cancelToken,
  });

  /// Fetch paginated wallpapers for a classification.
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> getWallpapersByClassification({
    required String classificationId,
    required int page,
    int perPage = 20,
  });
}
```

## Use Cases

### GetCategories

```dart
class GetCategories extends UseCase<List<CategoryEntity>, NoParams> {
  final CategoryRepository repository;
  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) =>
      repository.getCategories();
}
```

### GetClassifications

```dart
class GetClassifications extends UseCase<List<ClassificationEntity>, String> {
  final CategoryRepository repository;
  GetClassifications(this.repository);

  @override
  Future<Either<Failure, List<ClassificationEntity>>> call(String categoryId) =>
      repository.getClassifications(categoryId);
}
```

### GetWallpapersByCategory

```dart
class GetWallpapersByCategoryParams extends Equatable {
  final String categoryId;
  final int page;
  final int perPage;
  final CancelToken? cancelToken;

  const GetWallpapersByCategoryParams({
    required this.categoryId,
    required this.page,
    this.perPage = 20,
    this.cancelToken,
  });

  @override
  List<Object?> get props => [categoryId, page, perPage];
}

class GetWallpapersByCategory extends UseCase<PaginatedResponse<WallpaperEntity>, GetWallpapersByCategoryParams> {
  final WallpaperRepository repository;
  GetWallpapersByCategory(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> call(GetWallpapersByCategoryParams params) =>
      repository.getWallpapersByCategory(
        categoryId: params.categoryId,
        page: params.page,
        perPage: params.perPage,
        cancelToken: params.cancelToken,
      );
}
```

### GetWallpapersByClassification

```dart
class GetWallpapersByClassificationParams extends Equatable {
  final String classificationId;
  final int page;
  final int perPage;

  const GetWallpapersByClassificationParams({
    required this.classificationId,
    required this.page,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [classificationId, page, perPage];
}

class GetWallpapersByClassification extends UseCase<PaginatedResponse<WallpaperEntity>, GetWallpapersByClassificationParams> {
  final WallpaperRepository repository;
  GetWallpapersByClassification(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> call(GetWallpapersByClassificationParams params) =>
      repository.getWallpapersByClassification(
        classificationId: params.classificationId,
        page: params.page,
        perPage: params.perPage,
      );
}
```

## State Management

### HomeState (Freezed)

```dart
@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    // Categories
    @Default(Status.loading) Status categoriesStatus,
    @Default([]) List<CategoryEntity> categories,
    @Default(0) int selectedCategoryIndex,

    // Content (wallpapers or classifications depending on category type)
    @Default(Status.loading) Status contentStatus,
    @Default([]) List<WallpaperEntity> wallpapers,
    @Default([]) List<ClassificationEntity> classifications,

    // Pagination
    @Default(1) int currentPage,
    @Default(false) bool hasReachedEnd,
    @Default(false) bool isLoadingMore,

    // Error
    String? errorMessage,
  }) = _HomeState;
}

enum Status { loading, success, error, empty }
```

### HomeCubit Methods

```
HomeCubit(GetCategories, GetWallpapersByCategory, GetClassifications)
├── loadCategories()           → fetches categories, auto-selects first, loads content
├── selectCategory(int index)  → cancels in-flight, resets pagination, loads content
├── loadContent()              → dispatches to _loadWallpapers() or _loadClassifications() based on type
├── loadMore()                 → increments page, fetches next page, appends
├── _loadWallpapers()          → fetches wallpapers for selected category
├── _loadClassifications()     → fetches classifications for selected category
└── retry()                    → re-attempts last failed operation
```

### ClassificationDetailState (Freezed)

```dart
@freezed
sealed class ClassificationDetailState with _$ClassificationDetailState {
  const factory ClassificationDetailState({
    required ClassificationEntity classification,
    @Default(Status.loading) Status status,
    @Default([]) List<WallpaperEntity> wallpapers,
    @Default(1) int currentPage,
    @Default(false) bool hasReachedEnd,
    @Default(false) bool isLoadingMore,
    String? errorMessage,
  }) = _ClassificationDetailState;
}
```

### ClassificationDetailCubit Methods

```
ClassificationDetailCubit(GetWallpapersByClassification)
├── loadWallpapers()   → fetches first page
├── loadMore()         → fetches next page, appends
└── retry()            → re-attempts last failed operation
```

## Storage Map

| Key | Store | Format | Purpose |
|-----|-------|--------|---------|
| `categories_cache` | Hive box `categories` | JSON string (list of CategoryModel) | Stale-while-revalidate category cache |
| `categories_timestamp` | Hive box `categories` | int (epoch ms) | Cache freshness check |

Note: Wallpapers are NOT cached locally in Phase 3. They are always fetched from the server. Caching wallpapers would be a Phase 6 optimization if needed.
