# Research: AdMob Ad Units Integration

**Feature**: 010-admob-ad-units-setup | **Date**: 2026-03-27

## R1: RewardedInterstitialAd vs RewardedAd in google_mobile_ads

**Decision**: Replace existing `RewardedAd` with `RewardedInterstitialAd` for the download gate.

**Rationale**: The user explicitly specified "Rewarded Interstitial" format for the download ad unit (`ca-app-pub-2083776520196762/2641508848`). `RewardedInterstitialAd` is a distinct class in `google_mobile_ads` that combines interstitial presentation with reward mechanics — users can earn rewards but the ad can also appear without requiring explicit opt-in (unlike `RewardedAd` which shows a "Watch ad to continue" prompt).

**Alternatives considered**:
- Keep `RewardedAd`: Rejected — the AdMob console ad unit is configured as Rewarded Interstitial format, using `RewardedAd` class would cause a format mismatch and load failures.

**Implementation notes**:
- `RewardedInterstitialAd.load()` static method (same pattern as `RewardedAd.load()`)
- Callback: `RewardedInterstitialAdLoadCallback` (not `RewardedAdLoadCallback`)
- Show: `ad.show(onUserEarnedReward: (ad, reward) => ...)` — same reward callback API
- The existing `preloadRewardedAd()` / `showRewardedAd()` methods in AdHelper need renaming and class swap

---

## R2: InterstitialAd for Favorite Gate (Non-Blocking Pattern)

**Decision**: Add `InterstitialAd` support to AdHelper with a non-blocking gate pattern.

**Rationale**: The favorite gate uses a standard Interstitial — no reward is involved. The action (add favorite) proceeds after the ad is dismissed, regardless of how the user interacts with the ad. This is fundamentally different from the download gate where the reward callback controls whether the action proceeds.

**Alternatives considered**:
- Reuse `adGatePlaceholder` with a "always proceed" flag: Viable but adds complexity to the existing blocking gate function. Better to have a separate method.
- Show interstitial directly without a helper: Rejected — violates constitution VIII (all ad operations through AdHelper).

**Implementation notes**:
- `InterstitialAd.load()` static method
- `FullScreenContentCallback` for show/dismiss/fail events
- On dismiss → execute the pending action (add favorite)
- On fail to load → execute the pending action immediately (non-blocking)
- 60-second cooldown tracked via in-memory `DateTime? _lastInterstitialShown` field in AdHelper

---

## R3: Banner Ad Real Rendering (Current Widget is Placeholder)

**Decision**: Replace the mock `BannerAdWidget` with a real AdMob `BannerAd` rendered via `AdWidget`.

**Rationale**: Current `BannerAdWidget` displays static placeholder text — it never calls `AdHelper.loadBannerAd()` or renders an `AdWidget`. The `AdHelper` already has `loadBannerAd()` implemented; the widget just needs to connect to it.

**Alternatives considered**:
- Keep placeholder for development: Rejected — this feature is specifically about production ad integration.

**Implementation notes**:
- `AdHelper.loadBannerAd()` already creates a `BannerAd` instance with correct size
- Widget should call `loadBannerAd()` on init and access `AdHelper.bannerAd`
- Render via `AdWidget(ad: bannerAd)` wrapped in a `SizedBox(height: AdSize.banner.height)`
- On load failure: return `SizedBox.shrink()` (collapse gracefully)
- Dispose banner on widget dispose

---

## R4: Production Ad Unit ID Configuration

**Decision**: Update `.env.dev` and `env.dart` with production ad unit IDs. Add two new env variables for Rewarded Interstitial and Interstitial.

**Rationale**: Current env config defines 3 ad unit IDs (banner, rewarded, app_open) using Google test IDs. This feature adds 2 new formats (rewarded interstitial, interstitial) and replaces all IDs with production values.

**Production Ad Unit IDs**:

| Format | Unit Name | Unit ID | Env Variable |
|--------|-----------|---------|-------------|
| App Open | splash | `ca-app-pub-2083776520196762/2548207750` | `ADMOB_APP_OPEN_ID` |
| Rewarded Interstitial | download ad | `ca-app-pub-2083776520196762/2641508848` | `ADMOB_REWARDED_INTERSTITIAL_ID` (new) |
| Interstitial | favorite | `ca-app-pub-2083776520196762/1519998865` | `ADMOB_INTERSTITIAL_ID` (new) |
| Banner | banner | `ca-app-pub-2083776520196762/8536132654` | `ADMOB_BANNER_ID` |

**Implementation notes**:
- Add `ADMOB_REWARDED_INTERSTITIAL_ID` and `ADMOB_INTERSTITIAL_ID` to `.env.dev`
- Add corresponding fields to `Env` class in `env.dart`
- Run `dart run build_runner build` to regenerate `env.g.dart`
- Remove old `ADMOB_REWARDED_ID` (replaced by rewarded interstitial)

---

## R5: App Open Ad — No Frequency Cap

**Decision**: Remove the existing 4-hour frequency cap from the 005 implementation. Show App Open ad on every cold start.

**Rationale**: User explicitly clarified during `/speckit.clarify` that the App Open ad should show on every cold start with no frequency cap.

**Implementation notes**:
- Remove the `canShowAppOpenAd()` check in `PremiumLocalSource`
- Remove `last_app_open_shown` timestamp tracking from `ad_frequency` Hive box
- Simplify splash page: always load and show app open ad for free users
- The `ad_frequency` box may still be needed for the 60-second interstitial cooldown (or use in-memory tracking instead)

---

## R6: Preview Ad Gate Removal

**Decision**: Remove the existing rewarded ad gate from the preview (phone frame) action.

**Rationale**: User clarified during `/speckit.clarify` that preview should be free for all users. The current codebase already has no ad gate on preview (it was never implemented despite being in the 005 spec), so this is a no-op — just ensure no gate is accidentally added.

**Implementation notes**:
- Verify `wallpaper_detail_page.dart` preview callback has no `adGatePlaceholder` call (currently confirmed: it doesn't)
- No code changes needed for removal — just a spec alignment confirmation

---

## R7: Interstitial 60-Second Cooldown Mechanism

**Decision**: Track interstitial cooldown in-memory using a `DateTime` field in `AdHelper`, not in Hive.

**Rationale**: The 60-second cooldown is a session-level concern — it resets on app restart. Persisting to Hive would unnecessarily survive across sessions and add I/O overhead for a simple timestamp check.

**Alternatives considered**:
- Hive-based tracking (like the old app-open frequency cap): Rejected — overkill for a 60-second window that should reset per session.
- Cooldown in the Cubit: Rejected — violates constitution VIII (ad logic centralized in AdHelper).

**Implementation notes**:
- Add `DateTime? _lastInterstitialShown` field to `AdHelper`
- Before showing interstitial: check if `DateTime.now().difference(_lastInterstitialShown!) < Duration(seconds: 60)`
- If within cooldown: return immediately (action proceeds without ad)
- Update `_lastInterstitialShown` after each successful interstitial show

---

## R8: AdHelper Enum Update

**Decision**: Update the `AdType` enum from `{ appOpen, banner, rewarded }` to `{ appOpen, banner, rewardedInterstitial, interstitial }`.

**Rationale**: The enum must reflect the actual ad formats in use. The old `rewarded` type is replaced by `rewardedInterstitial`, and `interstitial` is a new type.

**Implementation notes**:
- Update enum definition
- Update all references (analytics event parameters use the enum name)
- Ensure analytics events use descriptive type strings: `'app_open'`, `'banner'`, `'rewarded_interstitial'`, `'interstitial'`
