import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:glowy_wallpaper/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glowy_wallpaper/core/di/injection_container.dart';
import 'package:glowy_wallpaper/features/notifications/domain/services/notification_service.dart';
import 'package:glowy_wallpaper/core/services/ad_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('user_cache');
  await Hive.openBox('categories');
  await Hive.openBox('favorites');
  await Hive.openBox('downloads');
  await Hive.openBox<String>('subscription_cache');
  await Hive.openBox<String>('ad_frequency');
  await Hive.openBox('app_bootstrap');
  await init();

  try {
    await Firebase.initializeApp();
    await sl<NotificationService>().initialize();
    await AdHelper.instance.initialize();
  } catch (e) {
    // Firebase/notification/ads initialization failed but don't block the app
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const GlowyApp(),
    ),
  );
}
