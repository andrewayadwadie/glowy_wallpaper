# Contract: Notification feature interfaces

UI contract for a Flutter app — internal Dart interfaces (no external HTTP API). Documents the
domain service, repository, use cases, and Cubit surface.

## NotificationService (domain/services) — abstract

```dart
abstract class NotificationService {
  Future<void> initialize();                  // one-time; call after Firebase init, before runApp
  Future<bool> requestPermission();           // OS prompt; returns granted; persists requested flag
  Future<String?> getFcmToken();              // current token or null
  Stream<String> get onTokenRefresh;          // token rotations
  bool get hasRequestedPermission;            // de-dup re-prompt
  Stream<NotificationEntity> get onNotificationTap; // foreground/background taps
  NotificationEntity? get initialNotification;      // terminated-state launch (consume once)
  void clearInitialNotification();
  Future<void> dispose();
}
```

Behavioral contract:

- `initialize()` MUST NOT throw on missing Firebase config (caught upstream in main); MUST register
  `onMessage`, `onMessageOpenedApp`, background handler, and create the `glowy_high_importance` channel.
- Foreground `onMessage` → show local notification (big-picture if imageUrl else big-text), payload = deeplink.
- Tap (`onDidReceiveNotificationResponse`, `onMessageOpenedApp`) → emit `NotificationEntity` on `onNotificationTap`.
- Terminated launch (`getInitialMessage`) → exposed via `initialNotification`, consumed once after app init.

## NotificationRepository (domain/repositories) — abstract

```dart
abstract class NotificationRepository {
  Future<Either<Failure, bool>> requestPermission();
  Future<Either<Failure, String?>> getToken();
  Stream<String> get tokenRefreshes;
  Stream<NotificationEntity> get taps;
}
```

## Use cases (domain/usecases)

```dart
class RequestNotificationPermission {  // call() => Future<Either<Failure, bool>>
  final NotificationRepository repository;
}
class GetFcmToken {                     // call() => Future<Either<Failure, String?>>
  final NotificationRepository repository;
}
```

## NotificationCubit (presentation/cubit)

```dart
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({ required this.requestPermission, required this.getFcmToken });
  Future<void> initNotifications();   // request perm → on grant fetch token → emit states
  // listens to taps → navigatorKey-based navigation (deeplink ?? Home)
  // dispose subscriptions in close()
}
```

State union: `initial | permissionRequesting | permissionGranted(token) | permissionDenied | error(failure)`.

## Navigation contract (AppRouter)

```dart
abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GoRouter router = GoRouter(navigatorKey: navigatorKey, /* ... */);
}
```

- Tap navigation MUST use `router.go(deeplink)` (declarative), never `Navigator.push` (FR-015).
- Invalid/missing deeplink → `router.go(AppRoutes.home)`.
