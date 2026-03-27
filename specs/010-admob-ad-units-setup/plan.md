# Implementation Plan: AdMob Ad Units Integration — Production Ad Setup

**Branch**: `010-admob-ad-units-setup` | **Date**: 2026-03-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/010-admob-ad-units-setup/spec.md`

## Summary

Integrate four production AdMob ad units into the Glowy Wallpaper app: App Open (splash), Rewarded Interstitial (download gate), Interstitial (favorite gate), and Banner (home bottom). This replaces existing test ad unit IDs with production IDs, swaps `RewardedAd` for `RewardedInterstitialAd`, adds new `InterstitialAd` support with a 60-second cooldown, fixes the banner widget to render a real AdMob banner, removes the preview ad gate, and wires analytics for all ad events.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: google_mobile_ads (existing), flutter_bloc (Cubit + Freezed), get_it + injectable, firebase_analytics
**Storage**: Hive (ad_frequency box for cooldown tracking), flutter_secure_storage (tokens)
**Testing**: mocktail, bloc_test
**Target Platform**: Android (API 21+), iOS (15+)
**Project Type**: Mobile app (Flutter)
**Performance Goals**: Ad preload within 5 seconds of consumption; 10-second timeout for on-demand loads; 60 fps UI unaffected by ad loading
**Constraints**: All ad operations via centralized `AdHelper` singleton (constitution VIII); no blocking UI thread; premium users see zero ads
**Scale/Scope**: 4 ad units, 6 files modified, 2 new ad formats added

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture — Feature-First | PASS | Ad logic stays in `core/services/ad_helper.dart`; presentation-layer gates in widgets/cubits. No cross-layer violations. |
| II. SOLID & DRY — No Duplication | PASS | Single `AdHelper` manages all 4 ad types. Ad gate logic reused via `adGatePlaceholder`. No hardcoded ad unit IDs — stored in Envied config. |
| III. Responsive-First with ScreenUtil | N/A | No new UI screens; banner widget already uses ScreenUtil. |
| IV. Theming — Light & Dark | N/A | No new themed UI components. |
| V. Error Handling — dartz Either | PASS | Ad failures handled gracefully with user feedback (snackbar). 10-second timeout prevents indefinite waits. |
| VI. Performance — No Memory Leaks | PASS | Ads disposed on navigation away. Preload is non-blocking. Banner disposed on Home exit. |
| VII. Testing — Unit Tests Required | PASS | Will add tests for AdHelper new methods, cooldown logic, and gate behavior. |
| VIII. Monetization & Firebase — Centralized | PASS | All ad operations through `AdHelper` singleton. Premium check via `SubscriptionCubit`. Analytics logged for all ad events. |

**Gate Result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/010-admob-ad-units-setup/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── ad-helper-interface.md  # Phase 1 output
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (files to modify)

```text
lib/
├── core/
│   ├── config/
│   │   └── env.dart                    # UPDATE: Add interstitial + rewarded interstitial IDs
│   ├── services/
│   │   └── ad_helper.dart              # UPDATE: Add InterstitialAd, RewardedInterstitialAd, cooldown
│   └── widgets/
│       ├── ad_gate_placeholder.dart    # UPDATE: Add non-blocking interstitial gate mode
│       └── banner_ad_widget.dart       # UPDATE: Replace placeholder with real AdMob BannerAd
├── features/
│   ├── splash/presentation/pages/
│   │   └── splash_page.dart            # UPDATE: Use production app open ad ID, remove frequency cap
│   ├── home/presentation/pages/
│   │   └── home_page.dart              # UPDATE: Wire real banner ad loading/disposal
│   ├── downloads/presentation/cubit/
│   │   └── download_cubit.dart         # UPDATE: Switch to RewardedInterstitialAd gate
│   ├── wallpaper_detail/presentation/
│   │   ├── pages/
│   │   │   └── wallpaper_detail_page.dart  # UPDATE: Add interstitial gate on favorite, remove preview gate
│   │   └── widgets/
│   │       └── detail_action_bar.dart  # REVIEW: Favorite button callback wiring
│   └── favorites/presentation/cubit/
│       └── favorite_cubit.dart         # REVIEW: Ad gate integration point
└── .env.dev                            # UPDATE: Production ad unit IDs
```

**Structure Decision**: Existing Clean Architecture structure. All ad logic centralized in `core/services/ad_helper.dart` per constitution VIII. No new feature folders needed — this is an enhancement to existing infrastructure.

## Complexity Tracking

No constitution violations to justify — all gates pass.
