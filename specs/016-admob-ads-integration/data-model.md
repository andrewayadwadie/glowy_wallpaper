# Phase 1 Data Model: AdMob Ads Integration

No persisted database/Hive schema changes. These are runtime/in-memory structures and value resolutions only.

---

## 1. AdPlacement (conceptual enum)

Identifies the four monetization surfaces. Drives ID resolution + analytics `placement` param.

| Value | Format | Trigger | Lifecycle |
|---|---|---|---|
| `rewardedDownload` | Rewarded | Download tap | single-use, preload + reload-after-show |
| `appOpen` | App Open | Post-splash + foreground resume | preloaded, 4h staleness, single-use |
| `homeBanner` | Anchored Adaptive Banner | Home visible | widget-owned, disposed on unmount |
| `categoryInterstitial` | Interstitial | Category switch | single-use, freq-capped, preload + reload |

Representation: a `dart enum AdPlacement` (in `ad_ids.dart` or `constants.dart`).

---

## 2. AdUnitResolution

Pure resolution of an ad unit id string. **Inputs**: `AdPlacement`, `kReleaseMode`, `Platform.isAndroid/isIOS`. **Output**: `String` unit id.

Rules:
- `!kReleaseMode` → Google test id for (placement, platform).
- `kReleaseMode && Android` → `Env.<placement>Id` (prod, from `.env.prod`).
- `kReleaseMode && iOS` → `Env.<placement>IosId` (prod iOS; currently test placeholder until supplied).

Validation: never returns empty; unknown placement is a compile-time-exhaustive `switch` (no `default`).

New `Env` fields (envied, regenerate with build_runner):
- `ADMOB_REWARDED_ID` (Android prod `…/6581955872`)
- `ADMOB_APP_OPEN_ID` (exists)
- `ADMOB_BANNER_ID` (exists)
- `ADMOB_INTERSTITIAL_ID` (exists)
- iOS variants (optional now): `ADMOB_*_IOS_ID` — default to test ids until real iOS units supplied.
- Obsolete: `ADMOB_REWARDED_INTERSTITIAL_ID` — remove if unreferenced after migration.

---

## 3. PremiumEntitlement (signal, not stored here)

Source of truth: `SubscriptionCubit` (`isPremium` / `shouldShowAds`). Mirrored into:

### AdGatekeeper
| Field | Type | Notes |
|---|---|---|
| `shouldShowAds` | `bool` | default `true`; set to `!isPremium` by app-root listener |

Behavior: every full-screen manager checks `gatekeeper.shouldShowAds` before showing; banner widget also short-circuits via bloc. When `false`: managers no-op the show and the gated user action proceeds normally.

---

## 4. FrequencyCooldownState (in-memory, per session)

Owned by `InterstitialAdManager`. Reset on app launch (manager construction). **Not persisted.**

| Field | Type | Initial | Rule |
|---|---|---|---|
| `_switchesSinceLastShow` | `int` | `0` | `++` on each category switch; reset to `0` after a show |
| `_lastShownAt` | `DateTime?` | `null` | set to `now` on show |
| `kSwitchCap` (N) | `const int` | `4` | show requires `_switchesSinceLastShow >= N` |
| `kCooldown` | `const Duration` | `60s` | show requires `_lastShownAt == null || now - _lastShownAt >= kCooldown` |

Show predicate: `shouldShowAds && adLoaded && switchesSinceLastShow >= N && cooldownElapsed`.

---

## 5. AppOpenState (in-memory)

Owned by `AppOpenAdManager`.

| Field | Type | Rule |
|---|---|---|
| `_appOpenAd` | `AppOpenAd?` | current preloaded ad |
| `_loadTime` | `DateTime?` | for 4h staleness |
| `_isShowingAd` | `bool` | guards stacked full-screen ads (FR-009) |
| `_isLoading` | `bool` | dedupe concurrent loads |
| `_lastShownAt` | `DateTime?` | resume cap ≥ 4 min (FR-010a) |
| `_appLaunchHandled` | `bool` | first foreground handled by splash, not resume |
| `kMaxCacheAge` | `const Duration` | `4h` |
| `kResumeCooldown` | `const Duration` | `4min` |

`isAdAvailable` = `_appOpenAd != null && now - _loadTime < kMaxCacheAge`.

---

## 6. RewardedState (in-memory)

Owned by `RewardedAdManager`.

| Field | Type | Rule |
|---|---|---|
| `_rewardedAd` | `RewardedAd?` | preloaded single-use |
| `_isLoading` | `bool` | dedupe loads |
| `kLoadTimeout` | `const Duration` | `5s` cold-start wait (R3) |

Outcome decision table:

| Event | Network-related? | Action |
|---|---|---|
| `onUserEarnedReward` | — | grant (download) |
| `onAdFailedToLoad` / load timeout | yes | grant (download) |
| `onAdFailedToLoad` / load timeout | no | `onDismissedWithoutReward` (no download) |
| `onAdFailedToShowFullScreenContent` | yes | grant |
| `onAdFailedToShowFullScreenContent` | no | `onDismissedWithoutReward` |
| `onAdDismissedFullScreenContent` w/o reward | — | `onDismissedWithoutReward` (no download) |

Always: dispose ad after show; reload fresh ad.

---

## 7. ConsentState (managed by UMP SDK)

Owned by `ConsentManager`; persistence handled by the Google UMP SDK (not app code).

| Concept | Source |
|---|---|
| consent status | `ConsentInformation.getConsentStatus()` |
| form available | `isConsentFormAvailable()` |
| can request ads | `canRequestAds()` |
| debug geography | `ConsentDebugSettings` (test devices) for FR-027 |

Flow state machine: `unknown → required → (form shown) → obtained|notRequired → adsRequestable`. Non-blocking: any error → proceed with `canRequestAds()` default.

---

## 8. AdNetworkError (pure helper)

`static bool isNetworkError(AdError error)`:
- `error.code == 2` → true (Android `ERROR_CODE_NETWORK_ERROR`).
- else lowercase(`error.message` + domain if present) contains any of `network`, `internet`, `connection`, `offline`, `timed out` → true.
- else false.

Unit-testable with fabricated `AdError`-like inputs (wrap in a small seam if `AdError` is not trivially constructible in tests).
