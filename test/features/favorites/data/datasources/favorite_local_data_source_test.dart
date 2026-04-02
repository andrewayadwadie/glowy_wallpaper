import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/features/favorites/data/datasources/favorite_local_data_source.dart';
import 'package:glowy_wallpaper/features/favorites/domain/entities/favorite_entity.dart';
import 'package:glowy_wallpaper/features/wallpapers/domain/entities/wallpaper_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

void main() {
  late Box box;
  late FavoriteLocalDataSource dataSource;

  setUp(() async {
    Hive.init('./test_hive');
    box = await Hive.openBox('test_favorites');
    dataSource = FavoriteLocalDataSourceImpl(box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  group('FavoriteLocalDataSource', () {
    test('should store and retrieve favorite correctly', () async {
      final wallpaper = WallpaperEntity(
        id: 'test_wallpaper_id',
        url: 'https://example.com/video.mp4',
        thumbUrl: 'https://example.com/thumb.jpg',
        isTopRated: false,
        mediaType: MediaType.video,
        classificationId: 'test_classification_id',
        classificationName: 'Test Classification',
        classificationThumbnailUrl:
            'https://example.com/classification_thumb.jpg',
        createdAt: DateTime.now(),
      );

      final favorite = FavoriteEntity(
        wallpaperId: 'test_wallpaper_id',
        wallpaper: wallpaper,
        userId: 'test_user_id',
        favoritedAt: DateTime.now(),
        syncStatus: FavoriteSyncStatus.localOnly,
      );

      await dataSource.add(favorite);
      final result = await dataSource.getAll();

      expect(result.length, 1);
      expect(result[0].wallpaperId, 'test_wallpaper_id');
      expect(result[0].wallpaper.id, 'test_wallpaper_id');
      expect(result[0].wallpaper.mediaType, MediaType.video);
    });

    test('should check if wallpaper is favorite', () async {
      final wallpaper = WallpaperEntity(
        id: 'test_wallpaper_id',
        url: 'https://example.com/image.jpg',
        thumbUrl: 'https://example.com/thumb.jpg',
        isTopRated: false,
        mediaType: MediaType.image,
        createdAt: DateTime.now(),
      );

      final favorite = FavoriteEntity(
        wallpaperId: 'test_wallpaper_id',
        wallpaper: wallpaper,
        userId: 'test_user_id',
        favoritedAt: DateTime.now(),
        syncStatus: FavoriteSyncStatus.localOnly,
      );

      await dataSource.add(favorite);

      final isFav = await dataSource.isFavorite('test_wallpaper_id');
      expect(isFav, true);

      final isNotFav = await dataSource.isFavorite('other_wallpaper_id');
      expect(isNotFav, false);
    });

    test('should remove favorite', () async {
      final wallpaper = WallpaperEntity(
        id: 'test_wallpaper_id',
        url: 'https://example.com/image.jpg',
        thumbUrl: 'https://example.com/thumb.jpg',
        isTopRated: false,
        mediaType: MediaType.image,
        createdAt: DateTime.now(),
      );

      final favorite = FavoriteEntity(
        wallpaperId: 'test_wallpaper_id',
        wallpaper: wallpaper,
        userId: 'test_user_id',
        favoritedAt: DateTime.now(),
        syncStatus: FavoriteSyncStatus.localOnly,
      );

      await dataSource.add(favorite);
      await dataSource.remove('test_wallpaper_id');

      final result = await dataSource.getAll();
      expect(result.length, 0);

      final isFav = await dataSource.isFavorite('test_wallpaper_id');
      expect(isFav, false);
    });
  });
}
