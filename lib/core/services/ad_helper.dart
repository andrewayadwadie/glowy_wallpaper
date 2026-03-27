import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glowy_wallpaper/core/config/env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdType { appOpen, banner, rewardedInterstitial, interstitial }

class AdHelper {
  static AdHelper? _instance;
  static AdHelper get instance => _instance ??= AdHelper._internal();

  AdHelper._internal();

  /// Reset singleton for testing. Do not use in production code.
  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  /// Expose cooldown setter for testing interstitial cooldown logic.
  @visibleForTesting
  set lastInterstitialShownForTest(DateTime? value) =>
      _lastInterstitialShown = value;

  // Lazy analytics to avoid FirebaseAnalytics.instance during test construction.
  FirebaseAnalytics? _analyticsInstance;
  FirebaseAnalytics get _analytics =>
      _analyticsInstance ??= FirebaseAnalytics.instance;

  BannerAd? _bannerAd;
  AppOpenAd? _appOpenAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  InterstitialAd? _interstitialAd;

  BannerAd? get bannerAd => _bannerAd;
  bool _isInitialized = false;
  bool _isAppOpenLoading = false;
  bool _isRewardedInterstitialLoading = false;
  bool _isInterstitialLoading = false;

  /// Tracks last interstitial show time for 60-second cooldown.
  DateTime? _lastInterstitialShown;

  /// Notifies listeners when banner ad load state changes.
  final ValueNotifier<bool> bannerAdLoaded = ValueNotifier(false);

  bool shouldShowAds = true;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('MobileAds initialized successfully');

      await preloadRewardedInterstitialAd();
      await preloadInterstitialAd();
    } catch (e) {
      debugPrint('MobileAds initialization failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Banner Ad
  // ---------------------------------------------------------------------------

  Future<void> loadBannerAd() async {
    if (!shouldShowAds) {
      _disposeBannerAd();
      return;
    }

    await _disposeBannerAd();

    _bannerAd = BannerAd(
      adUnitId: Env.adMobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('BannerAd loaded');
          bannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          _bannerAd = null;
          bannerAdLoaded.value = false;
        },
        onAdOpened: (_) {},
        onAdClosed: (_) {},
      ),
    );

    await _bannerAd?.load();
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    bannerAdLoaded.value = false;
  }

  Future<void> _disposeBannerAd() async {
    _bannerAd?.dispose();
    _bannerAd = null;
    bannerAdLoaded.value = false;
  }

  // ---------------------------------------------------------------------------
  // App Open Ad
  // ---------------------------------------------------------------------------

  Future<void> loadAppOpenAd() async {
    if (!shouldShowAds) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      return;
    }

    if (_isAppOpenLoading) return;

    _isAppOpenLoading = true;

    AppOpenAd.load(
      adUnitId: Env.adMobAppOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AppOpenAd loaded');
          _appOpenAd = ad;
          _isAppOpenLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          _appOpenAd = null;
          _isAppOpenLoading = false;
        },
      ),
    );
  }

  Future<void> showAppOpenAd() async {
    if (!shouldShowAds) return;
    if (_appOpenAd == null) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('AppOpenAd shown');
      },
      onAdDismissedFullScreenContent: (_) {
        _analytics.logEvent(
          name: 'ad_shown',
          parameters: {'ad_type': 'app_open'},
        );
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (_, error) {
        debugPrint('AppOpenAd failed to show: $error');
        _appOpenAd = null;
      },
    );

    _appOpenAd!.show();
  }

  // ---------------------------------------------------------------------------
  // Rewarded Interstitial Ad (download gate — blocking)
  // ---------------------------------------------------------------------------

  Future<bool> preloadRewardedInterstitialAd() async {
    if (!shouldShowAds) {
      _rewardedInterstitialAd?.dispose();
      _rewardedInterstitialAd = null;
      return false;
    }

    if (_isRewardedInterstitialLoading) return false;

    _isRewardedInterstitialLoading = true;

    final completer = Completer<bool>();

    // 10-second timeout
    final timer = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        debugPrint('RewardedInterstitialAd load timed out');
        _isRewardedInterstitialLoading = false;
        completer.complete(false);
      }
    });

    try {
      await RewardedInterstitialAd.load(
        adUnitId: Env.adMobRewardedInterstitialId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback:
            RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('RewardedInterstitialAd loaded');
            _rewardedInterstitialAd = ad;
            _isRewardedInterstitialLoading = false;
            timer.cancel();
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _isRewardedInterstitialLoading = false;
            timer.cancel();
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('RewardedInterstitialAd load exception: $e');
      _rewardedInterstitialAd = null;
      _isRewardedInterstitialLoading = false;
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return await completer.future;
  }

  Future<bool> showRewardedInterstitialAd({required String action}) async {
    if (!shouldShowAds) return true;

    if (_rewardedInterstitialAd == null) {
      final loaded = await preloadRewardedInterstitialAd();
      if (!loaded || _rewardedInterstitialAd == null) {
        _analytics.logEvent(
          name: 'ad_failed',
          parameters: {'ad_type': 'rewarded_interstitial', 'action': action},
        );
        return false;
      }
    }

    bool rewardEarned = false;
    final completer = Completer<bool>();

    try {
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdShowedFullScreenContent: (_) {
          debugPrint('RewardedInterstitialAd shown');
          _analytics.logEvent(
            name: 'ad_shown',
            parameters: {'ad_type': 'rewarded_interstitial'},
          );
        },
        onAdDismissedFullScreenContent: (_) {
          _rewardedInterstitialAd = null;
          if (rewardEarned) {
            _analytics.logEvent(
              name: 'reward_earned',
              parameters: {'action': action},
            );
          }
          preloadRewardedInterstitialAd();
          if (!completer.isCompleted) {
            completer.complete(rewardEarned);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('RewardedInterstitialAd failed to show: $error');
          _rewardedInterstitialAd = null;
          ad.dispose();
          preloadRewardedInterstitialAd();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;
        },
      );
    } catch (e) {
      debugPrint('RewardedInterstitialAd show exception: $e');
      _rewardedInterstitialAd = null;
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return await completer.future;
  }

  // ---------------------------------------------------------------------------
  // Interstitial Ad (favorite gate — non-blocking)
  // ---------------------------------------------------------------------------

  Future<bool> preloadInterstitialAd() async {
    if (!shouldShowAds) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      return false;
    }

    if (_isInterstitialLoading) return false;

    _isInterstitialLoading = true;

    final completer = Completer<bool>();

    try {
      await InterstitialAd.load(
        adUnitId: Env.adMobInterstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('InterstitialAd loaded');
            _interstitialAd = ad;
            _isInterstitialLoading = false;
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('InterstitialAd failed to load: $error');
            _interstitialAd = null;
            _isInterstitialLoading = false;
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('InterstitialAd load exception: $e');
      _interstitialAd = null;
      _isInterstitialLoading = false;
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return await completer.future;
  }

  /// Shows an interstitial ad for the favorite gate (non-blocking).
  /// [onComplete] is always called — after ad dismiss, or immediately if
  /// no ad is available, within cooldown, or user is premium.
  void showInterstitialAd({required VoidCallback onComplete}) {
    if (!shouldShowAds) {
      onComplete();
      return;
    }

    // 60-second cooldown
    if (_lastInterstitialShown != null &&
        DateTime.now().difference(_lastInterstitialShown!) <
            const Duration(seconds: 60)) {
      onComplete();
      return;
    }

    if (_interstitialAd == null) {
      onComplete();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('InterstitialAd shown');
        _lastInterstitialShown = DateTime.now();
        _analytics.logEvent(
          name: 'ad_shown',
          parameters: {'ad_type': 'interstitial'},
        );
      },
      onAdDismissedFullScreenContent: (_) {
        _interstitialAd = null;
        preloadInterstitialAd();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        _interstitialAd = null;
        ad.dispose();
        preloadInterstitialAd();
        onComplete();
      },
    );

    _interstitialAd!.show();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void dispose() {
    disposeBannerAd();
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
