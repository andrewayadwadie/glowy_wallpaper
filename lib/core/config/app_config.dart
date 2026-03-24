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
  static const String feedbackEmail = 'support@glowywallpapers.com';

  // Environment
  static const bool isProduction = false;
  static const bool enableLogging = true;

  // API Configuration
  static String get baseUrl {
    return isProduction ? 'http://localhost:3001' : 'http://localhost:3001';
  }
}
