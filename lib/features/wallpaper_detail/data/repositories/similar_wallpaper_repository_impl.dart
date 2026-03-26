import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
//import '../../../../core/network/network_info.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/repositories/similar_wallpaper_repository.dart';
import '../datasources/similar_wallpaper_remote_data_source.dart';

class SimilarWallpaperRepositoryImpl implements SimilarWallpaperRepository {
  final SimilarWallpaperRemoteDataSource _remote;
  //final NetworkInfo _networkInfo;

  SimilarWallpaperRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<WallpaperEntity>>> getSimilarWallpapers(
    String wallpaperId,
    CategoryType categoryType,
    String classificationId,
  ) async {
    try {
      final models = await _remote.getSimilarWallpapers(
        wallpaperId,
        categoryType,
        classificationId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(
        NetworkFailure(e.message ?? 'Failed to load similar wallpapers'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
