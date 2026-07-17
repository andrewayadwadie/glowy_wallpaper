# Research: Real API Integration

**Branch**: `007-api-integration` | **Date**: 2026-03-25

---

## Decision 1: Where does the new bootstrap data live architecturally?

**Decision**: New `lib/features/app/` feature — domain + data layers only (no presentation screen).

**Rationale**: The bootstrap response is a cross-cutting concern consumed by HomeCubit (categories), HomeDrawer (about/privacy/terms/share links/email), and ContentPage (dynamic text). A dedicated `app` feature keeps the domain entity (`AppMetadataEntity`) isolated from any single presentation feature, avoiding coupling between `home` and `categories`. No presentation layer is needed because no standalone screen exists for bootstrap data.

**Alternatives considered**:
- Extend existing `categories` feature — rejected because bootstrap returns far more than categories; mixing concerns violates SRP.
- Extend existing `home` feature — rejected because drawer and content pages live outside home; putting bootstrap data there creates improper cross-feature dependency.

---

## Decision 2: How to handle public APIs when an auth interceptor is attached to all requests?

**Decision**: Register a separate `publicDio` instance (without `AuthInterceptor`) in the DI container. All three public API data sources (`BootstrapRemoteDataSource`, updated `CategoryRemoteDataSource`, updated `WallpaperRemoteDataSource`) receive `publicDio`.

**Rationale**: The three public endpoints (bootstrap, content, classifications) must not send Authorization headers per FR-017. Creating a dedicated Dio instance is the cleanest approach — no URL exclusion logic, no conditional header stripping, no changes to `AuthInterceptor`. Named registration in GetIt (`publicDio` vs `authenticatedDio`) clearly signals intent.

**Alternatives considered**:
- URL exclusion list in `AuthInterceptor` — rejected: fragile, requires updating the interceptor whenever URLs change, violates Open/Closed principle.
- Pass a skip-auth flag per request — rejected: invasive, pollutes every call site.

---

## Decision 3: How should WallpaperEntity fields be updated to match API-2?

**Decision**: Fully replace `WallpaperModel` fields to match API-2 response exactly. Existing fields (`title`, `imageUrl`, `videoUrl`, `isPremium`, `classificationIds`) are replaced by the actual API fields (`url`, `thumbUrl`, `isTopRated`, `mediaType`, `classificationId`, `classificationName`, `classificationThumbnailUrl`, `createdAt`).

**Rationale**: The current model was a placeholder that does not match the real API contract. Since no production data is live yet, there is no migration risk. A clean replacement is safer than aliasing mismatched fields.

**Alternatives considered**:
- Alias old names to new ones with `@JsonKey` — rejected: confusing, accumulates debt, creates divergence between model and entity.

---

## Decision 4: How to merge `getWallpapersByClassification()` into the content endpoint?

**Decision**: Remove the standalone `getWallpapersByClassification()` method from `WallpaperRemoteDataSource`. Add an optional `classificationId` parameter to `getWallpapersByCategory()`. When provided, it appends `&classificationId={id}` to the query string. The API path remains `GET /api/v1/mobile/apps/{appId}/categories/{categoryId}/content`.

**Rationale**: The API design (per API-2 spec) uses a single content endpoint for all category types, with classification filtering via query param. Having two separate methods was an incorrect modeling of the API. Merging reduces the data source surface area and aligns exactly with the server contract.

**Alternatives considered**:
- Keep separate method, map to same endpoint — rejected: unnecessary duplication of URL construction logic.

---

## Decision 5: Where does `AppMetadata` live in the widget tree?

**Decision**: `AppMetadata` is stored as part of `HomeState` (`appMetadata` field). `HomeDrawer` and `ContentPage` access it via `context.watch<HomeCubit>().state.appMetadata`. No new root-level cubit is needed.

**Rationale**: `HomeCubit` already orchestrates the app startup flow (load categories, select first category, load content). Bootstrap is part of the same init sequence. `HomeDrawer` is a child of `HomeScreen` where `HomeCubit` is already in scope. This avoids adding a second root-level cubit (parallel to `SubscriptionCubit`) for a concern that is already naturally owned by the home initialization.

**Alternatives considered**:
- New `AppDataCubit` at the root — rejected: over-engineering for data that is only needed within the home/drawer context.
- Pass metadata through constructors — rejected: prop-drilling through drawer → menu items is verbose.

---

## Decision 6: How does stale-while-revalidate work for bootstrap?

**Decision**: On every app launch:
1. Check if Hive cache has a stored `AppMetadataModel`.
2. If yes → emit cached data immediately (no loading state).
3. Simultaneously fire a background network fetch.
4. When background fetch completes → update Hive cache and emit fresh data.
5. If no cache AND network fails → emit error state with retry.
6. If no cache AND network succeeds → emit data (normal load path).

**Rationale**: This matches the clarified requirement (Q2 answer: true stale-while-revalidate, always refreshes on launch). It mirrors the existing pattern already implemented in `CategoryRepositoryImpl.getCategories()`, which has a working `onCategoriesRefreshed` callback mechanism.

---

## Decision 7: How is `appId` provided to data sources?

**Decision**: Add `static const String appId = 'YOUR_APP_ID'` to `AppConfig`. Pass it as a constructor parameter to data sources that need it (`BootstrapRemoteDataSource`, `CategoryRemoteDataSource`, `WallpaperRemoteDataSource`). In production, this value should move to `envied` environment configuration.

**Rationale**: The `appId` is a compile-time configuration value, not runtime data. `AppConfig` already holds `androidPackageName`, `iosAppId`, etc. — `appId` belongs in the same place. The actual value will be provided by the backend team.

---

## Decision 8: How does `PaginatedResponse` adapt to the new API?

**Decision**: Update `PaginatedResponse<T>` to include `totalPages` alongside `total`. Compute `hasReachedEnd` as `currentPage >= totalPages` (changed from `hasMore: bool`). Rename `perPage` parameter to `limit` across all data source method signatures to match API query param name.

**Rationale**: The API returns `totalPages` which is the canonical end-of-list signal (per FR-008 and API-2 spec). The existing `hasMore: bool` field was a derived boolean that required the data source to compute it — moving this to the domain/cubit layer as `page >= totalPages` keeps the model purely descriptive.

---

## Decision 9: Test strategy for API integration

**Decision**: Use `mocktail` (already mandated by constitution) + `http_mock_adapter` (Dio-specific mock) for unit tests. Each data source gets its own test file with JSON fixture files stored under `test/fixtures/`. Tests cover: happy path, empty list, server error (500), network error, pagination last page.

**Rationale**: Constitution §VII mandates `mocktail`. `http_mock_adapter` is the idiomatic Dio testing solution — it intercepts at the adapter level without requiring a real HTTP client. JSON fixtures keep tests readable and reproducible.

**Alternatives considered**:
- `mockito` — rejected: constitution mandates `mocktail`.
- Real staging server — rejected: spec explicitly states "mock HTTP responses for determinism".
