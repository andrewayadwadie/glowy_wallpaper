// TODO(ads-disabled-018): entire ad layer paused — restore by removing this
// header and the closing block comment below. See specs/018-disable-ads-isolate-downloads/.
/*
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/ads/ad_gatekeeper.dart';
import 'package:glowy_wallpaper/core/ads/ad_ids.dart';
import 'package:glowy_wallpaper/core/ads/managers/app_open_ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _FakeAppOpenAd extends Fake implements AppOpenAd {
  @override
  FullScreenContentCallback<AppOpenAd>? fullScreenContentCallback;

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
  late List<_FakeAppOpenAd> loadedAds;
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
    required AppOpenAdLoadCallback adLoadCallback,
  }) async {
    loadCalls++;
    final ad = _FakeAppOpenAd();
    loadedAds.add(ad);
    adLoadCallback.onAdLoaded(ad);
  }

  AppOpenAdManager buildManager() => AppOpenAdManager(
    adIds,
    gatekeeper,
    loader: succeedingLoader,
    now: () => currentTime,
  );

  test('premium: neither loads nor shows', () async {
    gatekeeper.shouldShowAds = false;
    final manager = buildManager();

    await manager.loadAd();
    await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);

    expect(loadCalls, 0);
    expect(loadedAds, isEmpty);
  });

  test('splash shows a fresh preloaded ad', () async {
    final manager = buildManager();
    await manager.loadAd();

    await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);

    expect(loadedAds.single.shown, isTrue);
    expect(manager.isShowingAd, isTrue);
  });

  test('no ad available: no show, triggers a reload, never blocks', () async {
    final manager = buildManager();

    await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);
    await Future<void>.delayed(Duration.zero);

    // Nothing was shown but a load was kicked off for next time.
    expect(loadCalls, 1);
    expect(loadedAds.single.shown, isFalse);
  });

  test(
    'stale ad (>4h) is discarded, not shown, and replaced (FR-008)',
    () async {
      final manager = buildManager();
      await manager.loadAd();
      final staleAd = loadedAds.single;

      currentTime = currentTime.add(const Duration(hours: 5));
      await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);
      await Future<void>.delayed(Duration.zero);

      expect(staleAd.shown, isFalse);
      expect(staleAd.disposed, isTrue);
      expect(loadCalls, 2);
    },
  );

  test('isShowingAd guard suppresses a second show (FR-009)', () async {
    final manager = buildManager();
    await manager.loadAd();
    await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);
    expect(manager.isShowingAd, isTrue);

    // Load a second ad while the first is on screen, then try to show it.
    await manager.loadAd();
    await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);

    expect(loadedAds.length, 2);
    expect(loadedAds[1].shown, isFalse);
  });

  test('dismiss resets the guard and reloads (FR-010)', () async {
    final manager = buildManager();
    await manager.loadAd();
    await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);
    final shownAd = loadedAds.single;

    shownAd.fullScreenContentCallback!.onAdDismissedFullScreenContent!(shownAd);
    await Future<void>.delayed(Duration.zero);

    expect(manager.isShowingAd, isFalse);
    expect(shownAd.disposed, isTrue);
    expect(loadCalls, 2);
  });

  group('resume cap (FR-010a)', () {
    test('resume within 4 minutes of the last show is suppressed', () async {
      final manager = buildManager();
      await manager.loadAd();
      await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);
      final firstAd = loadedAds.single;
      firstAd.fullScreenContentCallback!.onAdDismissedFullScreenContent!(
        firstAd,
      );
      await Future<void>.delayed(Duration.zero);
      expect(loadedAds.length, 2);

      currentTime = currentTime.add(const Duration(minutes: 2));
      await manager.showIfAvailable(source: AppOpenAdManager.sourceResume);

      expect(loadedAds[1].shown, isFalse);
    });

    test('resume after >=4 minutes shows again', () async {
      final manager = buildManager();
      await manager.loadAd();
      await manager.showIfAvailable(source: AppOpenAdManager.sourceSplash);
      final firstAd = loadedAds.single;
      firstAd.fullScreenContentCallback!.onAdDismissedFullScreenContent!(
        firstAd,
      );
      await Future<void>.delayed(Duration.zero);
      expect(loadedAds.length, 2);

      currentTime = currentTime.add(const Duration(minutes: 5));
      await manager.showIfAvailable(source: AppOpenAdManager.sourceResume);

      expect(loadedAds[1].shown, isTrue);
    });

    test('first resume signal without a prior splash call is swallowed '
        '(cold start owned by splash)', () async {
      final manager = buildManager();
      await manager.loadAd();

      await manager.showIfAvailable(source: AppOpenAdManager.sourceResume);
      expect(loadedAds.single.shown, isFalse);

      // Subsequent resumes behave normally.
      await manager.showIfAvailable(source: AppOpenAdManager.sourceResume);
      expect(loadedAds.single.shown, isTrue);
    });
  });
}
*/

// TODO(ads-disabled-018): stub retained so the test runner can load this
// file (flutter test requires a main() entry point); the real tests above
// are fully paused inside the block comment.
void main() {}
