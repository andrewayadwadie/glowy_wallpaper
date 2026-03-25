import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../wallpapers/data/models/wallpaper_model.dart';

class SimilarWallpaperRemoteDataSource {
  final Dio _dio;
  SimilarWallpaperRemoteDataSource(this._dio);

  Future<List<WallpaperModel>> getSimilarWallpapers(
    String wallpaperId,
  ) async {
    final response = await _dio.get(
      '/api/v1/mobile/apps/${AppConfig.appId}/wallpapers/$wallpaperId/similar',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final items = data['items'] as List;
    return items
        .map((e) => WallpaperModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
