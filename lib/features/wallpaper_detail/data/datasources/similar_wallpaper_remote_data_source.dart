import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallpapers/data/models/wallpaper_model.dart';

class SimilarWallpaperRemoteDataSource {
  final Dio _dio;
  SimilarWallpaperRemoteDataSource(this._dio);

  Future<List<WallpaperModel>> getSimilarWallpapers(
    String wallpaperId,
    CategoryType categoryType,
    String classificationId,
  ) async {
    final String url = categoryType == CategoryType.classification
        ? '/api/v1/mobile/apps/${AppConfig.appId}/categories/$wallpaperId/content?classificationId=$classificationId'
        : '/api/v1/mobile/apps/${AppConfig.appId}/categories/$wallpaperId/content';
    final response = await _dio.get(url);
    final data = response.data['data'] as Map<String, dynamic>;
    final items = data['items'] as List;
    return items
        .map((e) => WallpaperModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
