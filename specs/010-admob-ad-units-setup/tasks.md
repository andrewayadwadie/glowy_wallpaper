# Tasks: AdMob Ad Units Integration — Production Ad Setup

**Input**: Design documents from `/specs/010-admob-ad-units-setup/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/ad-helper-interface.md

**Tests**: Not explicitly requested — test tasks omitted.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Exact file paths included in all descriptions

---

## Phase 1: Setup (Environment & Configuration)

**Purpose**: Update ad unit IDs and env config to production values; add new env variables for Rewarded Interstitial and Interstitial formats.

- [x] T001 Update `.env.dev` with production ad unit IDs: replace `ADMOB_BANNER_ID` with `ca-app-pub-2083776520196762/8536132654`, replace `ADMOB_APP_OPEN_ID` with `ca-app-pub-2083776520196762/2548207750`, add `ADMOB_REWARDED_INTERSTITIAL_ID=ca-app-pub-2083776520196762/2641508848`, add `ADMOB_INTERSTITIAL_ID=ca-app-pub-2083776520196762/1519998865`, remove old `ADMOB_REWARDED_ID`
- [x] T002 Update `lib/core/config/env.dart`: add `adMobRewardedInterstitialId` and `adMobInterstitialId` fields with `@EnviedField` annotations; remove old `adMobRewardedId` field
- [x] T003 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `lib/core/config/env.g.dart` with new ad unit IDs

**Checkpoint**: Env config compiles with 5 ad-related fields (appId, appOpenId, bannerId, rewardedInterstitialId, interstitialId). `flutter analyze` passes.

---

## Phase 2: Foundational (AdHelper Core Updates)

**Purpose**: Extend AdHelper singleton with new ad types, update enum, add cooldown tracking. All user stories depend on this phase.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T004 Update `AdType` enum in `lib/core/services/ad_helper.dart`: change `{ appOpen, banner, rewarded }` to `{ appOpen, banner, rewardedInterstitial, interstitial }`
- [x] T005 Add `RewardedInterstitialAd` support to `lib/core/services/ad_helper.dart`: replace `_rewardedAd` field with `_rewardedInterstitialAd: RewardedInterstitialAd?`, rename `_isAdLoading` to `_isRewardedInterstitialLoading`, implement `preloadRewardedInterstitialAd()` using `RewardedInterstitialAd.load()` with `Env.adMobRewardedInterstitialId` and 10-second timeout via `Completer` + `Timer`, implement `showRewardedInterstitialAd({required String action})` returning `Future<bool>` with reward callback, auto-preload after dismiss, and analytics logging (`ad_shown`, `reward_earned`, `ad_failed`)
- [x] T006 Add `InterstitialAd` support to `lib/core/services/ad_helper.dart`: add `_interstitialAd: InterstitialAd?`, `_isInterstitialLoading: bool`, `_lastInterstitialShown: DateTime?` fields; implement `preloadInterstitialAd()` using `InterstitialAd.load()` with `Env.adMobInterstitialId`; implement `showInterstitialAd({required VoidCallback onComplete})` that checks 60-second cooldown via `_lastInterstitialShown`, shows ad if loaded and outside cooldown, calls `onComplete` after dismiss (or immediately if ad not loaded / within cooldown / premium user), updates `_lastInterstitialShown` on show, auto-preloads after dismiss, logs `ad_shown` analytics
- [x] T007 Update `initialize()` in `lib/core/services/ad_helper.dart`: call both `preloadRewardedInterstitialAd()` and `preloadInterstitialAd()` on init (replace old `preloadRewardedAd()` call)
- [x] T008 Update `dispose()` in `lib/core/services/ad_helper.dart`: dispose `_rewardedInterstitialAd` and `_interstitialAd` (replace old `_rewardedAd` disposal)
- [x] T009 Remove old `preloadRewardedAd()` and `showRewardedAd()` methods from `lib/core/services/ad_helper.dart` (replaced by rewarded interstitial equivalents)

**Checkpoint**: AdHelper compiles with 4 ad types. `flutter analyze` passes. Old rewarded methods removed.

---

## Phase 3: User Story 1 — App Open Ad on Splash (Priority: P1) 🎯 MVP

**Goal**: Display App Open ad on every cold start for free users using production ad unit ID `ca-app-pub-2083776520196762/2548207750`, with no frequency cap.

**Independent Test**: Cold-start the app as a free user → App Open ad appears before Home. Cold-start as premium → no ad shown. Kill and relaunch immediately → ad shows again (no frequency cap).

### Implementation for User Story 1

- [x] T010 [US1] Update `loadAppOpenAd()` in `lib/core/services/ad_helper.dart` to use `Env.adMobAppOpenId` (already does — verify production ID flows through from env config)
- [x] T011 [US1] Update `lib/features/splash/presentation/pages/splash_page.dart`: remove any frequency-cap check (if `canShowAppOpenAd()` from `PremiumLocalSource` is called, remove it); ensure `loadAppOpenAd()` + `showAppOpenAd()` is called on every cold start for free users with no time-gap condition
- [x] T012 [US1] Verify `showAppOpenAd()` in `lib/core/services/ad_helper.dart` logs `ad_shown` analytics event with `{ad_type: 'app_open'}` on successful show

**Checkpoint**: App Open ad shows on every cold start for free users. No frequency cap. Premium users see no ad.

---

## Phase 4: User Story 2 — Rewarded Interstitial Ad Before Download (Priority: P1)

**Goal**: Gate wallpaper download behind a Rewarded Interstitial ad for free users. Download only proceeds after reward is earned. Uses production ad unit ID `ca-app-pub-2083776520196762/2641508848`.

**Independent Test**: As free user, tap Download → Rewarded Interstitial plays → earn reward → download starts. Dismiss early → download blocked. As premium → download starts immediately.

### Implementation for User Story 2

- [x] T013 [US2] Update `lib/core/widgets/ad_gate_placeholder.dart`: replace `AdHelper.instance.showRewardedAd()` call with `AdHelper.instance.showRewardedInterstitialAd(action: action)` — the rest of the blocking gate logic (show loading overlay, check reward result, proceed or block) remains the same
- [x] T014 [US2] Verify `lib/features/downloads/presentation/cubit/download_cubit.dart` uses `adGatePlaceholder()` with `action: 'download'` — no changes needed if it already calls the gate (the gate internally now uses rewarded interstitial)
- [x] T015 [US2] Add `ad_failed` analytics event logging in `showRewardedInterstitialAd()` in `lib/core/services/ad_helper.dart` when ad fails to load for a gated download action

**Checkpoint**: Download is gated by Rewarded Interstitial. Reward earned → download starts. No reward → blocked. Premium bypasses gate.

---

## Phase 5: User Story 3 — Interstitial Ad Before Favorite (Priority: P1)

**Goal**: Show Interstitial ad before add-favorite action for free users. Favorite always completes after ad dismissal (non-blocking). 60-second cooldown between interstitials. No ad on remove-favorite.

**Independent Test**: As free user, tap Favorite (add) → Interstitial shows → favorite added after dismiss. Tap Favorite (remove) → no ad, immediate removal. Add another favorite within 60s → no ad, immediate add. As premium → no ad.

### Implementation for User Story 3

- [x] T016 [US3] Update favorite button callback in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart`: wrap the `onFavorite` handler so that when user is adding a favorite (not currently favorited), call `AdHelper.instance.showInterstitialAd(onComplete: () { context.read<FavoriteCubit>().toggle(currentWallpaper); })` for free users; when removing a favorite (currently favorited), call `toggle()` directly with no ad
- [x] T017 [US3] Verify 60-second cooldown works in `showInterstitialAd()` in `lib/core/services/ad_helper.dart`: if `_lastInterstitialShown` is non-null and within 60 seconds, call `onComplete` immediately without showing ad
- [x] T018 [US3] Ensure rapid-tap protection: in the favorite button handler in `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart`, check `favState.isToggling` before triggering the ad flow to prevent multiple simultaneous interstitial triggers

**Checkpoint**: Interstitial shows on add-favorite only. 60s cooldown works. Remove-favorite has no ad. Premium bypasses. Rapid taps debounced.

---

## Phase 6: User Story 4 — Banner Ad on Home Screen (Priority: P2)

**Goal**: Display a real AdMob Banner ad at the bottom of the Home screen for free users using production ad unit ID `ca-app-pub-2083776520196762/8536132654`. Replace the current placeholder widget.

**Independent Test**: Open Home as free user → real banner ad visible at bottom. Navigate away → banner disposed. As premium → no banner shown. Ad fails to load → space collapses (no gap).

### Implementation for User Story 4

- [x] T019 [US4] Rewrite `lib/core/widgets/banner_ad_widget.dart`: replace placeholder text with real AdMob rendering — on widget init, call `AdHelper.instance.loadBannerAd()`; in build, check `SubscriptionCubit` state (return `SizedBox.shrink()` for premium); if `AdHelper.instance.bannerAd` is loaded, render `AdWidget(ad: AdHelper.instance.bannerAd!)` wrapped in `SizedBox(height: AdSize.banner.height.toDouble(), width: AdSize.banner.width.toDouble())`; if not loaded, return `SizedBox.shrink()`; call `AdHelper.instance.disposeBannerAd()` on widget dispose
- [x] T020 [US4] Update `lib/features/home/presentation/pages/home_page.dart`: verify `BannerAdWidget` is used in `bottomNavigationBar` for free users (already in place) — ensure it renders correctly with the rewritten widget
- [x] T021 [US4] Update `loadBannerAd()` in `lib/core/services/ad_helper.dart` to use `Env.adMobBannerId` (verify production ID flows through) and add a `ValueNotifier<bool>` or callback mechanism so `BannerAdWidget` can rebuild when the banner loads asynchronously

**Checkpoint**: Real banner ad visible on Home for free users. Collapses on failure. Hidden for premium. Disposed on navigation.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Remove legacy code, verify analytics, confirm preview gate removal, final validation.

- [x] T022 Remove the existing preview ad gate (if any) from `lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart`: verify the `onPreview` callback does NOT call `adGatePlaceholder` — currently confirmed absent, but add a code comment noting "Preview is intentionally not ad-gated (spec 010)"
- [x] T023 Remove old `ADMOB_REWARDED_ID` references from any remaining files: search codebase for `adMobRewardedId` and `ADMOB_REWARDED_ID` and clean up any stale references
- [x] T024 Verify all 4 production ad unit IDs are correctly wired by checking `lib/core/config/env.g.dart` after build_runner: App Open = `2548207750`, Rewarded Interstitial = `2641508848`, Interstitial = `1519998865`, Banner = `8536132654`
- [x] T025 Run `flutter analyze` and `dart format .` — fix all warnings and formatting issues
- [x] T026 Run quickstart.md validation checklist on a physical device: verify all 8 checkpoints pass (app open, banner, download gate, favorite add gate, favorite remove no gate, cooldown, preview no gate, premium bypass)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (env config must compile)
- **User Stories (Phase 3–6)**: All depend on Phase 2 (AdHelper core must be updated first)
  - US1, US2, US3, US4 can proceed in parallel after Phase 2
  - Or sequentially: US1 → US2 → US3 → US4
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (App Open)**: After Phase 2 — No dependencies on other stories. Touches: `splash_page.dart`, `ad_helper.dart`
- **US2 (Rewarded Interstitial Download)**: After Phase 2 — No dependencies on other stories. Touches: `ad_gate_placeholder.dart`, `download_cubit.dart`
- **US3 (Interstitial Favorite)**: After Phase 2 — No dependencies on other stories. Touches: `wallpaper_detail_page.dart`, `ad_helper.dart`
- **US4 (Banner)**: After Phase 2 — No dependencies on other stories. Touches: `banner_ad_widget.dart`, `home_page.dart`

### Within Each User Story

- Core implementation before integration
- Verify analytics logging after implementation
- Story complete before moving to next priority

### Parallel Opportunities

- T001 and T002 can run in parallel (different files)
- After Phase 2, all 4 user stories can run in parallel (different files, no cross-dependencies)
- T022 and T023 can run in parallel (different concerns)

---

## Parallel Example: After Phase 2

```
# All four stories can start simultaneously after Foundational phase:
Story 1: T010 → T011 → T012  (splash_page.dart, ad_helper.dart verification)
Story 2: T013 → T014 → T015  (ad_gate_placeholder.dart, download_cubit.dart)
Story 3: T016 → T017 → T018  (wallpaper_detail_page.dart, ad_helper.dart verification)
Story 4: T019 → T020 → T021  (banner_ad_widget.dart, home_page.dart)
```

---

## Implementation Strategy

### MVP First (User Story 1 + User Story 2)

1. Complete Phase 1: Setup (env config)
2. Complete Phase 2: Foundational (AdHelper core)
3. Complete Phase 3: US1 — App Open ad works on splash
4. Complete Phase 4: US2 — Download gate works with Rewarded Interstitial
5. **STOP and VALIDATE**: Core monetization flow (app open + download gate) functional
6. Continue with US3, US4, Polish

### Incremental Delivery

1. Setup + Foundational → AdHelper compiles with 4 ad types
2. US1 (App Open) → Test independently → First ad revenue on cold start
3. US2 (Download Gate) → Test independently → Download monetization active
4. US3 (Favorite Gate) → Test independently → Favorite monetization active
5. US4 (Banner) → Test independently → Passive home revenue active
6. Polish → All cleanup, analytics verification, quickstart validation

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story independently testable after Phase 2 completion
- Commit after each phase or logical group
- Ad unit IDs are production values — test on physical device, not emulator
- The old `RewardedAd` / `showRewardedAd()` code is fully replaced — no backward compatibility needed
