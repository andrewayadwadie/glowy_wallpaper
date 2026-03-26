# Tasks: Fix Favorites, Download & Preview

**Input**: Design documents from `/specs/009-fix-favorites-download-preview/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested — test tasks omitted.

**Organization**: Tasks grouped by user story. This is a bug-fix feature — most infrastructure exists. Tasks focus on fixing broken wiring, adding missing params, and enhancing the phone frame preview with video support.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Verification (Existing Infrastructure)

**Purpose**: Confirm existing infrastructure is intact before making changes

- [X] T001 Read and verify existing DI registration for FavoriteCubit, DownloadCubit, and all data sources in `lib/core/di/injection_container.dart`
- [X] T002 Read and verify Hive box initialization for 'favorites' and 'downloads' in `lib/main.dart`
- [X] T003 Read and verify GoRouter wallpaper detail route parameter extraction in `lib/core/routes/app_router.dart`

**Checkpoint**: Existing infrastructure verified — all Hive boxes, DI registrations, and route configs are intact.

---

## Phase 2: User Story 1 - Toggle Favorite on Wallpaper Detail (Priority: P1) MVP

**Goal**: Favorite button toggles reliably with immediate visual feedback, persists across swipes and app restarts, and prevents rapid-tap inconsistencies.

**Independent Test**: Open any wallpaper in detail view, tap heart icon, verify it fills. Swipe away and back — verify state persists. Close and reopen app — verify favorite still active.

### Implementation for User Story 1

- [X] T004 [US1] Wire `isToggling` guard from FavoriteCubit state to disable favorite button during async operations in `lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart` — read `FavoriteCubit` state `isToggling` field and set the favorite button's `onPressed` to `null` when `isToggling == true` to prevent rapid-tap data inconsistency
- [X] T005 [US1] Verify and fix BlocListener in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` that calls `FavoriteCubit.checkIsFavorite(wallpaperId)` whenever `currentIndex` changes in the PageView — ensure the listener fires for all navigation sources (home grid, favorites screen, downloads screen) and correctly reads the wallpaper ID from the current page index

**Checkpoint**: Favorite toggle works reliably — immediate visual feedback, no rapid-tap bugs, state persists across swipes.

---

## Phase 3: User Story 2 - View and Navigate from Favorites Screen (Priority: P1)

**Goal**: Favorites screen displays all favorited wallpapers in a grid. Tapping any item opens wallpaper detail with the full favorites list for swipeable browsing, heart icon shown as active.

**Independent Test**: Favorite 2-3 wallpapers, open favorites screen, verify all appear. Tap one — verify detail opens with filled heart and swiping works through all favorites.

### Implementation for User Story 2

- [X] T006 [US2] Fix navigation in `lib/features/favorites/presentation/pages/favorites_page.dart` — add `'categoryType': CategoryType.image` and `'classificationId': null` to the `extra` map in `context.push()` call when navigating to wallpaper detail. Ensure the full list of favorited wallpapers (converted to `List<WallpaperEntity>` via `favorite.wallpaper`) is passed as `'wallpapers'` and the tapped index is passed as `'initialIndex'`
- [X] T007 [US2] Verify favorites grid refreshes when returning from wallpaper detail after unfavoriting — ensure `FavoriteCubit.loadFavorites()` is called on page resume/focus in `lib/features/favorites/presentation/pages/favorites_page.dart` so that removed favorites disappear from the grid

**Checkpoint**: Favorites screen fully functional — grid displays favorites, navigation opens swipeable detail with correct heart state, unfavorited items disappear on return.

---

## Phase 4: User Story 3 - Download Wallpaper to Device Gallery (Priority: P1)

**Goal**: Download button saves full-resolution image/video to device gallery with progress indicator, permission handling, and local record persistence.

**Independent Test**: Tap download on any wallpaper, grant permission, verify file appears in device gallery. Check downloads screen shows the record.

### Implementation for User Story 3

- [X] T008 [US3] Verify download flow end-to-end in `lib/features/downloads/presentation/cubit/download_cubit.dart` — confirm permission request via `GalleryDataSource`, Dio streaming download with progress callback, gallery save via `gal`, and Hive record persistence all work. Fix any broken steps in the chain
- [X] T009 [US3] Verify permission-denied handling in `lib/features/downloads/data/datasources/gallery_data_source.dart` — ensure `openAppSettings()` is called when permission is permanently denied, and a user-friendly error message is surfaced through the cubit state to the UI
- [X] T010 [US3] Verify download progress indicator and success/error snackbar display in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` — confirm the BlocListener for DownloadCubit shows progress state on the download button and displays a SnackBar on success or error

**Checkpoint**: Download flow works end-to-end for both images and videos — permission handling, progress display, gallery save, and local record all functional.

---

## Phase 5: User Story 4 - View and Navigate from Downloads Screen (Priority: P2)

**Goal**: Downloads screen displays download history sorted by most recent. Tapping any item opens wallpaper detail with full downloads list for swipeable browsing.

**Independent Test**: Download 2 wallpapers, open downloads screen, verify both appear sorted by recency. Tap one — verify detail opens and swiping works.

### Implementation for User Story 4

- [X] T011 [US4] Fix navigation in `lib/features/downloads/presentation/pages/downloads_page.dart` — add `'categoryType'` (inferred from `DownloadRecordEntity.fileType`: use `CategoryType.image` for images, `CategoryType.video` for videos) and `'classificationId': null` to the `extra` map in `context.push()`. Ensure the full list of download records (converted to `List<WallpaperEntity>`) is passed as `'wallpapers'` with the tapped index as `'initialIndex'`
- [X] T012 [US4] Verify `WallpaperEntity` reconstruction from `DownloadRecordEntity` in `lib/features/downloads/presentation/pages/downloads_page.dart` — confirm the mapping correctly sets `id`, `url` (from `imageUrl`), `thumbUrl` (from `thumbnailUrl`), `mediaType` (from `fileType`), and `createdAt` (from `downloadedAt`). Ensure nullable fields (`classificationId`, `classificationName`, `classificationThumbnailUrl`) are explicitly set to `null`

**Checkpoint**: Downloads screen fully functional — grid displays history sorted by recency, navigation opens swipeable detail with correct data.

---

## Phase 6: User Story 5 - Phone Frame Preview (Priority: P2)

**Goal**: Preview button opens a phone wireframe screen. Images display inside the frame. Videos play looping and muted inside the frame, simulating a live wallpaper.

**Independent Test**: Open any image wallpaper detail, tap preview — verify image renders in phone frame. Open any video wallpaper detail, tap preview — verify video plays looping inside the frame. Dismiss — verify return to detail and video stops.

### Implementation for User Story 5

- [X] T013 [US5] Enhance `lib/features/wallpaper_detail/presentation/widgets/phone_frame_preview.dart` to accept `mediaType` (MediaType enum) and `videoUrl` (String) parameters. When `mediaType == MediaType.video`: initialize `VideoPlayerController.networkUrl(Uri.parse(videoUrl))`, set looping to `true`, set volume to `0` (muted), call `initialize()` then `play()`. Display the video inside the phone frame area using `VideoPlayer` widget wrapped in `ClipRRect` with the same border radius and sizing as the existing `AppCachedImage`. Show a loading indicator (using `flutter_spinkit` per constitution) while the video initializes. Keep existing `AppCachedImage` behavior for `MediaType.image`
- [X] T014 [US5] Add proper `VideoPlayerController` disposal in `phone_frame_preview.dart` — override `dispose()` to call `_controller.dispose()` before `super.dispose()`. Ensure the controller is only created when `mediaType == video` (null-safe). Convert widget from `StatelessWidget` to `StatefulWidget` if needed to manage controller lifecycle
- [X] T015 [US5] Update the preview button callback in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` to pass `mediaType` and `videoUrl` (the wallpaper's `url` field) to `PhoneFramePreview` when launching the preview overlay

**Checkpoint**: Phone frame preview works for both images (static display) and videos (looping muted playback). Resources properly released on dismiss.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Clean up dead code and validate all changes

- [X] T016 [P] Remove unused `isFavorite` and `isDownloading` fields from the Freezed state class in `lib/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart` — these fields duplicate state managed by separate FavoriteCubit and DownloadCubit and are never read by any widget
- [X] T017 Run `flutter analyze` from project root and fix any warnings introduced by the changes — ensure zero warnings per constitution requirement VII
- [X] T018 Run manual testing checklist from quickstart.md to verify all 5 user stories work end-to-end: (1) favorite toggle, (2) favorites screen navigation, (3) download to gallery, (4) downloads screen navigation, (5) phone frame preview with video

**Checkpoint**: All dead code removed, zero analyzer warnings, all user stories verified working.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Verification (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on Phase 1 verification
- **US2 (Phase 3)**: Depends on Phase 1; can run in parallel with US1
- **US3 (Phase 4)**: Depends on Phase 1; can run in parallel with US1, US2
- **US4 (Phase 5)**: Depends on Phase 1; can run in parallel with US1-US3
- **US5 (Phase 6)**: Depends on Phase 1; can run in parallel with US1-US4
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Independent — no dependency on other stories
- **US2 (P1)**: Shares FavoriteCubit with US1 but is independently testable
- **US3 (P1)**: Independent — no dependency on other stories
- **US4 (P2)**: Shares navigation pattern with US2 but is independently testable
- **US5 (P2)**: Independent — only modifies phone_frame_preview.dart

### Parallel Opportunities

Within each user story, tasks marked [P] can run in parallel. Across stories:

- T004 and T005 (US1) can run in parallel with T006, T007 (US2) — different files
- T008, T009, T010 (US3) can run in parallel with T011, T012 (US4) — different files
- T013, T014, T015 (US5) can run in parallel with US1-US4 — different files
- T016 (Polish) can run in parallel with T017 — different files

---

## Parallel Example: All P1 Stories Together

```bash
# These can all execute in parallel since they modify different files:

# US1: detail_action_bar.dart + wallpaper_detail_page.dart
Task T004: "Wire isToggling guard in detail_action_bar.dart"
Task T005: "Verify BlocListener for checkIsFavorite in wallpaper_detail_page.dart"

# US2: favorites_page.dart
Task T006: "Fix navigation params in favorites_page.dart"
Task T007: "Verify favorites grid refresh on return"

# US3: download_cubit.dart + gallery_data_source.dart
Task T008: "Verify download flow end-to-end"
Task T009: "Verify permission-denied handling"
Task T010: "Verify download progress indicator display"
```

---

## Implementation Strategy

### MVP First (US1 + US2: Favorite Toggle + Favorites Screen)

1. Complete Phase 1: Verification
2. Complete Phase 2: US1 — favorite toggle works reliably
3. Complete Phase 3: US2 — favorites screen navigates correctly
4. **STOP and VALIDATE**: Favorite + favorites flow works end-to-end
5. Proceed to remaining stories

### Incremental Delivery

1. Verification → Infrastructure confirmed
2. US1 (Favorite Toggle) → Heart button works reliably
3. US2 (Favorites Screen) → Full favorites flow end-to-end
4. US3 (Download to Gallery) → Download button saves to gallery
5. US4 (Downloads Screen) → Full download history flow
6. US5 (Phone Frame Preview) → Video plays in preview
7. Polish → Clean code, zero warnings

---

## Notes

- This is a **bug-fix feature** — all 6 modified files already exist with substantial implementations
- No new files need to be created; no new dependencies need to be added
- Tasks prefixed "Verify" mean: read the code, test the flow, fix if broken — the implementation may already be correct
- The biggest new code is in T013/T014 (video playback in phone frame preview) — ~40-60 lines
- Constitution compliance: AutoSizeText, ScreenUtil, CachedNetworkImage, dartz Either, flutter_spinkit loading — all already in use
