import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/errors/failure.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/entities/download_event.dart';
import '../../domain/entities/download_record_entity.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_local_data_source.dart';
import '../datasources/gallery_data_source.dart';
import '../services/download_engine.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadLocalDataSource _localDataSource;
  final GalleryDataSource _galleryDataSource;
  final DownloadEngine _engine;

  DownloadRepositoryImpl(
    this._localDataSource,
    this._galleryDataSource,
    this._engine,
  );

  @override
  Stream<DownloadEvent> get events => _engine.events;

  @override
  Future<Either<Failure, void>> downloadWallpaper(
    WallpaperEntity wallpaper, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final hasPermission = await _galleryDataSource.requestPermission();
      if (!hasPermission) {
        final isPermanentlyDenied = await _galleryDataSource
            .isPermanentlyDenied();
        if (isPermanentlyDenied) {
          // Return a sentinel message the presentation layer detects to show
          // the "Open Settings" dialog instead of a plain snackbar.
          return Left(CacheFailure('permission_permanently_denied'));
        }
        return Left(CacheFailure('Storage permission denied'));
      }

      final isVideo = wallpaper.mediaType == MediaType.video;
      final ext = isVideo ? 'mp4' : 'jpg';
      final tmpDir = await getTemporaryDirectory();
      final partPath = '${tmpDir.path}/wallpaper_${wallpaper.id}.$ext.part';
      final finalPath = '${tmpDir.path}/wallpaper_${wallpaper.id}.$ext';

      return await _engine.start(
        wallpaper: wallpaper,
        partPath: partPath,
        finalPath: finalPath,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DownloadRecordEntity>>>
  getDownloadHistory() async {
    try {
      final records = await _localDataSource.getAll();
      return Right(records);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isDownloaded(String wallpaperId) async {
    try {
      final result = await _localDataSource.isDownloaded(wallpaperId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
