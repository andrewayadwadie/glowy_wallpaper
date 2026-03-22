# Implementation Plan: Auth & User Profile

**Branch**: `002-auth-user-profile` | **Date**: 2026-03-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-auth-user-profile/spec.md`

## Summary

Implement authentication (login/register) and user profile for a two-tier user model (Guest / Premium). All users access Home without auth gating. Premium users see exclusive content and no ads. Guest users see regular content with ads. The splash screen validates stored tokens against a server endpoint on launch. Profile icon shows a login/register bottom sheet for guests, and full profile with subscription advantages + unsubscribe for premium users. Clean Architecture with Bloc/Cubit state management, Retrofit for API calls, and flutter_secure_storage for token persistence.

## Technical Context

**Language/Version**: Dart 3.11.3 / Flutter 3.41.5
**Primary Dependencies**: flutter_bloc, freezed, injectable + get_it, dio + retrofit, go_router, flutter_secure_storage, auto_size_text, flutter_screenutil, dartz, equatable
**Storage**: flutter_secure_storage (auth token), Hive (cached user data)
**Testing**: flutter_test, mocktail, bloc_test
**Target Platform**: Android (API 23+) / iOS (13+)
**Project Type**: Mobile app (cross-platform Flutter)
**Performance Goals**: Splash → Home in <3s, login/register <30s/<60s, form validation <200ms
**Constraints**: Offline-tolerant (cached status), local-first logout, no auth gate on Home
**Scale/Scope**: 6 screens (Splash update, Login, Register, Profile, Home update, bottom sheets)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture — Feature-First | PASS | Auth feature follows domain/data/presentation layers. Entities in domain, Freezed models in data, Cubits in presentation. |
| II. SOLID & DRY — No Duplication | PASS | Repository contract in domain, implementation in data. AutoSizeText used throughout. Constants in AppStrings/AppColors/AppDimens. |
| III. Responsive-First with ScreenUtil | PASS | All new screens will use .w/.h/.sp/.r extensions. Login/Register forms use AppDimens for padding/radius. |
| IV. Theming — Light & Dark via ThemeData | PASS | Auth screens use Theme.of(context) for all colors/styles. No inline colors. |
| V. Error Handling — dartz Either | PASS | All auth repository methods return Either<Failure, T>. Four-state pattern on all screens. |
| VI. Performance | PASS | No heavy operations. Token read from secure storage is async. API calls are standard Dio. |
| VII. Testing — Unit Tests Required | PASS | AuthCubit, AuthRepository, use cases will all have unit tests with mocktail. |
| VIII. Monetization & Firebase | PASS | SubscriptionCubit state determines ad visibility. Premium users see zero ads. Guest = ads shown. |

**Gate Result**: ALL PASS — proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/002-auth-user-profile/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contracts)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── api/                          # Existing: DioConsumer, interceptors
│   ├── errors/                       # Existing: Failure, exceptions
│   ├── routes/                       # UPDATE: auth guard in GoRouter
│   ├── theme/                        # Existing: AppTheme, AppColors
│   ├── usecases/                     # Existing: UseCase base
│   ├── utils/                        # UPDATE: AppStrings for auth strings
│   └── widgets/                      # UPDATE: auth bottom sheet widget
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/             # UserEntity
│   │   │   ├── repositories/         # AuthRepository contract
│   │   │   └── usecases/             # Login, Register, Logout, ValidateToken, GetCachedUser, Unsubscribe
│   │   ├── data/
│   │   │   ├── models/               # UserModel (Freezed), LoginRequest, RegisterRequest
│   │   │   ├── datasources/          # AuthRemoteDataSource (Retrofit), AuthLocalDataSource (SecureStorage + Hive)
│   │   │   └── repositories/         # AuthRepositoryImpl
│   │   └── presentation/
│   │       ├── cubit/                # AuthCubit, SubscriptionCubit
│   │       ├── pages/               # LoginPage, RegisterPage, ProfilePage
│   │       └── widgets/             # AuthFormField, LoginForm, RegisterForm, SubscriptionAdvantagesList
│   ├── home/
│   │   └── presentation/pages/      # UPDATE: HomePage to show profile icon with guest/premium behavior
│   └── splash/
│       └── presentation/pages/      # UPDATE: SplashPage to validate token and route
│
test/
├── features/
│   └── auth/
│       ├── domain/usecases/          # UseCase unit tests
│       ├── data/repositories/        # Repository impl tests
│       └── presentation/cubit/      # AuthCubit, SubscriptionCubit tests
```

**Structure Decision**: Feature-first Clean Architecture, consistent with Phase 1 foundation. Auth is a new feature module. Splash and Home are updated (not new). Shared widgets go in `lib/core/widgets/`.
