# Research: Auth & User Profile

**Feature**: 002-auth-user-profile
**Date**: 2026-03-20

## R1: Token Storage Strategy

**Decision**: Use `flutter_secure_storage` for auth token, `Hive` for cached user object.

**Rationale**: flutter_secure_storage uses Keychain (iOS) and EncryptedSharedPreferences (Android) — the most secure option for sensitive credentials. Hive is used for the user object cache (non-sensitive display data) because it's faster for reads and already in the project. The token is the only truly sensitive value.

**Alternatives considered**:
- Hive with encryption for token → Rejected: Hive encryption is AES-256 but key management is manual, less secure than OS-level keychain.
- SharedPreferences → Rejected: Not encrypted, constitution forbids plain local storage for tokens.

## R2: Auth State Management Pattern

**Decision**: Two Cubits — `AuthCubit` for login/register/logout flows, `SubscriptionCubit` (app-wide) for guest/premium status.

**Rationale**: Separating auth actions from subscription status allows the SubscriptionCubit to be provided at the root of the widget tree and read by any feature (ads, content filtering) without coupling to the auth flow. AuthCubit is scoped to auth screens only.

**Alternatives considered**:
- Single AuthBloc for everything → Rejected: Violates SRP; content filtering and ad display shouldn't depend on auth page state.
- Riverpod → Rejected: Constitution mandates flutter_bloc.

## R3: GoRouter Auth Guard Pattern

**Decision**: Use GoRouter's `redirect` callback to check SubscriptionCubit state. No route protection for Home (all users access it). Redirect authenticated users away from Login/Register.

**Rationale**: Since Home is guest-accessible, the guard only needs to: (1) redirect auth'd users away from /login and /register, (2) allow all users to access all other routes. Premium-gated actions are handled at the widget level (bottom sheet prompt), not at the route level.

**Alternatives considered**:
- Route-level protection for premium features → Rejected: Spec says guests can browse Home freely; premium gating happens at action level (favorite/download), not navigation level.
- Custom NavigatorObserver → Rejected: GoRouter's redirect is the idiomatic pattern.

## R4: Token Validation on Launch

**Decision**: During splash, if a stored token exists, call the `/subscription/status` endpoint with the token in the Authorization header. The 401 response signals an invalid token; any success response returns the user's current status.

**Rationale**: Reuses the existing `/subscription/status` endpoint rather than creating a dedicated `/auth/validate` endpoint. A 401 from any authenticated endpoint implicitly validates the token. This is simpler and already handled by the AuthInterceptor (which clears tokens on 401).

**Alternatives considered**:
- Dedicated `/auth/validate` endpoint → Rejected: Unnecessary if `/subscription/status` serves the same purpose (returns status or 401).
- JWT expiry check client-side → Rejected: Constitution says token is opaque; client doesn't decode it.

## R5: Guest-to-Auth Return Flow

**Decision**: When a guest triggers a premium action (favorite/download), show a bottom sheet with Login/Register. After successful auth, pop back to the previous screen and retry the action using a callback stored before the auth flow.

**Rationale**: GoRouter supports `extra` parameter for passing return context. The action callback is stored in the SubscriptionCubit or passed via route extra, and executed after auth completes and the user returns to the original screen.

**Alternatives considered**:
- Store pending action in SharedPreferences → Rejected: Over-engineered for a simple callback.
- Always return to Home after auth → Rejected: Spec explicitly requires returning to the exact item.

## R6: Unsubscribe Flow

**Decision**: Call `/auth/logout`-style unsubscribe endpoint → on success, update SubscriptionCubit to guest → clear premium-related cache → UI updates reactively.

**Rationale**: Immediate effect per spec. The SubscriptionCubit emits a new state, and all listening widgets (content grids, ad widgets, profile) rebuild automatically via BlocBuilder/BlocListener.

**Alternatives considered**:
- End-of-billing-period → Rejected: Spec explicitly says immediate effect.
- Require app restart → Rejected: Spec says premium items hidden and ads reappear within 1 second.

## R7: Retrofit Code Generation for Auth Endpoints

**Decision**: Create `AuthRemoteDataSource` as a Retrofit-annotated abstract class with methods for login, register, logout, subscription status, and unsubscribe. Run build_runner to generate implementation.

**Rationale**: Consistent with Phase 1 pattern (DioConsumer + Retrofit). Code generation reduces boilerplate and ensures type-safe API calls.

**Alternatives considered**:
- Manual Dio calls → Rejected: Constitution mandates Retrofit for networking.
