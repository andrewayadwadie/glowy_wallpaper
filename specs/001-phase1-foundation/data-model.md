# Data Model: Phase 1 — Foundation & Scaffolding

**Date**: 2026-03-19 | **Branch**: `001-phase1-foundation`

## Entities

Phase 1 defines foundational entities only — no feature-specific data models.

### Failure (sealed class)

```dart
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure { const ServerFailure(super.message); }
class CacheFailure extends Failure { const CacheFailure(super.message); }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class UnauthorizedFailure extends Failure { const UnauthorizedFailure(super.message); }
```

**Validation**: Message must be non-empty.
**Usage**: All repository methods return `Either<Failure, T>`.

### UseCase (abstract)

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
```

### AppRoute (constants)

```dart
abstract class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const favorites = '/favorites';
  static const downloads = '/downloads';
  static const wallpaperDetail = '/wallpaper/:id';
  static const classificationDetail = '/classification/:id';
  static const premium = '/premium';
  static const settings = '/settings';
  static const about = '/about';
}
```

### Environment (generated via Envied)

```dart
@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'ADMOB_APP_ID')
  static const String adMobAppId = _Env.adMobAppId;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY')
  static const String stripePublishableKey = _Env.stripePublishableKey;
}
```

## Relationships

No inter-entity relationships in Phase 1. Failure is consumed by all future repository implementations. UseCase is the base for all future use cases.

## State Transitions

No stateful entities in Phase 1. The splash screen has a simple flow:
```
App Launch → Native Splash → Init Services → Navigate to Home
                                    ↓ (on failure)
                              Error Screen (retry)
```
