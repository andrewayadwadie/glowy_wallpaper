---

description: "Task list for 018-disable-ads-isolate-downloads"
---

# Tasks: Disable Ads (Traceable) & Isolate-Backed Downloads

**Input**: Design documents from `/specs/018-disable-ads-isolate-downloads/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Test tasks ARE included — the spec requires them explicitly (FR-013, FR-017, US4
acceptance scenario 3), and constitution VII mandates unit tests for every use case, repository
implementation, and Cubit.

**Organization**: Grouped by user story so each can be implemented, tested, and shipped on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story the task serves (US1–US4)
- Exact file paths included in every task

## Marker rule (applies to every commenting task below)

Every disabled site carries `// TODO(ads-disabled-018): <one-line reason>` exactly as specified in
[`contracts/ad-disable-convention.md`](./contracts/ad-disable-convention.md). Pattern A = whole-file
block comment. Pattern B = line comments including the now-unused imports.

---

## Phase 1: Setup

**Purpose**: Establish a known-good baseline and the folders the new code lands in.

- [X] T001 Record the clean baseline: run `flutter analyze` and `flutter test` at repo root, note the current warning count and passing test count in the PR description — every later checkpoint is graded against this (baseline: 0 analyze issues, 116/116 tests passing)
- [X] T002 [P] Create `lib/features/downloads/data/services/` and `test/features/downloads/data/services/`
- [X] T003 [P] Verify the ad site inventory in `contracts/ad-disable-convention.md` still matches the code: `grep -rn "google_mobile_ads\|AdManager\|MobileAds\|AnchoredAdaptiveBanner\|ConsentManager\|AdGatekeeper\|AdsInitializer" lib/ test/ --include=*.dart` and reconcile any drift into that contract file before editing anything (no drift found)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: De-risk the two assumptions the whole ad-disable strategy rests on, plus the one shared
string. Small on purpose — most work in this feature is story-scoped.

**⚠️ CRITICAL**: T004 and T005 gate all commenting work. If either fails, the commenting strategy
changes before 16 files are touched, not after.

- [X] T004 Prove Dart nested block comments behave as assumed: wrap one file with inner `/* */` (use `lib/core/ads/ad_network_error.dart`) in Pattern A, run `flutter analyze`, then revert. If nesting fails, switch Pattern A to line comments in `contracts/ad-disable-convention.md` before proceeding (confirmed: nested `/* */` parses cleanly, no analyzer errors; probe reverted, file clean vs HEAD)
- [X] T005 [P] Confirm `flutter analyze` does not report TODO diagnostics: add a throwaway `// TODO(ads-disabled-018): probe` line to any lib file, run `flutter analyze`, confirm zero new issues, then revert. If it does report, add the suppression to `analysis_options.yaml` and note it in the plan's Complexity Tracking (confirmed: 0 new issues; probe reverted)
- [X] T006 [P] Add the restore-purchases label to `lib/core/utils/app_strings.dart` (constitution II — no hardcoded strings) (already exists: `AppStrings.restorePurchase` at line 128 — reused instead of duplicating)

**Checkpoint**: Commenting strategy validated; user story work can begin.

---

## Phase 3: User Story 1 - Download starts instantly, no ad required (Priority: P1) 🎯 MVP

**Goal**: Tapping Download saves the wallpaper immediately, with no rewarded ad, no ad wait, and no
chance of losing the download to an unfilled or dismissed ad.

**Independent Test**: On a device with ad serving blocked, tap Download on both an image and a video
wallpaper. Both save to the gallery with no ad shown and no ad-related delay. Offline and
permission-denied paths still produce their existing messages.

**Note**: this phase deliberately keeps the existing await/`onProgress` download path. US3 replaces
that path with the isolate engine. The cubit is therefore touched in both phases — that is the cost
of making US1 a standalone shippable MVP.

### Tests for User Story 1

> Write these first and watch them fail before touching the implementation.

- [X] T007 [US1] Rewrite `test/features/downloads/presentation/cubit/download_cubit_test.dart`: drop the `RewardedAdManager` mock entirely, assert `download()` reaches the use case with no ad collaborator, assert the offline short-circuit still emits `AppStrings.networkUnavailable`, assert success and failure analytics still fire (FR-017, FR-008)
- [X] T008 [P] [US1] Add a widget test at `test/features/wallpaper_detail/wallpaper_detail_download_test.dart` asserting the detail page renders no ad-gate overlay and the download control is actionable on first frame (US1 scenario 1)

### Implementation for User Story 1

- [X] T009 [US1] Strip the rewarded gate from `lib/features/downloads/presentation/cubit/download_cubit.dart`: comment the `rewarded_ad_manager.dart` import (line 3), the `_rewardedAdManager` field (17), the constructor param (25) and initializer (31), and the whole `showRewardedForDownload` block in `download()` (65–79); call `_performDownload(wallpaper)` directly after the connectivity check
- [X] T010 [US1] Comment the `isAdGateActive` field and its doc comment in `lib/features/downloads/presentation/cubit/download_state.dart` (lines 16–18)
- [X] T011 [US1] Comment every `isAdGateActive` reader in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` (the loader-overlay branch at 201–207) — must ship in the same commit as T010 or the build breaks (also commented the now-dead `app_loading.dart` import)
- [X] T012 [US1] Remove the `rewardedAdManager: sl(),` argument from the `DownloadCubit` registration in `lib/core/di/injection_container.dart` (line 299), marker included
- [X] T013 [US1] Run `flutter analyze` and `flutter test`; confirm zero warnings and the same passing count as the T001 baseline plus the new tests (0 issues; 115/115 passing — net -2 from consolidating 9 old ad-gate tests into 7, +1 new widget test, vs 116 baseline)

**Checkpoint**: US1 complete and shippable. Downloads no longer depend on ads (FR-001). Ads still
run everywhere else.

---

## Phase 4: User Story 2 - Ad-free app throughout (Priority: P2)

**Goal**: No banner, interstitial, app-open ad, or consent prompt appears anywhere; app startup no
longer waits on ad initialization; and the premium purchase entry point is hidden while restore
still works.

**Independent Test**: Cold-start a fresh install, browse home, switch categories 10×, open a
wallpaper, background and resume 3×, and navigate the whole app. No ad surface and no purchase entry
appears at any point. An existing subscriber still resolves as premium and can restore.

### Pattern A — whole ad files (all parallel, independent files)

- [X] T014 [P] [US2] Pattern A on `lib/core/ads/ads_initializer.dart`
- [X] T015 [P] [US2] Pattern A on `lib/core/ads/consent_manager.dart`
- [X] T016 [P] [US2] Pattern A on `lib/core/ads/ad_gatekeeper.dart`
- [X] T017 [P] [US2] Pattern A on `lib/core/ads/ad_ids.dart`
- [X] T018 [P] [US2] Pattern A on `lib/core/ads/ad_network_error.dart`
- [X] T019 [P] [US2] Pattern A on `lib/core/ads/managers/app_open_ad_manager.dart`
- [X] T020 [P] [US2] Pattern A on `lib/core/ads/managers/interstitial_ad_manager.dart`
- [X] T021 [P] [US2] Pattern A on `lib/core/ads/managers/rewarded_ad_manager.dart`
- [X] T022 [P] [US2] Pattern A on `lib/core/ads/widgets/anchored_adaptive_banner.dart`

### Pattern B — call sites in living files

- [X] T023 [P] [US2] Comment the `AdsInitializer` import (line 9) and the `initialize()` call (29–30) in `lib/main.dart` — startup must no longer await ads (FR-004)
- [X] T024 [P] [US2] Comment the ad imports (5–6), the resume app-open call (37–41), and the `AdGatekeeper` sync inside the subscription listener (60–63) in `lib/app.dart`, keeping the surrounding `BlocListener` intact
- [X] T025 [P] [US2] Comment the `AppOpenAdManager` import (line 7) and the post-splash show call (158–161) in `lib/features/splash/presentation/pages/splash_page.dart` (also commented the now-dead `currentState` local var, which existed only to gate that call)
- [X] T026 [US2] In `lib/features/home/presentation/pages/home_page.dart`: comment both ad imports (7–8) and the category-switch interstitial listener (28–33), and replace `bottomNavigationBar: isPremium ? null : const AnchoredAdaptiveBanner()` (99) with `bottomNavigationBar: null`, preserving the original in a marked comment — verify no empty band or shifted content remains (FR-005)
- [X] T027 [US2] Comment the `InterstitialAdManager` import (line 21) and the interstitial call (287) in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart` (favorite-add now toggles directly instead of via the interstitial's onComplete)
- [X] T028 [US2] In `lib/core/di/injection_container.dart`: comment the `google_mobile_ads` import (7), the six ad imports (60–66), and the `MobileAds` plus five ad-manager registrations (164–183)
- [X] T029 [US2] Verify `canShowAppOpenAd` in `lib/features/premium/data/datasources/premium_local_source.dart:74` now has no live caller and leave that file untouched — it is premium bookkeeping, not ad code (research R8) (confirmed via grep: zero call sites anywhere)

### Premium visibility (FR-021, FR-022)

- [X] T030 [US2] Add the marker header to the already-commented premium/manage-subscription block at `lib/features/home/presentation/widgets/home_drawer.dart:90–111` so it is traceable and reversed with everything else
- [X] T031 [US2] Comment the `/premium` `GoRoute` registration in `lib/core/routes/app_router.dart:144` with the marker, so no deep link or notification payload can reach the purchase screen (also commented the now-unused `SubscriptionCubit`/`PremiumCubit`/`GetPremiumPage` imports in this file)
- [X] T032 [US2] Add a **Restore Purchases** item to the info section of `lib/features/home/presentation/widgets/home_drawer.dart` using the existing `_buildMenuItem` helper and the `AppStrings` label from T006; wire it to `PremiumCubit.restore()` via `sl<PremiumCubit>()` (the drawer has no `PremiumCubit` provider today — provide it locally rather than adding a global one), reusing the cubit's existing success and failure messaging. It must never navigate to the purchase page (implemented as `_RestorePurchasesTile`, a local `BlocProvider<PremiumCubit>` + `BlocConsumer` wrapping the reused helper)

### Verification for User Story 2

- [X] T033 [US2] Confirm no live ad usage: `grep -rn "google_mobile_ads\|AdManager\|MobileAds\|AnchoredAdaptiveBanner" lib/ --include=*.dart | grep -v "^\s*//"` returns only commented lines, and `grep -rn "AppRoutes.premium" lib/ --include=*.dart` shows no live navigation (verified — remaining hits are all inside `lib/core/ads/**` block comments or the drawer's pre-existing `/*/ ... */` block)
- [X] T034 [US2] Run `flutter analyze` (zero warnings — every commented import must be commented too) and `flutter test` — **note**: reaching zero warnings here required pulling T053–T059 (Pattern A on the 7 `test/core/ads/*` files) forward from Phase 6, since the ad test files reference the now-commented production classes and won't compile otherwise; quickstart.md's Stage 3 already groups production + test Pattern-A together for this reason, tasks.md's phase split was coarser. Result: 0 analyze issues, 69/69 tests passing (down from 115 — 46 ad-behavior tests paused). Also discovered and fixed: a fully block-commented `.dart` test file has no `main()`, which `flutter test` treats as a load error (`Missing definition of main method`), not a silent skip — added a small stub `void main() {}` after the closing `*/` in each of the 7 files so the runner loads them as no-ops
- [ ] T035 [US2] Device pass, quickstart items 1, 2, 3, 4, 11, 12, 13: no consent form, no banner or gap, no interstitial across 10 category switches, no app-open ad across 3 resumes, no purchase entry anywhere, restore works, existing subscriber still premium — **not run**: no physical/emulator device attached in this environment; deferred to the user for manual verification

**Checkpoint**: US1 and US2 both complete. App is fully ad-free and startup no longer touches ads.

---

## Phase 5: User Story 3 - Interface stays smooth while downloading (Priority: P2)

**Goal**: The heavy transfer and file write move off the main isolate, memory stays flat regardless
of file size, and a download survives the user leaving the screen.

**Independent Test**: Download the largest available video on a mid-range device while scrolling the
similar-wallpapers list — scrolling stays fluid and progress keeps advancing. Leave the screen
mid-download and return: the file is saved with exactly one history entry. Kill the network
mid-transfer: failure message, no partial file, no history entry.

### Tests for User Story 3

> Write these first and watch them fail.

- [X] T036 [P] [US3] Create `test/features/downloads/data/services/download_engine_test.dart` with a fake `DownloadRunner` emitting scripted messages; assert single-flight rejection (EN-1), same-id join without a second job (EN-2), last-event replay to a late subscriber (EN-4), `.part` deletion with no history write on error (EN-6), and error-kind → typed-failure mapping (EN-7)
- [X] T037 [P] [US3] Create `test/features/downloads/data/repositories/download_repository_impl_test.dart` with mocked engine, gallery source, and local source; assert permission denial returns the existing sentinel messages unchanged and that no history entry is written on failure (FR-008, FR-020)
- [X] T038 [US3] Extend `test/features/downloads/presentation/cubit/download_cubit_test.dart` for the event-driven path: progress emitted from engine events, events for other wallpaper ids ignored (CU-3), and `close()` cancelling only the subscription while the job continues (CU-2, FR-018) (rewritten wholesale — the accept-vs-outcome split changes what every existing case asserts)

### Domain layer

- [X] T039 [P] [US3] Create the sealed `DownloadEvent` hierarchy (`DownloadStarted`, `DownloadProgressed`, `DownloadCompleted`, `DownloadFailed`) in `lib/features/downloads/domain/entities/download_event.dart` — pure Dart, no Flutter imports (constitution I)
- [X] T040 [US3] Add `Stream<DownloadEvent> get events;` to `lib/features/downloads/domain/repositories/download_repository.dart`, keeping the existing `downloadWallpaper` signature
- [X] T041 [P] [US3] Create `WatchDownloadEvents` in `lib/features/downloads/domain/usecases/watch_download_events.dart` returning `repository.events` (does not extend `UseCase<T, P>` — it is a continuous signal, not a one-shot)

### Data layer — isolate

- [X] T042 [P] [US3] Create the `DownloadRunner` abstraction and the `RunnerMessage` sealed types in `lib/features/downloads/data/services/download_runner.dart` per `contracts/download-engine.md`
- [X] T043 [US3] Create the top-level isolate entrypoint in `lib/features/downloads/data/services/download_isolate_entry.dart`: build a fresh `Dio` inside the isolate, use `dio.download(url, savePath, onReceiveProgress:)` (never `ResponseType.bytes`), throttle progress to ≥1% delta or ≥100 ms, always send a final 100% progress then exactly one `done` or `error`, and map `DioException` → `network`, `FileSystemException` → `io`, else `unknown`. No plugin channel calls (research R2)
- [X] T044 [US3] Implement `IsolateDownloadRunner` in `lib/features/downloads/data/services/download_runner.dart` using `Isolate.spawn` + `ReceivePort`; close the port and kill the isolate on every exit path including error (RN-6, constitution VI)

### Data layer — engine and repository

- [X] T045 [US3] Implement `DownloadEngine` in `lib/features/downloads/data/services/download_engine.dart`: single-flight `_activeId` guard, broadcast controller with last-event replay, and the terminal sequence — rename `.part` → final, gallery save, delete temp, save history, then emit `DownloadCompleted`; on any failure delete `.part` in a `finally` and emit `DownloadFailed` with no history write (EN-1…EN-9) (replay implemented via `Stream.multi`; also added `GalleryDataSource.saveFile(path, {isVideo})` since no existing method could save a file already on disk)
- [X] T046 [US3] Rewrite `downloadWallpaper` in `lib/features/downloads/data/repositories/download_repository_impl.dart`: keep permission handling and its sentinel messages, resolve the temp directory and build `partPath`/`finalPath` on the main isolate, delegate to `DownloadEngine.start`, and expose `events`; delete the `ResponseType.bytes` + `Uint8List.fromList` path entirely (FR-019)
- [X] T047 [P] [US3] Make `saveRecord` idempotent per `wallpaperId` in `lib/features/downloads/data/datasources/download_local_data_source.dart` — re-saving updates the existing entry instead of appending (FR-018, research R10) (already idempotent — Hive `box.put(wallpaperId, ...)` overwrites by key; no code change needed)

### Wiring and presentation

- [X] T048 [US3] Register `DownloadRunner`, `DownloadEngine`, and `WatchDownloadEvents` as lazy singletons in `lib/core/di/injection_container.dart`, and add `watchDownloadEvents` to the `DownloadCubit` factory registration — the cubit stays `registerFactory` (FR-018 depends on the engine being the singleton, not the cubit)
- [X] T049 [US3] Rewire `lib/features/downloads/presentation/cubit/download_cubit.dart` to the event stream: subscribe in the constructor, filter by `wallpaperId`, drive `isDownloading`/`downloadProgress`/messages from events, and cancel only the subscription in `close()` — preserve the existing analytics events and the notification-permission prompt on first success (CU-2…CU-6) (accept-vs-outcome split: `download()`'s synchronous `Left` only covers pre-spawn rejection — permission denial, busy; all progress/success/failure now come from the event stream)

### Verification for User Story 3

- [X] T050 [US3] Run `flutter analyze` and `flutter test`; all engine, repository, and cubit tests green (0 issues; 81/81 tests passing; `flutter build apk --debug` also verified — succeeds)
- [ ] T051 [US3] Device pass, quickstart items 6, 7, 10: largest video downloads while scrolling stays fluid with progress advancing; leaving the screen mid-download still saves with exactly one history entry; network killed mid-transfer gives a failure message with no partial file and no history entry — **not run**: no physical/emulator device attached in this environment; deferred to the user for manual verification
- [ ] T052 [US3] Memory check for SC-009: watch the memory graph during the largest video download and confirm peak stays flat rather than tracking file size — **not run**: requires a device and DevTools memory profiling session; deferred to the user for manual verification

**Checkpoint**: US1, US2, US3 all complete. Downloads are ad-free, off-thread, memory-flat, and
survive navigation.

---

## Phase 6: User Story 4 - Ad code disabled but traceable and restorable (Priority: P3)

**Goal**: Every disabled ad location is findable by one search, the suite passes with ad tests
paused the same way, and restoring ads is pure reversal.

**Independent Test**: Search the project for `ads-disabled-018`; every disabled location appears and
matches the inventory in `contracts/ad-disable-convention.md`. Uncommenting by marker restores ad
behaviour with no new implementation work.

- [X] T053 [P] [US4] Pattern A on `test/core/ads/ad_gatekeeper_test.dart` (done in Phase 4/T034 — required for `flutter analyze`/`flutter test` to pass once the production ad files were commented; see T034 note)
- [X] T054 [P] [US4] Pattern A on `test/core/ads/ad_network_error_test.dart` (done in Phase 4/T034)
- [X] T055 [P] [US4] Pattern A on `test/core/ads/anchored_adaptive_banner_test.dart` (done in Phase 4/T034)
- [X] T056 [P] [US4] Pattern A on `test/core/ads/app_open_ad_manager_test.dart` (done in Phase 4/T034)
- [X] T057 [P] [US4] Pattern A on `test/core/ads/consent_manager_test.dart` (done in Phase 4/T034)
- [X] T058 [P] [US4] Pattern A on `test/core/ads/interstitial_ad_manager_test.dart` (done in Phase 4/T034)
- [X] T059 [P] [US4] Pattern A on `test/core/ads/rewarded_ad_manager_test.dart` (done in Phase 4/T034)
- [X] T060 [US4] Marker audit: run `grep -rn "ads-disabled-018" lib/ test/` and reconcile the result line by line against the inventory in `contracts/ad-disable-convention.md` — every listed site present, no site missing, no stray variant spelling of the tag (SC-006) (26/26 inventory files present, 0 missing, 0 stray spellings; 2 extra hits are new US1/US3 test files with an explanatory marker reference in a comment, not disabled sites — not inventory drift)
- [X] T061 [US4] Reason-quality pass: confirm each marker states what the code *did* rather than that it was commented, carries no emoji, and appears once per contiguous block rather than per line (FR-010, constitution package standards) (confirmed clean on all 55 marker occurrences; multi-marker files like `injection_container.dart` and `download_cubit.dart` each mark genuinely distinct contiguous sites, not per-line spam)
- [X] T062 [US4] Restore rehearsal for SC-008: on a scratch commit, uncomment one Pattern A file and one Pattern B site by marker alone, confirm they compile and behave, then discard the scratch commit — this proves reversal needs no re-implementation. **Deviation**: no git commit was created (session policy — commits only on explicit request); rehearsed instead via direct file backup/restore/re-diff, which exercises the same claim. **First pass caught a real defect**: restoring `ad_gatekeeper.dart` (Pattern A) and `main.dart` (Pattern B) by marker alone did *not* reproduce the original files — several Pattern B sites had replaced the original explanatory comment with the marker's own reason instead of preserving both, and `injection_container.dart` had dropped a header comment (`//! Ads layer (016)...`) entirely with no replacement. Worse: `download_cubit.dart`'s rewarded-gate integration code was fully gone (not just re-commented) because US3 rewrote `download()` a second time over US1's already-commented version. Fixed all of it: preserved every original comment inside the commented blocks in `app.dart`, `injection_container.dart`, `home_page.dart`, `splash_page.dart`, `wallpaper_detail_page.dart` (both sites), `main.dart`, and `download_cubit.dart` (which also got an honest note that its gate needs re-wiring into the event-driven flow on restore, not pure uncommenting — an architecture-driven exception to "restore = uncomment"). Re-ran the rehearsal after fixing: Pattern A restore is now byte-identical to pre-feature HEAD; Pattern B restore is content-identical (a CRLF/LF diff-tool artifact from the Windows checkout, not real drift). Re-verified `flutter analyze`/`flutter test` clean after every fix (0 issues, 81/81 passing)
- [X] T063 [US4] Confirm the untouched list is genuinely untouched: `git diff --stat main` shows no changes to `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `lib/core/config/env.dart`, or `lib/core/config/env.g.dart` (manifest/plist/env files: zero diff. `pubspec.yaml` has one unrelated line — `path_provider_platform_interface` added to `dev_dependencies` for T037's test; the `google_mobile_ads` line itself is untouched)

**Checkpoint**: All four user stories complete.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T064 Run `dart format .` and confirm no unrelated files were reformatted by the commenting work (23 files formatted, all touched by this feature; `lib/firebase_options.dart` was also reformatted by the tool — a pre-existing trailing-newline nit unrelated to this feature — reverted to keep the diff scoped)
- [X] T065 Full gate: `flutter analyze` (zero warnings), `flutter test` (all green), `flutter build apk --debug` (succeeds) — SC-007 (0 issues; 81/81 passing; debug APK builds clean)
- [ ] T066 [P] Walk the full quickstart manual pass (all 13 items) end to end on one device in a single session — **not run**: no physical/emulator device attached in this environment; deferred to the user
- [X] T067 [P] Update `specs/018-disable-ads-isolate-downloads/checklists/requirements.md` with the delivery outcome, noting any requirement that shifted during implementation
- [ ] T068 Record the SC-005 improvement: measure tap-to-saved time before and after (the ad gate previously cost 5–30 s per download) and note the result in the PR — **not measured live**: no device. Structurally confirmed instead — `RewardedAdManager.loadTimeout = Duration(seconds: 5)` plus real ad-watch time is entirely gone from the download path (`DownloadCubit.download()` now calls the use case directly after the connectivity check); the 5–30 s figure was the removed code's own documented bound, not a benchmark to reproduce

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies — start immediately
- **Foundational (Phase 2)**: needs Setup. T004 and T005 block every commenting task in Phases 4 and 6
- **US1 (Phase 3)**: needs Foundational. No dependency on other stories — this is the MVP
- **US2 (Phase 4)**: needs Foundational. Best done after US1 — US1 removes the last live use of `RewardedAdManager`, so T021 has nothing to break
- **US3 (Phase 5)**: needs Foundational. Touches `download_cubit.dart` again after US1, so run it after US1 rather than concurrently
- **US4 (Phase 6)**: needs US1 and US2 complete — it audits the markers those phases produced
- **Polish (Phase 7)**: needs all desired stories complete

### Story-level notes

- **US1** is genuinely standalone and shippable on its own.
- **US2** is independent of US1 in principle; sequencing it second only avoids commenting a file that still has a live caller.
- **US3** shares one file with US1 (`download_cubit.dart`) — a deliberate tradeoff so US1 can ship alone. Do not run US1 and US3 in parallel.
- **US4** is an audit phase over US1 and US2 output plus the ad test files; it cannot start early.

### Within each story

- Tests are written before implementation and must fail first.
- Domain before data before presentation (constitution I).
- T010 and T011 must land together — commenting `isAdGateActive` without its readers breaks the build.
- T039–T041 (domain) before T042–T047 (data) before T048–T049 (wiring/presentation).

---

## Parallel Opportunities

**Phase 4 — the biggest win.** T014–T022 are nine independent files:

```bash
Task: "Pattern A on lib/core/ads/ads_initializer.dart"
Task: "Pattern A on lib/core/ads/consent_manager.dart"
Task: "Pattern A on lib/core/ads/ad_gatekeeper.dart"
Task: "Pattern A on lib/core/ads/ad_ids.dart"
Task: "Pattern A on lib/core/ads/ad_network_error.dart"
Task: "Pattern A on lib/core/ads/managers/app_open_ad_manager.dart"
Task: "Pattern A on lib/core/ads/managers/interstitial_ad_manager.dart"
Task: "Pattern A on lib/core/ads/managers/rewarded_ad_manager.dart"
Task: "Pattern A on lib/core/ads/widgets/anchored_adaptive_banner.dart"
```

T023, T024, T025 are also parallel (three separate files). T026, T027, T028 each touch a file with
other live logic — do them one at a time and re-run analyze after each.

**Phase 6**: T053–T059, seven independent test files, all parallel.

**Phase 5**: T036 and T037 in parallel; T039, T041, T042 in parallel; T047 parallel with T045/T046.

---

## Implementation Strategy

### MVP first (US1 only)

1. Phase 1 Setup → 2. Phase 2 Foundational → 3. Phase 3 US1 → 4. **Stop and validate**: downloads
work with no ad, offline and permission paths unchanged → 5. Ship.

That alone removes the 5–30 s ad gate from every download (SC-005), which is the single biggest user
win in this feature.

### Incremental delivery

1. Setup + Foundational → strategy validated
2. US1 → ad-free downloads → ship
3. US2 → fully ad-free app, purchase entry hidden, restore added → ship
4. US3 → off-thread, memory-flat, navigation-proof downloads → ship
5. US4 → marker audit and restore rehearsal → ship
6. Polish → full gate

### Parallel team strategy

After Foundational: one developer takes US1 → US3 (they share `download_cubit.dart`), another takes
US2 in parallel. US4 waits for both. This is the only split that avoids file conflicts.

---

## Task Summary

| Phase | Story | Tasks | Count |
|---|---|---|---|
| 1 — Setup | — | T001–T003 | 3 |
| 2 — Foundational | — | T004–T006 | 3 |
| 3 — Ad-free download | US1 (P1) | T007–T013 | 7 |
| 4 — Ad-free app | US2 (P2) | T014–T035 | 22 |
| 5 — Isolate downloads | US3 (P2) | T036–T052 | 17 |
| 6 — Traceability | US4 (P3) | T053–T063 | 11 |
| 7 — Polish | — | T064–T068 | 5 |
| **Total** | | | **68** |

Test tasks: T007, T008 (US1), T036, T037, T038 (US3). Ad test files are paused in T053–T059.

---

## Notes

- `[P]` = different files, no dependencies — safe to run concurrently.
- Commit after each task or logical group; the marker makes every ad commit self-describing.
- Any commented import must be commented alongside its usage — an unused import is an analyzer
  warning and constitution VII requires a clean `flutter analyze`.
- Never delete ad code. Never touch `pubspec.yaml`, the Android manifest, the iOS plist, or the
  envied ad ids (T063 enforces this).
- Traps worth re-reading before Phase 5: no `Dio` sent into the isolate, no plugin calls inside the
  isolate, no `ResponseType.bytes`, close the `ReceivePort` on every path, and do not make
  `DownloadCubit` a singleton. Full list in `quickstart.md`.
