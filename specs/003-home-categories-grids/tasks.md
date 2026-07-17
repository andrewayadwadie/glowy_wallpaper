# Tasks: Home, Categories & Content Grids

**Input**: Design documents from `/specs/003-home-categories-grids/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not explicitly requested. Test tasks omitted.

**Organization**: Tasks grouped by user story. Each story can be implemented and tested independently after Foundational phase completes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add new dependencies and string/dimension constants needed by all stories.

- [X] T001 Add `video_player` and `visibility_detector` packages to `pubspec.yaml`. Run `flutter pub get`. The exact lines to add under `dependencies:` are: `video_player: ^2.9.2` and `visibility_detector: ^0.4.0+2`. Place them alphabetically among existing dependencies.

- [X] T002 [P] Add Phase 3 string constants to `lib/core/utils/app_strings.dart`. Add these exact fields inside the existing `AppStrings` abstract class (do NOT remove any existing strings):
  ```dart
  // Phase 3 — Home, Categories & Content Grids
  static const String categories = 'Categories';
  static const String noCategories = 'No categories available';
  static const String noWallpapers = 'No wallpapers in this category';
  static const String noClassifications = 'No classifications available';
  static const String classificationDetail = 'Classification Detail';
  static const String myDownloads = 'My Downloads';
  static const String about = 'About';
  static const String rateApp = 'Rate App';
  static const String shareApp = 'Share App';
  static const String sendFeedback = 'Send Feedback';
  static const String comingSoon = 'Coming Soon';
  static const String offlineMode = 'Showing cached data';
  static const String loadingMore = 'Loading more...';
  ```

- [X] T003 [P] Add Phase 3 dimension constants to `lib/core/utils/app_dimens.dart`. Add these fields inside the existing `AppDimens` abstract class (do NOT remove any existing dimensions). If `AppDimens` uses `ScreenUtil` extensions already, follow the same pattern; otherwise use raw doubles:
  ```dart
  // Phase 3 — Category chips
  static double get categoryChipHeight => 40.h;
  static double get categoryChipPaddingH => 12.w;
  static double get categoryChipPaddingV => 6.h;
  static double get categoryChipGap => 8.w;
  static double get categorySelectorHeight => 56.h;

  // Phase 3 — Bento grid
  static double get bentoLargeCardHeight => 200.h;
  static double get bentoSmallCardHeight => 150.h;
  static double get bentoCardGap => 8.w;

  // Phase 3 — Content grid
  static double get gridSpacing => 8.w;
  static double get paginationThreshold => 200.h;
  ```
  Import `flutter_screenutil` at the top if not already imported: `import 'package:flutter_screenutil/flutter_screenutil.dart';`.

- [X] T004 [P] Add Phase 3 server endpoint constants to `lib/core/api/server_strings.dart`. Add these fields inside the existing `ServerStrings` abstract class (do NOT remove existing endpoints):
  ```dart
  // Phase 3 — Categories & Content
  static const String categoryWallpapers = '/categories/{id}/wallpapers';
  static const String categoryClassifications = '/categories/{id}/classifications';
  static const String classificationWallpapers = '/classifications/{id}/wallpapers';
  ```
  Note: `categories` and `wallpapers` constants already exist. Do NOT duplicate them.

- [X] T005 [P] Add route constant for classification detail in `lib/core/routes/routes.dart`. The route `classificationDetail` already exists as `/classification/:id`. Verify it is present. If not, add: `static const String classificationDetail = '/classification/:id';`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, repository contracts, data models, data sources, repository implementations, and use cases that ALL user stories depend on. These MUST be complete before any user story work begins.

**CRITICAL**: No user story work can begin until this phase is complete.

### Domain Entities (Pure Dart — no Flutter imports, no Freezed)

- [X] T006 [P] Create `CategoryType` enum and `CategoryEntity` in `lib/features/categories/domain/entities/category_entity.dart`. This file must contain:
  ```dart
  import 'package:equatable/equatable.dart';

  enum CategoryType { image, video, classification }

  class CategoryEntity extends Equatable {
    final String id;
    final String name;
    final CategoryType type;
    final String? thumbnailUrl;
    final int displayOrder;

    const CategoryEntity({
      required this.id,
      required this.name,
      required this.type,
      this.thumbnailUrl,
      required this.displayOrder,
    });

    @override
    List<Object?> get props => [id, name, type, thumbnailUrl, displayOrder];
  }
  ```

- [X] T007 [P] Create `ClassificationEntity` in `lib/features/categories/domain/entities/classification_entity.dart`:
  ```dart
  import 'package:equatable/equatable.dart';

  class ClassificationEntity extends Equatable {
    final String id;
    final String name;
    final String thumbnailUrl;
    final int wallpaperCount;

    const ClassificationEntity({
      required this.id,
      required this.name,
      required this.thumbnailUrl,
      required this.wallpaperCount,
    });

    @override
    List<Object?> get props => [id, name, thumbnailUrl, wallpaperCount];
  }
  ```

- [X] T008 [P] Create `WallpaperEntity` in `lib/features/wallpapers/domain/entities/wallpaper_entity.dart`:
  ```dart
  import 'package:equatable/equatable.dart';

  class WallpaperEntity extends Equatable {
    final String id;
    final String title;
    final String imageUrl;
    final String thumbnailUrl;
    final String? videoUrl;
    final bool isPremium;
    final String categoryId;
    final List<String> classificationIds;

    const WallpaperEntity({
      required this.id,
      required this.title,
      required this.imageUrl,
      required this.thumbnailUrl,
      this.videoUrl,
      required this.isPremium,
      required this.categoryId,
      this.classificationIds = const [],
    });

    @override
    List<Object?> get props => [id, title, imageUrl, thumbnailUrl, videoUrl, isPremium, categoryId, classificationIds];
  }
  ```

### Repository Contracts (Domain Layer)

- [X] T009 [P] Create `CategoryRepository` contract in `lib/features/categories/domain/repositories/category_repository.dart`:
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/errors/failure.dart';
  import '../entities/category_entity.dart';
  import '../entities/classification_entity.dart';

  abstract class CategoryRepository {
    Future<Either<Failure, List<CategoryEntity>>> getCategories();
    Future<Either<Failure, List<ClassificationEntity>>> getClassifications(String categoryId);
  }
  ```

- [X] T010 [P] Create `PaginatedResponse` generic class in `lib/features/wallpapers/data/models/paginated_response.dart`. This is a plain Dart class (NOT Freezed) because generic Freezed factories with `fromJson` are complex:
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
        items: (json['items'] as List)
            .map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList(),
        page: json['page'] as int,
        perPage: json['per_page'] as int,
        hasMore: json['has_more'] as bool,
        totalCount: json['total_count'] as int?,
      );
    }
  }
  ```

- [X] T011 Create `WallpaperRepository` contract in `lib/features/wallpapers/domain/repositories/wallpaper_repository.dart`. This depends on T010 for `PaginatedResponse`:
  ```dart
  import 'package:dartz/dartz.dart';
  import 'package:dio/dio.dart';
  import '../../../../core/errors/failure.dart';
  import '../../data/models/paginated_response.dart';
  import '../entities/wallpaper_entity.dart';

  abstract class WallpaperRepository {
    Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> getWallpapersByCategory({
      required String categoryId,
      required int page,
      int perPage = 20,
      CancelToken? cancelToken,
    });

    Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> getWallpapersByClassification({
      required String classificationId,
      required int page,
      int perPage = 20,
    });
  }
  ```

### Use Cases

- [X] T012 [P] Create `GetCategories` use case in `lib/features/categories/domain/usecases/get_categories.dart`:
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/errors/failure.dart';
  import '../../../../core/usecases/usecase.dart';
  import '../entities/category_entity.dart';
  import '../repositories/category_repository.dart';

  class GetCategories extends UseCase<List<CategoryEntity>, NoParams> {
    final CategoryRepository repository;
    GetCategories(this.repository);

    @override
    Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) =>
        repository.getCategories();
  }
  ```

- [X] T013 [P] Create `GetClassifications` use case in `lib/features/categories/domain/usecases/get_classifications.dart`. The params type is `String` (categoryId):
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/errors/failure.dart';
  import '../../../../core/usecases/usecase.dart';
  import '../entities/classification_entity.dart';
  import '../repositories/category_repository.dart';

  class GetClassifications extends UseCase<List<ClassificationEntity>, String> {
    final CategoryRepository repository;
    GetClassifications(this.repository);

    @override
    Future<Either<Failure, List<ClassificationEntity>>> call(String categoryId) =>
        repository.getClassifications(categoryId);
  }
  ```

- [X] T014 [P] Create `GetWallpapersByCategory` use case in `lib/features/wallpapers/domain/usecases/get_wallpapers_by_category.dart`. Define a `GetWallpapersByCategoryParams` class with `categoryId` (String), `page` (int), `perPage` (int, default 20), and `cancelToken` (CancelToken?, from `package:dio/dio.dart`). Extend `Equatable` for `props: [categoryId, page, perPage]` (do NOT include cancelToken in props). The use case extends `UseCase<PaginatedResponse<WallpaperEntity>, GetWallpapersByCategoryParams>` and calls `repository.getWallpapersByCategory(...)`.

- [X] T015 [P] Create `GetWallpapersByClassification` use case in `lib/features/wallpapers/domain/usecases/get_wallpapers_by_classification.dart`. Define a `GetWallpapersByClassificationParams` class with `classificationId` (String), `page` (int), `perPage` (int, default 20). Extend `Equatable`. The use case extends `UseCase<PaginatedResponse<WallpaperEntity>, GetWallpapersByClassificationParams>` and calls `repository.getWallpapersByClassification(...)`.

### Data Models (Freezed — requires build_runner)

- [X] T016 [P] Create `CategoryModel` (Freezed) in `lib/features/categories/data/models/category_model.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import '../../domain/entities/category_entity.dart';

  part 'category_model.freezed.dart';
  part 'category_model.g.dart';

  @freezed
  abstract class CategoryModel with _$CategoryModel {
    const CategoryModel._();

    const factory CategoryModel({
      required String id,
      required String name,
      required String type,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'display_order') required int displayOrder,
    }) = _CategoryModel;

    factory CategoryModel.fromJson(Map<String, dynamic> json) =>
        _$CategoryModelFromJson(json);

    CategoryEntity toEntity() => CategoryEntity(
      id: id,
      name: name,
      type: CategoryType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => CategoryType.image,
      ),
      thumbnailUrl: thumbnailUrl,
      displayOrder: displayOrder,
    );
  }
  ```

- [X] T017 [P] Create `ClassificationModel` (Freezed) in `lib/features/categories/data/models/classification_model.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import '../../domain/entities/classification_entity.dart';

  part 'classification_model.freezed.dart';
  part 'classification_model.g.dart';

  @freezed
  abstract class ClassificationModel with _$ClassificationModel {
    const ClassificationModel._();

    const factory ClassificationModel({
      required String id,
      required String name,
      @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
      @JsonKey(name: 'wallpaper_count') required int wallpaperCount,
    }) = _ClassificationModel;

    factory ClassificationModel.fromJson(Map<String, dynamic> json) =>
        _$ClassificationModelFromJson(json);

    ClassificationEntity toEntity() => ClassificationEntity(
      id: id,
      name: name,
      thumbnailUrl: thumbnailUrl,
      wallpaperCount: wallpaperCount,
    );
  }
  ```

- [X] T018 [P] Create `WallpaperModel` (Freezed) in `lib/features/wallpapers/data/models/wallpaper_model.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import '../../domain/entities/wallpaper_entity.dart';

  part 'wallpaper_model.freezed.dart';
  part 'wallpaper_model.g.dart';

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

    factory WallpaperModel.fromJson(Map<String, dynamic> json) =>
        _$WallpaperModelFromJson(json);

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

### Data Sources

- [X] T019 Create `CategoryRemoteDataSource` (Retrofit) in `lib/features/categories/data/datasources/category_remote_data_source.dart`. Follow the exact same pattern as `AuthRemoteDataSource` in `lib/features/auth/data/datasources/auth_remote_data_source.dart`. Use `@RestApi()`, `part 'category_remote_data_source.g.dart'`, factory constructor with `Dio dio`. Methods:
  - `@GET('/categories') Future<List<CategoryModel>> getCategories()` — returns raw list (server wraps in `items`, so the return type might need to be `Map<String, dynamic>` and manually parsed; OR if server returns a list directly, use `List<CategoryModel>`). **Safest approach**: Return `HttpResponse<dynamic>` or just use Dio directly in the data source like this instead of Retrofit:

  **Recommended approach** (use plain Dio instead of Retrofit for these endpoints, because the paginated response parsing is complex for code-gen):
  ```dart
  import 'package:dio/dio.dart';
  import '../models/category_model.dart';
  import '../models/classification_model.dart';

  class CategoryRemoteDataSource {
    final Dio _dio;
    CategoryRemoteDataSource(this._dio);

    Future<List<CategoryModel>> getCategories() async {
      final response = await _dio.get('/categories');
      final items = response.data['items'] as List;
      return items.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    Future<List<ClassificationModel>> getClassifications(String categoryId) async {
      final response = await _dio.get('/categories/$categoryId/classifications');
      final items = response.data['items'] as List;
      return items.map((e) => ClassificationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
  }
  ```

- [X] T020 Create `CategoryLocalDataSource` in `lib/features/categories/data/datasources/category_local_data_source.dart`. Uses Hive box named `categories` to cache category data. Methods:
  ```dart
  import 'dart:convert';
  import 'package:hive/hive.dart';
  import '../models/category_model.dart';

  abstract class CategoryLocalDataSource {
    Future<List<CategoryModel>?> getCachedCategories();
    Future<void> cacheCategories(List<CategoryModel> categories);
  }

  class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
    final Box box;
    CategoryLocalDataSourceImpl(this.box);

    static const String _categoriesKey = 'categories_cache';

    @override
    Future<List<CategoryModel>?> getCachedCategories() async {
      final jsonString = box.get(_categoriesKey) as String?;
      if (jsonString == null) return null;
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    @override
    Future<void> cacheCategories(List<CategoryModel> categories) async {
      final jsonString = json.encode(
        categories.map((c) => c.toJson()).toList(),
      );
      await box.put(_categoriesKey, jsonString);
    }
  }
  ```

- [X] T021 Create `WallpaperRemoteDataSource` in `lib/features/wallpapers/data/datasources/wallpaper_remote_data_source.dart`. Uses plain Dio (not Retrofit) for paginated responses:
  ```dart
  import 'package:dio/dio.dart';
  import '../models/paginated_response.dart';
  import '../models/wallpaper_model.dart';

  class WallpaperRemoteDataSource {
    final Dio _dio;
    WallpaperRemoteDataSource(this._dio);

    Future<PaginatedResponse<WallpaperModel>> getWallpapersByCategory({
      required String categoryId,
      required int page,
      int perPage = 20,
      CancelToken? cancelToken,
    }) async {
      final response = await _dio.get(
        '/categories/$categoryId/wallpapers',
        queryParameters: {'page': page, 'per_page': perPage},
        cancelToken: cancelToken,
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => WallpaperModel.fromJson(json),
      );
    }

    Future<PaginatedResponse<WallpaperModel>> getWallpapersByClassification({
      required String classificationId,
      required int page,
      int perPage = 20,
    }) async {
      final response = await _dio.get(
        '/classifications/$classificationId/wallpapers',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => WallpaperModel.fromJson(json),
      );
    }
  }
  ```

### Repository Implementations

- [X] T022 Create `CategoryRepositoryImpl` in `lib/features/categories/data/repositories/category_repository_impl.dart`. Implements stale-while-revalidate pattern. Depends on T009, T019, T020. Constructor takes `CategoryRemoteDataSource`, `CategoryLocalDataSource`, and `NetworkInfo`. The `getCategories()` method:
  1. Try to read cached categories from local source.
  2. If cache exists, return cached data as `Right(cachedCategories.map((m) => m.toEntity()).toList())`.
  3. In parallel (or after), if network is connected, fetch from remote source, cache the result, and return fresh data.
  4. If no cache AND no network → return `Left(NetworkFailure(...))`.
  5. If remote fails but cache exists → return cached data (stale).
  6. If remote fails and no cache → return `Left(ServerFailure(...))`.

  The `getClassifications()` method: simply calls remote source and maps to entities. Wrap in try/catch for `DioException` → `ServerFailure`, and check `NetworkInfo` first → `NetworkFailure`.

  Use `try/catch` with `DioException` for server errors. Use `NetworkInfo.isConnected` check before remote calls. Return `Either<Failure, ...>` for all methods. Import `failure.dart` from `lib/core/errors/failure.dart`.

- [X] T023 Create `WallpaperRepositoryImpl` in `lib/features/wallpapers/data/repositories/wallpaper_repository_impl.dart`. Implements `WallpaperRepository`. Constructor takes `WallpaperRemoteDataSource` and `NetworkInfo`. Both methods:
  1. Check `NetworkInfo.isConnected` → if not, return `Left(NetworkFailure('No internet connection'))`.
  2. Try remote source call, map `WallpaperModel` items to `WallpaperEntity` via `.toEntity()`.
  3. Return `Right(PaginatedResponse<WallpaperEntity>(items: entities, page: ..., perPage: ..., hasMore: ..., totalCount: ...))`.
  4. Catch `DioException` → if `CancelToken.isCancel(e)` → return `Left(ServerFailure('Request cancelled'))`. Otherwise → return `Left(ServerFailure(e.message ?? 'Server error'))`.

### Dependency Injection

- [X] T024 Register all Phase 3 dependencies in `lib/core/di/injection_container.dart`. Add the following registrations AFTER the existing auth registrations (do NOT remove any existing registrations). Open a new Hive box named `categories` in the `init()` function (add `await Hive.openBox('categories');` near the top of `init()`). Then register:
  ```dart
  // Categories Data Sources
  sl.registerLazySingleton(() => Hive.box('categories'));
  // IMPORTANT: Name the categories box registration to avoid conflict with auth box.
  // Use a named parameter or register the box with a specific instance name:
  // Since GetIt doesn't support multiple registrations of the same type without names,
  // register the categories box with instanceName:
  sl.registerLazySingleton<Box>(() => Hive.box('categories'), instanceName: 'categoriesBox');

  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(sl<Box>(instanceName: 'categoriesBox')),
  );

  // Categories Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl(), sl(), sl()),
  );

  // Categories Use Cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetClassifications(sl()));

  // Wallpapers Data Sources
  sl.registerLazySingleton<WallpaperRemoteDataSource>(
    () => WallpaperRemoteDataSource(sl<Dio>()),
  );

  // Wallpapers Repository
  sl.registerLazySingleton<WallpaperRepository>(
    () => WallpaperRepositoryImpl(sl(), sl()),
  );

  // Wallpapers Use Cases
  sl.registerLazySingleton(() => GetWallpapersByCategory(sl()));
  sl.registerLazySingleton(() => GetWallpapersByClassification(sl()));
  ```
  Add all necessary imports at the top of the file. Also open the Hive box in `main.dart` before calling `init()`: add `await Hive.openBox('categories');` in the `main()` function, right after the existing `await Hive.openBox('user_cache');` line.

- [X] T025 Run `dart run build_runner build --delete-conflicting-outputs` from the project root to generate all `.freezed.dart` and `.g.dart` files for the new models (CategoryModel, ClassificationModel, WallpaperModel). Verify no build errors. If there are errors, fix the model files and re-run.

**Checkpoint**: Foundation ready — all domain entities, contracts, models, data sources, repositories, use cases, and DI are in place. User story implementation can now begin.

---

## Phase 3: User Story 1 — Browse Categories and Image Wallpapers (Priority: P1) MVP

**Goal**: Users can see categories as horizontal chips, select a category, view image wallpapers in a responsive paginated grid, and tap a wallpaper to navigate to detail.

**Independent Test**: Launch app → categories load as chips → first is selected → image grid shows → tap another category → grid updates → scroll → more load → tap thumbnail → navigates to detail.

### Implementation for User Story 1

- [X] T026 [P] [US1] Create `HomeState` (Freezed) in `lib/features/home/presentation/cubit/home_state.dart`. Define a `Status` enum with values: `loading, success, error, empty`. Then define `HomeState` as a Freezed class:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import '../../../categories/domain/entities/category_entity.dart';
  import '../../../categories/domain/entities/classification_entity.dart';
  import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

  part 'home_state.freezed.dart';

  enum Status { loading, success, error, empty }

  @freezed
  class HomeState with _$HomeState {
    const factory HomeState({
      @Default(Status.loading) Status categoriesStatus,
      @Default([]) List<CategoryEntity> categories,
      @Default(0) int selectedCategoryIndex,
      @Default(Status.loading) Status contentStatus,
      @Default([]) List<WallpaperEntity> wallpapers,
      @Default([]) List<ClassificationEntity> classifications,
      @Default(1) int currentPage,
      @Default(false) bool hasReachedEnd,
      @Default(false) bool isLoadingMore,
      String? errorMessage,
    }) = _HomeState;
  }
  ```

- [X] T027 [US1] Create `HomeCubit` in `lib/features/home/presentation/cubit/home_cubit.dart`. This is the most complex file in Phase 3. Constructor takes `GetCategories`, `GetWallpapersByCategory`, and `GetClassifications` use cases. Initial state is `const HomeState()`. Holds a `CancelToken? _activeCancelToken` for request cancellation. Methods:

  **`loadCategories()`**: Call `getCategories(NoParams())`. On `Right(categories)`: sort by `displayOrder`, emit with `categoriesStatus: Status.success, categories: sorted`. If list is empty, emit `categoriesStatus: Status.empty`. Then auto-call `_loadContentForSelectedCategory()`. On `Left(failure)`: emit `categoriesStatus: Status.error, errorMessage: failure.message`.

  **`selectCategory(int index)`**: Cancel previous request (`_activeCancelToken?.cancel()`). Emit state with `selectedCategoryIndex: index, contentStatus: Status.loading, wallpapers: [], classifications: [], currentPage: 1, hasReachedEnd: false, isLoadingMore: false`. Then call `_loadContentForSelectedCategory()`.

  **`_loadContentForSelectedCategory()`**: Get selected category from `state.categories[state.selectedCategoryIndex]`. Based on `category.type`:
  - `CategoryType.image` or `CategoryType.video` → call `_loadWallpapers(category.id)`.
  - `CategoryType.classification` → call `_loadClassifications(category.id)`.

  **`_loadWallpapers(String categoryId)`**: Create new `_activeCancelToken = CancelToken()`. Call `getWallpapersByCategory(GetWallpapersByCategoryParams(categoryId: categoryId, page: state.currentPage, cancelToken: _activeCancelToken))`. On `Right(response)`: if `response.items.isEmpty && state.currentPage == 1` → emit `contentStatus: Status.empty`. Else → emit `contentStatus: Status.success, wallpapers: [...state.wallpapers, ...response.items], hasReachedEnd: !response.hasMore, isLoadingMore: false`. On `Left(failure)`: if failure message contains "cancelled" → do nothing (silently ignore). Else → emit `contentStatus: Status.error, errorMessage: failure.message`.

  **`_loadClassifications(String categoryId)`**: Call `getClassifications(categoryId)`. On `Right(classifications)`: if empty → emit `contentStatus: Status.empty`. Else → emit `contentStatus: Status.success, classifications: classifications`. On `Left(failure)`: emit `contentStatus: Status.error, errorMessage: failure.message`.

  **`loadMore()`**: If `state.hasReachedEnd || state.isLoadingMore || state.contentStatus != Status.success` → return. Emit `isLoadingMore: true, currentPage: state.currentPage + 1`. Then call `_loadWallpapers(state.categories[state.selectedCategoryIndex].id)`.

  **`retry()`**: If `state.categoriesStatus == Status.error` → call `loadCategories()`. Else → emit `contentStatus: Status.loading`. Call `_loadContentForSelectedCategory()`.

  **`selectedCategory` getter**: Returns `state.categories.isNotEmpty ? state.categories[state.selectedCategoryIndex] : null`.

  **`@override close()`**: Cancel active token. Call `super.close()`.

- [X] T028 [P] [US1] Create `CategorySelector` widget in `lib/features/home/presentation/widgets/category_selector.dart`. A `StatelessWidget` that takes `List<CategoryEntity> categories`, `int selectedIndex`, and `ValueChanged<int> onCategorySelected`. Renders a `SizedBox` with height `AppDimens.categorySelectorHeight`, containing a horizontal `ListView.builder` with `scrollDirection: Axis.horizontal`. Each item is a `GestureDetector` wrapping a `Container` with `BoxDecoration`:
  - Selected state: background `Theme.of(context).colorScheme.primary`, text color `Theme.of(context).colorScheme.onPrimary`.
  - Unselected state: background `Theme.of(context).colorScheme.surfaceContainerHighest`, text color `Theme.of(context).colorScheme.onSurface`.
  - Padding: `EdgeInsets.symmetric(horizontal: AppDimens.categoryChipPaddingH, vertical: AppDimens.categoryChipPaddingV)`.
  - Border radius: `BorderRadius.circular(AppDimens.radiusM)` (or `20.r` if `radiusM` doesn't exist — check `AppDimens` first).
  - Margin between chips: `EdgeInsets.only(right: AppDimens.categoryChipGap)`. First chip: add `EdgeInsets.only(left: AppDimens.paddingM)` (or `16.w`).
  - Text: `AutoSizeText(category.name, maxLines: 1, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor))`.
  - On tap: call `onCategorySelected(index)`.

- [X] T029 [P] [US1] Create `WallpaperThumbnail` widget in `lib/features/wallpapers/presentation/widgets/wallpaper_thumbnail.dart`. A `StatelessWidget` that takes `WallpaperEntity wallpaper` and `VoidCallback onTap`. Renders:
  ```dart
  GestureDetector(
    onTap: onTap,
    child: Hero(
      tag: 'wallpaper_${wallpaper.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusS.r), // or 8.r
        child: AppCachedImage(
          imageUrl: wallpaper.thumbnailUrl,
          fit: BoxFit.cover,
        ),
      ),
    ),
  )
  ```
  Import `AppCachedImage` from `lib/core/widgets/app_cached_image.dart`. Import `AppDimens` from `lib/core/utils/app_dimens.dart`.

- [X] T030 [US1] Create `WallpaperGrid` widget in `lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart`. A `StatelessWidget` that takes: `List<WallpaperEntity> wallpapers`, `bool isLoadingMore`, `bool hasReachedEnd`, `VoidCallback onLoadMore`, `ValueChanged<WallpaperEntity> onWallpaperTapped`, `bool isPremium` (from SubscriptionCubit).

  Filter wallpapers: `final displayWallpapers = isPremium ? wallpapers : wallpapers.where((w) => !w.isPremium).toList();`.

  Use `NotificationListener<ScrollNotification>` wrapping a `CustomScrollView`. In the notification listener, check: if `notification is ScrollEndNotification && notification.metrics.pixels >= notification.metrics.maxScrollExtent - AppDimens.paginationThreshold && !hasReachedEnd && !isLoadingMore` → call `onLoadMore()`.

  Inside `CustomScrollView`, use `SliverPadding` wrapping `SliverGrid` with `SliverGridDelegateWithFixedCrossAxisCount`. Use `LayoutBuilder` (or `MediaQuery`) to determine columns: `width < 400 ? 2 : (width < 700 ? 3 : 4)`. Alternatively, reuse the same breakpoint logic from existing `AdaptiveGrid` widget. Set `childAspectRatio: 0.75`, `crossAxisSpacing: AppDimens.gridSpacing`, `mainAxisSpacing: AppDimens.gridSpacing`.

  Each grid child: `WallpaperThumbnail(wallpaper: wallpaper, onTap: () => onWallpaperTapped(wallpaper))`.

  If `isLoadingMore`, add a `SliverToBoxAdapter` at the bottom with a centered `SizedBox(height: 60.h, child: Center(child: CircularProgressIndicator()))`.

- [X] T031 [US1] Create `ContentSwitcher` widget in `lib/features/home/presentation/widgets/content_switcher.dart`. A `StatelessWidget` that takes: `CategoryType? categoryType`, `List<WallpaperEntity> wallpapers`, `List<ClassificationEntity> classifications`, `Status contentStatus`, `bool isLoadingMore`, `bool hasReachedEnd`, `VoidCallback onLoadMore`, `ValueChanged<WallpaperEntity> onWallpaperTapped`, `ValueChanged<ClassificationEntity> onClassificationTapped`, `VoidCallback onRetry`, `String? errorMessage`, `bool isPremium`.

  Build method:
  - If `contentStatus == Status.loading` → return `Center(child: AppLoading())` (import from `lib/core/widgets/app_loading.dart`).
  - If `contentStatus == Status.error` → return `AppErrorWidget(message: errorMessage ?? AppStrings.error, onRetry: onRetry)` (import from `lib/core/widgets/app_error_widget.dart`).
  - If `contentStatus == Status.empty` → return a centered `Column` with an `Icon(Icons.image_not_supported_outlined, size: 64.sp)` and `AutoSizeText(AppStrings.noWallpapers)` and `ElevatedButton(onPressed: onRetry, child: AutoSizeText(AppStrings.retry))`.
  - If `contentStatus == Status.success` → switch on `categoryType`:
    - `CategoryType.image` → return `WallpaperGrid(...)`.
    - `CategoryType.video` → return `VideoGrid(...)` (will be created in US3; for now, return `WallpaperGrid(...)` as a fallback — video grid adds video auto-play on top of the same layout).
    - `CategoryType.classification` → return `ClassificationBentoGrid(...)` (will be created in US4; for now, return `Center(child: AutoSizeText('Classifications'))` as placeholder).
    - `null` → return empty `SizedBox()`.

- [X] T032 [US1] Rewrite `HomePage` in `lib/features/home/presentation/pages/home_page.dart`. REPLACE the entire file content. The new `HomePage` is a `StatelessWidget` wrapped in `BlocBuilder<HomeCubit, HomeState>`. Layout:
  ```
  Scaffold(
    appBar: AppBar(
      title: AutoSizeText(AppStrings.appName, maxLines: 1),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => _onProfileTapped(context),
        ),
      ],
    ),
    drawer: const HomeDrawer(),  // Will be created in US2, for now use null
    body: Column(
      children: [
        // Category selector (only if categories loaded)
        if (state.categoriesStatus == Status.success)
          CategorySelector(
            categories: state.categories,
            selectedIndex: state.selectedCategoryIndex,
            onCategorySelected: (index) =>
                context.read<HomeCubit>().selectCategory(index),
          ),
        // Content area
        Expanded(
          child: ContentSwitcher(
            categoryType: homeCubit.selectedCategory?.type,
            wallpapers: state.wallpapers,
            classifications: state.classifications,
            contentStatus: state.contentStatus,
            isLoadingMore: state.isLoadingMore,
            hasReachedEnd: state.hasReachedEnd,
            onLoadMore: () => context.read<HomeCubit>().loadMore(),
            onWallpaperTapped: (wallpaper) {
              // Navigate to wallpaper detail (placeholder for Phase 4)
              // context.push('/wallpaper/${wallpaper.id}');
            },
            onClassificationTapped: (classification) {
              context.push('/classification/${classification.id}', extra: classification);
            },
            onRetry: () => context.read<HomeCubit>().retry(),
            errorMessage: state.errorMessage,
            isPremium: context.read<SubscriptionCubit>().isPremium,
          ),
        ),
      ],
    ),
    // Banner ad placeholder at bottom for guest users
    bottomNavigationBar: context.read<SubscriptionCubit>().isPremium
        ? null
        : Container(
            height: 50.h,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: AutoSizeText(
                'Ad Space',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
  )
  ```

  Keep the existing `_onProfileTapped` method that uses `SubscriptionCubit`. Import `HomeCubit`, `HomeState`, `Status`, `CategorySelector`, `ContentSwitcher`, `SubscriptionCubit`, `AppStrings`, `AppDimens`, `AutoSizeText`, `flutter_screenutil`, `go_router`, `flutter_bloc`.

- [X] T033 [US1] Register `HomeCubit` as Factory in `lib/core/di/injection_container.dart`. Add after the existing cubit registrations:
  ```dart
  sl.registerFactory(
    () => HomeCubit(
      getCategories: sl(),
      getWallpapersByCategory: sl(),
      getClassifications: sl(),
    ),
  );
  ```
  Import `HomeCubit` from the presentation cubit path.

- [X] T034 [US1] Update `lib/app.dart` (or wherever the GoRouter and BlocProviders are configured) to wrap the `HomePage` route with a `BlocProvider<HomeCubit>`:
  - In the GoRouter configuration, find the `GoRoute` for `AppRoutes.home` (path: `/`).
  - Change its `builder` to wrap `HomePage` with `BlocProvider`:
    ```dart
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<HomeCubit>()..loadCategories(),
        child: const HomePage(),
      ),
    ),
    ```
  - Import `HomeCubit` and `sl` (GetIt instance).

- [X] T035 [US1] Run `dart run build_runner build --delete-conflicting-outputs` to generate `home_state.freezed.dart`. Verify no errors. Then run `dart format .` and `flutter analyze` — fix any warnings.

**Checkpoint**: US1 complete — categories display as chips, image wallpapers show in a responsive grid, pagination works, category switching works, premium filtering works. App is usable as MVP.

---

## Phase 4: User Story 2 — Home Screen Layout with Drawer (Priority: P2)

**Goal**: Home screen has a polished AppBar and a navigation drawer with 9 menu items.

**Independent Test**: Tap hamburger → drawer opens → all 9 items visible → tap items → navigates correctly.

### Implementation for User Story 2

- [X] T036 [US2] Create `HomeDrawer` widget in `lib/features/home/presentation/widgets/home_drawer.dart`. A `StatelessWidget` that returns a `Drawer` widget. Contents:
  ```dart
  Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.wallpaper, size: 48.sp, color: Theme.of(context).colorScheme.onPrimary),
              SizedBox(height: 8.h),
              AutoSizeText(
                AppStrings.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        // Navigation group
        _buildMenuItem(context, Icons.home_outlined, AppStrings.home, () {
          Navigator.pop(context);
          context.go(AppRoutes.home);
        }),
        _buildMenuItem(context, Icons.favorite_outline, AppStrings.favorites, () {
          Navigator.pop(context);
          context.push(AppRoutes.favorites);
        }),
        _buildMenuItem(context, Icons.download_outlined, AppStrings.myDownloads, () {
          Navigator.pop(context);
          context.push(AppRoutes.downloads);
        }),
        _buildMenuItem(context, Icons.workspace_premium, AppStrings.premium, () {
          Navigator.pop(context);
          context.push(AppRoutes.premium);
        }),
        const Divider(),
        // Settings group
        _buildMenuItem(context, Icons.settings_outlined, AppStrings.settings, () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        }),
        _buildMenuItem(context, Icons.info_outline, AppStrings.about, () {
          Navigator.pop(context);
          context.push(AppRoutes.about);
        }),
        const Divider(),
        // External actions group
        _buildMenuItem(context, Icons.star_outline, AppStrings.rateApp, () {
          Navigator.pop(context);
          // TODO: Replace with actual store URL in Phase 6
          // launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.glowy.wallpaper'));
        }),
        _buildMenuItem(context, Icons.share_outlined, AppStrings.shareApp, () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: AutoSizeText(AppStrings.comingSoon)),
          );
        }),
        _buildMenuItem(context, Icons.email_outlined, AppStrings.sendFeedback, () {
          Navigator.pop(context);
          // TODO: Replace with actual email in Phase 6
          // launchUrl(Uri.parse('mailto:support@glowywallpapers.com'));
        }),
      ],
    ),
  )
  ```

  Create a `_buildMenuItem` helper method:
  ```dart
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: AutoSizeText(title, maxLines: 1),
      onTap: onTap,
    );
  }
  ```

  Import `go_router`, `AutoSizeText`, `AppStrings`, `AppRoutes`, `AppDimens`, `flutter_screenutil`.

- [X] T037 [US2] Update `HomePage` in `lib/features/home/presentation/pages/home_page.dart` to use `HomeDrawer`. Change the `drawer: null` (or add `drawer` property if missing) to `drawer: const HomeDrawer()`. Import `HomeDrawer` from `lib/features/home/presentation/widgets/home_drawer.dart`.

**Checkpoint**: US2 complete — drawer opens from hamburger menu with all 9 items, navigation works to available routes.

---

## Phase 5: User Story 3 — Video Wallpaper Grid (Priority: P3)

**Goal**: Video-type categories show a grid where 2-3 videos auto-play muted loops, remaining show thumbnails.

**Independent Test**: Select video category → video cells appear → 2-3 auto-play → scroll off pauses → tap navigates.

### Implementation for User Story 3

- [X] T038 [P] [US3] Create `VideoThumbnail` widget in `lib/features/wallpapers/presentation/widgets/video_thumbnail.dart`. A `StatefulWidget` that takes `WallpaperEntity wallpaper`, `VoidCallback onTap`, and `bool shouldAutoPlay` (controlled by parent). State manages a `VideoPlayerController?`.

  In `initState`: if `shouldAutoPlay && wallpaper.videoUrl != null`, initialize video controller:
  ```dart
  _controller = VideoPlayerController.networkUrl(Uri.parse(wallpaper.videoUrl!))
    ..initialize().then((_) {
      if (mounted) {
        setState(() {});
        _controller!.setLooping(true);
        _controller!.setVolume(0.0);
        _controller!.play();
      }
    });
  ```

  In `didUpdateWidget`: if `shouldAutoPlay` changed:
  - Became true and controller is null → initialize (same as above).
  - Became true and controller exists → `_controller!.play()`.
  - Became false and controller exists → `_controller!.pause()`.

  In `dispose`: `_controller?.dispose()`.

  Build method:
  ```dart
  GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or thumbnail
          if (_controller != null && _controller!.value.isInitialized && shouldAutoPlay)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            AppCachedImage(imageUrl: wallpaper.thumbnailUrl, fit: BoxFit.cover),
          // Play icon overlay when not auto-playing
          if (!shouldAutoPlay || _controller == null || !_controller!.value.isInitialized)
            Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 40.sp,
                color: Colors.white.withAlpha(200),
              ),
            ),
        ],
      ),
    ),
  )
  ```
  Import `video_player`, `AppCachedImage`, `flutter_screenutil`.

- [X] T039 [US3] Create `VideoGrid` widget in `lib/features/wallpapers/presentation/widgets/video_grid.dart`. A `StatefulWidget` that takes the same props as `WallpaperGrid` (wallpapers, isLoadingMore, hasReachedEnd, onLoadMore, onWallpaperTapped, isPremium).

  State holds: `Set<int> _autoPlayIndices = {}` tracking which indices should auto-play (max 3).

  Uses `VisibilityDetector` from `visibility_detector` package to wrap each cell. On visibility change:
  - If `visibleFraction > 0.5` → add index to candidates.
  - If `visibleFraction <= 0.1` → remove index from candidates.
  - Recalculate `_autoPlayIndices`: take the first 3 from candidates (by order of visibility fraction, highest first). Call `setState` to update.

  The grid layout is the same as `WallpaperGrid` (same column logic, same pagination listener). Each cell:
  ```dart
  VisibilityDetector(
    key: Key('video_${wallpaper.id}'),
    onVisibilityChanged: (info) => _onVisibilityChanged(index, info),
    child: VideoThumbnail(
      wallpaper: wallpaper,
      onTap: () => onWallpaperTapped(wallpaper),
      shouldAutoPlay: _autoPlayIndices.contains(index),
    ),
  )
  ```

  Filter premium wallpapers same as WallpaperGrid. Import `visibility_detector`.

- [X] T040 [US3] Update `ContentSwitcher` in `lib/features/home/presentation/widgets/content_switcher.dart`. Replace the `CategoryType.video` case placeholder with actual `VideoGrid` widget:
  ```dart
  case CategoryType.video:
    return VideoGrid(
      wallpapers: wallpapers,
      isLoadingMore: isLoadingMore,
      hasReachedEnd: hasReachedEnd,
      onLoadMore: onLoadMore,
      onWallpaperTapped: onWallpaperTapped,
      isPremium: isPremium,
    );
  ```
  Import `VideoGrid` from `lib/features/wallpapers/presentation/widgets/video_grid.dart`.

**Checkpoint**: US3 complete — video categories show auto-playing previews (2-3 concurrent), thumbnails for the rest, pagination works.

---

## Phase 6: User Story 4 — Classification Bento Grid (Priority: P4)

**Goal**: Classification-type categories show a bento grid. Tapping a card opens a ClassificationDetail page with paginated wallpapers.

**Independent Test**: Select classification category → bento cards appear → tap card → detail page opens with wallpapers → pagination works.

### Implementation for User Story 4

- [X] T041 [P] [US4] Create `ClassificationCard` widget in `lib/features/categories/presentation/widgets/classification_card.dart`. A `StatelessWidget` that takes `ClassificationEntity classification`, `VoidCallback onTap`, and `double height`. Renders:
  ```dart
  GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusM.r), // or 12.r
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppCachedImage(
              imageUrl: classification.thumbnailUrl,
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(140),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Name overlay
            Positioned(
              left: 12.w,
              bottom: 12.h,
              right: 12.w,
              child: AutoSizeText(
                classification.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  )
  ```
  Import `AppCachedImage`, `AutoSizeText`, `AppDimens`, `flutter_screenutil`.

- [X] T042 [US4] Create `ClassificationBentoGrid` widget in `lib/features/categories/presentation/widgets/classification_bento_grid.dart`. A `StatelessWidget` that takes `List<ClassificationEntity> classifications` and `ValueChanged<ClassificationEntity> onClassificationTapped`. Renders a `ListView.builder` with the repeating bento pattern:

  Build a list of row widgets from the classifications. Pattern: index 0 = large (2-col span), index 1-2 = small row (two side by side), index 3 = large, index 4-5 = small row, etc. Algorithm:
  ```dart
  int i = 0;
  while (i < classifications.length) {
    // Large card
    rows.add(ClassificationCard(
      classification: classifications[i],
      onTap: () => onClassificationTapped(classifications[i]),
      height: AppDimens.bentoLargeCardHeight,
    ));
    i++;
    // Small cards row (up to 2)
    if (i < classifications.length) {
      final smallCards = <Widget>[];
      for (int j = 0; j < 2 && i < classifications.length; j++, i++) {
        smallCards.add(Expanded(
          child: ClassificationCard(
            classification: classifications[i],
            onTap: () => onClassificationTapped(classifications[i]),
            height: AppDimens.bentoSmallCardHeight,
          ),
        ));
        if (j == 0 && i + 1 < classifications.length) {
          smallCards.add(SizedBox(width: AppDimens.bentoCardGap));
        }
      }
      rows.add(Row(children: smallCards));
    }
  }
  ```

  Return `ListView.separated(itemCount: rows.length, itemBuilder: (_, i) => rows[i], separatorBuilder: (_, __) => SizedBox(height: AppDimens.bentoCardGap))` with `padding: EdgeInsets.all(AppDimens.paddingM)`.

- [X] T043 [P] [US4] Create `ClassificationDetailState` (Freezed) in `lib/features/categories/presentation/cubit/classification_detail_state.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
  import '../../domain/entities/classification_entity.dart';
  import '../../../home/presentation/cubit/home_state.dart'; // for Status enum

  part 'classification_detail_state.freezed.dart';

  @freezed
  class ClassificationDetailState with _$ClassificationDetailState {
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
  Note: Reuses the `Status` enum from `home_state.dart`. If this creates a circular dependency, move the `Status` enum to a shared file like `lib/core/utils/status_enum.dart` and import it in both files.

- [X] T044 [US4] Create `ClassificationDetailCubit` in `lib/features/categories/presentation/cubit/classification_detail_cubit.dart`. Constructor takes `GetWallpapersByClassification` use case and `ClassificationEntity classification`. Initial state: `ClassificationDetailState(classification: classification)`. Methods:

  **`loadWallpapers()`**: Call `getWallpapersByClassification(GetWallpapersByClassificationParams(classificationId: state.classification.id, page: state.currentPage))`. On `Right(response)`: if items empty && page 1 → emit `status: Status.empty`. Else → emit `status: Status.success, wallpapers: [...state.wallpapers, ...response.items], hasReachedEnd: !response.hasMore, isLoadingMore: false`. On `Left(failure)` → emit `status: Status.error, errorMessage: failure.message`.

  **`loadMore()`**: If `hasReachedEnd || isLoadingMore || status != success` → return. Emit `isLoadingMore: true, currentPage: state.currentPage + 1`. Call `loadWallpapers()`.

  **`retry()`**: Emit `status: Status.loading`. Call `loadWallpapers()`.

- [X] T045 [US4] Create `ClassificationDetailPage` in `lib/features/categories/presentation/pages/classification_detail_page.dart`. A `StatelessWidget` using `BlocBuilder<ClassificationDetailCubit, ClassificationDetailState>`. Layout:
  ```dart
  Scaffold(
    appBar: AppBar(
      title: AutoSizeText(state.classification.name, maxLines: 1),
    ),
    body: _buildBody(context, state),
  )
  ```

  `_buildBody` method: switch on `state.status`:
  - `Status.loading` → `Center(child: AppLoading())`.
  - `Status.error` → `AppErrorWidget(message: state.errorMessage ?? AppStrings.error, onRetry: () => context.read<ClassificationDetailCubit>().retry())`.
  - `Status.empty` → centered empty state with icon + `AutoSizeText(AppStrings.noWallpapers)`.
  - `Status.success` → `WallpaperGrid(wallpapers: state.wallpapers, isLoadingMore: state.isLoadingMore, hasReachedEnd: state.hasReachedEnd, onLoadMore: () => context.read<ClassificationDetailCubit>().loadMore(), onWallpaperTapped: (wp) { /* Phase 4 detail */ }, isPremium: context.read<SubscriptionCubit>().isPremium)`.

  Import `WallpaperGrid`, `AppLoading`, `AppErrorWidget`, `AutoSizeText`, `AppStrings`, `SubscriptionCubit`, `flutter_bloc`.

- [X] T046 [US4] Register `ClassificationDetailCubit` in `lib/core/di/injection_container.dart`:
  ```dart
  sl.registerFactoryParam<ClassificationDetailCubit, ClassificationEntity, void>(
    (classification, _) => ClassificationDetailCubit(
      getWallpapersByClassification: sl(),
      classification: classification,
    ),
  );
  ```
  Import `ClassificationDetailCubit` and `ClassificationEntity`.

- [X] T047 [US4] Add `ClassificationDetailPage` route to the GoRouter configuration in `lib/app.dart` (or wherever GoRouter is configured). Add a `GoRoute`:
  ```dart
  GoRoute(
    path: '/classification/:id',
    builder: (context, state) {
      final classification = state.extra as ClassificationEntity;
      return BlocProvider(
        create: (context) => sl<ClassificationDetailCubit>(param1: classification)
          ..loadWallpapers(),
        child: const ClassificationDetailPage(),
      );
    },
  ),
  ```
  Import `ClassificationDetailPage`, `ClassificationDetailCubit`, `ClassificationEntity`.

- [X] T048 [US4] Update `ContentSwitcher` in `lib/features/home/presentation/widgets/content_switcher.dart`. Replace the `CategoryType.classification` case placeholder with actual `ClassificationBentoGrid`:
  ```dart
  case CategoryType.classification:
    return ClassificationBentoGrid(
      classifications: classifications,
      onClassificationTapped: onClassificationTapped,
    );
  ```
  Import `ClassificationBentoGrid` from `lib/features/categories/presentation/widgets/classification_bento_grid.dart`.

- [X] T049 [US4] Run `dart run build_runner build --delete-conflicting-outputs` to generate `classification_detail_state.freezed.dart`. Verify no errors.

**Checkpoint**: US4 complete — classification categories show bento grid, tapping a card opens detail with paginated wallpapers.

---

## Phase 7: User Story 5 — Dynamic Content Switching (Priority: P5)

**Goal**: Verify all three grid types switch seamlessly when tapping different category types.

**Independent Test**: Select image → image grid → select video → video grid → select classification → bento → switch back.

### Implementation for User Story 5

- [X] T050 [US5] Verify `ContentSwitcher` handles all three `CategoryType` cases with real widgets (not placeholders). At this point, all three should already be wired from US1 (image), US3 (video), US4 (classification). Open `lib/features/home/presentation/widgets/content_switcher.dart` and verify:
  - `CategoryType.image` → `WallpaperGrid`
  - `CategoryType.video` → `VideoGrid`
  - `CategoryType.classification` → `ClassificationBentoGrid`
  If any are still placeholders, replace them with the real widget calls.

- [X] T051 [US5] Verify `HomeCubit.selectCategory()` properly cancels in-flight requests and resets state on category switch. Open `lib/features/home/presentation/cubit/home_cubit.dart` and confirm:
  1. `_activeCancelToken?.cancel()` is called at the start of `selectCategory()`.
  2. State resets: `wallpapers: [], classifications: [], currentPage: 1, hasReachedEnd: false, isLoadingMore: false, contentStatus: Status.loading`.
  3. New `CancelToken` is created in `_loadWallpapers()`.
  4. `DioException` with `CancelToken.isCancel(e)` is silently ignored in the repository.
  If any of these are missing, add them.

**Checkpoint**: US5 complete — all grid types switch seamlessly, no stale data, no crashes on rapid switching.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Code generation, formatting, static analysis, and end-to-end verification.

- [X] T052 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate ALL code-gen files. This is a final pass to catch any missing `.freezed.dart` or `.g.dart` files.

- [X] T053 Run `dart format .` from the project root to format all Dart files.

- [X] T054 Run `flutter analyze` and fix ALL warnings and errors. Common issues to look for:
  - Unused imports → remove them.
  - Missing `const` constructors → add `const` where possible.
  - Deprecated API usage → update to current API.
  - Type inference issues → add explicit types.
  Zero warnings required before completion.

- [X] T055 Verify the app compiles and runs: `flutter run`. Check:
  - Categories load on Home screen.
  - Category chips are tappable.
  - Image grid shows for image categories.
  - Video grid shows for video categories (auto-play if server has videos).
  - Bento grid shows for classification categories.
  - Drawer opens with all 9 items.
  - Classification detail page opens.
  - Pagination works.
  - Premium filtering works (test as guest: premium items hidden).
  If the app crashes or has visual issues, fix them.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (pubspec, strings, endpoints) — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 — MVP, implement first
- **US2 (Phase 4)**: Depends on Phase 2 — can run in parallel with US1
- **US3 (Phase 5)**: Depends on Phase 2 + US1 (reuses WallpaperGrid pattern)
- **US4 (Phase 6)**: Depends on Phase 2 — can run in parallel with US1/US2
- **US5 (Phase 7)**: Depends on US1, US3, US4 (integration verification)
- **Polish (Phase 8)**: Depends on all user stories

### User Story Dependencies

- **US1 (P1)**: After Phase 2 — no story dependencies (MVP)
- **US2 (P2)**: After Phase 2 — independent of US1 (drawer only)
- **US3 (P3)**: After Phase 2 + US1 (needs WallpaperGrid, ContentSwitcher pattern from US1)
- **US4 (P4)**: After Phase 2 — mostly independent (uses WallpaperGrid from US1 for detail page)
- **US5 (P5)**: After US1 + US3 + US4 (integration verification only)

### Within Each User Story

- State files (Freezed) before Cubits
- Cubits before Pages
- Widgets before Pages that use them
- DI registration before Pages that need injection
- build_runner after all Freezed files written

### Parallel Opportunities

- **Phase 1**: T002, T003, T004, T005 can all run in parallel (different files)
- **Phase 2**: T006, T007, T008 in parallel (entities). T009, T010, T011 after entities. T012-T015 in parallel (use cases). T016, T017, T018 in parallel (models). T019, T020, T021 after models. T022, T023 after data sources.
- **Phase 3**: T026, T028, T029 in parallel. T027 after T026 (needs HomeState). T030-T032 sequential.
- **Phase 4-6**: US2 (T036-T037) can run in parallel with US1. US4 (T041-T049) partially parallel with US3.

---

## Parallel Example: Phase 2 Entities

```bash
# Launch all entity files together (different files, no dependencies):
Task: T006 — CategoryEntity in categories/domain/entities/
Task: T007 — ClassificationEntity in categories/domain/entities/
Task: T008 — WallpaperEntity in wallpapers/domain/entities/
```

## Parallel Example: Phase 2 Use Cases

```bash
# After entities + contracts are done, launch use cases together:
Task: T012 — GetCategories
Task: T013 — GetClassifications
Task: T014 — GetWallpapersByCategory
Task: T015 — GetWallpapersByClassification
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T005)
2. Complete Phase 2: Foundational (T006-T025) — CRITICAL blocking phase
3. Complete Phase 3: US1 (T026-T035)
4. **STOP and VALIDATE**: Categories + image grid + pagination working
5. App is usable as MVP

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 → Image browsing works (MVP!)
3. Add US2 → Drawer navigation works
4. Add US3 → Video auto-play works
5. Add US4 → Classification bento + detail works
6. Add US5 → All grid types switch seamlessly
7. Polish → Clean, formatted, zero warnings

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story
- `Status` enum is shared — consider extracting to `lib/core/utils/status_enum.dart` if import cycles occur
- Video playback requires real URLs — test with mock API or test video URLs
- `PaginatedResponse` is plain Dart (not Freezed) to avoid generic serialization complexity
- Hive box `categories` must be opened in `main.dart` before DI init
- `CancelToken` from Dio is used for request cancellation — import from `package:dio/dio.dart`
- Hero tag `wallpaper_${id}` is set now for Phase 4 detail transition
