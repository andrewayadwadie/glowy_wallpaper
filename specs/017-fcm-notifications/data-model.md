# Phase 1 Data Model: FCM Push Notifications

## Entities

### NotificationEntity (domain)

Pure Dart, zero Flutter imports. Represents what the user sees and where a tap leads.

| Field | Type | Required | Notes |
|---|---|---|---|
| title | String | yes | Notification title; may be empty for data-only messages |
| body | String | yes | Notification body; rendered big-text when no image |
| deeplink | String? | no | App route beginning with `/`; null/invalid → Home fallback |
| imageUrl | String? | no | When present → big-picture style; download failure → big-text |

- **Validation**: `deeplink` is honored only if it starts with `/`; otherwise treated as null
  (Home fallback per FR-006).
- **Construction**: built from `RemoteMessage` (`message.notification.title/body`,
  `message.data['deeplink']`, `message.data['imageUrl']` or `message.notification.android.imageUrl`).
- **Supersedes**: existing `NotificationPayload(title, body, route, data)` — reconciled, removed.

### NotificationPermissionState (concept → encoded in Cubit state)

Whether the user has been asked and the outcome.

| Value | Meaning |
|---|---|
| notRequested | Permission prompt never shown |
| granted | User granted; token retrievable |
| denied | User denied; app continues, no re-prompt |

- Persisted flag: `permission_requested` (bool) in Hive box `notification_prefs`.

### DevicePushToken (value)

Platform-issued targeting identifier; may rotate.

| Field | Type | Notes |
|---|---|---|
| token | String? | Current FCM token; null if unavailable |
| refreshStream | Stream<String> | Emits updated token on rotation |

- **Exposure**: local only — no backend upload (Clarification Q1).

## Presentation state — NotificationState (Freezed union)

Maps FR-013 to a closed set of states.

| State | Payload | When |
|---|---|---|
| `initial` | — | Before init |
| `permissionRequesting` | — | While OS prompt in flight |
| `permissionGranted` | `String? token` | Granted; token obtained |
| `permissionDenied` | — | Denied; app continues |
| `error` | `Failure failure` | Init/permission/token error |

## Failures (reuse existing core failures — dartz Either)

`ServerFailure`, `CacheFailure`, `NetworkFailure` (existing). Repository methods return
`Either<Failure, T>`:

- `requestPermission()` → `Either<Failure, bool>` (granted?)
- `getToken()` → `Either<Failure, String?>`

## Relationships

```text
NotificationCubit ──uses──▶ RequestNotificationPermission ──▶ NotificationRepository ──▶ NotificationService
                  └─uses──▶ GetFcmToken ─────────────────────▶ NotificationRepository ──▶ NotificationService
NotificationService ──emits──▶ NotificationEntity (on tap)  ──▶ navigatorKey.go(deeplink ?? Home)
```
