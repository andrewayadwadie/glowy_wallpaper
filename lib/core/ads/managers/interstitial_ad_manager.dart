// TODO(ads-disabled-018): entire ad layer paused — restore by removing this
// header and the closing block comment below. See specs/018-disable-ads-isolate-downloads/.
/*
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utils/constants.dart';
import '../ad_gatekeeper.dart';
import '../ad_ids.dart';

/// Seam for the static [InterstitialAd.load] so tests can drive load
/// callbacks without the live SDK (constitution VII).
typedef InterstitialAdLoader =
    Future<void> Function({
      required String adUnitId,
      required AdRequest request,
      required InterstitialAdLoadCallback adLoadCallback,
    });

/// Frequency-capped interstitial on category navigation
/// (US4, FR-014–FR-017).
///
/// Cap/cooldown state is in-memory per session (clarification Q1, R9):
/// shows at most once per [switchCap] switches AND at least [cooldown]
/// apart. Never blocks navigation — silent no-op when conditions are unmet.
class InterstitialAdManager {
  InterstitialAdManager(
    this._adIds,
    this._gatekeeper, {
    FirebaseAnalytics? analytics,
    InterstitialAdLoader? loader,
    DateTime Function()? now,
  }) : _analytics = analytics,
       _loader = loader ?? InterstitialAd.load,
       _now = now ?? DateTime.now;

  final AdIds _adIds;
  final AdGatekeeper _gatekeeper;
  final FirebaseAnalytics? _analytics;
  final InterstitialAdLoader _loader;
  final DateTime Function() _now;

  /// Category switches required between shows (FR-015).
  static const int switchCap = 4;

  /// Minimum interval between interstitial shows (FR-015).
  static const Duration cooldown = Duration(seconds: 60);

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  int _switchesSinceLastShow = 0;
  DateTime? _lastShownAt;

  /// Preload an interstitial (dedupes). No-op for premium users.
  Future<void> preload() async {
    if (!_gatekeeper.shouldShowAds) return;
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;
    try {
      await _loader(
        adUnitId: _adIds.idFor(AdPlacement.categoryInterstitial),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('InterstitialAd loaded');
            _interstitialAd = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('InterstitialAd failed to load: $error');
            _interstitialAd = null;
            _isLoading = false;
            _logEvent(AppConstants.adFailedEvent);
          },
        ),
      );
    } catch (e) {
      debugPrint('InterstitialAd load exception: $e');
      _isLoading = false;
    }
  }

  /// Notifies the manager that a category switch happened. Increments the
  /// switch counter and shows the interstitial only when cap + cooldown +
  /// loaded-ad + shouldShowAds are all satisfied (FR-015/016).
  void onCategorySwitched() {
    if (!_gatekeeper.shouldShowAds) return;

    _switchesSinceLastShow++;
    if (_switchesSinceLastShow < switchCap) return;
    if (!_cooldownElapsed) return;

    final ad = _interstitialAd;
    if (ad == null) {
      // Switch proceeds ad-free; make sure the next trigger has inventory.
      unawaited(preload());
      return;
    }

    _showAd(ad);
  }

  /// Legacy action gate (favorite add): shows the interstitial if one is
  /// loaded and the cooldown has elapsed, then always invokes [onComplete]
  /// — immediately when no ad is shown. Never blocks the action.
  void showOnAction({required VoidCallback onComplete}) {
    if (!_gatekeeper.shouldShowAds || !_cooldownElapsed) {
      onComplete();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      unawaited(preload());
      onComplete();
      return;
    }

    _showAd(ad, onComplete: onComplete);
  }

  bool get _cooldownElapsed =>
      _lastShownAt == null || _now().difference(_lastShownAt!) >= cooldown;

  void _showAd(InterstitialAd ad, {VoidCallback? onComplete}) {
    // Single-use: claim the ad, reset cap state (R9).
    _interstitialAd = null;
    _switchesSinceLastShow = 0;
    _lastShownAt = _now();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('InterstitialAd shown');
        _logEvent(AppConstants.adShownEvent);
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _logEvent(AppConstants.adDismissedEvent);
        unawaited(preload());
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _logEvent(AppConstants.adFailedEvent);
        unawaited(preload());
        onComplete?.call();
      },
    );

    unawaited(ad.show());
  }

  void _logEvent(String name) {
    _analytics?.logEvent(
      name: name,
      parameters: {
        AppConstants.adTypeParam: 'interstitial',
        AppConstants.adPlacementParam:
            AdPlacement.categoryInterstitial.analyticsName,
      },
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
*/
