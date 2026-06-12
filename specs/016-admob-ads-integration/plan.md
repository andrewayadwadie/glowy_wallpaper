# Implementation Plan: AdMob Ads Integration

**Branch**: `016-admob-ads-integration` | **Date**: 2026-06-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/016-admob-ads-integration/spec.md`

## Summary

Consolidate Glowy's four ad placements behind a focused, cross-cutting `core/ads/` layer: a **rewarded** ad gating wallpaper downloads (network-error graceful degradation), an **app-open** ad after splash and on foreground resume (≥4-min cap), an **anchored adaptive banner** on Home, and a **frequency-capped interstitial** on category navigation. Replace the existing monolithic `AdHelper` singleton with per-format managers (SRP/ISP), resolve ad unit IDs by build-mode (test vs prod) and platform (Android/iOS), add a Google UMP consent flow at startup, suppress all ads for premium users, and emit Firebase Analytics events for every ad lifecycle outcome.

The download gate migrates from the current **RewardedInterstitial** format to a true **Rewarded** ad with reward-or-network-fallback semantics. All premium gating continues to flow from `SubscriptionCubit`.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: `google_mobile_ads ^5.3.0` (already present; includes UMP `ConsentInformation`/`ConsentForm`), `flutter_bloc`, `get_it` (manual registration — no injectable codegen in this repo), `firebase_analytics`, `flutter_screenutil`, `loader_overlay` + `flutter_spinkit` (loading overlays), `auto_size_text`, `envied` (prod config)
**Storage**: None new. Interstitial frequency/cooldown state is **in-memory per session** (Clarification Q1). Existing `ad_frequency` Hive box is NOT used by the new managers. Consent state is persisted by the UMP SDK itself.
**Testing**: `flutter_test` + `mocktail` + `bloc_test`. Ad-SDK seams isolated behind manager methods so frequency/cooldown/network-classification logic is unit-testable without the live SDK.
**Target Platform**: Android (real prod ad IDs known) and iOS (test IDs until prod iOS IDs supplied) — both in scope (Clarification, spec Q on iOS).
**Project Type**: Mobile app (Flutter), Clean Architecture, feature-first. Ads are cross-cutting → live in `core/`.
**Performance Goals**: 60 fps grid scroll unaffected by banner; app entry after splash adds no perceptible delay when no app-open ad is ready (SC-003); download never blocked by ad layer (SC-001).
**Constraints**: No ad SDK calls in `HomeCubit` or domain/data layers; full-screen ads single-use + reload-after-show; no stacked full-screen ads; premium ⇒ zero ads; test inventory in non-release builds only.
**Scale/Scope**: 4 placements, ~6 new `core/ads/` files + 1 consent manager, edits to splash, home, download cubit, env, DI, AndroidManifest, Info.plist. ~3 screens touched.

### Reality reconciliation (prompt vs repo — resolved decisions)

| Prompt assumption | Repo reality | Decision |
|---|---|---|
| 3 flavors + `main_dev/staging/prod.dart` | Single `lib/main.dart`, single `.env.prod` | Resolve test-vs-prod by **build mode** (`kReleaseMode`), not flavors. Documented in spec Assumptions + research. |
| `injectable`/`@lazySingleton` + build_runner for DI | `injection_container.dart` registers manually with `sl.registerLazySingleton(...)`; no `*.config.dart` | Register managers **manually** in `init()` matching existing pattern. No build_runner needed for DI. |
| `google_mobile_ads ^5.2.0` | `^5.3.0` already present | Keep `^5.3.0`. |
| Use `logger` package | Repo uses `debugPrint` + `FirebaseAnalytics`; constitution VIII mandates analytics | Use `FirebaseAnalytics` for lifecycle **events** (constitution-required) + `debugPrint` for dev logs. **Do not** add `logger` (avoids dep churn + matches codebase). |
| Rewarded for download = new unit | Download currently uses **RewardedInterstitial** | Replace with **Rewarded** format + new env id; remove old rewarded-interstitial download wiring (FR-006). |
| Real App ID is a TODO placeholder | Constitution VIII pins it | Use real Android App ID `ca-app-pub-2083776520196762~1431087691`. |

## Constitution Check

*GATE: evaluated against Constitution v1.0.0.*

| Principle | Status | Notes |
|---|---|---|
| I. Clean Architecture (feature-first) | ✅ PASS | Ads are cross-cutting infra → `core/ads/`. No domain/data ad logic. Managers called only from presentation (cubits/widgets/splash). |
| II. SOLID & DRY — no god classes | ✅ PASS (improves) | Splitting the 424-line `AdHelper` god class into per-format managers **better** satisfies SRP/ISP. Constants (slot height, event names) centralized in `AppDimens`/`constants`. Test IDs live in one `ad_ids.dart`. |
| III. Responsive ScreenUtil | ⚠️ PARTIAL — justified | Banner slot height = SDK-resolved `getAnchoredAdaptiveBannerAdSize` height (device px), not `.h`. This is SDK-driven and correct; ScreenUtil used for all surrounding padding/placeholders. See Complexity Tracking. |
| IV. Theming light/dark | ✅ PASS | No inlined colors in new widgets; banner placeholder uses theme/`AppColors`. |
| V. Error handling + 4-state + spinkit | ✅ PASS | Rewarded cold-start loading uses `loader_overlay`/`flutter_spinkit` (not raw `CircularProgressIndicator`). Ad failures never surface blocking errors (graceful degradation). Download repository still returns `Either<Failure,T>`. |
| VI. Performance / no leaks | ✅ PASS | Banner widget disposes its `BannerAd` in `dispose()`; full-screen ads disposed after show; app-open lifecycle observer removed on dispose. |
| VII. Testing + zero analyze warnings + no print | ✅ PASS | Unit tests for each manager's pure logic (network-error classification, frequency cap, cooldown, staleness) via `mocktail`. `debugPrint` (allowed) not `print`. |
| VIII. Monetization centralized + premium-guarded | ⚠️ CONFLICT — justified | Constitution says *"All AdMob ad operations MUST go through the centralized `AdHelper` singleton."* This feature **replaces** `AdHelper` with the `core/ads/` manager set. See Complexity Tracking + required amendment. Premium gating (ads only when `SubscriptionCubit` free) is **preserved**. Real App ID + analytics events preserved. |

**Gate result**: PASS with two justified deviations (III partial, VIII centralization mechanism). VIII requires a constitution PATCH/MINOR amendment to redefine "centralized ad access" as the `core/ads/` layer rather than a single `AdHelper` class — flagged for governance, does not block planning.

## Project Structure

### Documentation (this feature)

```text
specs/016-admob-ads-integration/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (manager interface contracts)
│   ├── rewarded_ad_manager.contract.md
│   ├── app_open_ad_manager.contract.md
│   ├── interstitial_ad_manager.contract.md
│   ├── anchored_adaptive_banner.contract.md
│   └── consent_manager.contract.md
├── checklists/
│   └── requirements.md  # from /speckit.specify
└── tasks.md             # /speckit.tasks output (NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── ads/                                   # NEW — cross-cutting ad layer
│   │   ├── ad_ids.dart                        # Resolves unit IDs by build-mode + platform
│   │   ├── ad_network_error.dart              # Network-error classification helper (testable)
│   │   ├── ads_initializer.dart               # MobileAds init + consent ordering wrapper
│   │   ├── ad_gatekeeper.dart                 # Single shouldShowAds source, synced from SubscriptionCubit
│   │   ├── consent_manager.dart               # Google UMP consent flow
│   │   ├── managers/
│   │   │   ├── rewarded_ad_manager.dart        # Download gate (preload, reward-or-network-fallback)
│   │   │   ├── app_open_ad_manager.dart        # Post-splash + resume, ≥4-min cap, staleness
│   │   │   └── interstitial_ad_manager.dart    # Category nav, freq-cap + cooldown
│   │   └── widgets/
│   │       └── anchored_adaptive_banner.dart   # Self-contained adaptive banner widget
│   ├── config/env.dart                        # EDIT — add rewarded + iOS unit id fields
│   ├── di/injection_container.dart            # EDIT — register managers + gatekeeper
│   ├── utils/app_dimens.dart                  # EDIT — banner slot fallback height constant
│   └── utils/constants.dart                   # EDIT — analytics event/param name constants
├── features/
│   ├── splash/presentation/pages/splash_page.dart   # EDIT — app-open via AppOpenAdManager
│   ├── home/presentation/pages/home_page.dart       # EDIT — adaptive banner + category interstitial listener
│   └── downloads/presentation/cubit/download_cubit.dart # EDIT — Rewarded gate w/ reward-or-fallback
└── main.dart                                  # EDIT — AdsInitializer (init + consent) before runApp

# REMOVE / DEPRECATE after migration
lib/core/services/ad_helper.dart               # superseded by core/ads/*
lib/core/widgets/banner_ad_widget.dart         # superseded by anchored_adaptive_banner.dart

android/app/src/main/AndroidManifest.xml       # EDIT — APPLICATION_ID meta-data (real App ID)
ios/Runner/Info.plist                          # EDIT — GADApplicationIdentifier, SKAdNetworkItems, NSUserTrackingUsageDescription

test/core/ads/                                 # NEW — manager logic unit tests
```

**Structure Decision**: Mobile-app Clean Architecture. Ads remain in `core/` (cross-cutting, not a feature). Per-format managers are independent `@lazySingleton`-equivalent registrations (manual `sl.registerLazySingleton`), each with one responsibility. Presentation calls manager methods; only the banner widget embeds an `AdWidget`. `HomeCubit` stays ad-free — the category interstitial is triggered by a `BlocListener` in `HomePage` on `selectedCategoryIndex` changes.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| **VIII**: replace single `AdHelper` singleton with multiple managers | Constitution II forbids god classes; `AdHelper` is a 424-line multi-responsibility class. Per-format managers give SRP/ISP, independent testing (FR-024), and independent disable. The feature's whole point is this restructure. | Keeping one `AdHelper` would force all 4 formats + consent + lifecycle into one class — directly violating Principle II and making FR-024 (independent testability/disable) and network-fallback logic harder to test in isolation. |
| **III**: banner slot height not from ScreenUtil | Anchored adaptive banner height is computed by the SDK for the device width (`getAnchoredAdaptiveBannerAdSize`). Hardcoding `.h` would mis-size the ad and risk policy issues / clipping. | A fixed `.h` height cannot match the SDK-chosen adaptive height; using it would either clip the ad or leave dead space, breaking SC-004. ScreenUtil is still used for the collapsed-state placeholder and padding. |

**Governance action (non-blocking)**: propose Constitution VIII amendment — redefine "centralized, guarded ad access" to mean the `core/ads/` manager layer (no scattered SDK calls in widgets/cubits) rather than literally the `AdHelper` singleton. Record in a follow-up `/speckit.constitution` run.

## Phase 0 → research.md
Resolves: Rewarded-vs-RewardedInterstitial migration, network-error code detection (Android code==2 / iOS domain), anchored adaptive banner sizing + slot reservation, UMP consent ordering, build-mode test/prod ID strategy, app-open resume lifecycle, premium-gating source wiring, manager testability seams.

## Phase 1 → data-model.md, contracts/, quickstart.md
Entities: AdPlacement, AdUnitResolution (build-mode × platform), PremiumEntitlement signal, FrequencyCooldownState (in-memory), ConsentState. Contracts: one per manager + banner widget + consent manager. Quickstart: manual steps (App ID, iOS plist, iOS unit IDs, build_runner for env regen, test-device registration) + verification checklist mapped to acceptance scenarios.
