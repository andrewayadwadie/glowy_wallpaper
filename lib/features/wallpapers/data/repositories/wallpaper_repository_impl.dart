import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/wallpaper_remote_data_source.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final WallpaperRemoteDataSource remoteDataSource;

  WallpaperRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>>
  getWallpapersByCategory({
    required String categoryId,
    required int page,
    int limit = 20,
    String? classificationId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await remoteDataSource.getWallpapersByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
        classificationId: classificationId,
        cancelToken: cancelToken,
      );
      return Right(
        PaginatedResponse(
          items: response.items.map((m) => m.toEntity()).toList(),
          page: response.page,
          limit: response.limit,
          total: response.total,
          totalPages: response.totalPages,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const Left(CancelledFailure());
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Server error'));
    }
  }
}
