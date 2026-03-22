import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../models/paginated_response.dart';
import '../datasources/wallpaper_remote_data_source.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final WallpaperRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WallpaperRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>>
  getWallpapersByCategory({
    required String categoryId,
    required int page,
    int perPage = 20,
    CancelToken? cancelToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final response = await remoteDataSource.getWallpapersByCategory(
        categoryId: categoryId,
        page: page,
        perPage: perPage,
        cancelToken: cancelToken,
      );
      return Right(
        PaginatedResponse(
          items: response.items.map((m) => m.toEntity()).toList(),
          page: response.page,
          perPage: response.perPage,
          hasMore: response.hasMore,
          totalCount: response.totalCount,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const Left(ServerFailure('Request cancelled'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Server error'));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>>
  getWallpapersByClassification({
    required String classificationId,
    required int page,
    int perPage = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final response = await remoteDataSource.getWallpapersByClassification(
        classificationId: classificationId,
        page: page,
        perPage: perPage,
      );
      return Right(
        PaginatedResponse(
          items: response.items.map((m) => m.toEntity()).toList(),
          page: response.page,
          perPage: response.perPage,
          hasMore: response.hasMore,
          totalCount: response.totalCount,
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Server error'));
    }
  }
}
