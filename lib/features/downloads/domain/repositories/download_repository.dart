import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/download_event.dart';
import '../entities/download_record_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

abstract class DownloadRepository {
  /// Resolves permission and paths, then delegates to the download engine.
  /// Returns once the job is accepted; the terminal outcome also arrives on
  /// [events]. [onProgress] is kept for source compatibility but is no
  /// longer the progress path — callers should read [events] instead.
  Future<Either<Failure, void>> downloadWallpaper(
    WallpaperEntity wallpaper, {
    void Function(int received, int total)? onProgress,
  });

  /// Engine event stream. Replays the last event to late subscribers so a
  /// rebuilt cubit resumes mid-progress instead of missing it.
  Stream<DownloadEvent> get events;

  Future<Either<Failure, List<DownloadRecordEntity>>> getDownloadHistory();

  Future<Either<Failure, bool>> isDownloaded(String wallpaperId);
}
