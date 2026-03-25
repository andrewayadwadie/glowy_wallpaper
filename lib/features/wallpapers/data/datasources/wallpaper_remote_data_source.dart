import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/wallpaper_model.dart';

class WallpaperRemoteDataSource {
  final Dio _dio;
  WallpaperRemoteDataSource(this._dio);

  Future<PaginatedResponse<WallpaperModel>> getWallpapersByCategory({
    required String categoryId,
    required int page,
    int limit = 20,
    String? classificationId,
    CancelToken? cancelToken,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (classificationId != null) {
      queryParams['classificationId'] = classificationId;
    }

    final response = await _dio.get(
      '/api/v1/mobile/apps/${AppConfig.appId}/categories/$categoryId/content',
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return PaginatedResponse.fromJson(
      data,
      (json) => WallpaperModel.fromJson(json),
    );
  }
}
