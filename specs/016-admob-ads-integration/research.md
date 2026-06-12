# Phase 0 Research: AdMob Ads Integration

All spec `[NEEDS CLARIFICATION]` markers were resolved during `/speckit.clarify`. The items below resolve **technical** unknowns needed for design.

---

## R1 — Download gate: migrate RewardedInterstitial → Rewarded

**Decision**: Use the **Rewarded** format (`RewardedAd`) for the download gate, with a new prod unit `ca-app-pub-2083776520196762/6581955872` (Android). Remove the existing `RewardedInterstitialAd` download wiring in `AdHelper` + `download_cubit.dart`.

**Rationale**: Spec FR-006 mandates a single rewarded placement and removal of old wiring. `RewardedAd` and `RewardedInterstitialAd` share near-identical APIs (`load`, `show(onUserEarnedReward:)`, `fullScreenContentCallback`), so migration is mechanical. The semantic difference the spec wants — *grant only on earned reward, except network failure* — is identical for both formats; format choice follows the provided ad unit (it is a Rewarded unit).

**Alternatives considered**: Keep RewardedInterstitial — rejected: contradicts FR-006 and the supplied prod unit is a Rewarded unit; mixing would leave dead code.

---

## R2 — Network-error classification (graceful degradation)

**Decision**: A pure helper `AdNetworkError.isNetworkError(AdError error)`:
- Android: `error.code == 2` (`ERROR_CODE_NETWORK_ERROR`).
- iOS: treat code `2` as network too, AND fall back to substring match on `error.domain`/`error.message` containing `network`/`internet`/`connection` (case-insensitive), since iOS GAD error codes differ.
- Applies to both `LoadAdError` (load failure) and the `AdError` in `onAdFailedToShowFullScreenContent`.

On a classified network error in the rewarded flow → invoke `onRewardGranted` (download proceeds). On a **non-network** failure or early dismissal without reward → do NOT grant.

**Rationale**: Spec FR-002/FR-004 + prompt's explicit Android code==2 rule; the domain/message fallback covers iOS where numeric codes are unreliable. Keeping it a pure function makes it unit-testable without the SDK (constitution VII).

**Alternatives considered**: Trust only numeric code — rejected: misses iOS. Treat *all* failures as network (always grant) — rejected: violates FR-004 (early dismiss must not download).

---

## R3 — Cold-start bounded wait (no ad ready at tap)

**Decision**: When `showRewardedForDownload` is called and no ad is loaded, attempt a load with a **~5s timeout** (tunable const). While waiting, presentation shows a `loader_overlay` + `flutter_spinkit` overlay. On timeout/failure: if network-related (or offline) → grant + download; otherwise → invoke `onDismissedWithoutReward` (no download). The download cubit already pre-checks `NetworkInfo.isConnected` and shows `networkUnavailable` when truly offline, so the timeout path mainly covers slow-fill.

**Rationale**: Clarification Q3 (≈5s + indicator). Bounds the wait (FR-003), reuses constitution-approved overlay packages (Principle V), never traps the user (SC-001/002).

**Alternatives considered**: 10s (old `AdHelper` value) — rejected: worse UX, Q3 chose ~5s. No wait/no spinner — rejected: Q3 chose an indicator.

---

## R4 — Anchored adaptive banner sizing + slot reservation

**Decision**: `AnchoredAdaptiveBanner` (StatefulWidget) computes size via
`await AdSize.getAnchoredAdaptiveBannerAdSize(Orientation.portrait, MediaQuery.of(context).size.width.truncate())`.
It owns its `BannerAd`, loads on init, and:
- While size is resolving / loading: reserve a slot using a fallback height constant `AppDimens.bannerSlotFallbackHeight` (≈50–60) so layout doesn't jump.
- On load success: size the slot to the resolved `AdSize.height`.
- On load failure (after one retry): return `SizedBox.shrink()` (slot collapses; FR-012).
- Embedded as Home `bottomNavigationBar` (current pattern) so it never overlaps the grid (FR-011).
- `dispose()` disposes the `BannerAd` (FR-013, Principle VI).

**Rationale**: Spec FR-011/012/013; adaptive sizing is the modern AdMob recommendation over fixed 320×50. Reusing `bottomNavigationBar` keeps the grid above it with zero overlap. Premium check via `BlocBuilder<SubscriptionCubit>` returning `shrink()` (mirrors existing `BannerAdWidget`).

**Alternatives considered**: Fixed `AdSize.banner` (current `BannerAdWidget`) — rejected by FR-011. `Stack` overlay on grid — rejected: risks covering content (SC-004).

---

## R5 — Google UMP consent flow + init ordering

**Decision**: `ConsentManager` (using `ConsentInformation.instance` / `ConsentForm`, shipped inside `google_mobile_ads`):
1. `AdsInitializer.initialize()` runs in `main()` before `runApp`.
2. Order: `requestConsentInfoUpdate(params)` → if a form is available & required, `loadAndShowConsentFormIfRequired()` → then `MobileAds.instance.initialize()` → then preload rewarded/interstitial/app-open.
3. A debug/forced-geography option (`ConsentDebugSettings`, test device ids) makes the prompt testable outside the EEA (FR-027).
4. Failure to gather consent (offline / not required) must not block launch (FR-026) — proceed and let AdMob serve the personalization level consent permits.

**Rationale**: Spec FR-025–027. UMP is bundled in `google_mobile_ads` (no new dependency). Google's documented sequence is consent-before-ad-load. Non-blocking on failure satisfies FR-026 and constitution V (no silent crash, app proceeds).

**Alternatives considered**: Separate `app_tracking_transparency` package — not required for UMP; iOS ATT string is still added to Info.plist for completeness. Skipping consent — rejected (Clarification: consent in scope).

---

## R6 — Test vs prod ID resolution without flavors

**Decision**: `AdIds` resolves per format using `kReleaseMode` + `Platform`:
- `kReleaseMode == false` (debug/profile) → Google **test** unit IDs (public constants in `ad_ids.dart`), per platform.
- `kReleaseMode == true` → **prod** IDs: Android from `Env` (envied `.env.prod`), iOS from new `Env` fields (test IDs as placeholder until real iOS units supplied).
- App ID is configured natively (manifest/plist), not via `AdIds`.

Test unit IDs (public, safe to hardcode in `ad_ids.dart`):

| Format | Android test | iOS test |
|---|---|---|
| Rewarded | `ca-app-pub-3940256099942544/5224354917` | `ca-app-pub-3940256099942544/1712485313` |
| App Open | `ca-app-pub-3940256099942544/9257395921` | `ca-app-pub-3940256099942544/5575463023` |
| Banner | `ca-app-pub-3940256099942544/6300978111` | `ca-app-pub-3940256099942544/2934735716` |
| Interstitial | `ca-app-pub-3940256099942544/1033173712` | `ca-app-pub-3940256099942544/4411468910` |

Prod Android IDs (into `.env.prod` via envied): Rewarded `…/6581955872`, App Open `…/2548207750`, Banner `…/8536132654`, Interstitial `…/1519998865` (publisher `ca-app-pub-2083776520196762`). New env field `ADMOB_REWARDED_ID` added; obsolete `ADMOB_REWARDED_INTERSTITIAL_ID` retained only if still referenced elsewhere, else removed.

**Rationale**: Repo has no flavors/`main_*` (verified) — build mode is the only reliable signal. Test IDs are Google-published constants, so hardcoding them in one dedicated file does not violate "no hardcoded config" (they are not secrets/env-specific). FR-019/020.

**Alternatives considered**: Introduce dev/staging/prod flavors + `main_*.dart` now — rejected: large refactor outside this feature's scope; build-mode achieves FR-019. Can be a future migration.

---

## R7 — App-open: post-splash show + foreground-resume show

**Decision**: `AppOpenAdManager`:
- `loadAd()` stores ad + `DateTime` load time; `_isAdAvailable` ⇒ ad != null AND age < 4h (FR-008).
- `showIfAvailable()` used by splash: shows only if available & `!_isShowingAd` (FR-007/009); on dismiss/fail → null + reload (FR-010).
- Resume: a `WidgetsBindingObserver`/`AppLifecycleListener` (registered by a small app-root widget, removed on dispose) calls `showIfAvailable()` on `resumed`, gated by an in-memory `_lastShown` timestamp ≥ 4 min (FR-010a) and `AdGatekeeper.shouldShowAds`. Cold-start's first foreground is owned by the splash show, not resume (guard with an `_appLaunchHandled` flag).

**Rationale**: Spec US2 + Clarification Q2 (post-splash + resume, ≥4-min cap). The current code calls `AdHelper.showAppOpenAd()` in splash but never preloads it, so it never shows — the new manager fixes load+show+resume.

**Alternatives considered**: Show on every resume — rejected (Q2 cap). Post-splash only — rejected (Q2 chose resume too).

---

## R8 — Category interstitial trigger without ad logic in HomeCubit

**Decision**: `HomePage` adds a `BlocListener<HomeCubit, HomeState>` with
`listenWhen: (prev, cur) => prev.selectedCategoryIndex != cur.selectedCategoryIndex && cur.categoriesStatus == Status.success`,
calling `interstitialAdManager.onCategorySwitched()`. The manager owns the frequency cap (default N=4 switches) + cooldown (≥60s) + load/show/reload. `HomeCubit.selectCategory` is unchanged (no ad code — constitution I/VIII intent).

**Rationale**: Spec FR-014–017; keeps Cubit pure. `selectedCategoryIndex` is already emitted. `listenWhen` excludes the initial `selectCategory(0)` from `loadAppData` by also requiring a *change* from the previous index (initial transitions from default 0→0 won't fire; first real user tap fires).

Edge: the very first `loadAppData` sets `selectedCategoryIndex: 0` from default `0` → no change → no fire. Good. User taps drive subsequent changes.

**Alternatives considered**: Trigger in `CategorySelector.onCategorySelected` callback — viable but a `BlocListener` on state is the spec's recommended hook and survives programmatic selection. Putting cap logic in Cubit — rejected (ad logic leak).

---

## R9 — Frequency/cooldown state: in-memory per session

**Decision** (Clarification Q1): `InterstitialAdManager` holds `int _switchesSinceLastShow` and `DateTime? _lastShownAt` as plain fields, reset on process start (manager is a lazy singleton constructed per app launch). No Hive. Show when `_switchesSinceLastShow >= N` AND (`_lastShownAt == null` OR `now - _lastShownAt >= 60s`) AND an ad is loaded AND `shouldShowAds`. The existing `ad_frequency` Hive box is left to legacy code and not used here.

**Rationale**: Q1 chose in-memory/per-session; simplest, no persistence, matches "Frequency/Cooldown State" entity. Unit-testable by injecting a clock or exposing setters (mirrors `AdHelper`'s `@visibleForTesting` cooldown setter).

---

## R10 — Premium gating source

**Decision**: Single `AdGatekeeper` holding `bool shouldShowAds` (default true), updated by an app-root listener on `SubscriptionCubit` (`shouldShowAds = !isPremium`). Full-screen managers check `AdGatekeeper.shouldShowAds` before showing; the banner widget additionally short-circuits via `BlocBuilder<SubscriptionCubit>`. Presentation entry points that already have context (HomePage, splash) may also check `isPremium` directly.

**Rationale**: Mirrors the existing `AdHelper.shouldShowAds` flag and `SubscriptionCubit.shouldShowAds` getter, giving managers (which lack `BuildContext`) a context-free premium signal. Satisfies FR-018 + constitution VIII (premium ⇒ zero ads). Avoids each manager depending on bloc.

**Alternatives considered**: Inject `SubscriptionCubit` into every manager — rejected: couples singletons to a factory-scoped cubit lifecycle. Pass `isPremium` into every call — workable but noisier; gatekeeper centralizes it.

---

## R11 — Logging/observability

**Decision**: Use `FirebaseAnalytics` for the required lifecycle **events** (`ad_shown`, `ad_failed`, `reward_earned`, `ad_dismissed` with an `ad_type`/`placement` param — names centralized in `constants.dart`) and `debugPrint` for developer logs. Do **not** add the `logger` package.

**Rationale**: Constitution VIII *requires* analytics for ad views; the repo already logs ad events via `FirebaseAnalytics` and dev lines via `debugPrint`. Adding `logger` would duplicate concerns and diverge from the codebase. Prompt's "logger" is satisfied in spirit by structured analytics + debugPrint. (Documented deviation in plan.)

---

## Summary of decisions

| # | Topic | Decision |
|---|---|---|
| R1 | Download format | Rewarded (replace RewardedInterstitial) |
| R2 | Network error | Pure `isNetworkError` (Android code 2 / iOS domain+code) |
| R3 | Cold-start wait | ~5s timeout + spinkit overlay, then network⇒grant |
| R4 | Banner | Anchored adaptive, self-disposing, collapses on fail |
| R5 | Consent | UMP (bundled), consent-before-init, non-blocking |
| R6 | ID resolution | `kReleaseMode` + `Platform`; test ids constant, prod via envied |
| R7 | App-open | Post-splash + resume (≥4-min cap), 4h staleness |
| R8 | Interstitial trigger | `BlocListener` on `selectedCategoryIndex`, Cubit stays pure |
| R9 | Freq/cooldown | In-memory per session (N=4, ≥60s) |
| R10 | Premium gate | `AdGatekeeper` synced from `SubscriptionCubit` |
| R11 | Logging | FirebaseAnalytics events + debugPrint (no `logger`) |
