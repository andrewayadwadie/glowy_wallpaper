import 'package:dio/dio.dart';
import '../models/paginated_response.dart';
import '../models/wallpaper_model.dart';

class WallpaperRemoteDataSource {
  final Dio _dio;
  WallpaperRemoteDataSource(this._dio);

  Future<PaginatedResponse<WallpaperModel>> getWallpapersByCategory({
    required String categoryId,
    required int page,
    int perPage = 20,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/categories/$categoryId/wallpapers',
      queryParameters: {'page': page, 'per_page': perPage},
      cancelToken: cancelToken,
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WallpaperModel.fromJson(json),
    );
  }

  Future<PaginatedResponse<WallpaperModel>> getWallpapersByClassification({
    required String classificationId,
    required int page,
    int perPage = 20,
  }) async {
    final response = await _dio.get(
      '/classifications/$classificationId/wallpapers',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => WallpaperModel.fromJson(json),
    );
  }
}
