import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../wallpapers/data/models/wallpaper_model.dart';

part 'similar_wallpaper_remote_data_source.g.dart';

@RestApi()
abstract class SimilarWallpaperRemoteDataSource {
  factory SimilarWallpaperRemoteDataSource(Dio dio, {String baseUrl}) =
      _SimilarWallpaperRemoteDataSource;

  @GET('/wallpapers/{wallpaperId}/similar')
  Future<List<WallpaperModel>> getSimilarWallpapers(
    @Path('wallpaperId') String wallpaperId,
  );
}
