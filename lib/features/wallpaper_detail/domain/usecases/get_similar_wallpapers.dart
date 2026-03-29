import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../repositories/similar_wallpaper_repository.dart';

class GetSimilarWallpapersParams extends Equatable {
  final String wallpaperId;
  final CategoryType categoryType;
  final String classificationId;
  const GetSimilarWallpapersParams(
    this.wallpaperId,
    this.categoryType,
    this.classificationId,
  );

  @override
  List<Object?> get props => [wallpaperId, categoryType, classificationId];
}

class GetSimilarWallpapers
    extends UseCase<List<WallpaperEntity>, GetSimilarWallpapersParams> {
  final SimilarWallpaperRepository repository;
  GetSimilarWallpapers(this.repository);

  @override
  Future<Either<Failure, List<WallpaperEntity>>> call(
    GetSimilarWallpapersParams params,
  ) => repository.getSimilarWallpapers(
    params.wallpaperId,
    params.categoryType,
    params.classificationId,
  );
}
