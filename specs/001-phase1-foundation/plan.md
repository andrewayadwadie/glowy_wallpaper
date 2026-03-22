# Implementation Plan: Phase 1 — Foundation & Scaffolding

**Branch**: `001-phase1-foundation` | **Date**: 2026-03-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-phase1-foundation/spec.md`

## Summary

Set up the complete Flutter project foundation: install all mandated packages, scaffold Clean Architecture folder structure (feature-first, 3 layers), wire core infrastructure (DI, networking, error handling, environment config, routing, theming, responsive scaling), configure native splash, and deliver a compiling app that navigates from splash to an empty Home shell on both platforms.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: flutter_bloc, freezed, injectable + get_it, dio + retrofit, go_router, hive + flutter_secure_storage, flutter_screenutil, envied, dartz, google_fonts (Poppins), cached_network_image, auto_size_text, loader_overlay + flutter_spinkit, easy_localization
**Storage**: Hive (cache), flutter_secure_storage (tokens/settings) — empty schemas in Phase 1
**Testing**: mocktail, bloc_test, flutter_test
**Target Platform**: Android API 23+ (6.0), iOS 13+
**Project Type**: Mobile app (Flutter, cross-platform)
**Performance Goals**: Native splash within 200ms, Home screen within 3s cold start, 60fps, zero overflow warnings
**Constraints**: Offline-capable foundation (error states handle no network), responsive 360dp–1024dp
**Scale/Scope**: ~50 screens across 6 phases, 10 features

## Constitution Check

*GATE: All checks pass — no violations.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture (NON-NEGOTIABLE) | WILL FIX | Current features lack domain/data/presentation layers — Phase 1 restructures |
| II. SOLID & DRY | OK | Constants files exist; will add AppDimens, AppAssets |
| III. ScreenUtil (NON-NEGOTIABLE) | OK | Package present; will wire ScreenUtilInit in main |
| IV. Theming | WILL FIX | Theme files exist; will add persistence via secure_storage |
| V. Error Handling (dartz Either) | OK | Failure class exists; will verify/align with constitution |
| VI. Performance | OK | CachedNetworkImage present; will enforce in core widgets |
| VII. Testing | WILL FIX | Missing mocktail, bloc_test — will add as dev_dependencies |
| VIII. Monetization & Firebase | OK | Firebase + AdMob packages present; centralized AdHelper deferred to Phase 5 |
| Package Standards | WILL FIX | ~15 missing packages — see research.md R-001 |

## Project Structure

### Documentation (this feature)

```text
specs/001-phase1-foundation/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart                          # Entry point: bindings → Hive → DI → Firebase → MaterialApp.router
├── app.dart                           # MaterialApp.router with ScreenUtilInit, theme, localization
├── core/
│   ├── api/
│   │   ├── api_consumer.dart          # Dio client factory
│   │   ├── api_interceptors.dart      # Auth interceptor, PrettyDioLogger (dev only)
│   │   └── server_strings.dart        # API endpoint constants
│   ├── config/
│   │   ├── app_config.dart            # App-wide config
│   │   └── env.dart                   # @Envied generated environment config
│   ├── di/
│   │   └── injection_container.dart   # Injectable + GetIt setup, @module for Dio/Hive/SecureStorage
│   ├── errors/
│   │   ├── exceptions.dart            # Custom exception classes
│   │   └── failure.dart               # Sealed Failure class (Server, Cache, Network, Unauthorized)
│   ├── localization/
│   │   └── localization_manager.dart  # easy_localization setup
│   ├── network/
│   │   └── network_info.dart          # Connectivity checker abstraction
│   ├── routes/
│   │   ├── app_router.dart            # GoRouter config with all placeholder routes
│   │   └── routes.dart                # AppRoutes named constants
│   ├── theme/
│   │   ├── app_theme.dart             # Light + dark ThemeData with Poppins
│   │   ├── colors.dart                # AppColors constants
│   │   └── typography.dart            # AppTextStyles constants
│   ├── usecases/
│   │   └── usecase.dart               # Base UseCase<Type, Params> abstract class
│   ├── utils/
│   │   ├── app_assets.dart            # Asset path constants
│   │   ├── app_dimens.dart            # Dimension constants (ScreenUtil)
│   │   ├── app_strings.dart           # String constants
│   │   ├── constants.dart             # General constants
│   │   ├── extensions.dart            # Dart/Flutter extensions
│   │   └── validators.dart            # Input validators
│   └── widgets/
│       ├── app_cached_image.dart      # CachedNetworkImage wrapper
│       ├── app_error_widget.dart      # Error display with retry action
│       ├── app_loading.dart           # loader_overlay + flutter_spinkit loading
│       ├── adaptive_grid.dart         # Responsive grid scaffold
│       ├── custom_button.dart         # Reusable button
│       └── custom_text_field.dart     # Reusable text field
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart     # Empty Home shell (AppBar + body)
│   │       └── widgets/               # (empty, future phases)
│   └── splash/
│       └── presentation/
│           └── pages/
│               └── splash_page.dart   # Init pipeline → navigate to Home
│
android/
├── app/
│   ├── google-services.json           # Firebase config (already present)
│   └── build.gradle                   # minSdk 23
│
ios/
└── (iOS 13 deployment target)
│
test/
├── core/
│   ├── errors/
│   │   └── failure_test.dart
│   └── usecases/
│       └── usecase_test.dart
│
.env.dev                               # Dev environment values
.env.staging                           # Staging environment values
.env.prod                              # Production environment values
flutter_native_splash.yaml             # Splash config (#121212 background)
```

**Structure Decision**: Feature-first Clean Architecture. Each feature gets `domain/`, `data/`, `presentation/` subdirectories. Core modules are shared infrastructure. The existing `onboarding` feature is kept but restructured into proper layers. Phase 1 only populates splash and home presentation layers (no domain/data needed yet).

## Complexity Tracking

No constitution violations requiring justification. All gaps are being filled by this phase.
