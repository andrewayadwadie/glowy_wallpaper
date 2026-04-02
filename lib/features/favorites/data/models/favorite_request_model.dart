import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_request_model.freezed.dart';
part 'favorite_request_model.g.dart';

@freezed
abstract class FavoriteRequestModel with _$FavoriteRequestModel {
  const factory FavoriteRequestModel({
    @JsonKey(name: 'wallpaper_id') required String wallpaperId,
  }) = _FavoriteRequestModel;

  factory FavoriteRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => when(
    (wallpaperId) => _$FavoriteRequestModelToJson(
      _FavoriteRequestModel(wallpaperId: wallpaperId),
    ),
  );
}

@freezed
abstract class MergeFavoritesRequestModel with _$MergeFavoritesRequestModel {
  const factory MergeFavoritesRequestModel({
    @JsonKey(name: 'wallpaper_ids') required List<String> wallpaperIds,
  }) = _MergeFavoritesRequestModel;

  factory MergeFavoritesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$MergeFavoritesRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => when(
    (wallpaperIds) => _$MergeFavoritesRequestModelToJson(
      _MergeFavoritesRequestModel(wallpaperIds: wallpaperIds),
    ),
  );
}
