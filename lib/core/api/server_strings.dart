import '../config/env.dart';

abstract class ServerStrings {
  static String get baseUrl => Env.apiBaseUrl;
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String categories = '/categories';
  static const String wallpapers = '/wallpapers';
  static const String favorites = '/favorites';
  static const String subscriptionStatus = '/subscription/status';
}
