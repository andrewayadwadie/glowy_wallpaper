# Tasks: Fix Runtime Bugs

**Input**: Design documents from `/specs/008-fix-runtime-bugs/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: User Story 1 - Smooth Category Switching (Priority: P1) MVP

**Goal**: Fix the setState rendering error that occurs when users switch between categories in the horizontal carousel, specifically when switching away from a video grid category.

**Independent Test**: Rapidly switch between all category types (images, videos, classifications) — no red error screen, no console errors, correct content displays for the selected category.

### Implementation for User Story 1

- [x] T001 [US1] Add `if (!mounted) return;` guard before `setState()` in `_onVisibilityChanged` method in `lib/features/wallpapers/presentation/widgets/video_grid.dart` (~line 50). This prevents setState from being called after the widget is disposed when the user switches categories.

**Checkpoint**: Category switching between all types (images, videos, classifications) works without rendering errors.

---

## Phase 2: User Story 2 - Classification Category Displays Data (Priority: P1)

**Goal**: Fix classification-type categories showing an internet connection error instead of the bento grid of classification cards.

**Independent Test**: Tap any IMAGE_CLASSIFICATION category — a bento grid of classification cards appears instead of a network error with retry button.

### Implementation for User Story 2

- [x] T002 [US2] Investigate and fix the classification API call in `lib/features/categories/data/datasources/category_remote_data_source.dart` (lines 21-32). Verify the API path `/api/v1/mobile/apps/{appId}/categories/{categoryId}/classifications` is correct, the response envelope parsing matches the actual API response (check if `data['data']` contains `classifications` vs `items` key), and fix any mismatches.
- [x] T003 [US2] Verify the Dio instance used for `CategoryRemoteDataSource` in `lib/core/di/injection_container.dart` (line ~182). If the classifications endpoint requires authentication, change from `publicDio` to the authenticated Dio instance. Test that the classification API call succeeds.

**Checkpoint**: Tapping a classification category loads and displays the bento grid of classification cards.

---

## Phase 3: User Story 3 - Wallpaper Detail Navigation Works (Priority: P1)

**Goal**: Fix the "Invalid navigation parameters" error when tapping any wallpaper item in any grid type.

**Independent Test**: Tap wallpapers from image grids, video grids, and classification detail grids — the detail carousel page opens correctly showing the tapped wallpaper.

### Implementation for User Story 3

- [x] T004 [P] [US3] Fix wallpaper tap navigation in `lib/features/home/presentation/pages/home_page.dart` (lines 57-60). Change from passing `extra: wallpaper` (single entity) to `extra: {'wallpapers': wallpapersList, 'initialIndex': tappedIndex}` matching the contract expected by `app_router.dart`. The wallpaper list comes from the current HomeCubit state's `wallpapers` field.
- [x] T005 [P] [US3] Fix wallpaper tap navigation in `lib/features/categories/presentation/pages/classification_detail_page.dart` (line 75). Change from passing `extra: wallpaper` to `extra: {'wallpapers': wallpapersList, 'initialIndex': tappedIndex}` matching the same navigation contract. The wallpaper list comes from the cubit state's wallpapers for the current classification.

**Checkpoint**: Tapping any wallpaper in any grid type navigates to the detail carousel page with correct data and swipe navigation.

---

## Phase 4: User Story 4 - Drawer Shows API-Sourced Content (Priority: P2)

**Goal**: Wire the drawer's content pages (About, Privacy Policy, Terms of Use) and actions (Share App, Rate App, Send Feedback) to use data from the bootstrap API instead of hardcoded placeholder text.

**Independent Test**: Open each drawer content page and verify it displays API-sourced content. Tap Share App, Rate App, and Send Feedback and verify correct links/email.

### Implementation for User Story 4

- [x] T006 [US4] Refactor `lib/features/home/presentation/pages/content_page.dart` to accept a `content` String parameter in its constructor instead of using the hardcoded `_body` getter (lines 22-31). Keep the `contentType` parameter for the page title. Remove the switch statement with hardcoded strings.
- [x] T007 [US4] Update the About, Privacy Policy, and Terms of Use menu item callbacks in `lib/features/home/presentation/widgets/home_drawer.dart` (lines 103-124) to pass the corresponding `appMetadata` field value (`appMetadata?.about`, `appMetadata?.privacyPolicy`, `appMetadata?.termsOfUse`) as the `content` parameter to `ContentPage`. Add a fallback empty string or placeholder if `appMetadata` is null.
- [x] T008 [US4] Verify the Rate App action in `lib/features/home/presentation/widgets/home_drawer.dart` uses the platform-appropriate store link from `appMetadata` (`androidShareLink` / `iphoneShareLink`) instead of any hardcoded store URL. Update if needed.

**Checkpoint**: All drawer content pages display API-sourced content. Share, Rate, and Feedback actions use correct API data.

---

## Phase 5: User Story 5 - Settings Removed from Drawer (Priority: P3)

**Goal**: Remove the non-functional Settings menu item from the drawer and its placeholder route.

**Independent Test**: Open the drawer — no Settings item is visible.

### Implementation for User Story 5

- [x] T009 [P] [US5] Remove the Settings `_buildMenuItem` block (lines 94-102) from `lib/features/home/presentation/widgets/home_drawer.dart`.
- [x] T010 [P] [US5] Remove the settings placeholder route from `lib/core/routes/app_router.dart` (lines 157-159). Also remove the `settings` constant from AppRoutes if it exists and is no longer referenced.

**Checkpoint**: Drawer no longer shows Settings. No orphaned route or constant remains.

---

## Phase 6: Polish & Verification

**Purpose**: Cross-cutting validation across all bug fixes.

- [x] T011 Run `flutter analyze` and verify zero warnings across all modified files.
- [x] T012 Run `flutter test` to verify no existing tests are broken by the changes.
- [x] T013 Manual smoke test following the quickstart.md verification checklist: (1) rapid category switching, (2) classification category loads, (3) wallpaper tap navigation works from all grids, (4) drawer has no Settings, (5) drawer content pages show API data, (6) Share/Rate/Feedback use API data.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (US1)**: No dependencies — can start immediately
- **Phase 2 (US2)**: No dependencies — can start immediately
- **Phase 3 (US3)**: No dependencies — can start immediately
- **Phase 4 (US4)**: No dependencies — can start immediately
- **Phase 5 (US5)**: No dependencies — can start immediately
- **Phase 6 (Polish)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Independent — modifies only `video_grid.dart`
- **US2 (P1)**: Independent — modifies `category_remote_data_source.dart` and `injection_container.dart`
- **US3 (P1)**: Independent — modifies `home_page.dart` and `classification_detail_page.dart`
- **US4 (P2)**: Independent — modifies `content_page.dart` and `home_drawer.dart`
- **US5 (P3)**: Shares `home_drawer.dart` with US4; should execute after US4 to avoid merge conflicts in the same file

### Within Each User Story

- Each story is 1-3 tasks, all within the same feature boundary
- No cross-story data model dependencies
- T004 and T005 can run in parallel (different files)
- T009 and T010 can run in parallel (different files)

### Parallel Opportunities

- All 5 user stories can start in parallel (different files, independent bugs)
- Exception: US5 shares `home_drawer.dart` with US4 — sequence US4 before US5
- T004 + T005 (US3) can run in parallel
- T009 + T010 (US5) can run in parallel

---

## Parallel Example: All P1 Stories

```bash
# All three P1 stories can run in parallel:
Task T001: "Guard setState in video_grid.dart"           # US1 — different file
Task T002: "Fix classification API in category_remote_data_source.dart"  # US2 — different file
Task T004: "Fix navigation in home_page.dart"             # US3 — different file
Task T005: "Fix navigation in classification_detail_page.dart"  # US3 — different file
```

---

## Implementation Strategy

### MVP First (All P1 Stories)

1. Complete Phase 1: US1 (setState fix) — 1 task
2. Complete Phase 2: US2 (classification fix) — 2 tasks
3. Complete Phase 3: US3 (navigation fix) — 2 tasks
4. **STOP and VALIDATE**: Core app flow works — browse, classify, navigate to detail
5. All three can run in parallel for fastest delivery

### Incremental Delivery

1. US1 + US2 + US3 → Core bugs fixed (MVP)
2. US4 → Drawer content wired to API
3. US5 → Settings cleanup
4. Phase 6 → Final verification

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- All user stories are independently testable
- Commit after each completed user story phase
- Total: 13 tasks (5 implementation tasks for P1, 3 for P2, 2 for P3, 3 for polish)
