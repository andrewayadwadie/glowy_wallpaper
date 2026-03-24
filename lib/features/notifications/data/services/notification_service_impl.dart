import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/notification_payload.dart';
import '../../domain/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: cannot use GetIt or any app singletons.
  // The route is retrieved via getInitialMessage() on next cold start.
}

const String _channelId = 'high_importance_channel';
const String _channelName = 'High Importance Notifications';
const String _permissionRequestedKey = 'permission_requested';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationPayload> _tapController =
      StreamController<NotificationPayload>.broadcast();

  String? _pendingRoute;
  Box? _prefsBox;

  @override
  String? get pendingRoute => _pendingRoute;

  @override
  void clearPendingRoute() => _pendingRoute = null;

  @override
  bool get hasRequestedPermission =>
      _prefsBox?.get(_permissionRequestedKey, defaultValue: false) as bool? ??
      false;

  @override
  Stream<NotificationPayload> get onNotificationTap => _tapController.stream;

  @override
  Future<void> initialize() async {
    _prefsBox = await Hive.openBox('notification_prefs');

    // Local notifications setup
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) {
          _tapController.add(
            NotificationPayload(title: '', body: '', route: route),
          );
        }
      },
    );

    // Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Foreground FCM message → show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      final route = _extractRoute(message);
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: route,
      );
    });

    // Background tap (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final route = _extractRoute(message);
      if (route != null) _pendingRoute = route;
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Terminated state: app launched via notification tap
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final route = _extractRoute(initialMessage);
      if (route != null) _pendingRoute = route;
    }
  }

  @override
  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await _prefsBox?.put(_permissionRequestedKey, true);
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  String? _extractRoute(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route == null || !route.startsWith('/')) return null;
    return route;
  }

  void dispose() {
    _tapController.close();
  }
}
