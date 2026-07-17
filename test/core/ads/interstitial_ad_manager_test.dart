import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/ads/ad_gatekeeper.dart';
import 'package:glowy_wallpaper/core/ads/ad_ids.dart';
import 'package:glowy_wallpaper/core/ads/managers/interstitial_ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _FakeInterstitialAd extends Fake implements InterstitialAd {
  @override
  FullScreenContentCallback<InterstitialAd>? fullScreenContentCallback;

  bool shown = false;
  bool disposed = false;

  @override
  Future<void> show() async {
    shown = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  late AdGatekeeper gatekeeper;
  late AdIds adIds;
  late DateTime currentTime;
  late List<_FakeInterstitialAd> loadedAds;
  late int loadCalls;

  setUp(() {
    gatekeeper = AdGatekeeper();
    adIds = AdIds(isRelease: false, platform: TargetPlatform.android);
    currentTime = DateTime(2026, 6, 10, 12);
    loadedAds = [];
    loadCalls = 0;
  });

  Future<void> succeedingLoader({
    required String adUnitId,
    required AdRequest request,
    required InterstitialAdLoadCallback adLoadCallback,
  }) async {
    loadCalls++;
    final ad = _FakeInterstitialAd();
    loadedAds.add(ad);
    adLoadCallback.onAdLoaded(ad);
  }

  InterstitialAdManager buildManager() => InterstitialAdManager(
    adIds,
    gatekeeper,
    loader: succeedingLoader,
    now: () => currentTime,
  );

  test('premium: never shows regardless of switch count', () async {
    final manager = buildManager();
    await manager.preload();
    gatekeeper.shouldShowAds = false;

    for (var i = 0; i < 10; i++) {
      manager.onCategorySwitched();
    }

    expect(loadedAds.single.shown, isFalse);
  });

  test(
    'fewer than ${InterstitialAdManager.switchCap} switches: no show',
    () async {
      final manager = buildManager();
      await manager.preload();

      for (var i = 0; i < InterstitialAdManager.switchCap - 1; i++) {
        manager.onCategorySwitched();
      }

      expect(loadedAds.single.shown, isFalse);
    },
  );

  test('cap met with a loaded ad: shows and resets the counter', () async {
    final manager = buildManager();
    await manager.preload();

    for (var i = 0; i < InterstitialAdManager.switchCap; i++) {
      manager.onCategorySwitched();
    }
    expect(loadedAds.first.shown, isTrue);

    // Dismiss -> reload for the next cycle.
    final firstAd = loadedAds.first;
    firstAd.fullScreenContentCallback!.onAdDismissedFullScreenContent!(firstAd);
    await Future<void>.delayed(Duration.zero);
    expect(firstAd.disposed, isTrue);
    expect(loadedAds.length, 2);

    // Counter was reset: advance past the cooldown, then 3 more switches
    // must NOT show; the 4th must.
    currentTime = currentTime.add(const Duration(minutes: 2));
    for (var i = 0; i < InterstitialAdManager.switchCap - 1; i++) {
      manager.onCategorySwitched();
    }
    expect(loadedAds[1].shown, isFalse);
    manager.onCategorySwitched();
    expect(loadedAds[1].shown, isTrue);
  });

  test('cap met but cooldown not elapsed: no show', () async {
    final manager = buildManager();
    await manager.preload();

    // First show.
    for (var i = 0; i < InterstitialAdManager.switchCap; i++) {
      manager.onCategorySwitched();
    }
    final firstAd = loadedAds.first;
    expect(firstAd.shown, isTrue);
    firstAd.fullScreenContentCallback!.onAdDismissedFullScreenContent!(firstAd);
    await Future<void>.delayed(Duration.zero);
    expect(loadedAds.length, 2);

    // Cap met again only 30s later: cooldown (60s) blocks the show.
    currentTime = currentTime.add(const Duration(seconds: 30));
    for (var i = 0; i < InterstitialAdManager.switchCap; i++) {
      manager.onCategorySwitched();
    }
    expect(loadedAds[1].shown, isFalse);
  });

  test(
    'no ad loaded at trigger: silent, navigation unaffected, preloads',
    () async {
      final manager = buildManager();

      for (var i = 0; i < InterstitialAdManager.switchCap; i++) {
        manager.onCategorySwitched();
      }
      await Future<void>.delayed(Duration.zero);

      // A preload was requested so the next trigger has inventory.
      expect(loadCalls, 1);
      expect(loadedAds.single.shown, isFalse);
    },
  );

  group('showOnAction (legacy favorite gate)', () {
    test('premium: onComplete fires immediately, no show', () async {
      final manager = buildManager();
      await manager.preload();
      gatekeeper.shouldShowAds = false;
      var completed = false;

      manager.showOnAction(onComplete: () => completed = true);

      expect(completed, isTrue);
      expect(loadedAds.single.shown, isFalse);
    });

    test('loaded ad: shows, onComplete fires on dismiss', () async {
      final manager = buildManager();
      await manager.preload();
      var completed = false;

      manager.showOnAction(onComplete: () => completed = true);
      final ad = loadedAds.single;
      expect(ad.shown, isTrue);
      expect(completed, isFalse);

      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
      expect(completed, isTrue);
    });

    test('no ad loaded: onComplete fires immediately', () async {
      final manager = buildManager();
      var completed = false;

      manager.showOnAction(onComplete: () => completed = true);

      expect(completed, isTrue);
    });
  });
}
