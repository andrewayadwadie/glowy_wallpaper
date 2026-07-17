import 'env.dart';

/// Application Configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'Glowy Wallpaper';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Store IDs — replace with actual IDs before publishing
  static const String androidPackageName = 'com.glowy.wallpaper';
  static const String iosAppId =
      '000000000'; // Replace with actual App Store ID
  static const String feedbackEmail =
      'support@glowywallpapers.com'; // fallback only — real value from bootstrap API

  // Backend App ID — used in all API routes: /api/v1/mobile/apps/{appId}/...
  static const String appId = '809a555c-34b9-4899-9c07-d0e295e2b2e5';

  // Environment
  static const bool isProduction = true;
  static const bool enableLogging = false;

  // API base URL is driven by the .env.prod file via envied — no hardcoded URLs.
  static String get baseUrl => Env.apiBaseUrl;
}
