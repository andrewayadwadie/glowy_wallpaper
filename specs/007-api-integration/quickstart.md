# Quickstart & Integration Scenarios: Real API Integration

**Branch**: `007-api-integration` | **Date**: 2026-03-25

---

## Scenario 1: Cold Start — No Cache

```
App launches cold, no Hive cache exists for 'app_bootstrap'.

1. HomeCubit.loadAppData() called
2. BootstrapLocalDataSource.getAppMetadata() → null (no cache)
3. BootstrapRemoteDataSource.getAppData(appId) → API-1 call (publicDio, no auth)
4. Response parsed → AppMetadataModel → AppMetadataEntity
5. BootstrapLocalDataSource.saveAppMetadata(entity) → stored in Hive
6. HomeState emitted:
     appMetadata = AppMetadataEntity (populated)
     categories = entity.categories (sorted by displayOrder)
     categoriesStatus = Status.success
7. HomeCubit auto-selects categories[0] (first by displayOrder)
8. HomeCubit.selectCategory(0) fires
9. Based on categories[0].type:
   - IMAGES/VIDEOS → WallpaperRemoteDataSource.getWallpapersByCategory(...)
   - IMAGE_CLASSIFICATION → CategoryRemoteDataSource.getClassifications(...)
10. Content grid renders
```

---

## Scenario 2: Warm Launch — Cache Exists

```
App launches, Hive 'app_bootstrap' has valid cached AppMetadataModel.

1. HomeCubit.loadAppData() called
2. BootstrapLocalDataSource.getAppMetadata() → cached AppMetadataModel
3. HomeState emitted immediately (no loading spinner):
     appMetadata = cached entity
     categories = cached categories
     categoriesStatus = Status.success
4. Auto-select first category → content loads
5. Background fetch fires simultaneously:
     BootstrapRemoteDataSource.getAppData(appId) (publicDio)
6. When background fetch completes → Hive updated → HomeState updated silently
   (UI updates only if categories changed — e.g., new category added)
```

---

## Scenario 3: Content Pagination

```
User taps "Neon" category (IMAGES type, categoryId = "cat-uuid-1").

Page 1:
  WallpaperRemoteDataSource.getWallpapersByCategory(
    categoryId: "cat-uuid-1", page: 1, limit: 20
  )
  → 20 items, pagination.totalPages = 8
  HomeState: wallpapers = [items 1-20], currentPage = 1, hasReachedEnd = false

User scrolls to bottom:
  HomeCubit.loadMore() called
  Check: currentPage(1) < totalPages(8) → proceed
  WallpaperRemoteDataSource.getWallpapersByCategory(
    categoryId: "cat-uuid-1", page: 2, limit: 20
  )
  → 20 more items
  HomeState: wallpapers = [items 1-40], currentPage = 2, hasReachedEnd = false

User reaches page 8 (last page):
  HomeCubit.loadMore() called
  Check: currentPage(8) >= totalPages(8) → hasReachedEnd = true → NO network call
  End-of-list indicator shown in grid
```

---

## Scenario 4: Classification Flow

```
User taps "By Style" category (IMAGE_CLASSIFICATION type, categoryId = "cat-uuid-3").

1. HomeCubit.selectCategory(2) called
2. category.type == IMAGE_CLASSIFICATION → fetch classifications
3. CategoryRemoteDataSource.getClassifications(
     appId: AppConfig.appId,
     categoryId: "cat-uuid-3"
   ) → publicDio, API-3
4. HomeState: classifications = [Cyberpunk, Minimal, ...], contentStatus = success

User taps "Cyberpunk" classification card (classificationId = "cls-uuid-1"):

5. HomeCubit.selectClassification("cls-uuid-1") called
6. WallpaperRemoteDataSource.getWallpapersByCategory(
     categoryId: "cat-uuid-3",
     page: 1,
     limit: 20,
     classificationId: "cls-uuid-1"   ← filter applied
   ) → publicDio, API-2
7. HomeState: wallpapers = [Cyberpunk wallpapers], contentStatus = success
8. Pagination works same as Scenario 3
```

---

## Scenario 5: Network Error (No Cache)

```
App launches, no cache, device has no network.

1. BootstrapLocalDataSource.getAppMetadata() → null
2. BootstrapRemoteDataSource.getAppData() → DioException (connection error)
3. AppRepositoryImpl → Left(NetworkFailure("No internet connection"))
4. HomeCubit receives Left → HomeState.categoriesStatus = Status.error
5. HomeScreen shows AppErrorWidget with "No internet connection" + Retry button

User taps Retry:
6. HomeCubit.retry() → loadAppData() called again
7. If network now available → proceeds to Scenario 1
```

---

## Scenario 6: Drawer Shows Dynamic Content

```
User opens the side drawer after bootstrap has loaded.

HomeDrawer reads:
  context.watch<HomeCubit>().state.appMetadata

AppMetadataEntity present:
- "About" menu item → taps → ContentPage shows appMetadata.about (API-sourced)
- "Privacy Policy" → ContentPage shows appMetadata.privacyPolicy (API-sourced)
- "Terms of Use" → ContentPage shows appMetadata.termsOfUse (API-sourced)
- "Share App" → Share.share(Platform.isAndroid
    ? appMetadata.androidShareLink
    : appMetadata.iphoneShareLink)
- "Send Feedback" → mailto: appMetadata.contactEmail

AppMetadataEntity null (bootstrap not yet complete):
- All above actions use AppConfig fallback values (graceful degradation)
```

---

## Scenario 7: Server Error During Content Load

```
User taps a category, server returns 500.

1. WallpaperRemoteDataSource.getWallpapersByCategory() → 500 response
2. WallpaperRepositoryImpl → Left(ServerFailure("Internal server error"))
3. HomeCubit → HomeState.contentStatus = Status.error
4. ContentSwitcher shows AppErrorWidget with server error message + Retry button
5. User taps Retry → HomeCubit.retry() → re-fetches page 1 of that category
```

---

## Key Integration Points

| Component | Change | Impact |
|-----------|--------|--------|
| `InjectionContainer` | Register `publicDio` (no AuthInterceptor), register `BootstrapRemoteDataSource`, `BootstrapLocalDataSource`, `AppRepositoryImpl`, `GetAppData` use case | New registrations |
| `HomeCubit` | Add `GetAppData` dependency, call `loadAppData()` on init, store `appMetadata` in state, auto-select first category | Constructor change |
| `HomeState` | Add `appMetadata: AppMetadataEntity?` field | Freezed regeneration |
| `HomeDrawer` | Read `appMetadata` from `HomeCubit` state instead of `AppConfig` | Behaviour change |
| `ContentPage` | Read body text from `appMetadata` via `HomeCubit` | Behaviour change |
| `WallpaperModel` | Fully replaced fields to match API-2 | Breaking change, regenerate Freezed |
| `CategoryModel` | Add `imageCount`, remove `thumbnailUrl` | Freezed regeneration |
| `ClassificationModel` | `wallpaperCount` → `itemCount` | Freezed regeneration |
| `PaginatedResponse` | Add `totalPages`, remove `hasMore` | Update all consumers |
| `WallpaperRemoteDataSource` | New URL, rename `perPage`→`limit`, add `classificationId?`, remove separate classification method | URL + signature change |
| `CategoryRemoteDataSource` | New URL with appId, remove `getCategories()` | URL change |
| `AppConfig` | Add `appId` constant | New field |

---

## Test Matrix

| Test | File | Scenarios Covered |
|------|------|-------------------|
| Bootstrap data source | `test/features/app/data/bootstrap_remote_data_source_test.dart` | Success, 404, 500, empty categories |
| Bootstrap repository | `test/features/app/data/app_repository_impl_test.dart` | Cache miss+fetch, cache hit+background, network error |
| GetAppData use case | `test/features/app/domain/get_app_data_test.dart` | Success, failure propagation |
| Wallpaper data source | `test/features/wallpapers/data/wallpaper_remote_data_source_test.dart` | Page 1, next page, last page, classificationId filter, 500 |
| Wallpaper repository | `test/features/wallpapers/data/wallpaper_repository_impl_test.dart` | Happy path, server failure, network failure |
| Classification data source | `test/features/categories/data/category_remote_data_source_test.dart` | Success, 404, 500 |
| HomeCubit | `test/features/home/presentation/home_cubit_test.dart` | Auto-select first category, pagination, loadMore stops at last page, retry |
