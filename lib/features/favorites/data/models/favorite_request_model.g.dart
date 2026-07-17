// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteRequestModel _$FavoriteRequestModelFromJson(
  Map<String, dynamic> json,
) => _FavoriteRequestModel(wallpaperId: json['wallpaper_id'] as String);

Map<String, dynamic> _$FavoriteRequestModelToJson(
  _FavoriteRequestModel instance,
) => <String, dynamic>{'wallpaper_id': instance.wallpaperId};

_MergeFavoritesRequestModel _$MergeFavoritesRequestModelFromJson(
  Map<String, dynamic> json,
) => _MergeFavoritesRequestModel(
  wallpaperIds: (json['wallpaper_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MergeFavoritesRequestModelToJson(
  _MergeFavoritesRequestModel instance,
) => <String, dynamic>{'wallpaper_ids': instance.wallpaperIds};
