# Tasks: Wallpaper Detail, Download & Favorites

**Input**: Design documents from `/specs/004-detail-download-favorites/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not explicitly requested — test tasks are not included. Unit tests should be written per constitution (Principle VII) but are not tracked as separate tasks here.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile (Flutter)**: `lib/features/`, `lib/core/` at repository root
- Platform configs: `android/app/src/main/`, `ios/Runner/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Install new dependencies, configure platform permissions, add assets, update constants

- [x] T001 Add `gal: ^2.3.0` and `permission_handler: ^11.3.1` to pubspec.yaml dependencies and run `flutter pub get`
- [x] T002 [P] Add Android storage permissions (WRITE_EXTERNAL_STORAGE maxSdkVersion 28, READ_MEDIA_IMAGES, READ_MEDIA_VIDEO) to android/app/src/main/AndroidManifest.xml
- [x] T003 [P] Add iOS photo library usage descriptions (NSPhotoLibraryAddUsageDescription, NSPhotoLibraryUsageDescription) to ios/Runner/Info.plist
- [x] T004 [P] Add phone_frame.png asset to assets/images/ and ensure it is registered under flutter.assets in pubspec.yaml
- [x] T005 [P] Update AppConstants with new Hive box names (`favoritesBoxName = 'favorites'`, `downloadsBoxName = 'downloads'`) in lib/core/utils/constants.dart
- [x] T006 [P] Update AppStrings with new string constants for detail screen, favorites page, downloads page, permission dialogs, toast messages, and empty states in lib/core/utils/app_strings.dart
- [x] T007 [P] Update AppAssets with phone frame asset path (`phoneFrame = 'assets/images/phone_frame.png'`) in lib/core/utils/app_assets.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create domain entities, data models, ad gate placeholder, and initialize Hive boxes — all shared across user stories

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T008 [P] Create FavoriteSyncStatus enum (synced, pending, localOnly) and FavoriteEntity (wallpaperId, wallpaper: WallpaperEntity, userId?, favoritedAt, syncStatus) in lib/features/favorites/domain/entities/favorite_entity.dart
- [x] T009 [P] Create WallpaperFileType enum (image, video) and DownloadRecordEntity (wallpaperId, thumbnailUrl, title, downloadedAt, fileType) in lib/features/downloads/domain/entities/download_record_entity.dart
- [x] T010 [P] Create FavoriteModel (Freezed) with toEntity()/fromEntity() mappers and JSON serialization in lib/features/favorites/data/models/favorite_model.dart
- [x] T011 [P] Create FavoriteRequestModel (Freezed) with wallpaperId field for server sync requests in lib/features/favorites/data/models/favorite_request_model.dart
- [x] T012 [P] Create DownloadRecordModel (Freezed) with toEntity()/fromEntity() mappers and JSON serialization in lib/features/downloads/data/models/download_record_model.dart
- [x] T013 Create AdGatePlaceholder utility that checks SubscriptionCubit state — if free user, invokes a callback that auto-proceeds (placeholder for Phase 5 rewarded ad) in lib/core/widgets/ad_gate_placeholder.dart
- [x] T014 Open Hive boxes (`favorites`, `downloads`) in lib/main.dart alongside existing user_cache and categories box initializations
- [x] T015 Run `dart run build_runner build --delete-conflicting-outputs` to generate Freezed code for FavoriteModel, FavoriteRequestModel, and DownloadRecordModel

**Checkpoint**: All entities, models, and infrastructure ready — user story implementation can now begin

---

## Phase 3: User Story 1 — Full-Screen Wallpaper Detail Carousel (Priority: P1) MVP

**Goal**: Users can tap a wallpaper thumbnail from any grid and enter a full-screen detail view with horizontal swipe navigation (carousel), semi-transparent action bar, video playback, and Hero animation transition

**Independent Test**: Tap wallpaper thumbnail from Home grid → verify Hero animation to full-screen detail → swipe left/right → verify carousel navigation → verify action bar visible with download/favorite/preview buttons → tap back → verify return to grid at same scroll position

### Implementation for User Story 1

- [x] T016 [US1] Create WallpaperDetailState (Freezed) with fields: wallpapers list, currentIndex, isFavorite, isDownloading, downloadProgress, similarWallpapersStatus, similarWallpapers list, errorMessage in lib/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart
- [x] T017 [US1] Create WallpaperDetailCubit with init (accepts wallpapers list + initial index), onPageChanged (updates currentIndex), and video controller management (muted loop, toggle sound) in lib/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart
- [x] T018 [US1] Create DetailActionBar widget with semi-transparent background, download button (with progress indicator slot), favorite heart button (filled/outlined slot), and preview button — all using ScreenUtil and AppColors in lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart
- [x] T019 [US1] Create WallpaperDetailPage with full-screen PageView.builder carousel, Hero animation (tag = wallpaper.id), CachedNetworkImage for images, video_player for video wallpapers (muted loop with tap-to-toggle sound), and DetailActionBar overlay in lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart
- [x] T020 [US1] Add Hero widget wrapping to existing wallpaper thumbnails (tag = wallpaper.id) in lib/features/wallpapers/presentation/widgets/wallpaper_thumbnail.dart
- [x] T021 [US1] Wire /wallpaper/:id route to WallpaperDetailPage — receive wallpaper list and initial index via GoRouter state.extra, provide WallpaperDetailCubit via BlocProvider in lib/core/routes/app_router.dart
- [x] T022 [US1] Register WallpaperDetailCubit as factory in lib/core/di/injection_container.dart
- [x] T023 [US1] Run `dart run build_runner build --delete-conflicting-outputs` for WallpaperDetailState Freezed generation

**Checkpoint**: Users can tap any wallpaper thumbnail → Hero animation to full-screen detail → swipe through carousel → see action bar → back to grid. MVP complete.

---

## Phase 4: User Story 2 — Download Wallpaper to Device Gallery (Priority: P2)

**Goal**: Users can download wallpaper images/videos to their device gallery with permission handling, progress indication, success toast, and local download metadata tracking

**Independent Test**: Open wallpaper detail → tap download → grant permissions → verify progress indicator → verify wallpaper appears in device gallery → verify success toast → verify download recorded in local Hive box

**Dependencies**: Requires US1 (detail screen with action bar)

### Implementation for User Story 2

- [x] T024 [P] [US2] Create DownloadRepository contract with downloadWallpaper(wallpaper, onProgress?), getDownloadHistory(), isDownloaded(wallpaperId) in lib/features/downloads/domain/repositories/download_repository.dart
- [x] T025 [P] [US2] Create DownloadWallpaper use case in lib/features/downloads/domain/usecases/download_wallpaper.dart
- [x] T026 [P] [US2] Create GetDownloadHistory use case in lib/features/downloads/domain/usecases/get_download_history.dart
- [x] T027 [US2] Create DownloadLocalDataSource — Hive box CRUD: saveRecord (upsert by wallpaperId, updates timestamp on re-download), getAll (sorted by downloadedAt desc), isDownloaded check in lib/features/downloads/data/datasources/download_local_data_source.dart
- [x] T028 [US2] Create GalleryDataSource — permission_handler for requestPermission (Android 13+ granular vs older storage), checkPermission, openAppSettings; gal for putImageBytes/putVideoBytes in lib/features/downloads/data/datasources/gallery_data_source.dart
- [x] T029 [US2] Create DownloadRepositoryImpl — orchestrates: check permissions → Dio download bytes with onReceiveProgress → gal save to gallery → Hive record upsert; returns Either with proper failure types in lib/features/downloads/data/repositories/download_repository_impl.dart
- [x] T030 [US2] Create DownloadCubit + DownloadState (Freezed) — manages download progress, debounce (prevent duplicate taps), ad gate placeholder trigger for free users, success/error states in lib/features/downloads/presentation/cubit/download_cubit.dart and lib/features/downloads/presentation/cubit/download_state.dart
- [x] T031 [US2] Wire download button in DetailActionBar to DownloadCubit — show loader_overlay progress during download, success toast via ScaffoldMessenger, error dialog with retry option in lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart
- [x] T032 [US2] Register DownloadLocalDataSource, GalleryDataSource, DownloadRepository, DownloadWallpaper, GetDownloadHistory, and DownloadCubit in lib/core/di/injection_container.dart

**Checkpoint**: Users can download wallpapers to gallery with permissions, progress, and toast confirmation

---

## Phase 5: User Story 3 — Favorite / Unfavorite Wallpapers (Priority: P3)

**Goal**: Users can toggle favorites from the detail screen with optimistic UI updates, local-first persistence, and background server sync for authenticated users (local-only for guests)

**Independent Test**: Open wallpaper detail → tap heart → verify fills immediately → close and reopen → verify still filled → tap again → verify outlines → verify background sync (for authenticated users)

**Dependencies**: Requires US1 (detail screen with action bar)

### Implementation for User Story 3

- [x] T033 [P] [US3] Create FavoriteRepository contract with addFavorite, removeFavorite, isFavorite, getFavorites, syncPendingFavorites, mergeGuestFavorites, refreshFromServer in lib/features/favorites/domain/repositories/favorite_repository.dart
- [x] T034 [P] [US3] Create ToggleFavorite use case (add if not favorite, remove if favorite) in lib/features/favorites/domain/usecases/toggle_favorite.dart
- [x] T035 [P] [US3] Create IsFavorite use case in lib/features/favorites/domain/usecases/is_favorite.dart
- [x] T036 [US3] Create FavoriteLocalDataSource — Hive box CRUD: add (with wallpaper snapshot + sync status), remove, getAll, isFavorite (O(1) lookup by key), getPending (sync status = pending), updateSyncStatus in lib/features/favorites/data/datasources/favorite_local_data_source.dart
- [x] T037 [US3] Create FavoriteRemoteDataSource (Retrofit) — GET /favorites, POST /favorites (body: wallpaper_id), DELETE /favorites/{wallpaperId}, POST /favorites/merge (body: wallpaper_ids array) in lib/features/favorites/data/datasources/favorite_remote_data_source.dart
- [x] T038 [US3] Create FavoriteRepositoryImpl — local-first add/remove with optimistic update, fire-and-forget background server sync for authenticated users, pending state on sync failure, guest users get localOnly sync status, server-wins conflict resolution on refresh in lib/features/favorites/data/repositories/favorite_repository_impl.dart
- [x] T039 [US3] Create FavoriteCubit + FavoriteState (Freezed) — manages optimistic toggle, isFavorite check per wallpaper (called on carousel page change), sync status tracking in lib/features/favorites/presentation/cubit/favorite_cubit.dart and lib/features/favorites/presentation/cubit/favorite_state.dart
- [x] T040 [US3] Wire favorite heart button in DetailActionBar to FavoriteCubit — filled/outlined icon toggle on tap, check isFavorite on each page change via WallpaperDetailCubit's onPageChanged in lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart
- [x] T041 [US3] Register FavoriteLocalDataSource, FavoriteRemoteDataSource, FavoriteRepository, ToggleFavorite, IsFavorite, and FavoriteCubit in lib/core/di/injection_container.dart

**Checkpoint**: Users can favorite/unfavorite from detail screen with instant UI feedback and background sync

---

## Phase 6: User Story 4 — Favorites Page (Priority: P4)

**Goal**: Users can navigate to a dedicated Favorites page showing all their favorited wallpapers in a responsive grid with local-first loading and server refresh

**Independent Test**: Favorite several wallpapers → navigate to Favorites via drawer → verify grid shows all favorites → tap one → verify detail opens → unfavorite → return → verify removed → remove all → verify empty state

**Dependencies**: Requires US3 (favorites data layer must exist)

### Implementation for User Story 4

- [x] T042 [P] [US4] Create GetFavorites use case (returns list of FavoriteEntity) in lib/features/favorites/domain/usecases/get_favorites.dart
- [x] T043 [P] [US4] Create MergeGuestFavorites use case (merges local-only favorites to server after login) in lib/features/favorites/domain/usecases/merge_guest_favorites.dart
- [x] T044 [US4] Create FavoritesGrid widget — responsive AdaptiveGrid of wallpaper thumbnails using AppCachedImage, Hero tags, tap to navigate to detail screen in lib/features/favorites/presentation/widgets/favorites_grid.dart
- [x] T045 [US4] Create FavoritesPage with four-state pattern (loading shimmer/error with retry/empty with Lottie illustration/success grid), loads from local first then refreshes from server, AppBar with title in lib/features/favorites/presentation/pages/favorites_page.dart
- [x] T046 [US4] Wire /favorites route to FavoritesPage with BlocProvider for FavoriteCubit in lib/core/routes/app_router.dart
- [x] T047 [US4] Register GetFavorites and MergeGuestFavorites use cases in lib/core/di/injection_container.dart

**Checkpoint**: Favorites page fully functional with local-first grid, server refresh, empty state, and detail navigation

---

## Phase 7: User Story 5 — My Downloads Page (Priority: P5)

**Goal**: Users can navigate to My Downloads page showing all previously downloaded wallpapers sorted by most recent, built entirely from local metadata

**Independent Test**: Download several wallpapers → navigate to Downloads via drawer → verify grid sorted by most recent → tap one → verify detail opens → verify empty state when no downloads

**Dependencies**: Requires US2 (download data layer must exist)

### Implementation for User Story 5

- [x] T048 [US5] Create DownloadsGrid widget — responsive AdaptiveGrid of download thumbnails using AppCachedImage, Hero tags, tap to navigate to detail screen in lib/features/downloads/presentation/widgets/downloads_grid.dart
- [x] T049 [US5] Create DownloadsPage with four-state pattern (loading/error/empty with Lottie illustration/success grid), loads from local Hive only (no network), sorted by downloadedAt desc, AppBar with title in lib/features/downloads/presentation/pages/downloads_page.dart
- [x] T050 [US5] Wire /downloads route to DownloadsPage with BlocProvider for DownloadCubit in lib/core/routes/app_router.dart

**Checkpoint**: Downloads page fully functional with local-only grid, sort order, empty state, and detail navigation

---

## Phase 8: User Story 6 — Phone Frame Preview (Priority: P6)

**Goal**: Users can preview a wallpaper inside a phone frame mockup as a full-screen overlay, with tap-to-dismiss and ad gate for free users

**Independent Test**: Open wallpaper detail → tap preview button → verify phone frame overlay with wallpaper inside → verify no stretching/distortion → tap anywhere → verify overlay dismisses

**Dependencies**: Requires US1 (detail screen with action bar)

### Implementation for User Story 6

- [X] T051 [US6] Create PhoneFramePreview widget — full-screen overlay with phone_frame.png asset, wallpaper scaled and clipped inside frame screen area (BoxFit.cover), dark semi-transparent background, tap anywhere to dismiss via Navigator.pop in lib/features/wallpaper_detail/presentation/widgets/phone_frame_preview.dart
- [X] T052 [US6] Wire preview button in DetailActionBar to show PhoneFramePreview overlay — trigger ad gate placeholder for free users before showing, pass current wallpaper image/thumbnail URL in lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart

**Checkpoint**: Phone frame preview overlay works with correct wallpaper scaling and dismiss behavior

---

## Phase 9: User Story 7 — Similar Wallpapers (Priority: P7)

**Goal**: Users can pull up a bottom sheet showing similar wallpapers, tap one to replace the carousel context and browse the discovery chain

**Independent Test**: Open wallpaper detail → pull up bottom sheet → verify similar wallpapers load → tap one → verify carousel replaces with similar list → verify empty/error states in sheet

**Dependencies**: Requires US1 (detail screen and WallpaperDetailCubit)

### Implementation for User Story 7

- [X] T053 [P] [US7] Create SimilarWallpaperRepository contract with getSimilarWallpapers(wallpaperId) returning Either<Failure, List<WallpaperEntity>> in lib/features/wallpaper_detail/domain/repositories/similar_wallpaper_repository.dart
- [X] T054 [P] [US7] Create GetSimilarWallpapers use case in lib/features/wallpaper_detail/domain/usecases/get_similar_wallpapers.dart
- [X] T055 [US7] Create SimilarWallpaperRemoteDataSource (Retrofit) — GET /wallpapers/{wallpaperId}/similar returning List<WallpaperModel> in lib/features/wallpaper_detail/data/datasources/similar_wallpaper_remote_data_source.dart
- [X] T056 [US7] Create SimilarWallpaperRepositoryImpl wrapping remote data source with network check and Either error handling in lib/features/wallpaper_detail/data/repositories/similar_wallpaper_repository_impl.dart
- [X] T057 [US7] Create SimilarWallpapersSheet widget — DraggableScrollableSheet with thumbnail grid inside, tap handler, empty state ("No similar wallpapers found"), error state with retry button in lib/features/wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart
- [X] T058 [US7] Add loadSimilarWallpapers(wallpaperId) and switchToSimilarContext(wallpapers, tappedIndex) methods to WallpaperDetailCubit — loads similar, replaces carousel wallpapers list and currentIndex on tap in lib/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart
- [X] T059 [US7] Integrate SimilarWallpapersSheet into WallpaperDetailPage — add "Similar" affordance button or swipe-up gesture to trigger sheet, connect sheet tap to cubit's switchToSimilarContext in lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart
- [X] T060 [US7] Register SimilarWallpaperRemoteDataSource, SimilarWallpaperRepository, and GetSimilarWallpapers use case in lib/core/di/injection_container.dart

**Checkpoint**: Similar wallpapers bottom sheet works with carousel context switching for discovery chain

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Analytics, code quality, and final verification

- [X] T061 [P] Add Firebase Analytics events for download_wallpaper, toggle_favorite, preview_wallpaper, and view_similar_wallpapers actions in relevant cubits (WallpaperDetailCubit, DownloadCubit, FavoriteCubit)
- [X] T062 [P] Run `flutter analyze` and `dart format .` — fix all warnings, remove unused imports, ensure zero warnings across all new files
- [X] T063 Run full quickstart.md verification flow on device/simulator — test all 8 verification steps end-to-end
- [X] T064 Run `dart run build_runner build --delete-conflicting-outputs` final pass to ensure all generated code is up to date

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup (T001 for packages, T005 for constants)
- **US1 (Phase 3)**: Depends on Foundational — BLOCKS US2, US3, US6, US7
- **US2 (Phase 4)**: Depends on US1 (detail screen action bar exists)
- **US3 (Phase 5)**: Depends on US1 (detail screen action bar exists) — can run parallel with US2
- **US4 (Phase 6)**: Depends on US3 (favorites data layer)
- **US5 (Phase 7)**: Depends on US2 (downloads data layer) — can run parallel with US4
- **US6 (Phase 8)**: Depends on US1 only — can run parallel with US2/US3
- **US7 (Phase 9)**: Depends on US1 only — can run parallel with US2/US3
- **Polish (Phase 10)**: Depends on all user stories being complete

### User Story Dependencies

```
Setup → Foundational → US1 (MVP) ─┬─→ US2 ──→ US5
                                   ├─→ US3 ──→ US4
                                   ├─→ US6
                                   └─→ US7
                                              ↓
                                           Polish
```

- **US1 (P1)**: Gateway — all other stories depend on the detail screen
- **US2 (P2)** + **US3 (P3)**: Can run in parallel after US1
- **US4 (P4)** + **US5 (P5)**: Can run in parallel after US3/US2 respectively
- **US6 (P6)** + **US7 (P7)**: Can run in parallel after US1 (no dependency on US2-US5)

### Within Each User Story

- Domain contracts and use cases first (parallelizable)
- Data sources before repository implementation
- Repository before cubit
- Cubit before UI integration
- DI registration after implementation

### Parallel Opportunities

- All Setup tasks T002-T007 can run in parallel (after T001)
- All Foundational entity/model tasks T008-T012 can run in parallel
- US2 and US3 can run in parallel after US1 completes
- US4, US5, US6, US7 can all run in parallel once their dependencies are met
- Within each story, domain contracts and use cases marked [P] can run in parallel

---

## Parallel Example: User Story 2

```bash
# Launch domain tasks in parallel:
Task T024: "Create DownloadRepository contract in lib/features/downloads/domain/repositories/download_repository.dart"
Task T025: "Create DownloadWallpaper use case in lib/features/downloads/domain/usecases/download_wallpaper.dart"
Task T026: "Create GetDownloadHistory use case in lib/features/downloads/domain/usecases/get_download_history.dart"

# Then sequential data layer:
Task T027: "Create DownloadLocalDataSource..."
Task T028: "Create GalleryDataSource..."
Task T029: "Create DownloadRepositoryImpl..."

# Then presentation:
Task T030: "Create DownloadCubit..."
Task T031: "Wire download button..."
Task T032: "Register DI..."
```

---

## Parallel Example: After US1 Completes

```bash
# These four story tracks can run in parallel:
Track A: US2 (T024-T032) — Download flow
Track B: US3 (T033-T041) — Favorites toggle
Track C: US6 (T051-T052) — Phone frame preview
Track D: US7 (T053-T060) — Similar wallpapers

# After Track A completes: US5 (T048-T050)
# After Track B completes: US4 (T042-T047)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (Detail Carousel)
4. **STOP and VALIDATE**: Tap thumbnails → full-screen detail → swipe carousel → Hero animation
5. Demo/validate if ready

### Incremental Delivery

1. Setup + Foundational → Infrastructure ready
2. US1 → Detail carousel works → **MVP!**
3. US2 + US3 (parallel) → Download + Favorites from detail screen
4. US4 + US5 (parallel) → Favorites page + Downloads page
5. US6 + US7 (parallel) → Phone preview + Similar wallpapers
6. Polish → Analytics, cleanup, final verification

### Sequential (Single Developer)

1. Setup → Foundational → US1 → US2 → US3 → US4 → US5 → US6 → US7 → Polish
2. Each story adds value without breaking previous stories
3. Commit after each task or logical group

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently testable after its phase completes
- Constitution requires: AutoSizeText (not Text), CachedNetworkImage (not Image.network), ScreenUtil for all sizes, loader_overlay + flutter_spinkit for loading, four-state pattern on all screens, Hero animations on thumbnail → detail
- Ad gate placeholder in this phase auto-proceeds; actual rewarded ad integration is Phase 5
- Favorites: local-first with server sync (authenticated) or local-only (guests)
- Downloads: local metadata only, no server sync
