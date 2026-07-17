# Contract: AdHelper Singleton Interface

**Feature**: 010-admob-ad-units-setup | **Date**: 2026-03-27

## Public API

### Initialization

```
initialize() → Future<void>
  - Initializes MobileAds SDK
  - Preloads rewarded interstitial ad
  - Preloads interstitial ad
  - Non-blocking (swallows exceptions gracefully)
```

### App Open Ad

```
loadAppOpenAd() → Future<void>
  - Loads AppOpenAd using Env.adMobAppOpenId
  - Guards against concurrent loads
  - No frequency cap (shows every cold start)

showAppOpenAd() → Future<void>
  - Shows loaded AppOpenAd
  - No-op if ad not loaded or shouldShowAds == false
  - Logs analytics: ad_shown {ad_type: 'app_open'}
  - Disposes ad after show/dismiss/fail
```

### Rewarded Interstitial Ad (Download Gate)

```
preloadRewardedInterstitialAd() → Future<bool>
  - Loads RewardedInterstitialAd using Env.adMobRewardedInterstitialId
  - Returns true if loaded, false on failure
  - Guards against concurrent loads via _isRewardedInterstitialLoading
  - 10-second timeout on load

showRewardedInterstitialAd({required String action}) → Future<bool>
  - If shouldShowAds == false → returns true (premium bypass)
  - If no ad loaded → attempts preload (with 10-second timeout)
  - Shows ad with reward callback
  - Returns true if reward earned, false otherwise
  - Logs analytics: ad_shown {ad_type: 'rewarded_interstitial'}, reward_earned {action}
  - Auto-preloads next ad after dismiss
```

### Interstitial Ad (Favorite Gate)

```
preloadInterstitialAd() → Future<bool>
  - Loads InterstitialAd using Env.adMobInterstitialId
  - Returns true if loaded, false on failure
  - Guards against concurrent loads via _isInterstitialLoading

showInterstitialAd({required VoidCallback onComplete}) → Future<void>
  - If shouldShowAds == false → calls onComplete immediately (premium bypass)
  - If within 60-second cooldown → calls onComplete immediately (no ad)
  - If no ad loaded → calls onComplete immediately (non-blocking)
  - Shows ad, calls onComplete after dismiss
  - Updates _lastInterstitialShown timestamp
  - Logs analytics: ad_shown {ad_type: 'interstitial'}
  - Auto-preloads next ad after dismiss
```

### Banner Ad

```
loadBannerAd() → Future<void>
  - Loads BannerAd using Env.adMobBannerId
  - Disposes existing banner before loading new one
  - No-op if shouldShowAds == false

bannerAd → BannerAd? (getter)
  - Returns loaded banner ad instance for widget rendering

disposeBannerAd() → void
  - Disposes and nulls banner ad
```

### Lifecycle

```
dispose() → void
  - Disposes all loaded ads (banner, app open, rewarded interstitial, interstitial)
  - Nulls all references
```

## Behavior Rules

1. **Premium bypass**: When `shouldShowAds == false`, all show methods return immediately (true for reward-based, call onComplete for interstitial, skip for app-open/banner).
2. **Single full-screen**: Only one full-screen ad at a time. The `_isRewardedInterstitialLoading` and `_isInterstitialLoading` flags prevent overlapping loads.
3. **Auto-preload**: After every rewarded interstitial or interstitial dismiss, the next ad is preloaded automatically.
4. **Cooldown**: Interstitial ads enforce a 60-second in-memory cooldown (`_lastInterstitialShown`). Resets on app restart.
5. **Timeout**: On-demand loads enforce a 10-second timeout. If exceeded, treated as load failure.
6. **Analytics**: Every ad show logs `ad_shown` with type. Rewarded interstitial logs `reward_earned`. Load failures log `ad_failed`.

## Ad Unit ID Mapping

| Method | Env Variable | Production ID |
|--------|-------------|---------------|
| `loadAppOpenAd` | `Env.adMobAppOpenId` | `ca-app-pub-2083776520196762/2548207750` |
| `loadBannerAd` | `Env.adMobBannerId` | `ca-app-pub-2083776520196762/8536132654` |
| `preloadRewardedInterstitialAd` | `Env.adMobRewardedInterstitialId` | `ca-app-pub-2083776520196762/2641508848` |
| `preloadInterstitialAd` | `Env.adMobInterstitialId` | `ca-app-pub-2083776520196762/1519998865` |
