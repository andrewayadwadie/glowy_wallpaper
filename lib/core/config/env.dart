import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.prod')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'ADMOB_APP_ID')
  static const String adMobAppId = _Env.adMobAppId;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY')
  static const String stripePublishableKey = _Env.stripePublishableKey;

  @EnviedField(varName: 'ADMOB_BANNER_ID')
  static const String adMobBannerId = _Env.adMobBannerId;

  @EnviedField(varName: 'ADMOB_APP_OPEN_ID')
  static const String adMobAppOpenId = _Env.adMobAppOpenId;

  @EnviedField(varName: 'ADMOB_REWARDED_INTERSTITIAL_ID')
  static const String adMobRewardedInterstitialId =
      _Env.adMobRewardedInterstitialId;

  @EnviedField(varName: 'ADMOB_INTERSTITIAL_ID')
  static const String adMobInterstitialId = _Env.adMobInterstitialId;

  @EnviedField(varName: 'IAP_MONTHLY_PRODUCT_ID')
  static const String iapMonthlyProductId = _Env.iapMonthlyProductId;

  @EnviedField(varName: 'IAP_YEARLY_PRODUCT_ID')
  static const String iapYearlyProductId = _Env.iapYearlyProductId;
}
