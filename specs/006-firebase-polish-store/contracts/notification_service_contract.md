# Contract: NotificationService

**Layer**: Domain (`lib/features/notifications/domain/services/`)
**Type**: Abstract class (interface)
**Scope**: App-wide singleton — registered as `LazySingleton<NotificationService>` in GetIt

---

## Interface Definition

```dart
abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  bool get hasRequestedPermission;
  String? get pendingRoute;
  void clearPendingRoute();
  Stream<NotificationPayload> get onNotificationTap;
}
```

---

## Method Contracts

### `initialize() → Future<void>`

**Pre-conditions**:
- Must be called before `runApp()` in `main.dart`.
- Firebase must already be initialized (`Firebase.initializeApp()` called before this).

**Behavior**:
1. Initializes `FlutterLocalNotificationsPlugin` with Android and iOS settings.
2. Creates Android notification channel (`high_importance_channel`, Importance.max).
3. Registers `FirebaseMessaging.onMessage` listener → calls `flutterLocalNotificationsPlugin.show()`.
4. Registers `FirebaseMessaging.onMessageOpenedApp` listener → sets `pendingRoute`.
5. Registers `FirebaseMessaging.onBackgroundMessage` top-level handler.
6. Calls `getInitialMessage()` and stores route in `pendingRoute` if the app was launched from a terminated-state notification.
7. Opens the Hive `notification_prefs` box.

**Post-conditions**:
- Service is ready to receive and display FCM notifications.
- `pendingRoute` may be set if app was launched via notification tap.

**Error handling**: Logs any initialization errors to `FirebaseCrashlytics`; does not throw.

---

### `requestPermission() → Future<bool>`

**Pre-conditions**: `initialize()` has been called.

**Behavior**:
1. Calls `FirebaseMessaging.instance.requestPermission()`.
2. Sets `hasRequestedPermission = true` in Hive (even if denied).
3. Logs `notification_permission_requested` event to `FirebaseAnalytics` with `{granted: bool}`.
4. Returns `true` if `AuthorizationStatus.authorized` or `AuthorizationStatus.provisional`.

**Post-conditions**: `hasRequestedPermission == true` regardless of grant outcome.

---

### `hasRequestedPermission → bool`

**Behavior**: Reads `notification_prefs` Hive box key `permission_requested`. Returns false if box is empty or key absent.

---

### `pendingRoute → String?`

**Behavior**: In-memory nullable string. Set when a notification with a `route` data field is tapped. Null if no pending navigation.

---

### `clearPendingRoute() → void`

**Behavior**: Sets `pendingRoute = null`. Called by GoRouter redirect after consuming the route.

---

### `onNotificationTap → Stream<NotificationPayload>`

**Behavior**: Emits a `NotificationPayload` when the user taps a foreground local notification (fired via `flutter_local_notifications` `onDidReceiveNotificationResponse`).

**Does NOT emit** for background or terminated taps — those use the `pendingRoute` mechanism.

---

## Implementation Notes

### Background Message Handler

Must be a **top-level function** (not a class method) due to FCM background isolate constraint:

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Store route if present — cannot use GetIt here (different isolate)
  // Route is retrieved via getInitialMessage() on next app launch
}
```

### Route Extraction

From FCM `RemoteMessage`:
```dart
String? _extractRoute(RemoteMessage message) {
  return message.data['route'] as String?;
}
```

Validation: route must start with `/`; if not, treat as null (navigate to home).

---

## Test Contract

| Scenario | Expected |
|----------|----------|
| `initialize()` called, FCM message received while foreground | `FlutterLocalNotificationsPlugin.show()` called once |
| `initialize()` called, user taps background notification with `route: '/wallpaper/x'` | `pendingRoute == '/wallpaper/x'` |
| `requestPermission()` called | `hasRequestedPermission == true` after call |
| `clearPendingRoute()` called | `pendingRoute == null` |
| FCM message with no `route` field | `pendingRoute` remains null |
| FCM message with invalid route (no leading `/`) | `pendingRoute` remains null |
