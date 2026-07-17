import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/services/notification_service.dart';

/// Background isolate handler. Runs in a separate isolate — MUST NOT access
/// GetIt or any app singletons (FR-012). Deep links for background/terminated
/// taps are delivered via onMessageOpenedApp / getInitialMessage, not here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

const String kChannelId = 'glowy_high_importance';
const String _channelName = 'Glowy High Importance';
const String _channelDescription =
    'High importance notifications for new wallpapers and updates';
const String _permissionRequestedKey = 'permission_requested';
const String _prefsBoxName = 'notification_prefs';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationEntity> _tapController =
      StreamController<NotificationEntity>.broadcast();

  NotificationEntity? _initialNotification;
  Box? _prefsBox;

  @override
  NotificationEntity? get initialNotification => _initialNotification;

  @override
  void clearInitialNotification() => _initialNotification = null;

  @override
  bool get hasRequestedPermission =>
      _prefsBox?.get(_permissionRequestedKey, defaultValue: false) as bool? ??
      false;

  @override
  Stream<NotificationEntity> get onNotificationTap => _tapController.stream;

  @override
  Future<void> initialize() async {
    _prefsBox = await Hive.openBox(_prefsBoxName);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
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
        final deeplink = response.payload;
        _tapController.add(_entityFromDeeplink(deeplink));
      },
    );

    // Android high-importance channel (single source of truth: kChannelId).
    const channel = AndroidNotificationChannel(
      kChannelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Foreground FCM message -> show a visible local notification.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap (app was in background).
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _tapController.add(_entityFromMessage(message));
    });

    // Background data message handler (separate isolate).
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Terminated state: app launched via a notification tap.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _initialNotification = _entityFromMessage(initialMessage);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return; // data-only: nothing user-visible.

    unawaited(
      FirebaseAnalytics.instance.logEvent(name: 'notification_receive'),
    );

    final entity = _entityFromMessage(message);
    final styleInformation = await _buildStyleInformation(entity);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          kChannelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFF22D3EE),
          styleInformation: styleInformation,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: entity.deeplink,
    );
  }

  /// Big-picture style when an image is available (download succeeds),
  /// otherwise expandable big-text. Download failure degrades to big-text.
  Future<StyleInformation> _buildStyleInformation(
    NotificationEntity entity,
  ) async {
    final bigText = BigTextStyleInformation(entity.body);
    final imageUrl = entity.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return bigText;

    try {
      final path = await _downloadToFile(imageUrl);
      if (path == null) return bigText;
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(path),
        contentTitle: entity.title,
        summaryText: entity.body,
      );
    } catch (_) {
      return bigText;
    }
  }

  Future<String?> _downloadToFile(String url) async {
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return null;
      final bytes = await consolidateHttpClientResponseBytes(response);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/notif_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      return file.path;
    } finally {
      httpClient.close();
    }
  }

  @override
  Future<String?> getFcmToken() => FirebaseMessaging.instance.getToken();

  @override
  Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

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

  NotificationEntity _entityFromMessage(RemoteMessage message) {
    final notification = message.notification;
    final imageUrl =
        message.data['imageUrl'] as String? ??
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl;
    return NotificationEntity(
      title: notification?.title ?? '',
      body: notification?.body ?? '',
      deeplink: validDeeplink(message.data['deeplink'] as String?),
      imageUrl: imageUrl,
    );
  }

  NotificationEntity _entityFromDeeplink(String? deeplink) =>
      NotificationEntity(deeplink: validDeeplink(deeplink));

  /// A deep link is honored only if it is a route starting with `/`.
  /// Returns null for missing/malformed links (callers fall back to Home).
  static String? validDeeplink(String? value) {
    if (value == null || !value.startsWith('/')) return null;
    return value;
  }

  @override
  Future<void> dispose() async {
    await _tapController.close();
  }
}
