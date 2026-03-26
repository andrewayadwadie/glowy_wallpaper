import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glowy_wallpaper/core/config/env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdType { appOpen, banner, rewarded }

class AdHelper {
  static AdHelper? _instance;
  static AdHelper get instance => _instance ??= AdHelper._internal();

  AdHelper._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  BannerAd? _bannerAd;
  AppOpenAd? _appOpenAd;
  RewardedAd? _rewardedAd;

  BannerAd? get bannerAd => _bannerAd;
  bool _isInitialized = false;
  bool _isAdLoading = false;

  bool shouldShowAds = true;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('MobileAds initialized successfully');

      await preloadRewardedAd();
    } catch (e) {
      debugPrint('MobileAds initialization failed: $e');
    }
  }

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
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          _bannerAd = null;
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
  }

  Future<void> _disposeBannerAd() async {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  Future<void> loadAppOpenAd() async {
    if (!shouldShowAds) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      return;
    }

    if (_isAdLoading) return;

    _isAdLoading = true;

    AppOpenAd.load(
      adUnitId: Env.adMobAppOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AppOpenAd loaded');
          _appOpenAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          _appOpenAd = null;
          _isAdLoading = false;
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

  Future<bool> preloadRewardedAd() async {
    debugPrint('preloadRewardedAd called');
    debugPrint('shouldShowAds: $shouldShowAds');
    debugPrint('_isAdLoading: $_isAdLoading');

    if (!shouldShowAds) {
      debugPrint('Ads are disabled, not preloading');
      _rewardedAd?.dispose();
      _rewardedAd = null;
      return false;
    }

    if (_isAdLoading) {
      debugPrint('Ad is already loading, skipping');
      return false;
    }

    _isAdLoading = true;
    debugPrint('Starting to load ad with unit ID: ${Env.adMobRewardedId}');

    final completer = Completer<bool>();

    try {
      await RewardedAd.load(
        adUnitId: Env.adMobRewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('RewardedAd loaded successfully');
            _rewardedAd = ad;
            _isAdLoading = false;
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('RewardedAd failed to load: $error');
            debugPrint('Error code: ${error.code}');
            debugPrint('Error message: ${error.message}');
            _rewardedAd = null;
            _isAdLoading = false;
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('RewardedAd load exception: $e');
      _rewardedAd = null;
      _isAdLoading = false;
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    debugPrint('Waiting for preload to complete');
    return await completer.future;
  }

  Future<bool> showRewardedAd({required String action}) async {
    debugPrint('showRewardedAd called for action: $action');
    debugPrint('shouldShowAds: $shouldShowAds');

    if (!shouldShowAds) {
      debugPrint('Ads are disabled, proceeding without ad');
      return true;
    }

    debugPrint('_rewardedAd is null: ${_rewardedAd == null}');

    if (_rewardedAd == null) {
      debugPrint('No ad loaded, trying to preload');
      final loaded = await preloadRewardedAd();
      debugPrint('Preload result: $loaded');
      debugPrint('_rewardedAd after preload is null: ${_rewardedAd == null}');

      if (!loaded || _rewardedAd == null) {
        debugPrint('Failed to load ad');
        return false;
      }
    }

    bool rewardEarned = false;
    final completer = Completer<bool>();

    try {
      debugPrint('Setting up fullScreenContentCallback');
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (_) {
          debugPrint('RewardedAd shown successfully');
        },
        onAdDismissedFullScreenContent: (_) {
          debugPrint('RewardedAd dismissed, rewardEarned: $rewardEarned');
          _rewardedAd = null;
          if (rewardEarned) {
            _analytics.logEvent(
              name: 'reward_earned',
              parameters: {'action': action},
            );
          }
          preloadRewardedAd();
          if (!completer.isCompleted) {
            completer.complete(rewardEarned);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('RewardedAd failed to show: $error');
          _rewardedAd = null;
          ad.dispose();
          preloadRewardedAd();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      debugPrint('Calling _rewardedAd.show()');
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;
        },
      );
    } catch (e) {
      debugPrint('RewardedAd show exception: $e');
      _rewardedAd = null;
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    debugPrint('Waiting for completer future');
    return await completer.future;
  }

  void dispose() {
    disposeBannerAd();
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
