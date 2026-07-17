# Data Model: Auth & User Profile

**Feature**: 002-auth-user-profile
**Date**: 2026-03-20

## Entities

### UserEntity (Domain Layer)

Pure Dart class in `lib/features/auth/domain/entities/user_entity.dart`.

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique user identifier from server |
| displayName | String | User's display name |
| email | String | User's email address |
| isPremium | bool | Whether user has active premium subscription |

**Validation Rules**:
- `id` must be non-empty
- `email` must be RFC 5322 compliant
- `displayName` must be non-empty, max 100 characters

**Extends**: `Equatable` (props: [id, displayName, email, isPremium])

### UserModel (Data Layer)

Freezed model in `lib/features/auth/data/models/user_model.dart`.

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| id | String | `id` | Server-assigned unique ID |
| displayName | String | `display_name` | User's display name |
| email | String | `email` | User's email |
| isPremium | bool | `is_premium` | Premium subscription status |

**Annotations**: `@freezed`, `@JsonSerializable`
**Methods**: `toEntity()` → converts to `UserEntity`

### LoginRequestModel (Data Layer)

Freezed model in `lib/features/auth/data/models/login_request_model.dart`.

| Field | Type | JSON Key |
|-------|------|----------|
| email | String | `email` |
| password | String | `password` |

### RegisterRequestModel (Data Layer)

Freezed model in `lib/features/auth/data/models/register_request_model.dart`.

| Field | Type | JSON Key |
|-------|------|----------|
| displayName | String | `display_name` |
| email | String | `email` |
| password | String | `password` |

Note: `confirmPassword` is validated client-side only — not sent to server.

### AuthResponseModel (Data Layer)

Freezed model in `lib/features/auth/data/models/auth_response_model.dart`.

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| token | String | `token` | Auth token for API requests |
| user | UserModel | `user` | User object with profile data |

### SubscriptionStatusModel (Data Layer)

Freezed model in `lib/features/auth/data/models/subscription_status_model.dart`.

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| isPremium | bool | `is_premium` | Current subscription status |

## State Transitions

### User Authentication State

```
Guest (no token)
  │
  ├── Register → API call → success → Premium (token stored, user cached)
  │                        → failure → Guest (error shown)
  │
  ├── Login → API call → success → Premium (token stored, user cached)
  │                     → failure → Guest (error shown, lockout after 5 fails)
  │
  └── App Launch (no token) → Guest (Home with regular content + ads)

Premium (token stored)
  │
  ├── Logout → API call → success/failure → Guest (token cleared, local-first)
  │
  ├── Unsubscribe → API call → success → Guest (immediate, premium hidden, ads shown)
  │                           → failure → Premium (error shown, retry)
  │
  ├── App Launch (token) → Validate → valid → Premium (Home with all content, no ads)
  │                                 → 401 → Guest (token cleared)
  │                                 → network error → last known status (default: Guest)
  │
  └── 401 on any API call → Guest (token cleared by AuthInterceptor)
```

### SubscriptionCubit States (Freezed)

```dart
@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.guest() = _Guest;
  const factory SubscriptionState.premium({required UserEntity user}) = _Premium;
  const factory SubscriptionState.loading() = _Loading;
}
```

### AuthCubit States (Freezed)

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({required UserEntity user}) = _Authenticated;
  const factory AuthState.error({required String message}) = _Error;
  const factory AuthState.lockedOut({required int remainingSeconds}) = _LockedOut;
}
```

## Relationships

```
AuthResponseModel
  ├── token: String (stored in SecureStorage)
  └── user: UserModel
        └── toEntity() → UserEntity (used by domain/presentation)

SubscriptionCubit
  ├── reads: AuthToken from SecureStorage
  ├── calls: ValidateToken use case
  └── emits: SubscriptionState (guest | premium)

AuthCubit
  ├── calls: Login, Register, Logout use cases
  ├── updates: SubscriptionCubit on success
  └── emits: AuthState (initial | loading | authenticated | error | lockedOut)
```

## Storage Map

| Data | Storage | Key/Box | Lifecycle |
|------|---------|---------|-----------|
| Auth token | flutter_secure_storage | `auth_token` | Written on login/register, cleared on logout/unsubscribe/401 |
| Cached user object | Hive box `user_cache` | `current_user` | Written on login/register/validate, cleared on logout/unsubscribe |
| Login attempt counter | In-memory (AuthCubit) | N/A | Resets on app restart, increments on failed login |
