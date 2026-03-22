import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/paginated_response.dart';
import '../entities/wallpaper_entity.dart';
import '../repositories/wallpaper_repository.dart';

class GetWallpapersByClassificationParams extends Equatable {
  final String classificationId;
  final int page;
  final int perPage;

  const GetWallpapersByClassificationParams({
    required this.classificationId,
    required this.page,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [classificationId, page, perPage];
}

class GetWallpapersByClassification
    extends
        UseCase<
          PaginatedResponse<WallpaperEntity>,
          GetWallpapersByClassificationParams
        > {
  final WallpaperRepository repository;
  GetWallpapersByClassification(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> call(
    GetWallpapersByClassificationParams params,
  ) => repository.getWallpapersByClassification(
    classificationId: params.classificationId,
    page: params.page,
    perPage: params.perPage,
  );
}
