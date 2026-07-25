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

/// Seam for the static [AppOpenAd.load] so tests can drive load callbacks
/// without the live SDK (constitution VII).
typedef AppOpenAdLoader =
    Future<void> Function({
      required String adUnitId,
      required AdRequest request,
      required AppOpenAdLoadCallback adLoadCallback,
    });

/// Shows an App Open ad after splash and on foreground resume
/// (US2, FR-007–FR-010a). Replaces `AdHelper.loadAppOpenAd`/`showAppOpenAd`.
///
/// Invariants: 4h staleness (FR-008), no stacked full-screen ads (FR-009),
/// reload after dismissal/failure (FR-010), resume cap ≥4 min (FR-010a).
class AppOpenAdManager {
  AppOpenAdManager(
    this._adIds,
    this._gatekeeper, {
    FirebaseAnalytics? analytics,
    AppOpenAdLoader? loader,
    DateTime Function()? now,
  }) : _analytics = analytics,
       _loader = loader ?? AppOpenAd.load,
       _now = now ?? DateTime.now;

  final AdIds _adIds;
  final AdGatekeeper _gatekeeper;
  final FirebaseAnalytics? _analytics;
  final AppOpenAdLoader _loader;
  final DateTime Function() _now;

  /// A preloaded ad older than this is stale and discarded (FR-008).
  static const Duration maxCacheAge = Duration(hours: 4);

  /// Minimum interval between foreground-resume shows (FR-010a).
  static const Duration resumeCooldown = Duration(minutes: 4);

  /// [showIfAvailable] `source` values.
  static const String sourceSplash = 'splash';
  static const String sourceResume = 'resume';

  AppOpenAd? _appOpenAd;
  DateTime? _loadTime;
  bool _isShowingAd = false;
  bool _isLoading = false;
  DateTime? _lastShownAt;
  bool _appLaunchHandled = false;

  /// Whether an app-open ad is currently on screen (FR-009 guard).
  bool get isShowingAd => _isShowingAd;

  bool get _isAdAvailable =>
      _appOpenAd != null &&
      _loadTime != null &&
      _now().difference(_loadTime!) < maxCacheAge;

  /// Preload an app-open ad and record its load time. Dedupes concurrent
  /// loads; a no-op when an ad is already cached or the user is premium.
  Future<void> loadAd() async {
    if (!_gatekeeper.shouldShowAds) return;
    if (_isLoading || _appOpenAd != null) return;

    _isLoading = true;
    try {
      await _loader(
        adUnitId: _adIds.idFor(AdPlacement.appOpen),
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AppOpenAd loaded');
            _appOpenAd = ad;
            _loadTime = _now();
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('AppOpenAd failed to load: $error');
            _appOpenAd = null;
            _isLoading = false;
            _logEvent(AppConstants.adFailedEvent);
          },
        ),
      );
    } catch (e) {
      debugPrint('AppOpenAd load exception: $e');
      _isLoading = false;
    }
  }

  /// Shows the ad if a fresh one is available and no full-screen ad is
  /// already showing. Non-blocking: returns immediately when not eligible.
  ///
  /// [source] is [sourceSplash] or [sourceResume] — used for analytics and
  /// the resume cooldown. The cold-start foreground is owned by the splash
  /// call; the first resume signal is swallowed if splash never ran.
  Future<void> showIfAvailable({required String source}) async {
    if (source == sourceSplash) _appLaunchHandled = true;

    if (!_gatekeeper.shouldShowAds) return;
    if (_isShowingAd) return;

    if (source == sourceResume) {
      if (!_appLaunchHandled) {
        _appLaunchHandled = true;
        return;
      }
      if (_lastShownAt != null &&
          _now().difference(_lastShownAt!) < resumeCooldown) {
        return;
      }
    }

    if (!_isAdAvailable) {
      // Stale or missing — discard and refresh the cache (FR-008).
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _loadTime = null;
      unawaited(loadAd());
      return;
    }

    final ad = _appOpenAd!;
    _appOpenAd = null;
    _loadTime = null;
    // Set synchronously so a racing second call can't stack ads (FR-009).
    _isShowingAd = true;
    _lastShownAt = _now();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('AppOpenAd shown ($source)');
        _logEvent(AppConstants.adShownEvent, source: source);
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _logEvent(AppConstants.adDismissedEvent, source: source);
        unawaited(loadAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpenAd failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _logEvent(AppConstants.adFailedEvent, source: source);
        unawaited(loadAd());
      },
    );

    await ad.show();
  }

  void _logEvent(String name, {String? source}) {
    _analytics?.logEvent(
      name: name,
      parameters: {
        AppConstants.adTypeParam: 'app_open',
        AppConstants.adPlacementParam: AdPlacement.appOpen.analyticsName,
        AppConstants.adSourceParam: ?source,
      },
    );
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _loadTime = null;
  }
}
*/
