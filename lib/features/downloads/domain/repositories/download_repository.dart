import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/download_record_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

abstract class DownloadRepository {
  Future<Either<Failure, void>> downloadWallpaper(
    WallpaperEntity wallpaper, {
    void Function(int received, int total)? onProgress,
  });

  Future<Either<Failure, List<DownloadRecordEntity>>> getDownloadHistory();

  Future<Either<Failure, bool>> isDownloaded(String wallpaperId);
}
