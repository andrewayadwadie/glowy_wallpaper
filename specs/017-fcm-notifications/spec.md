# Feature Specification: FCM Push Notifications & Local Notifications

**Feature Branch**: `017-fcm-notifications`
**Created**: 2026-06-20
**Status**: Draft (blocked — see Preconditions)
**Input**: User description: "Setup FCM + local notifications end-to-end for the Flutter app (Clean Architecture feature-first, Cubit+Freezed, Injectable+GetIt, GoRouter, dartz Either). Inspect project, report found/missing, add only what is missing, implement the notification feature with domain/data/presentation layers, a NotificationService, background handler, deep-link navigation, and permission handling."

## Preconditions *(blocking — verified during inspection)*

These external configuration files are **required** before any implementation can compile or run. Two are currently absent:

- **`lib/firebase_options.dart`** — ❌ MISSING. Must be generated (e.g. via `flutterfire configure`). The app currently calls `Firebase.initializeApp()` with no options.
- **`ios/Runner/GoogleService-Info.plist`** — ❌ MISSING. Required for iOS FCM delivery.
- **`android/app/google-services.json`** — ✅ present.

**Implementation MUST NOT proceed until the two missing files exist.** This spec defines the target behavior; the planning/implementation phases must treat the missing files as a hard gate.

## Current-State Reconciliation *(context for planning)*

A partial notification implementation already exists and diverges from the requested target. The spec treats the requested behavior as the source of truth; planning must reconcile (extend or rename) rather than duplicate:

- Existing `NotificationService` (abstract) + `NotificationServiceImpl` use channel id **`high_importance_channel`**; target channel id is **`glowy_high_importance`**.
- Existing notification icon is `@drawable/ic_notification`; target requests `@mipmap/ic_launcher`.
- Existing deep-link key is `message.data['route']`; target uses a `deeplink` field.
- Existing navigation uses a GoRouter **redirect** that reads a `pendingRoute` from the service; target requests a static `GlobalKey<NavigatorState>` on the router for direct navigation.
- A `NotificationPayload` Freezed model exists; target requests a `NotificationEntity(title, body, deeplink, imageUrl)` plus a `NotificationRepository`, two use cases, and a `NotificationCubit` state union.
- Dependency injection is **manual GetIt** (`sl`, `injection_container.dart`); the project does not run injectable codegen for new registrations. Target annotations (`@lazySingleton`, `@injectable`, `@module`) describe intent and must be realized via manual registration in this repo.

These are documented as decisions in the Assumptions section; they do not change the user-facing outcomes below.

## Clarifications

### Session 2026-06-20

- Q: Device token destination — send to backend or expose locally only? → A: Expose token locally only (stream + getter); no backend upload. Backend sync deferred to a later spec.
- Q: Notification image — render imageUrl or text-only? → A: If imageUrl present → big-picture (image) style; else big-text expandable.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Receive notifications while app is in foreground (Priority: P1)

A user actively using the app receives a push message from the backend (e.g. a new wallpaper drop). The app surfaces it as a visible local notification with a title and an expandable body, instead of silently dropping it.

**Why this priority**: Foreground delivery is the most common case during active engagement and is the baseline that proves FCM + local notification wiring works end-to-end. Without it nothing else is demonstrable.

**Independent Test**: Send a test push (via Firebase console / API) while the app is open; verify a notification with correct title and body appears in the system tray and expands to show full body text.

**Acceptance Scenarios**:

1. **Given** the app is in the foreground and notification permission is granted, **When** a push message with title and body arrives, **Then** a local notification is shown on the high-importance channel with the message's title and body.
2. **Given** a push message with a long body, **When** it is displayed, **Then** the body is presented in an expandable (big-text) style without truncating the meaningful content.
3. **Given** a push message that carries no notification title/body (data-only), **When** it arrives in the foreground, **Then** the app does not crash and shows nothing user-visible.

---

### User Story 2 - Tap a notification to open the linked destination (Priority: P1)

A user taps a notification (whether the app is in foreground, background, or fully closed) and is taken directly to the destination the notification points to (a deep link), or to Home when no destination is specified.

**Why this priority**: Deep-link navigation is the core value of push notifications — driving users to specific content. It must work across all three app lifecycle states.

**Independent Test**: Send a push containing a deep link, tap the notification from each of the three states (foreground, background, terminated), and confirm the app navigates to the linked screen each time.

**Acceptance Scenarios**:

1. **Given** the app is in the background, **When** the user taps a notification carrying a valid deep link, **Then** the app comes to the foreground and navigates to that deep link.
2. **Given** the app is terminated, **When** the user taps a notification carrying a deep link, **Then** the app launches and, after initialization completes, navigates to that deep link.
3. **Given** a notification carries no deep link, **When** the user taps it, **Then** the app navigates to the Home destination.
4. **Given** a notification carries a malformed or unknown deep link, **When** the user taps it, **Then** the app falls back to the Home destination without error.

---

### User Story 3 - Grant or deny notification permission (Priority: P2)

On first relevant launch the user is asked for permission to receive notifications. The app records the request, reflects the outcome, and behaves correctly whether the user grants or denies.

**Why this priority**: Required on modern Android (13+) and iOS for any notification to be delivered, but the receive/tap flows (P1) are the demonstrable value; permission is the enabling gate.

**Independent Test**: Launch on a fresh install; confirm the OS permission prompt appears once, and that granting yields a delivered notification while denying suppresses delivery without crashing.

**Acceptance Scenarios**:

1. **Given** a fresh install on Android 13+, **When** the notification flow initializes, **Then** the OS notification permission prompt is shown.
2. **Given** the user grants permission, **When** initialization completes, **Then** a device push token is obtained and available to the app.
3. **Given** the user denies permission, **When** initialization completes, **Then** the app continues to function and records that permission was denied.
4. **Given** permission was already requested previously, **When** the app relaunches, **Then** the OS prompt is not shown again redundantly.

---

### User Story 4 - Maintain a valid device token for targeting (Priority: P3)

The backend can reliably target this device because the app obtains its push token and observes token refreshes over time.

**Why this priority**: Necessary for server-side targeting but invisible to the end user and dependent on P1–P3 being in place.

**Independent Test**: On first launch with permission granted, confirm a token is produced (observable via a temporary debug log); simulate a token refresh and confirm the new token is surfaced through the refresh stream.

**Acceptance Scenarios**:

1. **Given** permission is granted, **When** the app initializes, **Then** a device push token is retrieved.
2. **Given** the platform rotates the token, **When** a refresh occurs, **Then** the updated token is emitted on the token-refresh stream.

---

### Edge Cases

- **Missing Firebase config** (`firebase_options.dart` / `GoogleService-Info.plist`): the app must not crash on startup; notification initialization failure is caught and the rest of the app launches normally.
- **Permission denied then later enabled in system settings**: subsequent notifications are delivered without requiring an in-app re-prompt.
- **Deep link arrives before navigation is ready** (terminated-state launch): navigation is deferred until the router/UI is initialized, then performed once.
- **Channel id mismatch** between the Android manifest default-channel meta-data and the code-created channel: must be identical to avoid notifications landing on an unintended channel.
- **Duplicate Firebase initialization**: Firebase must be initialized exactly once per process.
- **Background isolate**: the background message handler runs in a separate isolate and must not access app-wide singletons (dependency container).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST initialize Firebase exactly once before the app UI is shown, using generated Firebase options, and MUST tolerate initialization failure without blocking app launch.
- **FR-002**: System MUST display incoming push messages received while the app is in the foreground as visible local notifications on a dedicated high-importance notification channel.
- **FR-003**: Foreground local notifications MUST present long body text in an expandable style and carry the message's deep link as their tap payload.
- **FR-003a**: When a message carries an `imageUrl`, the local notification MUST be rendered in big-picture (image) style using the downloaded image; when no `imageUrl` is present, it MUST fall back to big-text expandable style. Image download failure MUST degrade gracefully to big-text style without error.
- **FR-004**: System MUST use a single, consistent high-importance channel identifier `glowy_high_importance` everywhere it is referenced (code-created channel and Android default-channel meta-data).
- **FR-005**: System MUST navigate to the deep link associated with a tapped notification when the app is in the foreground, background, or terminated state.
- **FR-006**: When a tapped notification has no deep link, or an invalid one, System MUST navigate to the Home destination.
- **FR-007**: For terminated-state launches via notification, System MUST defer navigation until the app is initialized and then navigate to the deep link once.
- **FR-008**: System MUST request OS notification permission on the appropriate platforms (iOS via the messaging permission request; Android 13+ via the runtime notification permission) and MUST record that a request was made.
- **FR-009**: System MUST continue operating normally when permission is denied, recording the denied outcome and not re-prompting redundantly on later launches.
- **FR-010**: System MUST retrieve the device push token when permission is available and expose it to the application.
- **FR-011**: System MUST expose a stream of token refreshes so updated tokens are observable.
- **FR-011a**: The device push token is exposed to the application locally only (getter + refresh stream); System MUST NOT upload the token to a backend in this feature. Backend token registration is out of scope and deferred to a later spec.
- **FR-012**: A background message handler MUST run in its own isolate, MUST NOT access the dependency-injection container or app singletons, and MUST be registered for background message delivery.
- **FR-013**: System MUST expose notification state to the UI as a defined set of states: initial, permission-requesting, permission-granted (with token), permission-denied, and error.
- **FR-014**: The notification capability MUST be organized in domain (entity, repository contract, use cases), data (repository implementation), and presentation (state + controller) layers, with token retrieval and permission requests exposed as use cases returning explicit success/failure results.
- **FR-015**: All in-app navigation triggered by notifications MUST use the app's declarative router (GoRouter), never imperative navigation.
- **FR-016**: The Android manifest MUST declare the permissions required for notification delivery and boot-time re-registration (post-notifications, vibrate, receive-boot-completed) and the FCM default-channel meta-data; iOS configuration MUST declare the required notification capability/keys.
- **FR-017**: The notification accent color `#22D3EE` MUST be available to the Android notification configuration.
- **FR-018**: A temporary, removable diagnostic MUST log the obtained push token on first launch for verification, with the expectation it is removed before release.
- **FR-019**: System MUST add only configuration and code that is currently missing, leaving existing working configuration unchanged where it already satisfies a requirement.

### Key Entities

- **Notification**: a message destined for the user. Attributes: title, body, deep link (target destination), optional image. Represents what the user sees and where a tap leads.
- **Notification permission state**: whether the user has been asked and the outcome (granted / denied / not-yet-requested).
- **Device push token**: the platform-issued identifier used by the backend to target this installation; may change over time via refresh.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of foreground push messages that carry a title/body are surfaced as a visible notification (no silent drops) in manual testing.
- **SC-002**: Tapping a deep-linked notification opens the correct destination in all three app states (foreground, background, terminated) — 3/3 states pass.
- **SC-003**: A notification with no/invalid deep link opens Home with zero crashes across repeated taps.
- **SC-004**: On a fresh install, the OS permission prompt appears exactly once, and never re-appears on subsequent normal launches.
- **SC-005**: A device push token is obtained within 5 seconds of a permitted first launch and is observable via the temporary diagnostic log.
- **SC-006**: When Firebase configuration is absent or initialization fails, the app still reaches its first interactive screen (no startup crash) in 100% of attempts.
- **SC-007**: The channel identifier is identical between the manifest meta-data and the code-created channel (single source of truth verified).

## Assumptions

- The project ships as a **single entry point** (`lib/main.dart`); there are no build flavors, so "update all flavor `main_*.dart`" resolves to updating the single `main.dart`.
- Dependency injection is performed via **manual GetIt registration** (`injection_container.dart`); injectable-style annotations in the request describe registration intent and are realized manually, consistent with the existing repo convention.
- Deep links are app route strings beginning with `/`; the canonical fallback destination is the existing Home route.
- The existing partial notification implementation will be **reconciled** (renamed/extended) to the target channel id, payload field naming, and layering rather than duplicated.
- Firebase config files (`firebase_options.dart`, `GoogleService-Info.plist`) will be generated outside this feature's code changes (via the FlutterFire tooling) and committed before implementation completes.
- Notification permission is requested at the point notifications become relevant in the app lifecycle (early app startup), not gated behind a separate onboarding screen, unless a later spec says otherwise.
- The temporary token diagnostic is acceptable for pre-release verification and tracked for removal.

## Dependencies

- Valid Firebase project with Android and iOS apps registered.
- Generated `lib/firebase_options.dart` and `ios/Runner/GoogleService-Info.plist` (blocking — see Preconditions).
- Existing GoRouter (`AppRouter`) and GetIt container.
