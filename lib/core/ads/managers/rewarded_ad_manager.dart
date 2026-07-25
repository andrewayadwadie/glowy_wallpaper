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
import '../ad_network_error.dart';

/// Seam for the static [RewardedAd.load] so tests can drive load callbacks
/// without the live SDK (constitution VII).
typedef RewardedAdLoader =
    Future<void> Function({
      required String adUnitId,
      required AdRequest request,
      required RewardedAdLoadCallback rewardedAdLoadCallback,
    });

enum _LoadResult { loaded, failedNetwork, failedOther, timeout }

/// Gates wallpaper downloads behind a Rewarded ad with
/// reward-or-network-fallback semantics (US1, FR-001–FR-006).
///
/// Replaces `AdHelper.showRewardedInterstitialAd` for downloads. Exactly one
/// of the two callbacks fires per [showRewardedForDownload] call:
/// - reward earned, NETWORK failure, or premium → `onRewardGranted`
/// - early dismissal or non-network failure → `onDismissedWithoutReward`
class RewardedAdManager {
  RewardedAdManager(
    this._adIds,
    this._gatekeeper, {
    FirebaseAnalytics? analytics,
    RewardedAdLoader? loader,
  }) : _analytics = analytics,
       _loader = loader ?? RewardedAd.load;

  final AdIds _adIds;
  final AdGatekeeper _gatekeeper;
  final FirebaseAnalytics? _analytics;
  final RewardedAdLoader _loader;

  /// Bounded cold-start wait when no ad is preloaded at tap (R3, FR-003).
  static const Duration loadTimeout = Duration(seconds: 5);

  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  Completer<_LoadResult>? _loadCompleter;

  /// Preload ahead of need. Safe to call repeatedly (dedupes).
  Future<void> preload() async {
    if (!_gatekeeper.shouldShowAds) return;
    await _loadAd();
  }

  Future<_LoadResult> _loadAd() {
    if (_rewardedAd != null) return Future.value(_LoadResult.loaded);
    if (_isLoading) return _loadCompleter!.future;

    _isLoading = true;
    final completer = Completer<_LoadResult>();
    _loadCompleter = completer;

    void finish(_LoadResult result) {
      _isLoading = false;
      if (!completer.isCompleted) completer.complete(result);
    }

    _loader(
      adUnitId: _adIds.idFor(AdPlacement.rewardedDownload),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded');
          _rewardedAd = ad;
          finish(_LoadResult.loaded);
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _logEvent(AppConstants.adFailedEvent);
          finish(
            AdNetworkError.isNetworkError(error)
                ? _LoadResult.failedNetwork
                : _LoadResult.failedOther,
          );
        },
      ),
    ).catchError((Object e) {
      debugPrint('RewardedAd load exception: $e');
      finish(_LoadResult.failedOther);
    });

    return completer.future;
  }

  /// Shows the rewarded ad for a download. See class docs for callback
  /// semantics. Never blocks beyond ~[loadTimeout] when no ad is preloaded.
  Future<void> showRewardedForDownload({
    required VoidCallback onRewardGranted,
    VoidCallback? onDismissedWithoutReward,
  }) async {
    if (!_gatekeeper.shouldShowAds) {
      onRewardGranted();
      return;
    }

    if (_rewardedAd == null) {
      final result = await _loadAd().timeout(
        loadTimeout,
        onTimeout: () => _LoadResult.timeout,
      );
      if (_rewardedAd == null) {
        // Timeout (slow fill) and network failures degrade gracefully to a
        // granted download (FR-002); any other failure does not (FR-004).
        if (result == _LoadResult.failedOther) {
          onDismissedWithoutReward?.call();
        } else {
          onRewardGranted();
        }
        return;
      }
    }

    _show(onRewardGranted, onDismissedWithoutReward);
  }

  void _show(
    VoidCallback onRewardGranted,
    VoidCallback? onDismissedWithoutReward,
  ) {
    // Single-use: claim the ad so a concurrent call can't reuse it (FR-005).
    final ad = _rewardedAd!;
    _rewardedAd = null;

    var rewardEarned = false;
    var callbackFired = false;

    void fireGranted() {
      if (callbackFired) return;
      callbackFired = true;
      onRewardGranted();
    }

    void fireDismissed() {
      if (callbackFired) return;
      callbackFired = true;
      onDismissedWithoutReward?.call();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('RewardedAd shown');
        _logEvent(AppConstants.adShownEvent);
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _logEvent(AppConstants.adDismissedEvent);
        unawaited(preload());
        if (rewardEarned) {
          fireGranted();
        } else {
          fireDismissed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: $error');
        ad.dispose();
        _logEvent(AppConstants.adFailedEvent);
        unawaited(preload());
        if (AdNetworkError.isNetworkError(error)) {
          fireGranted();
        } else {
          fireDismissed();
        }
      },
    );

    unawaited(
      ad.show(
        onUserEarnedReward: (_, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;
          _logEvent(AppConstants.rewardEarnedEvent);
        },
      ),
    );
  }

  void _logEvent(String name) {
    _analytics?.logEvent(
      name: name,
      parameters: {
        AppConstants.adTypeParam: 'rewarded',
        AppConstants.adPlacementParam:
            AdPlacement.rewardedDownload.analyticsName,
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
*/
