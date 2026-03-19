import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'ADMOB_APP_ID')
  static const String adMobAppId = _Env.adMobAppId;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY')
  static const String stripePublishableKey = _Env.stripePublishableKey;
}
