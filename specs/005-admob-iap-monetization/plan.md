# Implementation Plan: Monetization — AdMob Ads & In-App Purchases

**Branch**: `005-admob-iap-monetization` | **Date**: 2026-03-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-admob-iap-monetization/spec.md`

## Summary

Integrate three AdMob ad formats (app-open, banner, rewarded) and native in-app subscription purchases (Google Play Billing + StoreKit) into the existing Glowy Wallpapers app. Free users see ads and pass through rewarded gates for downloads/previews; premium subscribers enjoy an ad-free experience. Purchases are verified server-side with optimistic granting on verification failure. A centralized `AdHelper` singleton manages all ad lifecycle. The existing `SubscriptionCubit` is extended with IAP purchase state and local cache with 7-day TTL.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: google_mobile_ads ^5.3.0 (existing), in_app_purchase ^3.2.0 (NEW), flutter_bloc, freezed, injectable + get_it, dio + retrofit, firebase_analytics (existing)
**Storage**: Hive (subscription_cache box, ad_frequency box — NEW), flutter_secure_storage (auth tokens — existing)
**Testing**: mocktail, bloc_test (existing)
**Target Platform**: Android (min SDK 21) + iOS (min 15.0)
**Project Type**: Mobile app (Flutter cross-platform)
**Performance Goals**: Ad load < 3s, Get Premium price fetch < 3s, purchase flow responsive (no UI blocking)
**Constraints**: Offline-capable (7-day premium cache TTL), app-open ad frequency cap (4h minimum gap), no main-thread blocking during ad loads
**Scale/Scope**: 3 ad types, 2 IAP products, 1 new feature module (premium), 5 analytics events, ~15 new/modified files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture — Feature-First | PASS | New `premium` feature follows domain/data/presentation layers |
| II. SOLID & DRY — No Duplication | PASS | Centralized AdHelper, constants for ad IDs, shared use cases |
| III. Responsive-First with ScreenUtil | PASS | Get Premium page uses ScreenUtil for all dimensions |
| IV. Theming — Light & Dark | PASS | Get Premium and ad widgets use Theme.of(context) |
| V. Error Handling — dartz Either | PASS | All repository methods return Either<Failure, T>; four-state pattern on Get Premium page |
| VI. Performance | PASS | Ad loads are async, no main-thread blocking, proper disposal in close() |
| VII. Testing — Unit Tests Required | PASS | Unit tests for PremiumCubit, PremiumRepositoryImpl, AdHelper |
| VIII. Monetization & Firebase | PASS | AdHelper singleton per mandate; `shouldShowAds` drives visibility; Firebase Analytics events logged |
| Package: Payments | VIOLATION | Constitution lists `flutter_stripe`; using `in_app_purchase` instead — see Complexity Tracking |

**Post-Phase 1 Re-check**: All principles still pass. The `in_app_purchase` deviation is documented and justified.

## Project Structure

### Documentation (this feature)

```text
specs/005-admob-iap-monetization/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0: research decisions
├── data-model.md        # Phase 1: entities, state transitions, Hive boxes
├── quickstart.md        # Phase 1: setup and verification steps
├── contracts/
│   ├── subscription-verify.md   # Backend API contract
│   ├── ad-helper-interface.md   # AdHelper singleton interface
│   └── iap-interface.md         # IAP purchase/restore flow contract
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── services/
│   │   └── ad_helper.dart                         # NEW — centralized ad singleton
│   ├── config/
│   │   └── env.dart                               # MODIFY — add ad unit IDs + IAP product IDs
│   ├── di/
│   │   └── injection_container.dart               # MODIFY — register AdHelper, IAP, Premium deps
│   ├── widgets/
│   │   ├── ad_gate_placeholder.dart               # MODIFY → real rewarded ad gate
│   │   └── banner_ad_widget.dart                  # NEW — reusable banner ad widget
│   └── utils/
│       └── app_strings.dart                       # MODIFY — add premium page strings
├── features/
│   ├── premium/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── subscription_entity.dart       # NEW
│   │   │   │   └── premium_product_entity.dart    # NEW
│   │   │   ├── repositories/
│   │   │   │   └── premium_repository.dart        # NEW — contract
│   │   │   └── usecases/
│   │   │       ├── get_products.dart              # NEW
│   │   │       ├── purchase_premium.dart          # NEW
│   │   │       ├── restore_purchases.dart         # NEW
│   │   │       └── get_subscription_status.dart   # NEW
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── subscription_cache_model.dart  # NEW — Freezed, Hive adapter
│   │   │   │   └── premium_product_model.dart     # NEW — Freezed
│   │   │   ├── datasources/
│   │   │   │   ├── iap_data_source.dart           # NEW — in_app_purchase wrapper
│   │   │   │   ├── premium_remote_source.dart     # NEW — Retrofit verify/status
│   │   │   │   └── premium_local_source.dart      # NEW — Hive subscription cache
│   │   │   └── repositories/
│   │   │       └── premium_repository_impl.dart   # NEW
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── premium_cubit.dart             # NEW
│   │       │   └── premium_state.dart             # NEW — Freezed
│   │       ├── pages/
│   │       │   └── get_premium_page.dart          # NEW
│   │       └── widgets/
│   │           ├── plan_card_widget.dart           # NEW — monthly/yearly card
│   │           └── feature_comparison_widget.dart  # NEW — Free vs Premium table
│   ├── splash/
│   │   └── presentation/pages/
│   │       └── splash_page.dart                   # MODIFY — add app-open ad
│   ├── home/
│   │   └── presentation/pages/
│   │       └── home_page.dart                     # MODIFY — replace banner placeholder
│   ├── auth/
│   │   └── presentation/cubit/
│   │       └── subscription_cubit.dart            # MODIFY — wire IAP state updates
│   └── wallpaper_detail/
│       └── presentation/
│           └── pages/
│               └── wallpaper_detail_page.dart     # MODIFY — wire rewarded ad for preview
└── main.dart                                      # MODIFY — open new Hive boxes

test/
└── features/
    └── premium/
        ├── domain/usecases/
        │   ├── get_products_test.dart
        │   ├── purchase_premium_test.dart
        │   ├── restore_purchases_test.dart
        │   └── get_subscription_status_test.dart
        ├── data/repositories/
        │   └── premium_repository_impl_test.dart
        └── presentation/cubit/
            └── premium_cubit_test.dart
```

**Structure Decision**: Follows the existing feature-first Clean Architecture pattern. The `premium` feature module is a new self-contained feature with its own domain/data/presentation stack. The `AdHelper` sits in `core/services/` as it is cross-feature infrastructure (Constitution Principle VIII).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `in_app_purchase` instead of constitution's `flutter_stripe` | Native Google Play Billing + StoreKit subscription flows are required per spec and project roadmap | `flutter_stripe` only handles card/web payments — it cannot initiate Play Store or App Store subscription sheets. There is no simpler way to achieve native platform subscriptions. |
