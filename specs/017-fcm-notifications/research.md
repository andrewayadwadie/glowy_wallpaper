# Phase 0 Research: FCM Push Notifications & Local Notifications

All Technical Context unknowns resolved (no NEEDS CLARIFICATION remained after `/speckit.clarify`).
Findings below are decisions for reconciling the existing partial implementation to the target.

## D1: Notification channel identifier

- **Decision**: Single constant `glowy_high_importance` used in code-created `AndroidNotificationChannel`
  AND in the manifest FCM default-channel meta-data.
- **Rationale**: FR-004 + SC-007 require one source of truth; mismatch sends notifications to an
  unintended channel. Existing code uses `high_importance_channel` — must be renamed everywhere.
- **Alternatives considered**: Keep existing id — rejected, contradicts target spec.

## D2: Deep-link payload field

- **Decision**: Read deep link from `message.data['deeplink']`; carry it as the local-notification
  tap `payload`. Fallback to Home (`AppRoutes.home = '/'`) when absent/invalid (not starting with `/`).
- **Rationale**: Spec target field name is `deeplink` (FR-005/006). Existing `route` key reconciled.
- **Alternatives considered**: Support both keys — rejected as DRY/ambiguity violation; one canonical field.

## D3: Navigation mechanism (3 lifecycle states)

- **Decision**: Add `static final GlobalKey<NavigatorState> navigatorKey` to `AppRouter`, pass to
  `GoRouter(navigatorKey: ...)`. Navigate via `navigatorKey.currentContext` / router `.go()`.
  Foreground tap + background (`onMessageOpenedApp`) navigate directly. Terminated
  (`getInitialMessage`) defers until first frame, then navigates once (FR-007).
- **Rationale**: FR-015 mandates declarative GoRouter, never imperative `Navigator.push`. A static
  navigatorKey gives a stable handle from the service/Cubit without `BuildContext` plumbing. Replaces
  the existing fragile redirect-on-home approach.
- **Alternatives considered**: Keep redirect reading `pendingRoute` — rejected (couples nav to home
  route match + subscription state, brittle for terminated launches). Imperative Navigator — forbidden by FR-015.

## D4: Big-picture vs big-text rendering

- **Decision**: When `imageUrl` present, download bytes and render `BigPictureStyleInformation`;
  else `BigTextStyleInformation` (expandable body). Download failure degrades to big-text (FR-003a).
- **Rationale**: Clarification Q2 = Option A. Image download must not block/crash; wrap in try and
  fall back. Use a temp file path for Android big-picture (flutter_local_notifications requirement).
- **Alternatives considered**: Always big-text (drop image) — rejected per clarification.

## D5: Background isolate handler

- **Decision**: Top-level `@pragma('vm:entry-point')` function registered via
  `FirebaseMessaging.onBackgroundMessage`. MUST call `Firebase.initializeApp()` itself if it needs
  Firebase, MUST NOT touch GetIt/`sl` or app singletons (FR-012). Existing handler is a no-op stub —
  acceptable; deep link for background/terminated taps comes via `onMessageOpenedApp` /
  `getInitialMessage`, not the background data handler.
- **Rationale**: Background handler runs in a separate isolate; singletons are not shared.
- **Alternatives considered**: Access DI in handler — explicitly forbidden, would crash.

## D6: Permission flow + de-dup

- **Decision**: iOS via `FirebaseMessaging.requestPermission`; Android 13+ via the same plus the
  runtime POST_NOTIFICATIONS permission. Persist `permission_requested = true` in Hive box
  `notification_prefs` after first request; skip re-prompt when flag set (FR-008/009, SC-004).
- **Rationale**: Existing impl already persists the flag — reuse box, no new storage.
- **Alternatives considered**: New box / flutter_secure_storage — rejected, reuse existing `notification_prefs`.

## D7: Token exposure (no backend)

- **Decision**: `getFCMToken()` returns token; `onTokenRefresh` stream surfaces rotations. No backend
  upload. Temporary `debugPrint` of token on first launch (FR-018), tracked for removal pre-release.
- **Rationale**: Clarification Q1 = Option A (local only). Backend sync is a later spec.
- **Alternatives considered**: Upload to backend — deferred; no endpoint in scope.

## D8: Firebase single init + failure tolerance

- **Decision**: `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` once in
  `main()` (using generated `firebase_options.dart`), wrapped in try/catch so init failure does not
  block `runApp` (FR-001, SC-006). Service `initialize()` likewise tolerant.
- **Rationale**: Missing config must not crash startup; app reaches first interactive screen.
- **Alternatives considered**: Bare `initializeApp()` (current) — works but spec requires generated options.

## D9: DI strategy

- **Decision**: Manual GetIt registration in `injection_container.dart` Phase 6 block — register
  `NotificationService`, `NotificationRepository`, both use cases, and `NotificationCubit`.
- **Rationale**: Repo does not run injectable codegen (spec Assumption + Current-State Reconciliation).
- **Alternatives considered**: injectable annotations/codegen — rejected, not used in this repo.

## D10: Android manifest + iOS config

- **Decision**: Add `POST_NOTIFICATIONS`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED` uses-permission; add
  FCM `default_notification_channel_id = glowy_high_importance`, default notification icon
  (`@mipmap/ic_launcher`), and default notification color (`@color/notification_color` → `#22D3EE`
  in `res/values/colors.xml`). iOS: enable Push Notifications + Background Modes (remote-notification)
  and `GoogleService-Info.plist`. Add only what's missing (FR-019).
- **Rationale**: FR-016/017. Current manifest has none of the notification perms/meta-data.
- **Alternatives considered**: N/A — required by spec.
