import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/ads/ad_gatekeeper.dart';
import 'package:glowy_wallpaper/core/ads/ad_ids.dart';
import 'package:glowy_wallpaper/core/ads/managers/rewarded_ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _TestLoadAdError extends LoadAdError {
  _TestLoadAdError(super.code, super.domain, super.message, super.responseInfo);
}

class _TestAdError extends AdError {
  _TestAdError(super.code, super.domain, super.message);
}

class _FakeRewardedAd extends Fake implements RewardedAd {
  @override
  FullScreenContentCallback<RewardedAd>? fullScreenContentCallback;

  OnUserEarnedRewardCallback? earnedCallback;
  bool shown = false;
  bool disposed = false;

  @override
  Future<void> show({
    required OnUserEarnedRewardCallback onUserEarnedReward,
  }) async {
    shown = true;
    earnedCallback = onUserEarnedReward;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  late AdGatekeeper gatekeeper;
  late AdIds adIds;

  setUp(() {
    gatekeeper = AdGatekeeper();
    adIds = AdIds(isRelease: false, platform: TargetPlatform.android);
  });

  RewardedAdManager buildManager(RewardedAdLoader loader) =>
      RewardedAdManager(adIds, gatekeeper, loader: loader);

  /// Loader that immediately delivers [ad].
  RewardedAdLoader loaderWithAd(
    _FakeRewardedAd Function() adFactory, {
    void Function()? onLoadCalled,
  }) =>
      ({
        required String adUnitId,
        required AdRequest request,
        required RewardedAdLoadCallback rewardedAdLoadCallback,
      }) async {
        onLoadCalled?.call();
        rewardedAdLoadCallback.onAdLoaded(adFactory());
      };

  /// Loader that immediately fails with [error].
  RewardedAdLoader failingLoader(LoadAdError error) =>
      ({
        required String adUnitId,
        required AdRequest request,
        required RewardedAdLoadCallback rewardedAdLoadCallback,
      }) async {
        rewardedAdLoadCallback.onAdFailedToLoad(error);
      };

  group('premium gating', () {
    test('premium ⇒ immediate grant, no SDK load', () async {
      gatekeeper.shouldShowAds = false;
      var loadCalls = 0;
      var granted = false;
      var dismissed = false;
      final manager = buildManager(
        loaderWithAd(_FakeRewardedAd.new, onLoadCalled: () => loadCalls++),
      );

      await manager.showRewardedForDownload(
        onRewardGranted: () => granted = true,
        onDismissedWithoutReward: () => dismissed = true,
      );

      expect(granted, isTrue);
      expect(dismissed, isFalse);
      expect(loadCalls, 0);
    });

    test('premium ⇒ preload is a no-op', () async {
      gatekeeper.shouldShowAds = false;
      var loadCalls = 0;
      final manager = buildManager(
        loaderWithAd(_FakeRewardedAd.new, onLoadCalled: () => loadCalls++),
      );

      await manager.preload();

      expect(loadCalls, 0);
    });
  });

  group('cold-start load outcomes', () {
    test('network load failure ⇒ grant (graceful degradation)', () async {
      var granted = false;
      var dismissed = false;
      final manager = buildManager(
        failingLoader(_TestLoadAdError(2, 'gma', 'Network error', null)),
      );

      await manager.showRewardedForDownload(
        onRewardGranted: () => granted = true,
        onDismissedWithoutReward: () => dismissed = true,
      );

      expect(granted, isTrue);
      expect(dismissed, isFalse);
    });

    test('non-network load failure ⇒ dismissed callback, no grant', () async {
      var granted = false;
      var dismissed = false;
      final manager = buildManager(
        failingLoader(_TestLoadAdError(0, 'gma', 'Invalid request', null)),
      );

      await manager.showRewardedForDownload(
        onRewardGranted: () => granted = true,
        onDismissedWithoutReward: () => dismissed = true,
      );

      expect(granted, isFalse);
      expect(dismissed, isTrue);
    });
  });

  group('show outcomes', () {
    test('earned reward then dismiss ⇒ grant exactly once', () async {
      final ad = _FakeRewardedAd();
      var grantCount = 0;
      var dismissed = false;
      final manager = buildManager(loaderWithAd(() => ad));
      await manager.preload();

      await manager.showRewardedForDownload(
        onRewardGranted: () => grantCount++,
        onDismissedWithoutReward: () => dismissed = true,
      );
      expect(ad.shown, isTrue);

      ad.earnedCallback!(ad, RewardItem(1, 'reward'));
      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);

      expect(grantCount, 1);
      expect(dismissed, isFalse);
      expect(ad.disposed, isTrue);
    });

    test('early dismiss without reward ⇒ no grant', () async {
      final ad = _FakeRewardedAd();
      var granted = false;
      var dismissed = false;
      final manager = buildManager(loaderWithAd(() => ad));
      await manager.preload();

      await manager.showRewardedForDownload(
        onRewardGranted: () => granted = true,
        onDismissedWithoutReward: () => dismissed = true,
      );
      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);

      expect(granted, isFalse);
      expect(dismissed, isTrue);
    });

    test('show failure, network-related ⇒ grant', () async {
      final ad = _FakeRewardedAd();
      var granted = false;
      final manager = buildManager(loaderWithAd(() => ad));
      await manager.preload();

      await manager.showRewardedForDownload(
        onRewardGranted: () => granted = true,
      );
      ad.fullScreenContentCallback!.onAdFailedToShowFullScreenContent!(
        ad,
        _TestAdError(2, 'gma', 'Network error'),
      );

      expect(granted, isTrue);
    });

    test('show failure, non-network ⇒ dismissed callback', () async {
      final ad = _FakeRewardedAd();
      var granted = false;
      var dismissed = false;
      final manager = buildManager(loaderWithAd(() => ad));
      await manager.preload();

      await manager.showRewardedForDownload(
        onRewardGranted: () => granted = true,
        onDismissedWithoutReward: () => dismissed = true,
      );
      ad.fullScreenContentCallback!.onAdFailedToShowFullScreenContent!(
        ad,
        _TestAdError(1, 'gma', 'Internal error'),
      );

      expect(granted, isFalse);
      expect(dismissed, isTrue);
    });
  });

  test(
    'dismiss triggers dispose and a fresh preload (single-use, FR-005)',
    () async {
      final ads = <_FakeRewardedAd>[];
      var loadCalls = 0;
      final manager = buildManager(
        loaderWithAd(() {
          final ad = _FakeRewardedAd();
          ads.add(ad);
          return ad;
        }, onLoadCalled: () => loadCalls++),
      );
      await manager.preload();
      expect(loadCalls, 1);

      await manager.showRewardedForDownload(onRewardGranted: () {});
      final shownAd = ads.first;
      expect(shownAd.shown, isTrue);

      shownAd.fullScreenContentCallback!.onAdDismissedFullScreenContent!(
        shownAd,
      );
      // Allow the unawaited preload() future to run.
      await Future<void>.delayed(Duration.zero);

      expect(shownAd.disposed, isTrue);
      expect(loadCalls, 2);
    },
  );
}
