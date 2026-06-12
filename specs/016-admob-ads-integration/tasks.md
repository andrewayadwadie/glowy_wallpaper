---
description: "Task list for AdMob Ads Integration"
---

# Tasks: AdMob Ads Integration

**Input**: Design documents from `/specs/016-admob-ads-integration/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: INCLUDED — Constitution VII mandates unit tests (mocktail) for every manager/cubit. Test tasks are written before their implementation and must fail first.

**Organization**: Grouped by user story (priority order P1→P3). Each story is an independently testable increment.

## Path Conventions
Flutter mobile app, Clean Architecture, feature-first. Ads are cross-cutting → `lib/core/ads/`. Tests under `test/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Config, native setup, and stateless shared pieces every story depends on.

- [X] T001 [P] Add `ADMOB_REWARDED_ID=ca-app-pub-2083776520196762/6581955872` and optional iOS prod placeholders (`ADMOB_*_IOS_ID`) to `.env.prod`
- [X] T002 [P] Add `EnviedField`s in `lib/core/config/env.dart` for `ADMOB_REWARDED_ID` (and iOS variants); leave `ADMOB_REWARDED_INTERSTITIAL_ID` until references removed in T037
- [X] T003 Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate `env.g.dart` (depends on T002)
- [X] T004 [P] Add AdMob App ID meta-data to `android/app/src/main/AndroidManifest.xml` inside `<application>`: `com.google.android.gms.ads.APPLICATION_ID` = `ca-app-pub-2083776520196762~1431087691`
- [X] T005 [P] Add `GADApplicationIdentifier` (TODO real iOS App ID), `SKAdNetworkItems` (Google list), and `NSUserTrackingUsageDescription` to `ios/Runner/Info.plist`
- [X] T006 [P] Add `bannerSlotFallbackHeight` constant to `lib/core/utils/app_dimens.dart` (banner reserved-slot fallback, ~50–60)
- [X] T007 [P] Add ad analytics event/param name constants (`adShown`, `adFailed`, `rewardEarned`, `adDismissed`, `placement`/`ad_type`) to `lib/core/utils/constants.dart`
- [X] T008 [P] Create `AdPlacement` enum + `AdIds` resolver (build-mode `kReleaseMode` × `Platform`, test ids as constants, prod via `Env`) in `lib/core/ads/ad_ids.dart`
- [X] T009 [P] Create pure `AdNetworkError.isNetworkError(AdError)` helper (Android code==2; iOS domain/message fallback) in `lib/core/ads/ad_network_error.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Init pipeline, consent, premium gate, DI scaffold. **Blocks all user stories** — managers cannot init/serve without these.

**⚠️ CRITICAL**: Complete before any US phase.

- [X] T010 [P] Create `AdGatekeeper` (`bool shouldShowAds`, default true) in `lib/core/ads/ad_gatekeeper.dart`
- [X] T011 [P] Create `ConsentManager` (UMP `ConsentInformation`/`ConsentForm`, `gather()` non-blocking, `canRequestAds()`, debug-geography support) in `lib/core/ads/consent_manager.dart`
- [X] T012 Create `AdsInitializer.initialize()` (gather consent → `MobileAds.initialize()` → `RequestConfiguration` test device ids → guarded preload of any registered manager via `sl.isRegistered`; never throws) in `lib/core/ads/ads_initializer.dart` (depends T008, T011)
- [X] T013 Register shared ad deps (`AdIds`, `AdGatekeeper`, `ConsentManager`, `AdsInitializer`) in `lib/core/di/injection_container.dart` (depends T008–T012)
- [X] T014 Wire `await sl<AdsInitializer>().initialize();` before `runApp` and remove `AdHelper.instance.initialize()` in `lib/main.dart` (depends T013)
- [X] T015 Sync `AdGatekeeper.shouldShowAds = !isPremium` from `SubscriptionCubit` at app root in `lib/app.dart` (depends T010)
- [X] T016 [P] Unit tests for `AdNetworkError`, `AdGatekeeper`, and `ConsentManager` (mocktail) in `test/core/ads/ad_network_error_test.dart`, `test/core/ads/ad_gatekeeper_test.dart`, `test/core/ads/consent_manager_test.dart`

**Checkpoint**: SDK initializes behind consent, premium gate live, DI ready — stories can begin.

---

## Phase 3: User Story 1 — Reward-gated download (Priority: P1) 🎯 MVP

**Goal**: Download tap shows a Rewarded ad; reward (or network failure) grants the download; non-network early dismiss does not. Never traps the user.

**Independent Test**: Online → ad → download saves. Offline/no-fill → download proceeds, no ad error. Early-close (online) → no download. Premium → direct download.

### Tests for User Story 1 ⚠️ (write first, must fail)

- [X] T017 [P] [US1] `RewardedAdManager` unit tests (premium⇒grant; network load-fail⇒grant; non-network fail⇒dismiss cb; earned⇒grant once; early dismiss⇒no grant; reload-after-show) in `test/core/ads/rewarded_ad_manager_test.dart`

### Implementation for User Story 1

- [X] T018 [US1] Implement `RewardedAdManager` (`preload`, `showRewardedForDownload({onRewardGranted, onDismissedWithoutReward})`, ~5s cold-start timeout, reward-or-network-fallback via `AdNetworkError`, dispose+reload after show, analytics events) in `lib/core/ads/managers/rewarded_ad_manager.dart` (depends T008, T009, T010)
- [X] T019 [US1] Register `RewardedAdManager` in `lib/core/di/injection_container.dart` (auto-preloaded by `AdsInitializer`)
- [X] T020 [US1] Refactor `DownloadCubit.download` to inject `RewardedAdManager`, run `_downloadWallpaper` inside `onRewardGranted`, drop direct `AdHelper.showRewardedInterstitialAd`; update its factory in `injection_container.dart` in `lib/features/downloads/presentation/cubit/download_cubit.dart`
- [X] T021 [US1] Add `loader_overlay`/`flutter_spinkit` cold-start loading overlay around the download trigger in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart`
- [X] T022 [US1] Update `test/features/downloads/presentation/cubit/download_cubit_test.dart` for the rewarded-gate flow (mock `RewardedAdManager`)

**Checkpoint**: US1 fully functional & testable. MVP deliverable.

---

## Phase 4: User Story 2 — App-open ad after splash + resume (Priority: P2)

**Goal**: App-open ad once after splash (if ready), and on foreground resume (≥4-min cap), with 4h staleness + no-stacked guard.

**Independent Test**: Cold start with preloaded ad → ad → Home. No ad → straight to Home. Resume after ≥4min → ad; within 4min → none. Premium → never.

### Tests for User Story 2 ⚠️ (write first, must fail)

- [X] T023 [P] [US2] `AppOpenAdManager` unit tests (premium⇒no show; stale >4h⇒discard; isShowingAd guard; resume cap via injected clock) in `test/core/ads/app_open_ad_manager_test.dart`

### Implementation for User Story 2

- [X] T024 [US2] Implement `AppOpenAdManager` (`loadAd` w/ load-time, `showIfAvailable({source})`, 4h staleness, `_isShowingAd` guard, resume ≥4min cap, `_appLaunchHandled`, reload after dismiss/fail, analytics) in `lib/core/ads/managers/app_open_ad_manager.dart` (depends T008, T010)
- [X] T025 [US2] Register `AppOpenAdManager` in `lib/core/di/injection_container.dart`
- [X] T026 [US2] Replace `AdHelper.instance.showAppOpenAd()` with `sl<AppOpenAdManager>().showIfAvailable(source: 'splash')` (guest only) in `lib/features/splash/presentation/pages/splash_page.dart`
- [X] T027 [US2] Add `WidgetsBindingObserver` at app root calling `showIfAvailable(source: 'resume')` on `AppLifecycleState.resumed`; remove observer on dispose, in `lib/app.dart`

**Checkpoint**: US1 + US2 both work independently.

---

## Phase 5: User Story 3 — Home bottom adaptive banner (Priority: P2)

**Goal**: Self-contained anchored adaptive banner pinned at Home bottom; collapses on failure; disposes properly; never covers grid.

**Independent Test**: Home → adaptive banner at bottom, grid unobstructed. Force load fail → slot collapses (no grey box). Leave Home → disposed. Premium → no slot.

### Tests for User Story 3 ⚠️ (write first, must fail)

- [X] T028 [P] [US3] `AnchoredAdaptiveBanner` widget tests (premium⇒shrink; load failure⇒shrink) in `test/core/ads/anchored_adaptive_banner_test.dart`

### Implementation for User Story 3

- [X] T029 [US3] Implement `AnchoredAdaptiveBanner` (resolve `getAnchoredAdaptiveBannerAdSize`, reserve `AppDimens.bannerSlotFallbackHeight` while loading, one retry then collapse, `BlocBuilder<SubscriptionCubit>` premium shrink, dispose `BannerAd`) in `lib/core/ads/widgets/anchored_adaptive_banner.dart` (depends T008, T006)
- [X] T030 [US3] Swap `bottomNavigationBar` from `BannerAdWidget` to `AnchoredAdaptiveBanner` in `lib/features/home/presentation/pages/home_page.dart`
- [X] T031 [US3] Delete `lib/core/widgets/banner_ad_widget.dart` and remove its imports/usages

**Checkpoint**: US1 + US2 + US3 independently functional.

---

## Phase 6: User Story 4 — Category interstitial, frequency-capped (Priority: P3)

**Goal**: Interstitial on category switch, capped (once per 4 switches) + cooldown (≥60s), in-memory per session; never blocks navigation.

**Independent Test**: Rapid category switches → interstitial at most once/4 switches AND ≥60s apart. No ad loaded → switch proceeds + preload. Premium → never.

### Tests for User Story 4 ⚠️ (write first, must fail)

- [X] T032 [P] [US4] `InterstitialAdManager` unit tests (premium⇒never; <N switches⇒no show; cooldown not elapsed⇒no show; cap+cooldown+loaded⇒show & counter reset; injected clock) in `test/core/ads/interstitial_ad_manager_test.dart`

### Implementation for User Story 4

- [X] T033 [US4] Implement `InterstitialAdManager` (`preload`, `onCategorySwitched`, in-memory `_switchesSinceLastShow`/`_lastShownAt`, N=4 cap + 60s cooldown, show⇒reset+reload, analytics) in `lib/core/ads/managers/interstitial_ad_manager.dart` (depends T008, T010)
- [X] T034 [US4] Register `InterstitialAdManager` in `lib/core/di/injection_container.dart`
- [X] T035 [US4] Add `BlocListener<HomeCubit, HomeState>` with `listenWhen` on `selectedCategoryIndex` change (status success) → `sl<InterstitialAdManager>().onCategorySwitched()` in `lib/features/home/presentation/pages/home_page.dart` (HomeCubit stays ad-free)

**Checkpoint**: All four stories independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T036 Delete legacy `lib/core/services/ad_helper.dart` + `test/core/services/ad_helper_test.dart`; fix any remaining references (depends T020, T026, T031)
- [X] T037 [P] Remove obsolete `ADMOB_REWARDED_INTERSTITIAL_ID` from `lib/core/config/env.dart` + `.env.prod` if unreferenced, then re-run build_runner
- [X] T038 Run `flutter analyze` (zero warnings, no `print`) and `dart format .`
- [ ] T039 Execute `quickstart.md` verification checklist (all US acceptance scenarios + consent + test/prod ids + analytics)
- [X] T040 [P] Confirm `flutter test` green across `test/core/ads/` and updated download cubit test

---

## Dependencies & Execution Order

### Phase Dependencies
- **Setup (P1)**: no deps. T003 after T002.
- **Foundational (P2)**: after Setup. T012→T013→T014; T010→T015. BLOCKS all stories.
- **User Stories (P3–P6)**: after Foundational. Independent of each other (different manager files); shared edits to `injection_container.dart`, `home_page.dart`, `app.dart` create light ordering (see below).
- **Polish (P7)**: after all targeted stories.

### User Story Independence
- **US1 (P1)**: own manager + download cubit. No dependency on US2–US4.
- **US2 (P2)**: own manager + splash + app.dart resume. Independent of US1/US3/US4.
- **US3 (P2)**: own widget + home_page bottomNavigationBar. Independent.
- **US4 (P3)**: own manager + home_page BlocListener. Independent.

### Shared-file soft ordering (same file, sequence not parallel)
- `lib/core/di/injection_container.dart`: T013, T019, T020, T025, T034 — serialize edits.
- `lib/features/home/presentation/pages/home_page.dart`: T030 (US3) and T035 (US4) — serialize.
- `lib/app.dart`: T015 (foundational) and T027 (US2) — serialize.

### Parallel Opportunities
- Setup: T001, T004, T005, T006, T007, T008, T009 in parallel (T002→T003 serial).
- Foundational: T010, T011, T016 parallel; T012/T013/T014 serial.
- All `[P]` test tasks (T017, T023, T028, T032) parallel once Foundational done.
- With a team: US1/US2/US3/US4 in parallel after Foundational (mind shared-file ordering).

---

## Parallel Example: Foundational + US1 kickoff

```bash
# Foundational parallel pieces:
Task: "AdGatekeeper in lib/core/ads/ad_gatekeeper.dart"            # T010
Task: "ConsentManager in lib/core/ads/consent_manager.dart"        # T011
Task: "Unit tests for helpers in test/core/ads/*"                  # T016

# Then US1 test-first:
Task: "RewardedAdManager tests in test/core/ads/rewarded_ad_manager_test.dart"  # T017
```

---

## Implementation Strategy

### MVP First (US1 only)
1. Phase 1 Setup → 2. Phase 2 Foundational → 3. Phase 3 US1 → STOP & validate reward-gated download (incl. offline grant). Deploy as MVP.

### Incremental Delivery
Foundation → US1 (MVP) → US2 → US3 → US4 → Polish. Each story tested independently before the next.

### Notes
- `[P]` = different files, no incomplete deps.
- Tests fail before implementation (constitution VII).
- `flutter analyze` zero warnings before each commit.
- Commit after each task or logical group.
- Real iOS App ID + iOS per-format unit IDs still required before iOS release (see quickstart manual steps).
