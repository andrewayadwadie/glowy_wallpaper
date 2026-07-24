import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:glowy_wallpaper/core/widgets/staggered_wallpaper_card.dart';
import 'package:glowy_wallpaper/features/wallpapers/domain/entities/wallpaper_entity.dart';
import 'package:glowy_wallpaper/features/wallpapers/presentation/widgets/wallpaper_grid.dart';

class _StubCacheManager implements CacheManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WallpaperEntity _wallpaper(String id) => WallpaperEntity(
  id: id,
  url: 'https://example.com/$id.jpg',
  thumbUrl: 'https://example.com/$id-thumb.jpg',
  isTopRated: false,
  mediaType: MediaType.image,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  setUp(() {
    GetIt.I.registerSingleton<CacheManager>(
      _StubCacheManager(),
      instanceName: 'wallpaperThumbnailCacheManager',
    );
  });

  tearDown(() {
    GetIt.I.unregister<CacheManager>(
      instanceName: 'wallpaperThumbnailCacheManager',
    );
  });

  testWidgets(
    'each StaggeredWallpaperCard carries a ValueKey matching its wallpaper id',
    (tester) async {
      final wallpapers = [_wallpaper('a'), _wallpaper('b'), _wallpaper('c')];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: WallpaperGrid(
                wallpapers: wallpapers,
                isLoadingMore: false,
                hasReachedEnd: true,
                onLoadMore: () {},
                onWallpaperTapped: (_) {},
                isPremium: false,
              ),
            ),
          ),
        ),
      );

      for (final wallpaper in wallpapers) {
        final cardFinder = find.byWidgetPredicate(
          (widget) =>
              widget is StaggeredWallpaperCard &&
              widget.key == ValueKey(wallpaper.id),
        );
        expect(cardFinder, findsOneWidget);
      }
    },
  );
}
