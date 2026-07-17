# Tasks: Real API Integration

**Input**: Design documents from `/specs/007-api-integration/`
**Prerequisites**: plan.md ✅ spec.md ✅ research.md ✅ data-model.md ✅ contracts/ ✅ quickstart.md ✅

**Tests**: Included — explicitly requested in spec (FR-014, FR-015, FR-016, US4)

**Organization**: Tasks grouped by user story. Tests included in each story's phase per spec requirement.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Non-breaking infrastructure changes that unblock all user stories

- [ ] T001 Add `appId` constant to `lib/core/config/app_config.dart` (value: placeholder string matching backend app ID; note: move to envied in production)
- [ ] T002 Register `publicDio` (Dio instance without AuthInterceptor, with LoggingInterceptor in debug only) using `instanceName: 'publicDio'` in `lib/core/di/injection_container.dart`
- [ ] T003 Update `PaginatedResponse<T>` — add `totalPages: int` field, remove `hasMore: bool` field in `lib/core/models/paginated_response.dart`; update all existing consumers of `hasMore` to use `page >= totalPages`
- [ ] T004 Create JSON test fixture files: `test/fixtures/bootstrap_success.json`, `test/fixtures/bootstrap_empty_categories.json`, `test/fixtures/content_page1_success.json`, `test/fixtures/content_last_page_success.json`, `test/fixtures/content_classified_success.json`, `test/fixtures/classifications_success.json`, `test/fixtures/server_error.json` — use exact JSON shapes from `contracts/api-contracts.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entity + data model updates that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 [P] Update `CategoryEntity` — add `imageCount: int`, remove `thumbnailUrl` field in `lib/features/categories/domain/entities/category_entity.dart`
- [ ] T006 [P] Update `ClassificationEntity` — rename `wallpaperCount` → `itemCount` in `lib/features/categories/domain/entities/classification_entity.dart`
- [ ] T007 [P] Update `WallpaperEntity` — replace `title`, `imageUrl`, `videoUrl`, `isPremium`, `classificationIds` with `url: String`, `thumbUrl: String`, `isTopRated: bool`, `mediaType: MediaType`, `classificationId: String?`, `classificationName: String?`, `classificationThumbnailUrl: String?`, `createdAt: DateTime`; add `MediaType` enum (`image`, `video`) to same file or `lib/features/wallpapers/domain/entities/media_type.dart`
- [ ] T008 [P] Update `CategoryModel` (data layer) — add `imageCount` JSON field, remove `thumbnailUrl`, update `toEntity()` in `lib/features/categories/data/models/category_model.dart` (requires T005)
- [ ] T009 [P] Update `ClassificationModel` (data layer) — rename `wallpaperCount` → `itemCount` with `@JsonKey(name: 'itemCount')`, update `toEntity()` in `lib/features/categories/data/models/classification_model.dart` (requires T006)
- [ ] T010 [P] Fully replace `WallpaperModel` fields — `url`, `thumbUrl`, `isTopRated`, `mediaType` (String mapped to `MediaType` enum), nullable `classificationId`/`classificationName`/`classificationThumbnailUrl`, `createdAt` as `DateTime` with ISO 8601 JSON parsing; update `toEntity()` in `lib/features/wallpapers/data/models/wallpaper_model.dart` (requires T007)
- [ ] T011 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate Freezed and JSON serialization for `CategoryModel`, `ClassificationModel`, `WallpaperModel` (requires T008, T009, T010)
- [ ] T012 Update `WallpaperRepository` abstract contract — add `classificationId: String?` optional param, rename `perPage` → `limit`, remove `getWallpapersByClassification()` method in `lib/features/wallpapers/domain/repositories/wallpaper_repository.dart` (requires T007)

**Checkpoint**: All domain entities and data models match real API shapes — user story phases can begin

---

## Phase 3: User Story 1 — App Bootstrap with Real Data (Priority: P1) 🎯 MVP

**Goal**: App fetches live app metadata + categories from API-1 on every cold start. HomeDrawer About/Privacy/Terms/Share/Email use server values. First category auto-selected.

**Independent Test**: Launch app → verify category carousel shows server categories in correct order → open drawer → tap About → verify text matches backend-configured `about` field → tap Share App → verify it uses server-provided store link.

### Tests for User Story 1

- [ ] T013 [P] [US1] Write `test/features/app/data/bootstrap_remote_data_source_test.dart` — test cases: (1) success response maps all fields from `bootstrap_success.json`, (2) success with empty categories array from `bootstrap_empty_categories.json`, (3) 404 throws ServerFailure, (4) 500 throws ServerFailure; use `mocktail` + Dio mock adapter
- [ ] T014 [P] [US1] Write `test/features/app/data/app_repository_impl_test.dart` — test cases: (1) no cache → remote fetch → saves to local → returns entity, (2) cache exists → returns cached immediately → background fetch fires, (3) no cache + network error → returns NetworkFailure; mock `BootstrapRemoteDataSource` and `BootstrapLocalDataSource` with `mocktail`
- [ ] T015 [P] [US1] Write `test/features/app/domain/get_app_data_test.dart` — test cases: (1) repository returns Right(entity) → use case returns Right(entity), (2) repository returns Left(failure) → use case returns Left(failure); mock `AppRepository` with `mocktail`

### Implementation for User Story 1

- [ ] T016 [P] [US1] Create `AppMetadataEntity` with fields: `name`, `description`, `about`, `privacyPolicy`, `termsOfUse`, `androidShareLink`, `iphoneShareLink`, `contactEmail`, `categories: List<CategoryEntity>` in `lib/features/app/domain/entities/app_metadata_entity.dart`
- [ ] T017 [P] [US1] Create `AppRepository` abstract contract with `Future<Either<Failure, AppMetadataEntity>> getAppData()` in `lib/features/app/domain/repositories/app_repository.dart`
- [ ] T018 [US1] Create `GetAppData` use case — thin delegate to `AppRepository.getAppData()` in `lib/features/app/domain/usecases/get_app_data.dart` (requires T017)
- [ ] T019 [P] [US1] Create `AppMetadataModel` (Freezed + `@JsonSerializable`) — fields match `data.app` from bootstrap envelope; includes `List<CategoryModel> categories`; `toEntity()` converts to `AppMetadataEntity` sorting categories by `displayOrder` in `lib/features/app/data/models/app_metadata_model.dart`
- [ ] T020 [US1] Create `BootstrapRemoteDataSource` — injects `@Named('publicDio') Dio`, calls `GET /api/v1/mobile/apps/{appId}` (appId from `AppConfig.appId`), parses envelope `data.app` → returns `AppMetadataModel` in `lib/features/app/data/datasources/bootstrap_remote_data_source.dart`
- [ ] T021 [US1] Create `BootstrapLocalDataSource` — injects Hive box `app_bootstrap`, methods: `getAppMetadata() → AppMetadataModel?`, `saveAppMetadata(AppMetadataModel)` using JSON map serialization in `lib/features/app/data/datasources/bootstrap_local_data_source.dart`
- [ ] T022 [US1] Create `AppRepositoryImpl` — stale-while-revalidate: if local cache exists emit cached entity immediately then background-refresh; if no cache fetch remote first; map all failures to typed `Failure` subclasses in `lib/features/app/data/repositories/app_repository_impl.dart` (requires T020, T021)
- [ ] T023 [US1] Run `dart run build_runner build --delete-conflicting-outputs` to generate `AppMetadataModel` Freezed + JSON code
- [ ] T024 [US1] Register app feature in DI: `BootstrapRemoteDataSource` (with `@Named('publicDio') Dio`), `BootstrapLocalDataSource` (with Hive box `app_bootstrap`), `AppRepositoryImpl` bound to `AppRepository`, `GetAppData` use case in `lib/core/di/injection_container.dart` (also open Hive box `app_bootstrap` in init sequence)
- [ ] T025 [US1] Add `appMetadata: AppMetadataEntity?` field to `HomeState` (Freezed) and regenerate in `lib/features/home/presentation/cubit/home_state.dart` — also run `dart run build_runner build --delete-conflicting-outputs`
- [ ] T026 [US1] Update `HomeCubit` — add `GetAppData` dependency; replace `loadCategories()` with `loadAppData()` that calls `GetAppData` use case; on success store `appMetadata` + `categories` in state and immediately call `selectCategory(0)` for auto-select; remove `GetCategories` dependency in `lib/features/home/presentation/cubit/home_cubit.dart`
- [ ] T027 [US1] Update `HomeDrawer` — read `context.watch<HomeCubit>().state.appMetadata` for: app name in header, share links (`androidShareLink`/`iphoneShareLink` by platform), contact email; fall back to `AppConfig` values when `appMetadata` is null in `lib/features/home/presentation/widgets/home_drawer.dart`
- [ ] T028 [US1] Update `ContentPage` — replace hardcoded `_body` switch with values from `HomeCubit` state: `appMetadata?.about`, `appMetadata?.privacyPolicy`, `appMetadata?.termsOfUse`; show loading or fallback when null in `lib/features/home/presentation/pages/content_page.dart`

**Checkpoint**: US1 independently verifiable — cold start shows real categories and real drawer metadata

---

## Phase 4: User Story 2 — Real Wallpaper & Video Content with Pagination (Priority: P2)

**Goal**: IMAGES and VIDEOS categories load real paginated content from API-2. Infinite scroll appends items until `page >= totalPages`.

**Independent Test**: Tap any IMAGES category → grid fills with server wallpapers (thumbnails load via `thumbUrl`) → scroll to bottom → next page appends without scroll jump → reach last page → no more requests fire.

### Tests for User Story 2

- [ ] T029 [P] [US2] Write `test/features/wallpapers/data/wallpaper_remote_data_source_test.dart` — test cases: (1) page 1 success maps all fields from `content_page1_success.json`, (2) last page success from `content_last_page_success.json`, (3) classificationId filter appends query param from `content_classified_success.json`, (4) 500 throws ServerFailure; use `mocktail`
- [ ] T030 [P] [US2] Write `test/features/wallpapers/data/wallpaper_repository_impl_test.dart` — test cases: (1) remote success → Right(PaginatedResponse) with correct fields, (2) DioException connection → Left(NetworkFailure), (3) DioException status 500 → Left(ServerFailure)

### Implementation for User Story 2

- [ ] T031 [US2] Update `WallpaperRemoteDataSource` — change URL to `GET /api/v1/mobile/apps/{appId}/categories/{categoryId}/content`, rename `perPage` → `limit`, add `classificationId: String?` optional query param (append only if non-null), remove `getWallpapersByClassification()` method, parse response from `data.items[]` + `data.pagination` in `lib/features/wallpapers/data/datasources/wallpaper_remote_data_source.dart`
- [ ] T032 [US2] Update `WallpaperRepositoryImpl` — align with updated `WallpaperRepository` contract (add `classificationId?`, rename `perPage`→`limit`, remove `getWallpapersByClassification()`) in `lib/features/wallpapers/data/repositories/wallpaper_repository_impl.dart`
- [ ] T033 [US2] Update `HomeCubit.loadMore()` — replace `hasMore` check with `state.currentPage >= totalPages` guard using `PaginatedResponse.totalPages` in `lib/features/home/presentation/cubit/home_cubit.dart`

**Checkpoint**: US2 independently verifiable — IMAGES/VIDEOS categories load real content with working pagination

---

## Phase 5: User Story 3 — Real Classifications Bento Grid (Priority: P3)

**Goal**: IMAGE_CLASSIFICATION categories fetch real classification cards from API-3. Tapping a card loads filtered content via `classificationId` query param.

**Independent Test**: Tap an IMAGE_CLASSIFICATION category → bento grid shows server-returned classification cards (name, thumbnail, itemCount badge) → tap a card → wallpaper grid loads showing only wallpapers for that classification.

### Tests for User Story 3

- [ ] T034 [P] [US3] Write `test/features/categories/data/category_remote_data_source_test.dart` — test cases: (1) classifications success maps all fields from `classifications_success.json` (id, name, thumbnailUrl, itemCount), (2) 404 throws ServerFailure, (3) 500 throws ServerFailure; use `mocktail`

### Implementation for User Story 3

- [ ] T035 [US3] Update `CategoryRemoteDataSource` — change `getClassifications()` URL to `GET /api/v1/mobile/apps/{appId}/categories/{categoryId}/classifications`, inject `@Named('publicDio') Dio` and `AppConfig.appId`, remove `getCategories()` method in `lib/features/categories/data/datasources/category_remote_data_source.dart`
- [ ] T036 [US3] Update `CategoryRepository` abstract contract — remove `getCategories()` method declaration in `lib/features/categories/domain/repositories/category_repository.dart`
- [ ] T037 [US3] Update `CategoryRepositoryImpl` — remove `getCategories()` stale-while-revalidate logic and `onCategoriesRefreshed` callback (categories now sourced from AppRepository), keep and update `getClassifications()` in `lib/features/categories/data/repositories/category_repository_impl.dart`

**Checkpoint**: US3 independently verifiable — IMAGE_CLASSIFICATION categories show real bento grid with working classification drill-down

---

## Phase 6: User Story 4 — API Integration Test Coverage (Priority: P4)

**Goal**: Full automated test suite passes with zero failures across all three API integration flows.

**Independent Test**: Run `flutter test` — all tests pass, zero failures, zero errors.

- [ ] T038 [US4] Write `test/features/home/presentation/home_cubit_test.dart` using `bloc_test` — test cases: (1) `loadAppData()` on success emits categoriesStatus=success and auto-calls `selectCategory(0)`, (2) `loadMore()` appends next page items to wallpapers list, (3) `loadMore()` does NOT fire when `currentPage >= totalPages`, (4) `retry()` re-calls `loadAppData()` after error state; mock `GetAppData`, `GetWallpapersByCategory`, `GetClassifications` with `mocktail`

**Checkpoint**: All tests green — feature is verified correct across all 3 APIs

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup, final code gen pass, quality gates

- [ ] T039 Remove stale `GetCategories` use case registration and `CategoryRepositoryImpl` stale-while-revalidate callback setup from `lib/core/di/injection_container.dart` (categories now sourced from `AppRepositoryImpl`)
- [ ] T040 Run `dart run build_runner build --delete-conflicting-outputs` — final code generation pass for all Freezed models and JSON serializers
- [ ] T041 Run `flutter test` — verify all tests in `test/features/app/`, `test/features/wallpapers/`, `test/features/categories/`, `test/features/home/` pass with zero failures
- [ ] T042 Run `flutter analyze` — fix any warnings or lint errors introduced by model field changes, removed methods, or updated imports
- [ ] T043 Run `dart format .` — ensure consistent formatting across all new and modified files

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately; T001–T004 all independent
- **Foundational (Phase 2)**: Depends on Phase 1 completion — BLOCKS all user stories
  - T005, T006, T007 parallelizable (different entity files)
  - T008, T009, T010 parallelizable (different model files); each depends on its corresponding entity update
  - T011 (build_runner) depends on T008 + T009 + T010
  - T012 (WallpaperRepository contract) depends on T007
- **User Stories (Phase 3–6)**: All depend on Phase 2 completion
  - US1 (Phase 3): Foundational → T016–T028 in sequence with internal parallelism
  - US2 (Phase 4): Foundational → T031–T033; T029/T030 (tests) parallelizable
  - US3 (Phase 5): Foundational + US2's T031 (classificationId param on content API) → T035–T037
  - US4 (Phase 6): All previous phases complete → T038
- **Polish (Phase 7)**: All phases complete

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational only — no other story dependency
- **US2 (P2)**: Depends on Foundational only — US1 and US2 can run in parallel
- **US3 (P3)**: Depends on Foundational + US2 (T031 adds `classificationId?` to content API call that US3 tap-on-card uses)
- **US4 (P4)**: Depends on US1 + US2 + US3 all complete (tests the integrated cubit)

### Within Each User Story

- Tests (T013–T015, T029–T030, T034, T038) written before or alongside implementation
- Domain entities/use cases before data layer implementations
- Data layer complete before presentation layer updates (US1: T016–T022 before T025–T028)

---

## Parallel Example: User Story 1

```
# Tests (write in parallel — different files):
T013: test/features/app/data/bootstrap_remote_data_source_test.dart
T014: test/features/app/data/app_repository_impl_test.dart
T015: test/features/app/domain/get_app_data_test.dart

# Domain (write in parallel — different files):
T016: lib/features/app/domain/entities/app_metadata_entity.dart
T017: lib/features/app/domain/repositories/app_repository.dart
T019: lib/features/app/data/models/app_metadata_model.dart

# Sequential (each depends on prior):
T018: GetAppData use case (needs T017)
T020: BootstrapRemoteDataSource (needs T016, T019)
T021: BootstrapLocalDataSource (needs T016)
T022: build_runner (needs T019)
T022: AppRepositoryImpl (needs T020, T021)
T024: DI registration (needs T020, T021, T022, T018)
T025: HomeState update (needs T016)
T026: HomeCubit update (needs T018, T025)
T027: HomeDrawer update (needs T025, T026)
T028: ContentPage update (needs T025, T026)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T004)
2. Complete Phase 2: Foundational (T005–T012) — CRITICAL
3. Complete Phase 3: User Story 1 (T013–T028)
4. **STOP and VALIDATE**: cold start shows real categories + drawer metadata
5. App is functional with live backend data

### Incremental Delivery

1. Phase 1 + 2 → Foundation ready (models match API)
2. Phase 3 (US1) → Real bootstrap + metadata — categories carousel live
3. Phase 4 (US2) → Real wallpaper/video grids with pagination
4. Phase 5 (US3) → Real classification bento grid
5. Phase 6 (US4) → Full test coverage confirmed
6. Phase 7 → Clean, production-ready code

---

## Notes

- All data source tasks use `@Named('publicDio')` Dio — no auth token on any of these 3 APIs
- `getCategories()` removal from `CategoryRepository` is a breaking change — search for all call sites before removing
- `WallpaperModel` field replacement is breaking — run `flutter analyze` after T010 to find all outdated usages
- `PaginatedResponse` `hasMore` removal (T003) — check `WallpaperRepositoryImpl` and `HomeCubit` for all `hasMore` references
- Tests use `mocktail` (not `mockito`) per constitution §VII
- Fixture JSON files (T004) must exactly match API contracts documented in `contracts/api-contracts.md`
