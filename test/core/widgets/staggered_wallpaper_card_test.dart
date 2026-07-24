import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:glowy_wallpaper/core/services/aspect_ratio_cache.dart';
import 'package:glowy_wallpaper/core/widgets/app_cached_image.dart';
import 'package:glowy_wallpaper/core/widgets/app_shimmer_widget.dart';
import 'package:glowy_wallpaper/core/widgets/staggered_wallpaper_card.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 200, child: child)),
    ),
  );
}

class _StubCacheManager implements CacheManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TrackingCacheManager implements CacheManager {
  bool getFileStreamCalled = false;

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    getFileStreamCalled = true;
    return const Stream.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    AspectRatioCache.clear();
    GetIt.I.registerSingleton<CacheManager>(
      _StubCacheManager(),
      instanceName: 'wallpaperThumbnailCacheManager',
    );
  });

  tearDown(() {
    AspectRatioCache.clear();
    GetIt.I.unregister<CacheManager>(
      instanceName: 'wallpaperThumbnailCacheManager',
    );
  });

  group('StaggeredWallpaperCard', () {
    const testUrl = 'https://example.com/wallpaper.jpg';

    testWidgets('renders at 3:4 fallback ratio before decode', (tester) async {
      await tester.pumpWidget(
        _wrap(StaggeredWallpaperCard(imageUrl: testUrl, onTap: () {})),
      );

      // Card should be visible at its fallback ratio
      expect(find.byType(StaggeredWallpaperCard), findsOneWidget);
      // AspectRatio widget should be present
      expect(find.byType(AspectRatio), findsWidgets);
    });

    testWidgets('shows overlay widget when provided', (tester) async {
      const overlayKey = Key('test_overlay');

      await tester.pumpWidget(
        _wrap(
          StaggeredWallpaperCard(
            imageUrl: testUrl,
            onTap: () {},
            overlay: const SizedBox(key: overlayKey, width: 20, height: 20),
          ),
        ),
      );

      expect(find.byKey(overlayKey), findsOneWidget);
    });

    testWidgets('overlay is positioned top-left', (tester) async {
      const overlayKey = Key('badge');

      await tester.pumpWidget(
        _wrap(
          StaggeredWallpaperCard(
            imageUrl: testUrl,
            onTap: () {},
            overlay: const SizedBox(key: overlayKey, width: 10, height: 10),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(
        find.ancestor(
          of: find.byKey(overlayKey),
          matching: find.byType(Positioned),
        ),
      );

      expect(positioned.top, isNotNull);
      expect(positioned.left, isNotNull);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          StaggeredWallpaperCard(imageUrl: testUrl, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(StaggeredWallpaperCard));
      expect(tapped, isTrue);
    });

    testWidgets('wraps in Hero when heroTag provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StaggeredWallpaperCard(
            imageUrl: testUrl,
            onTap: () {},
            heroTag: 'test_hero',
          ),
        ),
      );

      expect(find.byType(Hero), findsOneWidget);
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'test_hero');
    });

    testWidgets('renders custom child inside AspectRatio', (tester) async {
      const childKey = Key('custom_child');

      await tester.pumpWidget(
        _wrap(
          StaggeredWallpaperCard(
            imageUrl: testUrl,
            child: const ColoredBox(key: childKey, color: Colors.red),
          ),
        ),
      );

      expect(find.byKey(childKey), findsOneWidget);
      // Custom child should be inside an AspectRatio
      expect(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(AspectRatio),
        ),
        findsWidgets,
      );
    });

    testWidgets('does not add Hero when heroTag is null', (tester) async {
      await tester.pumpWidget(
        _wrap(StaggeredWallpaperCard(imageUrl: testUrl, onTap: () {})),
      );

      expect(find.byType(Hero), findsNothing);
    });

    testWidgets('applies semantics label when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StaggeredWallpaperCard(
            imageUrl: testUrl,
            onTap: () {},
            semanticLabel: 'Nature wallpaper',
          ),
        ),
      );

      expect(find.bySemanticsLabel('Nature wallpaper'), findsOneWidget);
    });

    testWidgets(
      'aspect-ratio probe resolves through the shared GetIt CacheManager',
      (tester) async {
        final tracking = _TrackingCacheManager();
        GetIt.I.unregister<CacheManager>(
          instanceName: 'wallpaperThumbnailCacheManager',
        );
        GetIt.I.registerSingleton<CacheManager>(
          tracking,
          instanceName: 'wallpaperThumbnailCacheManager',
        );

        await tester.pumpWidget(
          _wrap(StaggeredWallpaperCard(imageUrl: testUrl, onTap: () {})),
        );

        expect(tracking.getFileStreamCalled, isTrue);
      },
    );

    testWidgets(
      'a memoized aspect ratio renders the image on frame one with no shimmer '
      'skeleton and no resize replay (scroll-back path)',
      (tester) async {
        // Use a manager returning an empty stream so AppCachedImage can build
        // without throwing while it waits for image bytes.
        final tracking = _TrackingCacheManager();
        GetIt.I.unregister<CacheManager>(
          instanceName: 'wallpaperThumbnailCacheManager',
        );
        GetIt.I.registerSingleton<CacheManager>(
          tracking,
          instanceName: 'wallpaperThumbnailCacheManager',
        );

        // Simulate this card having been decoded earlier in the session.
        AspectRatioCache.put(testUrl, 1.6);

        await tester.pumpWidget(
          _wrap(StaggeredWallpaperCard(imageUrl: testUrl, onTap: () {})),
        );

        // The real image path renders immediately — the card-level shimmer
        // skeleton (AppShimmerWidget) never appears.
        expect(find.byType(AppCachedImage), findsOneWidget);
        expect(find.byType(AppShimmerWidget), findsNothing);

        // The card is already at its final ratio on the first frame; the
        // 3:4 -> ratio resize tween did not replay.
        final ratios = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
        expect(
          ratios.any((a) => (a.aspectRatio - 1.6).abs() < 0.001),
          isTrue,
          reason:
              'card should sit at the memoized 1.6 ratio, not animate from '
              'the 0.75 fallback',
        );
      },
    );
  });
}
