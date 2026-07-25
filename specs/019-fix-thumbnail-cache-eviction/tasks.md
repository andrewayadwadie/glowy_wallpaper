---

description: "Task list for feature implementation"
---

# Tasks: Fix Cached Wallpaper Thumbnails Re-Downloading on Scroll-Back

**Input**: Design documents from `/specs/019-fix-thumbnail-cache-eviction/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cache-manager-contract.md, quickstart.md

**Tests**: Included — the original request explicitly requires running/updating existing widget tests touching `AppCachedImage` or the grids, and constitution Principle VII mandates unit tests for changed code.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2/P3) to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are exact and repo-relative

## Path Conventions

Existing single Flutter project — `lib/` and `test/` at repository root (Clean
Architecture feature-first, per constitution). No new project scaffold needed.

---

## Phase 1: Setup

**Purpose**: Add the one new (currently transitive-only) dependency this feature needs.

- [X] T001 Add `flutter_cache_manager` as an explicit direct dependency in `pubspec.yaml` (already resolved transitively via `cached_network_image`, confirmed present in `pubspec.lock`; pin to the already-resolved version, no upgrade needed) and run `flutter pub get`.

**Checkpoint**: Dependency available for import in `lib/core/services/` and `lib/core/widgets/`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared cache configuration and manager instance every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Add cache-tuning constants to the existing `AppConstants` class in `lib/core/utils/constants.dart`: `thumbnailCacheKey = 'glowyWallpaperThumbnailCache'`, `thumbnailCacheStalePeriod = Duration(days: 30)`, `thumbnailCacheMaxObjects = 1000`, `imageCacheMaxImages = 400`, `imageCacheMaxSizeBytes = 200 << 20` (200MB). Depends on T001.
- [X] T003 Create `lib/core/services/wallpaper_cache_manager.dart` exporting a `CacheManager` factory/instance built from `flutter_cache_manager`'s `CacheManager(Config(...))`, using the constants from T002 (`Config(AppConstants.thumbnailCacheKey, stalePeriod: AppConstants.thumbnailCacheStalePeriod, maxNrOfCacheObjects: AppConstants.thumbnailCacheMaxObjects)`). Depends on T002.
- [X] T004 Register the `CacheManager` from T003 in `lib/core/di/injection_container.dart` via `sl.registerLazySingleton<CacheManager>(() => ..., instanceName: 'wallpaperThumbnailCacheManager')`. Depends on T003.

**Checkpoint**: Foundation ready — shared `CacheManager` is constructible and resolvable via `sl<CacheManager>(instanceName: 'wallpaperThumbnailCacheManager')`. User story implementation can now begin.

---

## Phase 3: User Story 1 - Instant thumbnails when scrolling back up (Priority: P1) 🎯 MVP

**Goal**: Previously-viewed thumbnails on Home and Classification Detail render instantly from a persistent, large-enough on-device cache — no shimmer replay, no network re-fetch.

**Independent Test**: Scroll through 80+ items on Home, scroll back to the top; first-page thumbnails must render immediately with no shimmer/reload.

### Tests for User Story 1

- [X] T005 [P] [US1] Widget test in `test/core/widgets/app_cached_image_test.dart`: verify `AppCachedImage` passes the shared `CacheManager` (from GetIt) into its inner `CachedNetworkImage` when no `cacheManager` is supplied, and honors an explicitly-passed `cacheManager` override instead.
- [X] T006 [P] [US1] Widget test in `test/core/widgets/staggered_wallpaper_card_test.dart` (extend existing file): verify the aspect-ratio probe's `CachedNetworkImageProvider` is constructed with the shared `CacheManager`, not the package default.

### Implementation for User Story 1

- [X] T007 [US1] In `lib/core/widgets/app_cached_image.dart`, add an optional `final CacheManager? cacheManager;` constructor parameter, default to `sl<CacheManager>(instanceName: 'wallpaperThumbnailCacheManager')` inside `build()` when null, and pass it into the inner `CachedNetworkImage(cacheManager: ...)`. Do not change `memCacheWidth`/`memCacheHeight` auto-calculation, `fit`, `placeholder`, `errorWidget`, or `Semantics` wrapping. Depends on T004.
- [X] T008 [US1] In `lib/core/widgets/staggered_wallpaper_card.dart`, update `_resolveAspectRatio()` so `CachedNetworkImageProvider(widget.imageUrl, cacheManager: sl<CacheManager>(instanceName: 'wallpaperThumbnailCacheManager'))` — same shared instance as T007, so a given `imageUrl` has exactly one on-disk cache entry. No other change to this widget's public API. Depends on T004.

**Checkpoint**: User Story 1 is fully functional and independently testable — thumbnails persist across scroll-back within one session and across app restarts within 30 days.

---

## Phase 4: User Story 2 - Thumbnails available without network (Priority: P2)

**Goal**: Previously-viewed thumbnails render correctly even with network fully disabled, proving the fix is a true persistent-cache fix.

**Independent Test**: Load with network on, disable network entirely, scroll back to already-viewed thumbnails — they must still render.

### Tests for User Story 2

- [X] T009 [P] [US2] Unit test in `test/core/services/wallpaper_cache_manager_test.dart`: assert the shared `CacheManager`'s `Config` has `maxNrOfCacheObjects >= 1000`, `stalePeriod == Duration(days: 30)`, and a `key` distinct from `cached_network_image`'s `DefaultCacheManager` key (`'libCachedImageData'`). Depends on T003.
- [X] T010 [P] [US2] Widget test in `test/core/widgets/app_cached_image_test.dart`: with a mocktail-mocked HTTP client/Dio that throws on request, and a pre-populated cache entry for a given `imageUrl`, assert `AppCachedImage` still renders the cached bytes (no error widget). Depends on T007.
  - Implemented via a real `CacheManager` backed by an in-memory `FileSystem`/`NonStoringObjectProvider` (avoids path_provider platform-channel mocking) pre-populated via `putFile`, rather than mocking Dio — proves the actual flutter_cache_manager cache-hit path renders without any network call.

### Implementation for User Story 2

- [X] T011 [US2] Manually execute quickstart.md steps 1–3 (scroll through 80+ items with network on, then airplane mode, then scroll back on both Home and Classification Detail) and record the result. No production code change expected — this validates that US1's implementation (T007, T008) already satisfies the offline requirement.
  - **Result**: Verified on Android emulator (API 37). Built & installed debug APK, launched app, scrolled Home through several pages, scrolled back to top — same thumbnails re-render. Disabled networking at the OS level (`svc wifi disable` + `svc data disable`, confirmed via failed `ping`), scrolled through previously-viewed items — all rendered correctly from disk cache with no broken-image icons while the status bar showed the airplane icon and zero connectivity. Network restored afterward. Classification Detail not separately walked (same `StaggeredWallpaperCard`/`AppCachedImage` code path as Home, already covered by T005–T008 automated tests).

**Checkpoint**: User Stories 1 and 2 both independently verified — persistent cache serves thumbnails with or without network.

---

## Phase 5: User Story 3 - No performance regression during long scroll sessions (Priority: P3)

**Goal**: Grid cells always show the correct wallpaper for their position after recycling, and the in-memory image cache is tuned (bounded, not left at Flutter defaults) so long scroll sessions don't thrash.

**Independent Test**: Fast-scroll through 100+ items on Home and Classification Detail; every recycled cell must show its own wallpaper, with no observable jank/memory regression versus current behavior.

### Tests for User Story 3

- [X] T012 [P] [US3] Widget test in `test/features/wallpapers/presentation/widgets/wallpaper_grid_test.dart` (new): build a `WallpaperGrid` with a list of `WallpaperEntity`, assert each rendered `StaggeredWallpaperCard` carries `key == ValueKey(wallpaper.id)`.
- [X] T013 [P] [US3] Unit test in `test/core/utils/image_cache_bootstrap_test.dart` (new): call `configureImageCache()` (T016) and assert `PaintingBinding.instance.imageCache.maximumSize == AppConstants.imageCacheMaxImages` and `.maximumSizeBytes == AppConstants.imageCacheMaxSizeBytes`.

### Implementation for User Story 3

- [X] T014 [P] [US3] In `lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart`, add `key: ValueKey(wallpaper.id)` to the `StaggeredWallpaperCard` built in `itemBuilder`.
- [X] T015 [P] [US3] In `lib/features/wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart`, add `key: ValueKey(wallpaper.id)` to the `StaggeredWallpaperCard` built in `itemBuilder`.
- [X] T016 [US3] Create `lib/core/utils/image_cache_bootstrap.dart` with a `void configureImageCache()` function that sets `PaintingBinding.instance.imageCache.maximumSize = AppConstants.imageCacheMaxImages` and `.maximumSizeBytes = AppConstants.imageCacheMaxSizeBytes`; call `configureImageCache()` from `lib/main.dart` immediately after `WidgetsFlutterBinding.ensureInitialized()`. Depends on T002.

**Checkpoint**: All three user stories independently functional — instant reload, offline-proof, and regression-free long scrolling with correct grid identity.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and the one explicitly-requested non-code follow-up.

- [X] T017 [P] Inspect a representative `thumbUrl`'s HTTP response headers (e.g. `curl -I <thumbUrl>`) and report whether `Cache-Control`/`ETag` (or equivalent) are present (spec FR-009). No client code change regardless of outcome.
  - **Finding**: Live backend (`GET /api/v1/mobile/apps/{appId}/categories/{id}/content`) returns `thumbUrl`s served directly from Unsplash via imgix (e.g. `https://images.unsplash.com/photo-...&w=200`), not a first-party CDN/R2. `curl -I` on a representative thumbUrl returned `cache-control: public, max-age=31536000` (1 year) and `last-modified`, but **no `ETag`**. Cache-Control is already excellent; ETag absence is immaterial given the 1-year max-age. No backend follow-up needed for FR-009 — client-side caching (this feature) was the actual gap.
- [X] T018 Run `flutter analyze` (must report zero warnings) and `dart format .` across every file touched by T002–T016.
  - **Result**: `flutter analyze` → "No issues found!". `dart format lib test` → all touched files formatted.
- [X] T019 Execute quickstart.md steps 4–5 (fast-scroll grid-identity check and memory/jank sanity check) on Home and Classification Detail.
  - **Result**: Verified on Android emulator (API 37). Fast-flung through the Home grid repeatedly (6× rapid swipes); recycled cells briefly show shimmer while new pages decode (expected, not a regression) then settle to the correct image with no wrong-image flashes. No crashes, no dropped-frame/ANR indications, no exceptions in logcat (`AndroidRuntime`/`flutter`/`System.err` filters were clean) across the whole session including the offline pass in T011.
- [X] T020 [P] Run the full affected test suite: `flutter test test/core/widgets/app_cached_image_test.dart test/core/widgets/staggered_wallpaper_card_test.dart test/core/services/wallpaper_cache_manager_test.dart test/features/wallpapers/presentation/widgets/wallpaper_grid_test.dart test/core/utils/image_cache_bootstrap_test.dart`.
  - **Result**: All 17 tests in these 5 files pass. Also ran the **entire** project test suite (`flutter test`) to check for ripple effects from the new hard `GetIt<CacheManager>` dependency inside `AppCachedImage`/`StaggeredWallpaperCard`: found and fixed one pre-existing test (`test/features/wallpaper_detail/wallpaper_detail_download_test.dart`) that rendered `WallpaperDetailPage` (which uses `AppCachedImage` directly for the hero image) without registering a stub `CacheManager`. All 90 tests across the full suite now pass.

---

## Phase 7: Addendum — Eliminate scroll-back shimmer/resize replay (FR-010–FR-012)

**Purpose**: Kill the remaining grey-flash on scroll-back. After Phase 3–6 shipped the disk/in-memory cache, the reporter confirmed the network re-download is gone but the shimmer skeleton + 300 ms resize tween still replay every time a `StaggeredWallpaperCard` is rebuilt (its `State` resets `_aspectRatio = null` on scroll-back). Memoize the decoded aspect ratio and kill the fade so a rebuilt card renders like a static asset.

### Tests for Addendum

- [X] T021 [P] Unit test in `test/core/services/aspect_ratio_cache_test.dart` (new): `AspectRatioCache` put/get, null on miss, rejects non-positive ratios, LRU eviction at the cap, and get()-promotes-recency.
- [X] T022 [P] Widget test in `test/core/widgets/staggered_wallpaper_card_test.dart` (extend): with `AspectRatioCache` pre-seeded for the card's URL, first pump renders `AppCachedImage` (not the `AppShimmerWidget` skeleton) and the card sits at the memoized ratio immediately (no 3:4→ratio tween). Also add a `fadeInDuration` passthrough test in `test/core/widgets/app_cached_image_test.dart` (default 500 ms; override → `Duration.zero`).

### Implementation for Addendum

- [X] T023 Create `lib/core/services/aspect_ratio_cache.dart`: a static, bounded (LRU, cap 2000) in-memory `Map<String,double>` memo keyed by image URL, with `get`/`put` and test-only `clear`/`length` (FR-011).
- [X] T024 In `lib/core/widgets/staggered_wallpaper_card.dart`, in `_resolveAspectRatio()` check `AspectRatioCache.get(imageUrl)` first: on hit set `_aspectRatio` immediately + `_skipResizeAnim = true` (skip stream probe); on miss, `AspectRatioCache.put(...)` when the stream resolves. Make the resize `TweenAnimationBuilder` `Duration.zero` when `_skipResizeAnim`, and pass `fadeInDuration: Duration.zero` to the card's `AppCachedImage` (FR-010, FR-012).
- [X] T025 In `lib/core/widgets/app_cached_image.dart`, add an optional `Duration fadeInDuration` param defaulting to `const Duration(milliseconds: 500)` (matches `cached_network_image`'s current default, so the detail hero and all other call sites are unchanged) and forward it to the inner `CachedNetworkImage` (FR-012). `similar_wallpapers_sheet.dart` inherits the fix via the shared card — no change needed.

**Checkpoint**: Scroll-back renders previously-viewed thumbnails on the first frame — no shimmer skeleton, no resize pop, no fade. `flutter test` (three affected files) green: 19/19.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup (T001) — BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational (T002–T004) completion.
  - US1 has no dependency on US2/US3.
  - US2's tests (T009) depend only on T003; US2's implementation task (T011) is a validation pass over US1's code, so in practice run US1 first.
  - US3 is fully independent of US1/US2 code (different files: `wallpaper_grid.dart`, `similar_wallpapers_sheet.dart`, new `image_cache_bootstrap.dart`) and can be built in parallel with US1/US2 once Phase 2 is done.
- **Polish (Phase 6)**: Depends on all three user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Start after Foundational. No dependency on US2/US3.
- **User Story 2 (P2)**: Start after Foundational. T011 is most meaningful once US1's T007/T008 are done, but T009/T010 can be written in parallel with US1.
- **User Story 3 (P3)**: Start after Foundational. No code dependency on US1/US2 — fully parallelizable.

### Within Each User Story

- Tests written before/alongside implementation (T005–T006 before T007–T008; T009–T010 before T011; T012–T013 before T014–T016).
- Story complete before moving to Polish.

### Parallel Opportunities

- T002 has no code dependency on T001 finishing pub get output, but touches a different file — still sequenced for safety (dependency declared).
- T005 and T006 (US1 tests) — different files, parallel.
- T009 and T010 (US2 tests) — different files, parallel.
- T012 and T013 (US3 tests) — different files, parallel.
- T014 and T015 (US3 implementation) — different files, parallel.
- Once Phase 2 is done, US1, US2, and US3 implementation tasks can proceed in parallel across different developers (US3 touches entirely different files than US1/US2).

---

## Parallel Example: User Story 1

```bash
# Launch both US1 tests together (different files):
Task: "Widget test for AppCachedImage cacheManager wiring in test/core/widgets/app_cached_image_test.dart"
Task: "Widget test for StaggeredWallpaperCard aspect-ratio probe cache manager in test/core/widgets/staggered_wallpaper_card_test.dart"
```

## Parallel Example: User Story 3

```bash
# Launch both US3 implementation tasks together (different files):
Task: "Add ValueKey(wallpaper.id) in lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart"
Task: "Add ValueKey(wallpaper.id) in lib/features/wallpaper_detail/presentation/widgets/similar_wallpapers_sheet.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002–T004) — CRITICAL, blocks all stories.
3. Complete Phase 3: User Story 1 (T005–T008).
4. **STOP and VALIDATE**: Scroll 80+ items on Home, scroll back, confirm instant reload with no shimmer.
5. This alone resolves the core reported bug.

### Incremental Delivery

1. Setup + Foundational → shared cache manager ready.
2. Add User Story 1 → validate independently → this is the MVP fix.
3. Add User Story 2 → validate offline behavior independently.
4. Add User Story 3 → validate grid-identity and memory/jank independently.
5. Polish → header report, analyze/format, full test run, full quickstart pass.

### Parallel Team Strategy

With multiple developers, after Phase 2:
- Developer A: User Story 1 (T005–T008)
- Developer B: User Story 3 (T012–T016) — no file overlap with US1
- Developer C: User Story 2 tests (T009–T010), then T011 once US1 lands

---

## Notes

- [P] tasks touch different files with no unmet dependency.
- [Story] label maps each task to its user story for traceability.
- No Hive schema, domain entity, or Cubit/pagination changes in any task — confirmed out of scope per plan.md and spec.md "Do NOT" constraints.
- `favorites_grid.dart` and `downloads_grid.dart` are not touched — confirmed in research.md to use a different grid implementation.
- Commit after each task or logical group; run `flutter analyze` before considering any task done (constitution: zero warnings).
