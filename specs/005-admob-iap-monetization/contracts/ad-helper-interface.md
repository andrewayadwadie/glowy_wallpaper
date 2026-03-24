# Contract: AdHelper Singleton Interface

**Direction**: Internal (presentation layer → AdHelper → google_mobile_ads SDK)
**Pattern**: Centralized ad lifecycle manager per Constitution Principle VIII

## Public Interface

### Initialization

```
initialize()
  Called once during app startup (main.dart).
  Initializes MobileAds SDK and begins preloading ads.
```

### Ad Operations

```
loadBannerAd() → BannerAd?
  Returns a loaded banner ad for the Home screen.
  Returns null if user is premium or ad fails to load.
  Caller is responsible for disposal via disposeBannerAd().

disposeBannerAd()
  Disposes the current banner ad. Called when Home screen is left.

showAppOpenAd() → Future<bool>
  Shows the app-open ad if conditions are met:
    - User is free tier (checks SubscriptionCubit.shouldShowAds)
    - At least 4 hours since last show (checks Hive ad_frequency box)
    - Ad is loaded
  Returns true if ad was shown, false otherwise.
  Records show timestamp in Hive.

showRewardedAd({required String action}) → Future<bool>
  Shows a rewarded ad for gated actions (download, preview).
  Checks SubscriptionCubit.shouldShowAds first — returns true immediately for premium users.
  For free users:
    - If ad loaded: shows ad, returns true only if reward earned
    - If ad not loaded: returns false (caller shows "Ad unavailable" message)
  Auto-preloads next rewarded ad after consumption.
  Logs analytics event on show and reward.

shouldShowAds → bool
  Convenience getter. Reads SubscriptionCubit state.
```

### Lifecycle

```
dispose()
  Disposes all loaded ads. Called on app termination.
```

## Dependency Diagram

```
AdHelper
  ├── reads → SubscriptionCubit.shouldShowAds
  ├── reads/writes → Hive 'ad_frequency' box (last shown timestamp)
  ├── uses → google_mobile_ads (BannerAd, RewardedAd, AppOpenAd)
  ├── uses → FirebaseAnalytics (event logging)
  └── reads → Env (ad unit IDs per environment)
```

## Ad Unit IDs (from Env)

| Ad Type | Env Variable | Test ID (dev) | Production ID |
|---------|-------------|---------------|---------------|
| App Open | `ADMOB_APP_OPEN_ID` | Google test ID | TBD |
| Banner | `ADMOB_BANNER_ID` | Google test ID | TBD |
| Rewarded | `ADMOB_REWARDED_ID` | Google test ID | TBD |
