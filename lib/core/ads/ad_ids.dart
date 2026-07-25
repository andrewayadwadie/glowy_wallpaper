// TODO(ads-disabled-018): entire ad layer paused — restore by removing this
// header and the closing block comment below. See specs/018-disable-ads-isolate-downloads/.
/*
import 'package:flutter/foundation.dart';

import '../config/env.dart';

/// The four monetization surfaces (spec 016, data-model §1).
/// Drives ad unit ID resolution and the analytics `placement` param.
enum AdPlacement {
  rewardedDownload('rewarded_download'),
  appOpen('app_open'),
  homeBanner('home_banner'),
  categoryInterstitial('category_interstitial');

  const AdPlacement(this.analyticsName);

  /// Value sent as the `placement`/`ad_type` analytics parameter.
  final String analyticsName;
}

/// Resolves ad unit IDs by build mode (test vs prod) and platform.
///
/// - Debug/profile builds always use Google's public TEST unit IDs so no
///   live inventory is ever requested outside release builds (FR-019/020).
/// - Release builds use production IDs from [Env] (`.env.prod` via envied).
///   iOS prod fields currently hold test placeholders until real iOS unit
///   IDs are supplied.
///
/// The AdMob App ID is configured natively (AndroidManifest / Info.plist),
/// not here.
class AdIds {
  AdIds({bool? isRelease, TargetPlatform? platform})
    : _isRelease = isRelease ?? kReleaseMode,
      _platform = platform ?? defaultTargetPlatform;

  final bool _isRelease;
  final TargetPlatform _platform;

  /// Device IDs registered for safe live testing
  /// (`RequestConfiguration.testDeviceIds`). The SDK logs each device's ID
  /// on its first ad request — add it here when testing on a real device.
  static const List<String> testDeviceIds = <String>[];

  // Google-published test unit IDs (public constants — safe to hardcode).
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testAppOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppOpenIos =
      'ca-app-pub-3940256099942544/5575463023';
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  bool get _isIos => _platform == TargetPlatform.iOS;

  /// Resolved unit ID for [placement]. Never returns an empty string.
  String idFor(AdPlacement placement) {
    if (!_isRelease) {
      switch (placement) {
        case AdPlacement.rewardedDownload:
          return _isIos ? _testRewardedIos : _testRewardedAndroid;
        case AdPlacement.appOpen:
          return _isIos ? _testAppOpenIos : _testAppOpenAndroid;
        case AdPlacement.homeBanner:
          return _isIos ? _testBannerIos : _testBannerAndroid;
        case AdPlacement.categoryInterstitial:
          return _isIos ? _testInterstitialIos : _testInterstitialAndroid;
      }
    }
    switch (placement) {
      case AdPlacement.rewardedDownload:
        return _isIos ? Env.adMobRewardedIosId : Env.adMobRewardedId;
      case AdPlacement.appOpen:
        return _isIos ? Env.adMobAppOpenIosId : Env.adMobAppOpenId;
      case AdPlacement.homeBanner:
        return _isIos ? Env.adMobBannerIosId : Env.adMobBannerId;
      case AdPlacement.categoryInterstitial:
        return _isIos ? Env.adMobInterstitialIosId : Env.adMobInterstitialId;
    }
  }
}
*/
