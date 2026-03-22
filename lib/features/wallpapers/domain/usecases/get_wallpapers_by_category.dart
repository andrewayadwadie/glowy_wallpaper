import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/paginated_response.dart';
import '../entities/wallpaper_entity.dart';
import '../repositories/wallpaper_repository.dart';

class GetWallpapersByCategoryParams extends Equatable {
  final String categoryId;
  final int page;
  final int perPage;
  final CancelToken? cancelToken;

  const GetWallpapersByCategoryParams({
    required this.categoryId,
    required this.page,
    this.perPage = 20,
    this.cancelToken,
  });

  @override
  List<Object?> get props => [categoryId, page, perPage];
}

class GetWallpapersByCategory
    extends
        UseCase<
          PaginatedResponse<WallpaperEntity>,
          GetWallpapersByCategoryParams
        > {
  final WallpaperRepository repository;
  GetWallpapersByCategory(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>> call(
    GetWallpapersByCategoryParams params,
  ) => repository.getWallpapersByCategory(
    categoryId: params.categoryId,
    page: params.page,
    perPage: params.perPage,
    cancelToken: params.cancelToken,
  );
}
