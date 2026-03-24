import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../repositories/similar_wallpaper_repository.dart';

class GetSimilarWallpapersParams extends Equatable {
  final String wallpaperId;
  const GetSimilarWallpapersParams(this.wallpaperId);

  @override
  List<Object?> get props => [wallpaperId];
}

class GetSimilarWallpapers
    extends UseCase<List<WallpaperEntity>, GetSimilarWallpapersParams> {
  final SimilarWallpaperRepository repository;
  GetSimilarWallpapers(this.repository);

  @override
  Future<Either<Failure, List<WallpaperEntity>>> call(
    GetSimilarWallpapersParams params,
  ) => repository.getSimilarWallpapers(params.wallpaperId);
}
