import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/features/downloads/data/datasources/download_local_data_source.dart';
import 'package:glowy_wallpaper/features/downloads/domain/entities/download_record_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

void main() {
  late Box box;
  late DownloadLocalDataSource dataSource;

  setUp(() async {
    Hive.init('./test_hive');
    box = await Hive.openBox('test_downloads');
    dataSource = DownloadLocalDataSourceImpl(box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  group('DownloadLocalDataSource', () {
    test('should store and retrieve download record correctly', () async {
      final record = DownloadRecordEntity(
        wallpaperId: 'test_wallpaper_id',
        imageUrl: 'https://example.com/image.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        title: 'Test Wallpaper',
        downloadedAt: DateTime.now(),
        fileType: WallpaperFileType.image,
        isTopRated: false,
      );

      await dataSource.saveRecord(record);
      final result = await dataSource.getAll();

      expect(result.length, 1);
      expect(result[0].wallpaperId, 'test_wallpaper_id');
      expect(result[0].imageUrl, 'https://example.com/image.jpg');
      expect(result[0].fileType, WallpaperFileType.image);
    });

    test('should check if wallpaper is downloaded', () async {
      final record = DownloadRecordEntity(
        wallpaperId: 'test_wallpaper_id',
        imageUrl: 'https://example.com/image.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        title: 'Test Wallpaper',
        downloadedAt: DateTime.now(),
        fileType: WallpaperFileType.image,
        isTopRated: false,
      );

      await dataSource.saveRecord(record);

      final isDownloaded = await dataSource.isDownloaded('test_wallpaper_id');
      expect(isDownloaded, true);

      final isNotDownloaded = await dataSource.isDownloaded(
        'other_wallpaper_id',
      );
      expect(isNotDownloaded, false);
    });

    test('should sort records by downloadedAt descending', () async {
      final record1 = DownloadRecordEntity(
        wallpaperId: 'wallpaper_1',
        imageUrl: 'https://example.com/image1.jpg',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        title: 'Wallpaper 1',
        downloadedAt: DateTime(2024, 1, 1),
        fileType: WallpaperFileType.image,
        isTopRated: false,
      );

      final record2 = DownloadRecordEntity(
        wallpaperId: 'wallpaper_2',
        imageUrl: 'https://example.com/image2.jpg',
        thumbnailUrl: 'https://example.com/thumb2.jpg',
        title: 'Wallpaper 2',
        downloadedAt: DateTime(2024, 1, 2),
        fileType: WallpaperFileType.image,
        isTopRated: false,
      );

      final record3 = DownloadRecordEntity(
        wallpaperId: 'wallpaper_3',
        imageUrl: 'https://example.com/image3.jpg',
        thumbnailUrl: 'https://example.com/thumb3.jpg',
        title: 'Wallpaper 3',
        downloadedAt: DateTime(2024, 1, 3),
        fileType: WallpaperFileType.image,
        isTopRated: false,
      );

      await dataSource.saveRecord(record3);
      await dataSource.saveRecord(record1);
      await dataSource.saveRecord(record2);

      final result = await dataSource.getAll();

      expect(result.length, 3);
      expect(result[0].wallpaperId, 'wallpaper_3');
      expect(result[1].wallpaperId, 'wallpaper_2');
      expect(result[2].wallpaperId, 'wallpaper_1');
    });
  });
}
