import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/favorite_model.dart';
import '../models/favorite_request_model.dart';

part 'favorite_remote_data_source.g.dart';

@RestApi()
abstract class FavoriteRemoteDataSource {
  factory FavoriteRemoteDataSource(Dio dio, {String baseUrl}) =
      _FavoriteRemoteDataSource;

  @GET('/api/v1/favorites')
  Future<List<FavoriteModel>> getFavorites();

  @POST('/api/v1/favorites')
  Future<void> addFavorite(@Body() FavoriteRequestModel request);

  @DELETE('/api/v1/favorites/{wallpaperId}')
  Future<void> removeFavorite(@Path('wallpaperId') String wallpaperId);

  @POST('/api/v1/favorites/merge')
  Future<void> mergeFavorites(@Body() MergeFavoritesRequestModel request);
}
