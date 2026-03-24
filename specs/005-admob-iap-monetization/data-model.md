# Data Model: Monetization — AdMob Ads & In-App Purchases

**Branch**: `005-admob-iap-monetization` | **Date**: 2026-03-24

## Entities

### SubscriptionEntity (extends existing)

The existing `SubscriptionCubit` manages `SubscriptionState` (guest/premium/loading). Phase 5 adds a persisted subscription record for cache and verification tracking.

| Field | Type | Description |
|-------|------|-------------|
| `status` | enum: `free`, `premium` | Current subscription tier |
| `productId` | String? | Store product ID (e.g., `premium_monthly`, `premium_yearly`) |
| `purchaseToken` | String? | Platform purchase token (Google) or transaction ID (Apple) |
| `verificationState` | enum: `verified`, `pending`, `unverified` | Server-side verification result |
| `expiryDate` | DateTime? | Subscription expiry; null for free users |
| `lastVerifiedAt` | DateTime? | Timestamp of last successful server verification |

**State transitions**:
```
free → pending (purchase completed, verification in flight)
pending → premium (server verification succeeds)
pending → premium (server unreachable — optimistic grant)
premium → free (subscription lapses on cold-start check)
premium → free (pending receipt re-verification fails on cold start)
premium → free (cache TTL exceeds 7 days without re-check)
```

**Validation rules**:
- `productId`, `purchaseToken`, `expiryDate` are non-null when `status == premium`
- `lastVerifiedAt` must be within 7 days for cached premium to be trusted offline
- `verificationState == pending` triggers silent re-verification on next cold start

---

### PremiumProductEntity

Retrieved live from the platform store at runtime. Not persisted.

| Field | Type | Description |
|-------|------|-------------|
| `productId` | String | Store product identifier |
| `title` | String | Display name (e.g., "Premium Monthly") |
| `price` | String | Formatted price with currency (e.g., "$4.99/mo") |
| `billingPeriod` | enum: `monthly`, `yearly` | Subscription duration |
| `rawPrice` | double | Numeric price for comparison/sorting |

**Validation rules**:
- Both a monthly and yearly product must be available for the Get Premium screen to render
- If only one product loads, show only that option with no plan selector

---

### AdUnitState (runtime only, not persisted)

Managed by `AdHelper` singleton. One instance per ad type.

| Field | Type | Description |
|-------|------|-------------|
| `type` | enum: `appOpen`, `banner`, `rewarded` | Ad format |
| `loadState` | enum: `idle`, `loading`, `loaded`, `failed` | Current load status |
| `lastShownAt` | DateTime? | For frequency cap (app-open: 4-hour minimum gap) |
| `adObject` | dynamic | Platform ad instance (BannerAd, RewardedAd, AppOpenAd) |

**Lifecycle rules**:
- Banner: loaded once when Home is entered, disposed when Home is left
- Rewarded: preloaded on app start and after each consumption
- App-open: loaded during splash, shown if eligible (free user + 4h gap), then disposed

---

### AnalyticsEvent (fire-and-forget, not persisted)

| Event Name | Trigger Point | Parameters |
|------------|---------------|------------|
| `ad_shown` | App-open or rewarded ad displayed | `ad_type`: `app_open` / `rewarded` |
| `reward_earned` | Rewarded ad completed successfully | `action`: `download` / `preview` |
| `purchase_initiated` | User taps "Subscribe Now" | `product_id`, `billing_period` |
| `purchase_succeeded` | Premium granted after verification | `product_id`, `verification_state` |
| `restore_succeeded` | Premium restored via Restore Purchase | `product_id` |

## Relationships

```
UserEntity (existing)
  └── has one → SubscriptionEntity (cached in Hive)
        └── references → PremiumProductEntity (runtime, from store)

SubscriptionCubit (existing)
  ├── reads → SubscriptionEntity (from Hive cache)
  ├── emits → SubscriptionState (guest / premium / loading)
  └── drives → AdHelper.shouldShowAds

AdHelper (new singleton)
  ├── manages → AdUnitState[appOpen]
  ├── manages → AdUnitState[banner]
  ├── manages → AdUnitState[rewarded]
  └── checks → SubscriptionCubit.shouldShowAds

WallpaperDetailCubit (existing)
  └── calls → AdHelper.showRewardedAd() before download/preview
```

## Hive Boxes

| Box Name | Purpose | Key | Value |
|----------|---------|-----|-------|
| `subscription_cache` (NEW) | Persisted subscription state | `'current'` | SubscriptionCacheModel (JSON) |
| `ad_frequency` (NEW) | App-open ad frequency cap tracking | `'last_app_open_shown'` | DateTime ISO string |
| `user_cache` (existing) | User data | userId | UserModel |
| `favorites` (existing) | Favorite wallpapers | wallpaperId | FavoriteModel |
| `downloads` (existing) | Download records | wallpaperId | DownloadRecordModel |
