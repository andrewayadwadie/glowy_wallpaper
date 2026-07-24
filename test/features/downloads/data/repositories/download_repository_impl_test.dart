import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/downloads/data/datasources/download_local_data_source.dart';
import 'package:glowy_wallpaper/features/downloads/data/datasources/gallery_data_source.dart';
import 'package:glowy_wallpaper/features/downloads/data/repositories/download_repository_impl.dart';
import 'package:glowy_wallpaper/features/downloads/data/services/download_engine.dart';
import 'package:glowy_wallpaper/features/downloads/domain/entities/download_event.dart';
import 'package:glowy_wallpaper/features/downloads/domain/entities/download_record_entity.dart';
import 'package:glowy_wallpaper/features/wallpapers/domain/entities/wallpaper_entity.dart';

class MockDownloadLocalDataSource extends Mock
    implements DownloadLocalDataSource {}

class MockGalleryDataSource extends Mock implements GalleryDataSource {}

class MockDownloadEngine extends Mock implements DownloadEngine {}

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => '/tmp';
}

final _wallpaper = WallpaperEntity(
  id: 'w1',
  url: 'https://example.com/w1.jpg',
  thumbUrl: 'https://example.com/w1-thumb.jpg',
  isTopRated: false,
  mediaType: MediaType.image,
  createdAt: DateTime(2024),
);

void main() {
  late MockDownloadLocalDataSource local;
  late MockGalleryDataSource gallery;
  late MockDownloadEngine engine;
  late DownloadRepositoryImpl repository;

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    registerFallbackValue(_wallpaper);
    registerFallbackValue(
      DownloadRecordEntity(
        wallpaperId: 'fallback',
        imageUrl: 'https://example.com/fallback.jpg',
        thumbnailUrl: 'https://example.com/fallback-thumb.jpg',
        title: 'fallback',
        downloadedAt: DateTime(2024),
        fileType: WallpaperFileType.image,
      ),
    );
  });

  setUp(() {
    local = MockDownloadLocalDataSource();
    gallery = MockGalleryDataSource();
    engine = MockDownloadEngine();
    repository = DownloadRepositoryImpl(local, gallery, engine);
  });

  test('permission denied (permanently): returns the existing sentinel message '
      'unchanged, without touching the engine (FR-008)', () async {
    when(() => gallery.requestPermission()).thenAnswer((_) async => false);
    when(() => gallery.isPermanentlyDenied()).thenAnswer((_) async => true);

    final result = await repository.downloadWallpaper(_wallpaper);

    expect(
      result,
      Left<Failure, void>(CacheFailure('permission_permanently_denied')),
    );
    verifyNever(
      () => engine.start(
        wallpaper: any(named: 'wallpaper'),
        partPath: any(named: 'partPath'),
        finalPath: any(named: 'finalPath'),
      ),
    );
  });

  test('permission denied (not permanent): returns the existing sentinel '
      'message unchanged', () async {
    when(() => gallery.requestPermission()).thenAnswer((_) async => false);
    when(() => gallery.isPermanentlyDenied()).thenAnswer((_) async => false);

    final result = await repository.downloadWallpaper(_wallpaper);

    expect(
      result,
      Left<Failure, void>(CacheFailure('Storage permission denied')),
    );
  });

  test('permission granted: resolves paths and delegates to the engine, '
      'without writing any history entry itself (FR-020 — the engine owns '
      'that on the success/failure paths)', () async {
    when(() => gallery.requestPermission()).thenAnswer((_) async => true);
    when(
      () => engine.start(
        wallpaper: any(named: 'wallpaper'),
        partPath: any(named: 'partPath'),
        finalPath: any(named: 'finalPath'),
      ),
    ).thenAnswer((_) async => const Right(null));

    final result = await repository.downloadWallpaper(_wallpaper);

    expect(result, const Right<Failure, void>(null));
    final captured = verify(
      () => engine.start(
        wallpaper: captureAny(named: 'wallpaper'),
        partPath: captureAny(named: 'partPath'),
        finalPath: captureAny(named: 'finalPath'),
      ),
    ).captured;
    expect(captured[0], _wallpaper);
    expect(captured[1], endsWith('.jpg.part'));
    expect(captured[2], endsWith('.jpg'));
    verifyNever(() => local.saveRecord(any()));
  });

  test('events forwards the engine event stream', () async {
    final controller = StreamController<DownloadEvent>();
    when(() => engine.events).thenAnswer((_) => controller.stream);

    final received = <DownloadEvent>[];
    final subscription = repository.events.listen(received.add);
    controller.add(const DownloadStarted('w1'));
    await pumpEventQueue();

    expect(received, [const DownloadStarted('w1')]);

    await subscription.cancel();
    await controller.close();
  });
}
