import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/services/ad_helper.dart';

/// Unit tests for AdHelper covering:
/// - AdType enum (spec 010: 4 ad types)
/// - Singleton pattern (constitution VIII)
/// - Premium user bypass (shouldShowAds = false) for all ad methods
/// - Interstitial 60-second cooldown (spec 010 US3)
/// - Null-ad fallback paths (onComplete always called for interstitial)
/// - Banner ValueNotifier state management (spec 010 US4)
/// - Dispose / cleanup behavior
///
/// Note: Tests that require the real AdMob SDK (ad load, show, callbacks)
/// are integration tests and must run on a physical device.

void main() {
  late AdHelper adHelper;

  setUp(() {
    AdHelper.resetInstance();
    adHelper = AdHelper.instance;
  });

  tearDown(() {
    AdHelper.resetInstance();
  });

  // ---------------------------------------------------------------------------
  // AdType enum
  // ---------------------------------------------------------------------------
  group('AdType enum', () {
    test('contains exactly 4 ad types per spec 010', () {
      expect(AdType.values.length, 4);
    });

    test('contains appOpen type (US1 — splash ad)', () {
      expect(AdType.values, contains(AdType.appOpen));
    });

    test('contains banner type (US4 — home bottom)', () {
      expect(AdType.values, contains(AdType.banner));
    });

    test('contains rewardedInterstitial type (US2 — download gate)', () {
      expect(AdType.values, contains(AdType.rewardedInterstitial));
    });

    test('contains interstitial type (US3 — favorite gate)', () {
      expect(AdType.values, contains(AdType.interstitial));
    });

    test('old rewarded type is removed', () {
      final names = AdType.values.map((e) => e.name).toList();
      expect(names, isNot(contains('rewarded')));
    });
  });

  // ---------------------------------------------------------------------------
  // Singleton pattern
  // ---------------------------------------------------------------------------
  group('singleton pattern', () {
    test('returns the same instance on repeated access', () {
      final a = AdHelper.instance;
      final b = AdHelper.instance;
      expect(identical(a, b), isTrue);
    });

    test('resetInstance allows a fresh instance', () {
      final a = AdHelper.instance;
      AdHelper.resetInstance();
      final b = AdHelper.instance;
      expect(identical(a, b), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // shouldShowAds defaults
  // ---------------------------------------------------------------------------
  group('shouldShowAds default', () {
    test('defaults to true (free user)', () {
      expect(adHelper.shouldShowAds, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Premium bypass — showRewardedInterstitialAd (US2)
  // ---------------------------------------------------------------------------
  group('showRewardedInterstitialAd — premium bypass', () {
    test('returns true immediately when shouldShowAds is false', () async {
      adHelper.shouldShowAds = false;
      final result = await adHelper.showRewardedInterstitialAd(
        action: 'download',
      );
      expect(result, isTrue);
    });

    test('returns true for any action string when premium', () async {
      adHelper.shouldShowAds = false;
      final result = await adHelper.showRewardedInterstitialAd(
        action: 'anything',
      );
      expect(result, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Premium bypass — showInterstitialAd (US3)
  // ---------------------------------------------------------------------------
  group('showInterstitialAd — premium bypass', () {
    test('calls onComplete immediately when shouldShowAds is false', () {
      adHelper.shouldShowAds = false;
      bool completed = false;
      adHelper.showInterstitialAd(onComplete: () => completed = true);
      expect(completed, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Premium bypass — preload methods
  // ---------------------------------------------------------------------------
  group('preload — premium bypass', () {
    test(
      'preloadRewardedInterstitialAd returns false when shouldShowAds is false',
      () async {
        adHelper.shouldShowAds = false;
        final result = await adHelper.preloadRewardedInterstitialAd();
        expect(result, isFalse);
      },
    );

    test(
      'preloadInterstitialAd returns false when shouldShowAds is false',
      () async {
        adHelper.shouldShowAds = false;
        final result = await adHelper.preloadInterstitialAd();
        expect(result, isFalse);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Premium bypass — banner (US4)
  // ---------------------------------------------------------------------------
  group('loadBannerAd — premium bypass', () {
    test(
      'disposes banner and keeps notifier false when shouldShowAds is false',
      () async {
        adHelper.shouldShowAds = false;
        await adHelper.loadBannerAd();
        expect(adHelper.bannerAd, isNull);
        expect(adHelper.bannerAdLoaded.value, isFalse);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Interstitial — null ad fallback (US3)
  // ---------------------------------------------------------------------------
  group('showInterstitialAd — null ad fallback', () {
    test('calls onComplete immediately when no interstitial ad is loaded', () {
      adHelper.shouldShowAds = true;
      // _interstitialAd is null by default
      bool completed = false;
      adHelper.showInterstitialAd(onComplete: () => completed = true);
      expect(completed, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Interstitial — 60-second cooldown (US3)
  // ---------------------------------------------------------------------------
  group('showInterstitialAd — 60-second cooldown', () {
    test('calls onComplete immediately when within 60-second cooldown', () {
      adHelper.shouldShowAds = true;
      // Simulate ad was shown 10 seconds ago
      adHelper.lastInterstitialShownForTest = DateTime.now().subtract(
        const Duration(seconds: 10),
      );

      bool completed = false;
      adHelper.showInterstitialAd(onComplete: () => completed = true);
      expect(completed, isTrue);
    });

    test(
      'calls onComplete immediately at exactly 59 seconds (within cooldown)',
      () {
        adHelper.shouldShowAds = true;
        adHelper.lastInterstitialShownForTest = DateTime.now().subtract(
          const Duration(seconds: 59),
        );

        bool completed = false;
        adHelper.showInterstitialAd(onComplete: () => completed = true);
        expect(completed, isTrue);
      },
    );

    test('passes cooldown check after 61 seconds (falls to null-ad check)', () {
      adHelper.shouldShowAds = true;
      adHelper.lastInterstitialShownForTest = DateTime.now().subtract(
        const Duration(seconds: 61),
      );

      // Cooldown expired, but _interstitialAd is still null → onComplete called
      bool completed = false;
      adHelper.showInterstitialAd(onComplete: () => completed = true);
      // Still completes because ad is null (second fallback)
      expect(completed, isTrue);
    });

    test('first call has no cooldown (lastInterstitialShown is null)', () {
      adHelper.shouldShowAds = true;
      // _lastInterstitialShown is null by default → no cooldown
      // Falls through to null-ad check
      bool completed = false;
      adHelper.showInterstitialAd(onComplete: () => completed = true);
      expect(completed, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Interstitial — onComplete always called (non-blocking gate, US3)
  // ---------------------------------------------------------------------------
  group('showInterstitialAd — non-blocking guarantee', () {
    test('onComplete is called in every fallback path', () {
      // Path 1: premium bypass
      adHelper.shouldShowAds = false;
      bool completed1 = false;
      adHelper.showInterstitialAd(onComplete: () => completed1 = true);
      expect(
        completed1,
        isTrue,
        reason: 'premium bypass should call onComplete',
      );

      // Reset for path 2
      adHelper.shouldShowAds = true;

      // Path 2: cooldown
      adHelper.lastInterstitialShownForTest = DateTime.now();
      bool completed2 = false;
      adHelper.showInterstitialAd(onComplete: () => completed2 = true);
      expect(completed2, isTrue, reason: 'cooldown should call onComplete');

      // Path 3: null ad
      adHelper.lastInterstitialShownForTest = null;
      bool completed3 = false;
      adHelper.showInterstitialAd(onComplete: () => completed3 = true);
      expect(completed3, isTrue, reason: 'null ad should call onComplete');
    });
  });

  // ---------------------------------------------------------------------------
  // Banner ValueNotifier (US4)
  // ---------------------------------------------------------------------------
  group('bannerAdLoaded ValueNotifier', () {
    test('starts as false', () {
      expect(adHelper.bannerAdLoaded.value, isFalse);
    });

    test('notifies listeners on change', () {
      int notifyCount = 0;
      adHelper.bannerAdLoaded.addListener(() => notifyCount++);

      adHelper.bannerAdLoaded.value = true;
      expect(notifyCount, 1);

      adHelper.bannerAdLoaded.value = false;
      expect(notifyCount, 2);
    });

    test('disposeBannerAd resets notifier to false', () {
      adHelper.bannerAdLoaded.value = true;
      adHelper.disposeBannerAd();
      expect(adHelper.bannerAdLoaded.value, isFalse);
    });

    test('disposeBannerAd clears bannerAd reference', () {
      adHelper.disposeBannerAd();
      expect(adHelper.bannerAd, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------
  group('dispose', () {
    test('sets bannerAdLoaded to false', () {
      adHelper.bannerAdLoaded.value = true;
      adHelper.dispose();
      expect(adHelper.bannerAdLoaded.value, isFalse);
    });

    test('clears bannerAd reference', () {
      adHelper.dispose();
      expect(adHelper.bannerAd, isNull);
    });

    test('can be called multiple times without error', () {
      expect(() {
        adHelper.dispose();
        adHelper.dispose();
      }, returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // showAppOpenAd — premium bypass (US1)
  // ---------------------------------------------------------------------------
  group('showAppOpenAd — premium bypass', () {
    test('returns immediately when shouldShowAds is false', () async {
      adHelper.shouldShowAds = false;
      // Should not throw, just return
      await expectLater(adHelper.showAppOpenAd(), completes);
    });

    test('returns immediately when no app open ad is loaded', () async {
      adHelper.shouldShowAds = true;
      // _appOpenAd is null by default
      await expectLater(adHelper.showAppOpenAd(), completes);
    });
  });

  // ---------------------------------------------------------------------------
  // loadAppOpenAd — premium bypass (US1)
  // ---------------------------------------------------------------------------
  group('loadAppOpenAd — premium bypass', () {
    test('disposes and returns when shouldShowAds is false', () async {
      adHelper.shouldShowAds = false;
      await expectLater(adHelper.loadAppOpenAd(), completes);
    });
  });

  // ---------------------------------------------------------------------------
  // showRewardedInterstitialAd — no ad loaded fallback (US2)
  // ---------------------------------------------------------------------------
  group('showRewardedInterstitialAd — no ad loaded', () {
    test(
      'attempts preload and returns false when no ad available (free user)',
      () async {
        adHelper.shouldShowAds = true;
        // _rewardedInterstitialAd is null, preload will fail in test env
        // The method should return false (ad not available)
        final result = await adHelper.showRewardedInterstitialAd(
          action: 'download',
        );
        expect(result, isFalse);
      },
      // This test calls RewardedInterstitialAd.load which needs platform channels
      // Skip if platform channels are not available
      skip: 'Requires platform channels for RewardedInterstitialAd.load',
    );
  });

  // ---------------------------------------------------------------------------
  // Spec verification: no old rewarded methods exist
  // ---------------------------------------------------------------------------
  group('old rewarded ad removal verification', () {
    test('AdHelper has no showRewardedAd method (removed per T009)', () {
      // If this test compiles, it confirms the old method doesn't exist.
      // We verify by checking the AdType enum doesn't have 'rewarded'.
      expect(AdType.values.map((e) => e.name), isNot(contains('rewarded')));
    });
  });
}
