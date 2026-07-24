import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/categories/domain/entities/category_entity.dart';
import 'package:glowy_wallpaper/features/downloads/presentation/cubit/download_cubit.dart';
import 'package:glowy_wallpaper/features/downloads/presentation/cubit/download_state.dart';
import 'package:glowy_wallpaper/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:glowy_wallpaper/features/favorites/presentation/cubit/favorite_state.dart';
import 'package:glowy_wallpaper/features/wallpaper_detail/presentation/cubit/wallpaper_detail_cubit.dart';
import 'package:glowy_wallpaper/features/wallpaper_detail/presentation/cubit/wallpaper_detail_state.dart';
import 'package:glowy_wallpaper/features/wallpaper_detail/presentation/pages/wallpaper_detail_page.dart';
import 'package:glowy_wallpaper/features/wallpapers/domain/entities/wallpaper_entity.dart';

class MockWallpaperDetailCubit extends MockCubit<WallpaperDetailState>
    implements WallpaperDetailCubit {}

class MockDownloadCubit extends MockCubit<DownloadState>
    implements DownloadCubit {}

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class _StubCacheManager implements CacheManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _wallpaper = WallpaperEntity(
  id: 'w1',
  url: 'https://example.com/image.jpg',
  thumbUrl: 'https://example.com/thumb.jpg',
  isTopRated: false,
  mediaType: MediaType.image,
  createdAt: DateTime(2024),
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
    'US1: renders no ad-gate overlay and the download control is actionable on first frame',
    (WidgetTester tester) async {
      registerFallbackValue(_wallpaper);

      final detailCubit = MockWallpaperDetailCubit();
      final downloadCubit = MockDownloadCubit();
      final favoriteCubit = MockFavoriteCubit();

      whenListen(
        detailCubit,
        const Stream<WallpaperDetailState>.empty(),
        initialState: WallpaperDetailState(wallpapers: [_wallpaper]),
      );
      whenListen(
        downloadCubit,
        const Stream<DownloadState>.empty(),
        initialState: const DownloadState(),
      );
      whenListen(
        favoriteCubit,
        const Stream<FavoriteState>.empty(),
        initialState: const FavoriteState(),
      );
      when(() => downloadCubit.download(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<WallpaperDetailCubit>.value(value: detailCubit),
                BlocProvider<DownloadCubit>.value(value: downloadCubit),
                BlocProvider<FavoriteCubit>.value(value: favoriteCubit),
              ],
              child: WallpaperDetailPage(
                wallpapers: [_wallpaper],
                initialIndex: 0,
                categoryType: CategoryType.image,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // TODO(ads-disabled-018): no ad-gate overlay to assert against — the
      // rewarded gate and its loading overlay no longer exist in this tree.
      expect(find.byType(CircularProgressIndicator), findsNothing);

      expect(find.text(AppStrings.download), findsOneWidget);
      final downloadIcon = find.byIcon(Icons.download_rounded);
      expect(downloadIcon, findsOneWidget);

      await tester.tap(downloadIcon);
      await tester.pump();

      verify(() => downloadCubit.download(_wallpaper)).called(1);
    },
  );
}
