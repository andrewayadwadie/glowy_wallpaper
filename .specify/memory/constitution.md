<!--
SYNC IMPACT REPORT
==================
Version change: [unversioned] → 1.0.0
Added sections:
  - Core Principles (I–VIII)
  - Package & Dependency Standards
  - Development Workflow & Quality Gates
  - Governance
Modified principles: N/A (initial fill)
Removed sections: N/A (initial fill)
Templates requiring updates:
  - .specify/templates/plan-template.md ⚠ pending (no constitution-check section found)
  - .specify/templates/spec-template.md ⚠ pending
  - .specify/templates/tasks-template.md ⚠ pending
Deferred TODOs:
  - RATIFICATION_DATE set to 2026-03-19 (today, first adoption)
-->

# Glowy Wallpapers Constitution

## Core Principles

### I. Clean Architecture — Feature-First (NON-NEGOTIABLE)

Every feature MUST be organized in three layers: **domain**, **data**, and **presentation**.
No layer may import from a layer above it. Business logic lives exclusively in the domain layer.
Feature folders are self-contained units; cross-feature communication happens only through shared
domain entities or dependency-injected use cases.

- Domain: entities, repository contracts, use cases — pure Dart, zero Flutter imports.
- Data: models (Freezed), data sources (Retrofit/Hive/SecureStorage), repository implementations.
- Presentation: Cubits/Blocs (Freezed states), pages, widgets.

Rationale: enforces testability, separation of concerns, and prevents spaghetti coupling.

### II. SOLID & DRY — No Duplication, No God Classes

Every class MUST have a single responsibility. Abstractions (repository contracts, use-case
interfaces) MUST be defined in the domain layer and consumed via dependency injection (Injectable +
GetIt). Duplicated logic MUST be extracted into a shared utility, extension, or base class before
a second usage is added.

- No hardcoded strings, colors, dimensions, or API paths anywhere in the codebase.
- All constants live in dedicated constants files (`AppColors`, `AppTextStyles`, `AppDimens`,
  `AppStrings`, `AppRoutes`, `AppAssets`).
- AutoSizedText MUST be used instead of Text widgets throughout the UI.

Rationale: makes the codebase predictable, searchable, and refactor-safe.

### III. Responsive-First with ScreenUtil (NON-NEGOTIABLE)

Every size value (width, height, font size, radius, padding, margin) MUST use ScreenUtil extensions
(`.w`, `.h`, `.sp`, `.r`). Hard-coded pixel values are forbidden. Layouts MUST be verified on
phone, large phone, and tablet form factors using adaptive grid columns.

Rationale: the app targets a wide range of Android and iOS screen densities.

### IV. Theming — Light & Dark via ThemeData

The app MUST support both light and dark themes through Material 3 `ThemeData`. No color or text
style may be inlined in a widget; all values MUST come from `Theme.of(context)` or the centralized
`AppColors`/`AppTextStyles` constants. Google Fonts MUST be applied via the theme's `textTheme`.
Theme switching MUST be persisted via `flutter_secure_storage`.

Rationale: consistent visual identity and accessibility across system preferences.

### V. Error Handling — dartz Either, No Silent Failures

All repository methods MUST return `Either<Failure, T>`. Failures are typed
(`ServerFailure`, `CacheFailure`, `NetworkFailure`, `UnauthorizedFailure`). No `try/catch` block
may swallow an exception silently. Every screen MUST implement the four-state pattern:
**loading → error (with retry) → empty (with illustration) → success**.
`loader_overlay` + `flutter_spinkit` MUST be used for loading overlays; raw
`CircularProgressIndicator` is forbidden.

Rationale: professional-grade UX and debuggability in production.

### VI. Performance — No Memory Leaks, No Heavy Operations on Main Thread

- `CachedNetworkImage` MUST be used for all network images; raw `Image.network` is forbidden.
- Video cells MUST pause when off-screen (visibility detection); auto-play only when visible.
- `Dio` download bytes operations MUST run in an isolate or be streamed; never block the UI thread.
- Cubits and controllers MUST dispose of subscriptions and streams in `close()`/`dispose()`.
- Over-engineering and premature abstraction are forbidden; add complexity only when required.
- Over-animation is forbidden; animations MUST serve a UX purpose and respect `reduce-motion`.

Rationale: wallpaper grids and video thumbnails are inherently heavy — discipline is mandatory.

### VII. Testing — Unit Tests Required

Every use case, repository implementation, and Cubit MUST have corresponding unit tests.
Tests MUST use `mocktail` for mocking. No feature is considered complete without passing tests.
`flutter analyze` MUST report zero warnings before any commit. No `print()` statements,
no unused imports, no TODOs in merged code.

Rationale: prevents regressions in a monetized, production app.

### VIII. Monetization & Firebase — Centralized, Guarded Access

- All AdMob ad operations MUST go through the centralized `AdHelper` singleton.
- Ads MUST only be shown when `SubscriptionCubit` state is `free`; premium users MUST see zero ads.
- AdMob App ID: `ca-app-pub-2083776520196762~1431087691`.
- Firebase Project ID: `glowywallpaper` | Project Number: `453600262733`.
- `google-services.json` is located at `android/app/google-services.json` (already downloaded).
- Firebase Analytics events MUST be logged for every significant user action (download, favorite,
  subscription, ad view).
- Local notifications (flutter_local_notifications) MUST be used for in-app foreground FCM display.

Rationale: revenue and engagement depend on correct, non-leaking ad and notification behavior.

## Package & Dependency Standards

All packages MUST use the latest stable version at the time of integration. Version pinning to a
specific patch is allowed only when a known regression exists (document the reason in pubspec).

**Mandatory packages** (MUST be present and correctly configured):

| Concern | Package |
|---|---|
| State Management | flutter_bloc, bloc |
| Code Generation | freezed, freezed_annotation, build_runner, injectable, injectable_generator |
| Networking | dio, retrofit, retrofit_generator |
| Navigation | go_router |
| Image Caching | cached_network_image |
| Local Storage | flutter_secure_storage (tokens & settings), hive, hive_flutter (cache) |
| UI Utilities | gap, auto_size_text, loader_overlay, flutter_spinkit, shimmer |
| Responsiveness | flutter_screenutil |
| Fonts | google_fonts |
| Splash | flutter_native_splash, flutter_launcher_icons |
| Equality | equatable |
| Functional | dartz |
| Animations | hero widgets (built-in), animations (Flutter team package) |
| Ads | google_mobile_ads |
| Payments | flutter_stripe |
| Notifications | firebase_messaging, flutter_local_notifications, firebase_analytics |
| DI | get_it, injectable |
| Environment | envied |
| Testing | mocktail, bloc_test |
| CI/CD | Fastlane |

**Forbidden patterns**:
- `Image.network` — use `CachedNetworkImage`.
- `Text(...)` — use `AutoSizeText(...)`.
- Hardcoded colors, sizes, strings, or API URLs anywhere.
- Emoji characters in code comments.
- Over-commented code; comments MUST explain *why*, not *what*.

## Development Workflow & Quality Gates

1. Follow the phase order in `plan.md`: Phase 1 → 2 → 3 → 4 → 5 → 6. Do not skip phases.
2. Each task in a phase MUST be implemented with its full Clean Architecture stack
   (domain → data → presentation) before moving to the next task.
3. Run `flutter analyze` and `dart format .` before every commit; zero warnings required.
4. Run unit tests for the affected feature before marking a task complete.
5. Fastlane lanes MUST be configured for Android (Play Store) and iOS (App Store) distribution.
6. No hardcoded flavor-specific values; use `envied` for dev/staging/prod configuration.
7. All screens MUST handle loading, error, empty, and success states explicitly.
8. Hero animations MUST be used on wallpaper thumbnail → detail screen transitions.

## Governance

This constitution supersedes all other coding conventions, README instructions, and ad-hoc
decisions. Any amendment requires:

1. A version bump (MAJOR/MINOR/PATCH per semver rules defined in the spec kit workflow).
2. Documentation of the change and rationale in this file's Sync Impact Report comment.
3. Propagation review across `.specify/templates/` and `plan.md`.

Versioning policy:
- MAJOR: removal or redefinition of a principle, or breaking architecture change.
- MINOR: new principle added, new mandatory package, new quality gate.
- PATCH: wording clarification, typo fix, non-semantic refinement.

Compliance is reviewed at the start of each phase. All agent-assisted implementation sessions
MUST load this constitution before generating code.

**Version**: 1.0.0 | **Ratified**: 2026-03-19 | **Last Amended**: 2026-03-19