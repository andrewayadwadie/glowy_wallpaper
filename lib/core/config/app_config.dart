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
  static const String appId = '809a555c-34b9-4899-9c07-d0e295e2b2e5';

  // Environment
  static const bool isProduction = true;
  static const bool enableLogging = false;

  // API Configuration
  // NOTE: On Android emulator, "localhost" resolves to the emulator itself, not the host machine.
  // Use 10.0.2.2 to reach the host machine's localhost from within the emulator.
  // On iOS simulator, "localhost" works fine.
  // For a physical device, use your machine's local network IP (e.g. 192.168.x.x).
  static const String _devHost = '16.171.121.31';
  static const int _devPort = 3000;

  static String get baseUrl {
    return isProduction
        ? 'http://16.171.121.31:3000'
        : 'http://$_devHost:$_devPort';
  }
}
