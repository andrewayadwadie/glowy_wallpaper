# Data Model: Firebase, Polish & Store Readiness

**Feature**: 006-firebase-polish-store | **Date**: 2026-03-25

---

## New Entities

### NotificationPayload

Represents the data extracted from a push notification message. Created when FCM delivers a notification and used to drive navigation.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `title` | String | Yes | Notification title text |
| `body` | String | Yes | Notification body text |
| `route` | String? | No | GoRouter path to navigate to (e.g., `/wallpaper/abc123`) |
| `data` | Map<String, String> | No | Raw FCM data payload for additional parameters |

**Validation rules**:
- `route`, if present, must start with `/` and match a defined AppRoute.
- If `route` is null or unrecognised, navigation falls back to `/` (Home).

**State transitions**: None. Immutable value object.

**Dart representation**:
```dart
// lib/features/notifications/domain/entities/notification_payload.dart
@freezed
abstract class NotificationPayload with _$NotificationPayload {
  const factory NotificationPayload({
    required String title,
    required String body,
    String? route,
    @Default({}) Map<String, String> data,
  }) = _NotificationPayload;
}
```

---

### ContentType (enum)

Identifies which bootstrap API field to render in the shared `ContentPage`.

| Value | Bootstrap Field | Drawer Menu Item |
|-------|-----------------|-----------------|
| `about` | `data.app.about` | About |
| `privacyPolicy` | `data.app.privacyPolicy` | Privacy Policy |
| `termsOfUse` | `data.app.termsOfUse` | Terms of Use |

**Dart representation**:
```dart
// lib/core/enums/content_type.dart
enum ContentType { about, privacyPolicy, termsOfUse }
```

---

## Updated Hive Boxes

### `notification_prefs` (new Hive box)

Stores lightweight notification preferences. Box name: `notification_prefs`.

| Key | Type | Default | Purpose |
|-----|------|---------|---------|
| `permission_requested` | bool | false | Whether the FCM permission dialog has been shown. Set to true after first request regardless of grant outcome. |

**Access pattern**: Read in `NotificationServiceImpl.hasRequestedPermission`. Written by `WallpaperDetailCubit` after the first successful download or favorite.

---

## Existing Entities Referenced (no changes)

### AppConfigModel (existing — `lib/features/home/data/models/`)

Fields consumed by new drawer actions:

| Field | Used By |
|-------|---------|
| `contactEmail` | Send Feedback (`mailto:` link) |
| `androidShareLink` | Share App (Android), Rate App fallback URL |
| `iphoneShareLink` | Share App (iOS), Rate App App Store URL |
| `about` | About page content |
| `privacyPolicy` | Privacy Policy page content |
| `termsOfUse` | Terms of Use page content |

No structural changes to `AppConfigModel`. All fields are already returned by the bootstrap API (API-1) and cached.

---

## Service Contracts (not data entities)

### NotificationService (abstract)

Lives in domain layer: `lib/features/notifications/domain/services/notification_service.dart`

```dart
abstract class NotificationService {
  /// One-time initialization: FCM + flutter_local_notifications setup.
  /// Must be called before runApp().
  Future<void> initialize();

  /// Request FCM permission from the OS. Returns true if granted.
  Future<bool> requestPermission();

  /// Whether permission has already been requested in a previous session.
  bool get hasRequestedPermission;

  /// Route string to navigate to after login, set from a notification tap.
  String? get pendingRoute;

  /// Clear the pending route after navigation is complete.
  void clearPendingRoute();

  /// Stream of notification taps (foreground notifications only).
  Stream<NotificationPayload> get onNotificationTap;
}
```

**Registration**: `sl.registerLazySingleton<NotificationService>(() => NotificationServiceImpl())`
