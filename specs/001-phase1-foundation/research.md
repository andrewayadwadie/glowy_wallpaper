# Research: Phase 1 — Foundation & Scaffolding

**Date**: 2026-03-19 | **Branch**: `001-phase1-foundation`

## R-001: Package Gap Analysis

**Decision**: Add all constitution-mandated packages missing from pubspec.yaml.

**Missing dependencies** (must add):
- `freezed_annotation`, `injectable`, `retrofit`, `hive`, `hive_flutter`, `flutter_secure_storage`, `auto_size_text`, `loader_overlay`, `flutter_spinkit`, `gap`, `envied`, `envied_annotation`, `flutter_native_splash`, `flutter_launcher_icons`, `json_annotation`, `flutter_stripe`

**Missing dev_dependencies** (must add):
- `freezed`, `build_runner`, `injectable_generator`, `retrofit_generator`, `json_serializable`, `mocktail`, `bloc_test`, `envied_generator`, `hive_generator`

**Already present** (no action): `flutter_bloc`, `bloc`, `go_router`, `get_it`, `dio`, `dartz`, `equatable`, `google_fonts`, `cached_network_image`, `flutter_screenutil`, `shimmer`, `google_mobile_ads`, `firebase_core`, `firebase_analytics`, `firebase_messaging`, `flutter_local_notifications`

**Rationale**: Constitution mandates these packages. Adding them all in Phase 1 ensures the foundation is complete.

**Alternatives considered**: Adding packages incrementally per phase — rejected because constitution requires them present from the start.

## R-002: Localization Approach

**Decision**: Keep `easy_localization` (already installed and configured with `assets/lang/` ARB files) instead of switching to `flutter_localizations`.

**Rationale**: The project already uses `easy_localization` with asset folder configured. Switching would be unnecessary churn. The clarification intent (scaffold localization infra in Phase 1 with English-only) is already satisfied.

**Alternatives considered**: `flutter_localizations` + `intl` — rejected because easy_localization is already set up and is more feature-rich (hot reload, JSON/ARB support, context extensions).

## R-003: Feature-First Folder Structure

**Decision**: Restructure `lib/features/` so each feature has `domain/`, `data/`, `presentation/` subdirectories per Constitution Principle I.

**Current state**: Features (home, splash, onboarding) are flat — just views files, no layered structure.

**Rationale**: Constitution Principle I is NON-NEGOTIABLE. All features must have three layers.

## R-004: Environment Configuration with Envied

**Decision**: Use `envied` with `.env.dev`, `.env.staging`, `.env.prod` files. Generate `Env` class with `@Envied` annotation. Store API base URL, AdMob app ID, and placeholder Stripe key.

**Rationale**: Constitution forbids hardcoded values. Envied generates type-safe, obfuscated env access.

**Alternatives considered**: `flutter_dotenv` — rejected because constitution mandates `envied`.

## R-005: Native Splash Configuration

**Decision**: Use `flutter_native_splash` with deep dark (#121212) background. Logo asset TBD — use solid color fallback per spec assumptions.

**Rationale**: Spec FR-001 requires branded splash with #121212 background. Assumption allows solid-color fallback.

## R-006: Theme Persistence

**Decision**: Persist theme mode (light/dark/system) in `flutter_secure_storage` per Constitution Principle IV.

**Rationale**: Constitution explicitly requires theme switching persisted via flutter_secure_storage.

**Note**: Spec FR-003 says "automatically switch based on system preference" — the persisted value should default to `system` mode, allowing manual override in future phases.
