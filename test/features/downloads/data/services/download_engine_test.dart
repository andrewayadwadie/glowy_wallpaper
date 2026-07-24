import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/downloads/data/datasources/download_local_data_source.dart';
import 'package:glowy_wallpaper/features/downloads/data/datasources/gallery_data_source.dart';
import 'package:glowy_wallpaper/features/downloads/data/services/download_engine.dart';
import 'package:glowy_wallpaper/features/downloads/data/services/download_runner.dart';
import 'package:glowy_wallpaper/features/downloads/domain/entities/download_event.dart';
import 'package:glowy_wallpaper/features/downloads/domain/entities/download_record_entity.dart';
import 'package:glowy_wallpaper/features/wallpapers/domain/entities/wallpaper_entity.dart';

class MockGalleryDataSource extends Mock implements GalleryDataSource {}

class MockDownloadLocalDataSource extends Mock
    implements DownloadLocalDataSource {}

/// Scripted [DownloadRunner]: each `run()` call gets its own controller so a
/// test can push exact message sequences without a real isolate.
class FakeDownloadRunner implements DownloadRunner {
  final List<({String url, String savePath})> calls = [];
  final List<StreamController<RunnerMessage>> controllers = [];

  StreamController<RunnerMessage> get last => controllers.last;

  @override
  Stream<RunnerMessage> run({required String url, required String savePath}) {
    calls.add((url: url, savePath: savePath));
    final controller = StreamController<RunnerMessage>();
    controllers.add(controller);
    return controller.stream;
  }
}

WallpaperEntity _wallpaper(String id) => WallpaperEntity(
  id: id,
  url: 'https://example.com/$id.jpg',
  thumbUrl: 'https://example.com/$id-thumb.jpg',
  isTopRated: false,
  mediaType: MediaType.image,
  createdAt: DateTime(2024),
);

void main() {
  late FakeDownloadRunner runner;
  late MockGalleryDataSource gallery;
  late MockDownloadLocalDataSource local;
  late DownloadEngine engine;
  late Directory tempDir;

  setUpAll(() {
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
    runner = FakeDownloadRunner();
    gallery = MockGalleryDataSource();
    local = MockDownloadLocalDataSource();
    engine = DownloadEngine(runner, gallery, local);
    tempDir = Directory.systemTemp.createTempSync('download_engine_test_');

    when(
      () => gallery.saveFile(any(), isVideo: any(named: 'isVideo')),
    ).thenAnswer((_) async {});
    when(() => local.saveRecord(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  String partPathFor(String id) => '${tempDir.path}/$id.jpg.part';
  String finalPathFor(String id) => '${tempDir.path}/$id.jpg';

  test('EN-1: a different id while busy is rejected without disturbing the '
      'running job', () async {
    final partA = partPathFor('a');
    final resultA = await engine.start(
      wallpaper: _wallpaper('a'),
      partPath: partA,
      finalPath: finalPathFor('a'),
    );
    expect(resultA.isRight(), isTrue);
    expect(runner.calls.length, 1);

    final resultB = await engine.start(
      wallpaper: _wallpaper('b'),
      partPath: partPathFor('b'),
      finalPath: finalPathFor('b'),
    );

    expect(resultB.isLeft(), isTrue);
    // No second runner job was spawned for b.
    expect(runner.calls.length, 1);
    expect(engine.activeWallpaperId, 'a');
  });

  test('EN-2: starting the same id already in flight joins it — no second job, '
      'no duplicate side effects', () async {
    final partA = partPathFor('a');
    await engine.start(
      wallpaper: _wallpaper('a'),
      partPath: partA,
      finalPath: finalPathFor('a'),
    );
    expect(runner.calls.length, 1);

    final joined = await engine.start(
      wallpaper: _wallpaper('a'),
      partPath: partA,
      finalPath: finalPathFor('a'),
    );

    expect(joined.isRight(), isTrue);
    expect(runner.calls.length, 1);
  });

  test('EN-4: events replays the last event to a late subscriber', () async {
    final partA = partPathFor('a');
    await engine.start(
      wallpaper: _wallpaper('a'),
      partPath: partA,
      finalPath: finalPathFor('a'),
    );
    runner.last.add(RunnerProgress(50, 100));
    await pumpEventQueue();

    final replayed = await engine.events.first;

    expect(replayed, isA<DownloadProgressed>());
    expect((replayed as DownloadProgressed).progress, 0.5);
  });

  test('EN-6/EN-7: on error, the .part file is deleted, no history entry is '
      'written, and the failure kind maps to a typed Failure', () async {
    final partA = partPathFor('a');
    File(partA).writeAsStringSync('partial bytes');

    await engine.start(
      wallpaper: _wallpaper('a'),
      partPath: partA,
      finalPath: finalPathFor('a'),
    );
    final failedFuture = engine.events.firstWhere((e) => e is DownloadFailed);
    runner.last.add(RunnerError('network', 'connection dropped'));
    await runner.last.close();
    final failedEvent = await failedFuture as DownloadFailed;

    expect(File(partA).existsSync(), isFalse);
    verifyNever(() => local.saveRecord(any()));
    expect(failedEvent.failure, isA<NetworkFailure>());
    expect(engine.isBusy, isFalse);
  });

  test(
    'io error kind maps to CacheFailure; unknown kind maps to ServerFailure',
    () async {
      await engine.start(
        wallpaper: _wallpaper('a'),
        partPath: partPathFor('a'),
        finalPath: finalPathFor('a'),
      );
      final failedAFuture = engine.events.firstWhere(
        (e) => e is DownloadFailed,
      );
      runner.last.add(RunnerError('io', 'disk full'));
      await runner.last.close();
      final failedA = await failedAFuture as DownloadFailed;
      expect(failedA.failure, isA<CacheFailure>());

      await engine.start(
        wallpaper: _wallpaper('b'),
        partPath: partPathFor('b'),
        finalPath: finalPathFor('b'),
      );
      final failedBFuture = engine.events.firstWhere(
        (e) => e is DownloadFailed && e.wallpaperId == 'b',
      );
      runner.last.add(RunnerError('unknown', 'boom'));
      await runner.last.close();
      final failedB = await failedBFuture as DownloadFailed;
      expect(failedB.failure, isA<ServerFailure>());
    },
  );

  test(
    'success: renames .part to final, saves to gallery, writes history, '
    'emits Completed only after both succeed, then frees the engine',
    () async {
      final partA = partPathFor('a');
      final finalA = finalPathFor('a');
      File(partA).writeAsStringSync('all the bytes');

      await engine.start(
        wallpaper: _wallpaper('a'),
        partPath: partA,
        finalPath: finalA,
      );
      final completedFuture = engine.events.firstWhere(
        (e) => e is DownloadCompleted,
      );
      runner.last.add(RunnerDone());
      await runner.last.close();
      await completedFuture;

      verify(() => gallery.saveFile(finalA, isVideo: false)).called(1);
      verify(() => local.saveRecord(any())).called(1);
      expect(File(partA).existsSync(), isFalse);
      expect(File(finalA).existsSync(), isFalse);
      expect(engine.isBusy, isFalse);
    },
  );
}
