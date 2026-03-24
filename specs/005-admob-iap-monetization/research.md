# Research: Monetization — AdMob Ads & In-App Purchases

**Branch**: `005-admob-iap-monetization` | **Date**: 2026-03-24

## R1: AdMob Integration Pattern for Flutter

**Decision**: Use `google_mobile_ads` (already in pubspec at v5.3.0) with a centralized `AdHelper` singleton that manages all ad lifecycle (load, show, dispose) for banner, rewarded, and app-open ad types.

**Rationale**: The constitution mandates a centralized `AdHelper` (Principle VIII). The package is already declared and `MobileAds.instance` is already registered in GetIt. The singleton pattern prevents duplicate ad loads and ensures proper disposal.

**Alternatives considered**:
- Direct `google_mobile_ads` usage per-widget: rejected because it violates the centralized access mandate and leads to lifecycle leaks.
- Third-party ad mediation (e.g., AdMob mediation with Unity Ads): rejected as over-engineering for current scope.

## R2: In-App Purchase Plugin Choice

**Decision**: Use `in_app_purchase` (official Flutter team plugin) instead of `flutter_stripe` listed in the constitution.

**Rationale**: The project roadmap and spec explicitly require native platform subscriptions (Google Play Billing on Android, StoreKit on iOS). `flutter_stripe` is designed for card/web payments and cannot handle native store subscriptions. The `in_app_purchase` plugin is the Flutter team's official abstraction over both platform billing libraries.

**Alternatives considered**:
- `flutter_stripe`: rejected — does not support Google Play Billing or StoreKit subscription flows.
- `purchases_flutter` (RevenueCat): rejected — adds a paid third-party dependency and backend requirement beyond what is specified.
- Direct platform channels: rejected — unnecessary when the official plugin exists.

**Constitution impact**: This is a justified deviation from the Payments row in the constitution's package table. Documented in plan.md Complexity Tracking.

## R3: Receipt Verification Strategy

**Decision**: Client sends purchase token/receipt to `POST /subscription/verify` on the backend. Backend validates with Google Play Developer API / App Store Server API and returns verified status. Client caches result locally in Hive with 7-day TTL.

**Rationale**: Server-side verification is an industry-standard security requirement (both Google and Apple mandate it for production apps). The optimistic-grant-then-re-verify pattern (from clarification Q1) means the user is never blocked at purchase time, but security is maintained via cold-start re-verification.

**Alternatives considered**:
- Client-side only verification: rejected — trivially bypassable, violates store policies.
- Blocking verification (must succeed before premium granted): rejected per clarification session decision.

## R4: App-Open Ad Lifecycle Management

**Decision**: Load the app-open ad during splash initialization. Show it after `SubscriptionCubit.checkStatus()` completes, only if the user is free-tier and the 4-hour frequency cap has not been hit. If the ad is not ready when splash completes, skip it and navigate to Home.

**Rationale**: The frequency cap (clarification Q4) prevents user fatigue. Non-blocking behavior ensures the app never hangs on a slow ad network. Google's own documentation recommends loading app-open ads during splash and showing them at transition points.

**Alternatives considered**:
- Load ad lazily after Home loads, show on next app-resume: rejected — spec requires showing before Home on cold start.
- Block navigation until ad loads: rejected per edge case decision.

## R5: Rewarded Ad Preloading Strategy

**Decision**: Preload one rewarded ad on app start (after splash). After each ad is consumed (shown + reward earned), immediately preload the next one. If preload fails, retry once after 5 seconds. If still failed, the gated action shows "Ad unavailable" message.

**Rationale**: FR-006 mandates automatic preloading. Single-ad preloading is sufficient since users rarely trigger two gated actions faster than an ad can load (typically 2–5 seconds).

**Alternatives considered**:
- Preload a pool of 2–3 rewarded ads: rejected — wastes bandwidth and memory; unnecessary for a wallpaper app's usage pattern.
- Load on-demand when user taps action: rejected — introduces 2–5 second wait at action time, poor UX.

## R6: Subscription State Persistence

**Decision**: Extend existing Hive storage with a `subscription_cache` box storing: verification state (`verified`/`pending`/`unverified`), product ID, expiry date, and a timestamp of last successful verification. Cache TTL: 7 days per clarification Q3.

**Rationale**: Hive is already the project's cache layer (categories, favorites, downloads). Adding a subscription box is consistent. The 7-day TTL balances offline UX with security. The `SubscriptionCubit` already reads from cache on startup.

**Alternatives considered**:
- `SharedPreferences`: rejected — less structured, no type safety, already using Hive everywhere.
- `flutter_secure_storage`: rejected — overkill for non-secret subscription status; secure storage is reserved for auth tokens per existing pattern.

## R7: Analytics Event Implementation

**Decision**: Use existing `FirebaseAnalytics` instance (already registered in GetIt) to log the 5 key funnel events defined in FR-016. Events are fired from use cases or cubits at the moment the action occurs.

**Rationale**: Firebase Analytics is already integrated. No additional SDK needed. Logging from the cubit/use-case layer (not the widget layer) ensures events are captured regardless of UI variations.

**Alternatives considered**:
- Custom analytics service abstraction: rejected — over-engineering for 5 events on a single analytics backend.
- Widget-level event logging: rejected — fragile, misses programmatic triggers.
