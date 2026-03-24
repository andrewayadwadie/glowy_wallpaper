import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

abstract class SimilarWallpaperRepository {
  Future<Either<Failure, List<WallpaperEntity>>> getSimilarWallpapers(
    String wallpaperId,
  );
}
