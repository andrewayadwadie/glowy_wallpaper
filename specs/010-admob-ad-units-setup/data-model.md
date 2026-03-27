# Data Model: AdMob Ad Units Integration

**Feature**: 010-admob-ad-units-setup | **Date**: 2026-03-27

## Entities

### AdType (Enum — updated)

Replaces the existing `AdType` enum in `ad_helper.dart`.

| Value | Description | Ad Class |
|-------|-------------|----------|
| `appOpen` | Full-screen ad shown on cold start | `AppOpenAd` |
| `banner` | Persistent banner at Home bottom | `BannerAd` |
| `rewardedInterstitial` | Reward-gated ad for downloads | `RewardedInterstitialAd` |
| `interstitial` | Non-blocking ad before add-favorite | `InterstitialAd` |

**Removed**: `rewarded` (replaced by `rewardedInterstitial`)

### AdHelper (Singleton — updated fields)

| Field | Type | Description |
|-------|------|-------------|
| `_bannerAd` | `BannerAd?` | Loaded banner ad instance |
| `_appOpenAd` | `AppOpenAd?` | Loaded app-open ad instance |
| `_rewardedInterstitialAd` | `RewardedInterstitialAd?` | Loaded rewarded interstitial instance (was `_rewardedAd: RewardedAd?`) |
| `_interstitialAd` | `InterstitialAd?` | **NEW** — Loaded interstitial instance |
| `_lastInterstitialShown` | `DateTime?` | **NEW** — Timestamp of last interstitial display (60s cooldown) |
| `_isInitialized` | `bool` | SDK initialization flag |
| `_isRewardedInterstitialLoading` | `bool` | Loading guard for rewarded interstitial (was `_isAdLoading`) |
| `_isInterstitialLoading` | `bool` | **NEW** — Loading guard for interstitial |
| `shouldShowAds` | `bool` | Master flag tied to subscription status |

### Ad Unit Configuration (Env — updated)

| Env Variable | Value | Format |
|-------------|-------|--------|
| `ADMOB_APP_ID` | `ca-app-pub-2083776520196762~1431087691` | App ID (unchanged) |
| `ADMOB_APP_OPEN_ID` | `ca-app-pub-2083776520196762/2548207750` | App Open |
| `ADMOB_BANNER_ID` | `ca-app-pub-2083776520196762/8536132654` | Banner |
| `ADMOB_REWARDED_INTERSTITIAL_ID` | `ca-app-pub-2083776520196762/2641508848` | Rewarded Interstitial (**NEW**) |
| `ADMOB_INTERSTITIAL_ID` | `ca-app-pub-2083776520196762/1519998865` | Interstitial (**NEW**) |

**Removed**: `ADMOB_REWARDED_ID` (replaced by `ADMOB_REWARDED_INTERSTITIAL_ID`)

## State Transitions

### Rewarded Interstitial Ad (Download Gate — Blocking)

```
idle → loading → loaded → showing → dismissed
                                      ├── reward_earned → proceed (download starts)
                                      └── no_reward → blocked (user informed)
       loading → failed → blocked (user informed, "ad unavailable")
       loading → timeout (10s) → failed
```

### Interstitial Ad (Favorite Gate — Non-Blocking)

```
idle → loading → loaded → showing → dismissed → proceed (favorite added)
       loading → failed → proceed (favorite added immediately, no ad)
       cooldown_active → proceed (favorite added immediately, no ad)
```

### App Open Ad (Splash — Every Cold Start)

```
idle → loading → loaded → showing → dismissed → navigate to Home
       loading → failed → navigate to Home (no delay)
```

### Banner Ad (Home — Persistent)

```
idle → loading → loaded → visible (rendered via AdWidget)
       loading → failed → collapsed (SizedBox.shrink)
       visible → disposed (on navigate away from Home)
```

## Relationships

- `AdHelper` manages all 4 ad types as a singleton (constitution VIII)
- `SubscriptionCubit.isPremium` → controls `AdHelper.shouldShowAds`
- `adGatePlaceholder` → calls `AdHelper.showRewardedInterstitialAd()` for downloads
- `AdHelper.showInterstitialAd()` → called directly from wallpaper detail page for favorites
- `BannerAdWidget` → reads `AdHelper.bannerAd` for rendering
- `Env` → provides all ad unit IDs to `AdHelper`
- `FirebaseAnalytics` → receives `ad_shown`, `reward_earned`, `ad_failed` events from `AdHelper`
