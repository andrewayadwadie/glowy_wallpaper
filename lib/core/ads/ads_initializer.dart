import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../di/injection_container.dart';
import 'ad_ids.dart';
import 'consent_manager.dart';
import 'managers/app_open_ad_manager.dart';
import 'managers/interstitial_ad_manager.dart';
import 'managers/rewarded_ad_manager.dart';

/// Startup pipeline for the ad stack (research R5): gather consent first,
/// then initialize the Mobile Ads SDK, then preload full-screen formats.
///
/// Called once from `main()` before `runApp`. Never throws — any failure is
/// logged and the app launches normally without ads (FR-026, SC-001).
class AdsInitializer {
  AdsInitializer(this._consentManager, this._mobileAds);

  final ConsentManager _consentManager;
  final MobileAds _mobileAds;

  Future<void> initialize() async {
    try {
      await _consentManager.gather();
    } catch (e) {
      debugPrint('Consent gathering failed: $e');
    }

    try {
      await _mobileAds.initialize();
      await _mobileAds.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: AdIds.testDeviceIds),
      );
      debugPrint('MobileAds initialized');
    } catch (e) {
      debugPrint('MobileAds initialization failed: $e');
      return;
    }

    // Preload full-screen formats so the first trigger has an ad ready.
    // Guarded: only managers already registered in DI are touched, and a
    // preload failure never propagates.
    if (sl.isRegistered<RewardedAdManager>()) {
      unawaited(sl<RewardedAdManager>().preload());
    }
    if (sl.isRegistered<InterstitialAdManager>()) {
      unawaited(sl<InterstitialAdManager>().preload());
    }
    if (sl.isRegistered<AppOpenAdManager>()) {
      unawaited(sl<AppOpenAdManager>().loadAd());
    }
  }
}
