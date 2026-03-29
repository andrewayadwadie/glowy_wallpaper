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
  // Replace with actual backend app ID before publishing
  static const String appId = 'dcb4ac5f-17b9-4938-b0a9-8f1e78c4beb6';

  // Environment
  static const bool isProduction = false;
  static const bool enableLogging = true;

  // API Configuration
  // NOTE: On Android emulator, "localhost" resolves to the emulator itself, not the host machine.
  // Use 10.0.2.2 to reach the host machine's localhost from within the emulator.
  // On iOS simulator, "localhost" works fine.
  // For a physical device, use your machine's local network IP (e.g. 192.168.x.x).
  static const String _devHost = '10.0.2.2';
  static const int _devPort = 3001;

  static String get baseUrl {
    return isProduction
        ? 'https://api.glowywallpapers.com'
        : 'http://$_devHost:$_devPort';
  }
}
