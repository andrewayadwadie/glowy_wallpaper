import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/wallpaper_entity.dart';

abstract class WallpaperRepository {
  Future<Either<Failure, PaginatedResponse<WallpaperEntity>>>
  getWallpapersByCategory({
    required String categoryId,
    required int page,
    int limit = 20,
    String? classificationId,
    CancelToken? cancelToken,
  });
}
