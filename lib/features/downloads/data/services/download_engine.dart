import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/entities/download_event.dart';
import '../../domain/entities/download_record_entity.dart';
import '../datasources/download_local_data_source.dart';
import '../datasources/gallery_data_source.dart';
import 'download_runner.dart';

/// Session-scoped, single-flight owner of the active download job.
/// Registered as a lazy singleton (see `injection_container.dart`) so the
/// job outlives any per-route [DownloadCubit] — closing the detail page
/// never touches it (FR-018).
class DownloadEngine {
  DownloadEngine(this._runner, this._gallery, this._local);

  final DownloadRunner _runner;
  final GalleryDataSource _gallery;
  final DownloadLocalDataSource _local;

  final _controller = StreamController<DownloadEvent>.broadcast();
  StreamSubscription<RunnerMessage>? _subscription;

  String? _activeId;
  String? _partPath;
  WallpaperEntity? _activeWallpaper;
  DownloadEvent? _last;

  bool get isBusy => _activeId != null;
  String? get activeWallpaperId => _activeId;

  /// Replays the last event to late subscribers, then forwards live events —
  /// so a rebuilt cubit resumes mid-progress instead of missing it.
  Stream<DownloadEvent> get events => Stream.multi((controller) {
    final last = _last;
    if (last != null) controller.add(last);
    final sub = _controller.stream.listen(
      controller.add,
      onError: controller.addError,
    );
    controller.onCancel = sub.cancel;
  });

  Future<Either<Failure, void>> start({
    required WallpaperEntity wallpaper,
    required String partPath,
    required String finalPath,
  }) async {
    if (_activeId == wallpaper.id) {
      // Same job already in flight — join it, start nothing new.
      return const Right(null);
    }
    if (_activeId != null) {
      return Left(CacheFailure('A download is already in progress'));
    }

    _activeId = wallpaper.id;
    _partPath = partPath;
    _activeWallpaper = wallpaper;
    _emit(DownloadStarted(wallpaper.id));

    _subscription = _runner
        .run(url: wallpaper.url, savePath: partPath)
        .listen((message) => _handleMessage(wallpaper.id, message, finalPath));

    return const Right(null);
  }

  Future<void> _handleMessage(
    String wallpaperId,
    RunnerMessage message,
    String finalPath,
  ) async {
    switch (message) {
      case RunnerProgress(:final received, :final total):
        final progress = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
        _emit(DownloadProgressed(wallpaperId, progress));
      case RunnerDone():
        await _completeJob(wallpaperId, finalPath);
      case RunnerError(:final kind, :final message):
        await _failJob(wallpaperId, _mapFailure(kind, message));
    }
  }

  Future<void> _completeJob(String wallpaperId, String finalPath) async {
    final partPath = _partPath;
    final wallpaper = _activeWallpaper;
    try {
      if (partPath == null || wallpaper == null) {
        throw StateError('completed with no active job state');
      }
      await File(partPath).rename(finalPath);

      final isVideo = wallpaper.mediaType == MediaType.video;
      await _gallery.saveFile(finalPath, isVideo: isVideo);

      final savedFile = File(finalPath);
      if (await savedFile.exists()) await savedFile.delete();

      await _local.saveRecord(
        DownloadRecordEntity(
          wallpaperId: wallpaper.id,
          imageUrl: wallpaper.url,
          thumbnailUrl: wallpaper.thumbUrl,
          title: wallpaper.id,
          downloadedAt: DateTime.now(),
          fileType: isVideo ? WallpaperFileType.video : WallpaperFileType.image,
          isTopRated: wallpaper.isTopRated,
        ),
      );

      _emit(DownloadCompleted(wallpaperId));
    } catch (e) {
      await _cleanupPartial(partPath, finalPath);
      _emit(DownloadFailed(wallpaperId, ServerFailure(e.toString())));
    } finally {
      _reset();
    }
  }

  Future<void> _failJob(String wallpaperId, Failure failure) async {
    await _cleanupPartial(_partPath, null);
    _emit(DownloadFailed(wallpaperId, failure));
    _reset();
  }

  Future<void> _cleanupPartial(String? partPath, String? finalPath) async {
    for (final path in [partPath, finalPath]) {
      if (path == null) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort cleanup — never let it mask the original failure.
      }
    }
  }

  Failure _mapFailure(String kind, String message) {
    switch (kind) {
      case 'network':
        return NetworkFailure(message);
      case 'io':
        return CacheFailure(message);
      default:
        return ServerFailure(message);
    }
  }

  void _emit(DownloadEvent event) {
    _last = event;
    _controller.add(event);
  }

  void _reset() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _activeId = null;
    _partPath = null;
    _activeWallpaper = null;
  }
}
