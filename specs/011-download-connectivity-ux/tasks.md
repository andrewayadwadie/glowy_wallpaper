# Tasks: Improve Download Connectivity Check and UX

**Input**: Design documents from `/specs/011-download-connectivity-ux/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Included — constitution principle VII requires unit tests for every Cubit, repository implementation, and use case.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependency changes and string constants needed by all user stories

- [x] T001 Update pubspec.yaml — remove `gal: ^2.3.0`, add `image_gallery_saver_plus`; run `flutter pub get`
- [x] T002 Add `networkUnavailable` string constant (e.g., "Network unavailable. Please check your connection and try again.") to `lib/core/utils/app_strings.dart`; also add `permissionPermanentlyDenied` string for the settings dialog message

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Wire up the new `NetworkInfo` dependency into `DownloadCubit` so all user stories can use it

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Add `NetworkInfo` parameter to `DownloadCubit` constructor in `lib/features/downloads/presentation/cubit/download_cubit.dart` — store as `final NetworkInfo _networkInfo;` alongside existing dependencies
- [x] T004 Update `DownloadCubit` factory registration in `lib/core/di/injection_container.dart` — pass `sl<NetworkInfo>()` as the new `networkInfo` named parameter

**Checkpoint**: Foundation ready — `DownloadCubit` can access `NetworkInfo.isConnected`. User story implementation can now begin.

---

## Phase 3: User Story 1 — Download Blocked When Offline (Priority: P1) MVP

**Goal**: Users with no usable internet see a "Network unavailable" snackbar instantly; no download request is made.

**Independent Test**: Disable device network → tap download → verify snackbar appears and no network request is made.

### Implementation for User Story 1

- [x] T005 [US1] Implement connectivity check at the start of `download()` method in `lib/features/downloads/presentation/cubit/download_cubit.dart` — call `await _networkInfo.isConnected` before any other logic; if `false`, emit `state.copyWith(errorMessage: AppStrings.networkUnavailable)` and return early
- [x] T006 [US1] Add `download_wallpaper_failed` analytics event with `reason: 'no_connectivity'` parameter in `lib/features/downloads/presentation/cubit/download_cubit.dart` — log via `_analytics?.logEvent()` in the connectivity check failure path
- [x] T007 [US1] Write unit tests for connectivity guard in `test/features/downloads/presentation/cubit/download_cubit_test.dart` — test cases: (1) offline blocks download and emits error, (2) online proceeds past connectivity check, (3) duplicate download guard still works

**Checkpoint**: US1 is fully functional — offline users see immediate feedback, no network requests wasted.

---

## Phase 4: User Story 2 — Download Proceeds Despite Ad Gate Failure (Priority: P2)

**Goal**: Ad loading/display errors never block the download. The full-screen dark overlay (`AdGateWidget` route) is removed from the download flow entirely.

**Independent Test**: Simulate ad load failure → verify download completes automatically without user intervention and without a blocking overlay.

### Implementation for User Story 2

- [x] T008 [US2] Restructure `download()` method in `lib/features/downloads/presentation/cubit/download_cubit.dart` — remove `adGatePlaceholder` route navigation and `onProceed` callback nesting. New flow: (1) connectivity check, (2) call `AdHelper.instance.showRewardedInterstitialAd(action: 'download')` directly (non-blocking — proceed regardless of result), (3) execute download logic inline. Remove `BuildContext` parameter from `download()` since route navigation is no longer needed.
- [x] T009 [US2] Update download button call site in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` — change `context.read<DownloadCubit>().download(currentWallpaper, context)` to `context.read<DownloadCubit>().download(currentWallpaper)` (no `BuildContext` parameter)
- [x] T010 [US2] Remove `ad_gate_placeholder.dart` import from `lib/features/downloads/presentation/cubit/download_cubit.dart` and remove unused `package:flutter/material.dart` import if no longer needed
- [x] T011 [US2] Write unit tests for ad gate fallback in `test/features/downloads/presentation/cubit/download_cubit_test.dart` — test cases: (1) ad fails → download still proceeds, (2) ad succeeds → download proceeds, (3) premium user (shouldShowAds=false) → ad skipped, download proceeds

**Checkpoint**: US2 is fully functional — ad failures are silently bypassed, dark overlay is gone, downloads always proceed when online.

---

## Phase 5: User Story 3 — Wallpaper Saved to Device Gallery (Priority: P2)

**Goal**: Downloaded wallpapers are saved using `image_gallery_saver_plus` and appear in the device's native gallery app. Permanent permission denial shows a dialog with "Open Settings" button.

**Independent Test**: Download a wallpaper → open device gallery app → verify wallpaper is visible.

### Implementation for User Story 3

- [x] T012 [US3] Replace `gal` calls with `image_gallery_saver_plus` in `GalleryDataSourceImpl` in `lib/features/downloads/data/datasources/gallery_data_source.dart` — swap `Gal.putImageBytes()` → `ImageGallerySaverPlus.saveImage()`, swap `Gal.putVideo()` → `ImageGallerySaverPlus.saveFile()`, update `requestPermission()` to use `permission_handler` only (remove `Gal.hasAccess`/`Gal.requestAccess`), keep `isPermanentlyDenied()` using `permission_handler`
- [x] T013 [US3] Update `DownloadRepositoryImpl` in `lib/features/downloads/data/repositories/download_repository_impl.dart` — remove direct `openAppSettings()` call on permanent denial; instead return a distinct `CacheFailure` message (e.g., `'permission_permanently_denied'`) that the presentation layer can detect
- [x] T014 [US3] Add permanent-denial dialog handling in `BlocListener` in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` — detect the `'permission_permanently_denied'` error message from `DownloadState.errorMessage` and show an `AlertDialog` with explanation text and an "Open Settings" button that calls `openAppSettings()` from `permission_handler`
- [x] T015 [US3] Add failure analytics for `gallery_permission_denied` and `download_error` reasons in `lib/features/downloads/presentation/cubit/download_cubit.dart` — log `download_wallpaper_failed` event with appropriate reason parameter on each failure path
- [x] T016 [US3] Write unit tests for `GalleryDataSourceImpl` in `test/features/downloads/data/datasources/gallery_data_source_test.dart` — test cases: (1) `putImageBytes` calls `ImageGallerySaverPlus.saveImage()`, (2) `putVideoBytes` writes temp file and calls `ImageGallerySaverPlus.saveFile()`, (3) `requestPermission` delegates to `permission_handler`

**Checkpoint**: US3 is fully functional — wallpapers appear in device gallery, permanent denial shows actionable dialog.

---

## Phase 6: User Story 4 — Non-Blocking Download Progress Indicator (Priority: P3)

**Goal**: Download progress is shown as an animated fill + percentage on the download button itself. No full-screen overlay, no raw `CircularProgressIndicator`. Screen remains fully interactive during download.

**Independent Test**: Tap download → verify button shows fill progress with percentage → verify rest of screen is interactive → verify button reverts to default on completion.

### Implementation for User Story 4

- [x] T017 [US4] Replace raw `CircularProgressIndicator` in `_ActionButton` with an animated progress widget in `lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart` — when `isDownloading` is true, show a `Stack` with a circular progress indicator (determinate, using `downloadProgress` value) and centered percentage text (e.g., `"${(downloadProgress * 100).toInt()}%"`). Use `flutter_screenutil` `.sp` for text size. Ensure the button is disabled during download but the rest of the action bar remains interactive.
- [x] T018 [US4] Ensure download button reverts to default icon state on completion or failure in `lib/features/wallpaper_detail/presentation/widgets/detail_action_bar.dart` — verify that when `isDownloading` transitions back to `false`, the button shows the standard download icon without stale progress state

**Checkpoint**: US4 is fully functional — download progress is inline, non-blocking, and informative.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across all user stories

- [x] T019 Run `flutter analyze` and fix any warnings across all modified files
- [x] T020 Run full test suite: `flutter test test/features/downloads/` — verify all unit tests pass
- [ ] T021 Execute manual verification checklist from `specs/011-download-connectivity-ux/quickstart.md` — (1) airplane mode → snackbar, (2) ad fails → download proceeds, (3) ad succeeds → download proceeds, (4) wallpaper in gallery, (5) button shows progress, (6) deny permission → error, (7) permanent denial → settings dialog

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (pubspec updated) — BLOCKS all user stories
- **User Stories (Phase 3–6)**: All depend on Phase 2 completion
  - US1 (Phase 3) and US3 (Phase 5) can run in parallel (different files)
  - US2 (Phase 4) touches same file as US1 (`download_cubit.dart`) — run after US1
  - US4 (Phase 6) depends on US2 (ad gate overlay removed first) — run after US2
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — no dependencies on other stories
- **US2 (P2)**: Depends on US1 completion (both modify `download_cubit.dart` — US1 adds connectivity check, US2 restructures the rest of the method)
- **US3 (P2)**: Can start after Phase 2 — independent of US1/US2 (modifies different files: `gallery_data_source.dart`, `download_repository_impl.dart`)
- **US4 (P3)**: Can start after Phase 2 — modifies only `detail_action_bar.dart` (independent file), but the full UX improvement depends on US2 removing the blocking ad gate overlay

### Within Each User Story

- Implementation tasks before integration/UI tasks
- All tasks within a story complete before marking story checkpoint
- Tests validate the story independently

### Parallel Opportunities

```
Phase 2 complete
├── US1 (download_cubit.dart)     ──→ US2 (download_cubit.dart) ──→ US4 (detail_action_bar.dart)
└── US3 (gallery_data_source.dart, download_repository_impl.dart)  [runs in parallel with US1]
```

---

## Parallel Example: After Phase 2

```text
# These can run in parallel (different files):
Task T005 [US1]: Connectivity check in download_cubit.dart
Task T012 [US3]: Replace gal with image_gallery_saver_plus in gallery_data_source.dart

# These run sequentially (same file):
Task T005 [US1] → T008 [US2]: Both modify download_cubit.dart
Task T008 [US2] → T017 [US4]: US4 depends on US2 removing the blocking overlay
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (pubspec + strings)
2. Complete Phase 2: Foundational (DI wiring)
3. Complete Phase 3: US1 — connectivity guard
4. **STOP and VALIDATE**: Test offline → snackbar, online → proceeds
5. This alone prevents the worst UX issue (silent failures on no network)

### Incremental Delivery

1. Setup + Foundational → dependencies ready
2. US1 → connectivity guard → **MVP deployed**
3. US3 → gallery saver swap → wallpapers visible in gallery (can run parallel with US1)
4. US2 → ad gate fallback → ads never block downloads
5. US4 → progress button → polished UX
6. Polish → analyze, tests, manual verification

### Single Developer Flow

1. Phase 1 → Phase 2 → Phase 3 (US1) → Phase 5 (US3) → Phase 4 (US2) → Phase 6 (US4) → Phase 7
   - US3 before US2 because US3 is independent and US2 restructures shared code

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- `AdGateWidget` in `lib/core/widgets/ad_gate_placeholder.dart` is NOT deleted — it may be used by other features. Only the import/usage in `download_cubit.dart` is removed.
- `AdHelper.shouldShowAds` already handles premium vs. free logic — no need to inject `SubscriptionCubit` into `DownloadCubit`
- The existing `NetworkInfo` + `InternetConnectionChecker` performs real DNS reachability checks (not just radio status) — no new package needed for connectivity
- Constitution V: raw `CircularProgressIndicator` is forbidden. US4 (T017) replaces the one in `detail_action_bar.dart` with a determinate progress + percentage widget.
