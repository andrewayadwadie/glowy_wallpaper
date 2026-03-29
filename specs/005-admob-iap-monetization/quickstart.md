# Quickstart: Monetization — AdMob Ads & In-App Purchases

**Branch**: `005-admob-iap-monetization` | **Date**: 2026-03-24

## Prerequisites

1. **Google Play Console**: Two subscription products created (`premium_monthly`, `premium_yearly`)
2. **App Store Connect**: Two auto-renewable subscription products with matching IDs
3. **Backend**: `POST /subscription/verify` and `GET /subscription/status` endpoints deployed
4. **AdMob Console**: Three ad units created (app-open, banner, rewarded) with unit IDs

## Environment Setup

Add to `.env.dev`, `.env.staging`, `.env.prod`:

```
ADMOB_BANNER_ID=ca-app-pub-3940256099942544/6300978111          # test ID for dev
ADMOB_REWARDED_ID=ca-app-pub-3940256099942544/5224354917        # test ID for dev
ADMOB_APP_OPEN_ID=ca-app-pub-3940256099942544/9257395921        # test ID for dev
IAP_MONTHLY_PRODUCT_ID=premium_monthly
IAP_YEARLY_PRODUCT_ID=premium_yearly
```

## New Dependency

Add to `pubspec.yaml`:

```yaml
dependencies:
  in_app_purchase: ^3.2.0
```

## New Hive Boxes

Open in `main.dart` during initialization:

```
await Hive.openBox('subscription_cache');
await Hive.openBox('ad_frequency');
```

## Key Files to Create

```
lib/
├── core/
│   ├── services/
│   │   └── ad_helper.dart                    # Centralized ad singleton
│   └── config/
│       └── env.dart                          # Add new ad unit ID fields
├── features/
│   └── premium/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── subscription_entity.dart
│       │   │   └── premium_product_entity.dart
│       │   ├── repositories/
│       │   │   └── premium_repository.dart   # Contract
│       │   └── usecases/
│       │       ├── get_products.dart
│       │       ├── purchase_premium.dart
│       │       ├── restore_purchases.dart
│       │       └── get_subscription_status.dart
│       ├── data/
│       │   ├── models/
│       │   │   ├── subscription_cache_model.dart
│       │   │   └── premium_product_model.dart
│       │   ├── datasources/
│       │   │   ├── iap_data_source.dart      # in_app_purchase wrapper
│       │   │   ├── premium_remote_source.dart # Retrofit verify/status
│       │   │   └── premium_local_source.dart  # Hive subscription cache
│       │   └── repositories/
│       │       └── premium_repository_impl.dart
│       └── presentation/
│           ├── cubit/
│           │   └── premium_cubit.dart
│           ├── pages/
│           │   └── get_premium_page.dart
│           └── widgets/
│               ├── plan_card_widget.dart
│               └── feature_comparison_widget.dart
```

## Key Files to Modify

```
lib/main.dart                                  # Open new Hive boxes
lib/core/config/env.dart                       # Add ad unit ID + IAP product ID fields
lib/core/di/injection_container.dart           # Register AdHelper, IAP, Premium deps
lib/core/widgets/ad_gate_placeholder.dart      # Replace with real rewarded ad gate
lib/features/splash/presentation/pages/splash_page.dart  # Add app-open ad
lib/features/home/presentation/pages/home_page.dart      # Replace banner placeholder
lib/features/auth/presentation/cubit/subscription_cubit.dart  # Wire IAP state
```

## Verification Steps

1. Cold-start app as free user → app-open ad shows (first time), banner on Home
2. Tap Download → rewarded ad plays → download proceeds after reward
3. Tap Preview → rewarded ad plays → preview opens after reward
4. Open Get Premium → monthly and yearly prices display from store
5. Subscribe → payment sheet → premium granted → all ads disappear
6. Kill + reopen → no ads shown, downloads/previews work freely
7. Fresh install → Restore Purchase → premium restored
8. Wait 4h, cold-start again → app-open ad reappears (frequency cap)
