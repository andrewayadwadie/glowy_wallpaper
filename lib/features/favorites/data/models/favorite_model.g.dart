// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteModel _$FavoriteModelFromJson(Map<String, dynamic> json) =>
    _FavoriteModel(
      wallpaperId: json['wallpaper_id'] as String,
      wallpaper: WallpaperModel.fromJson(
        json['wallpaper'] as Map<String, dynamic>,
      ),
      userId: json['user_id'] as String?,
      favoritedAt: DateTime.parse(json['favorited_at'] as String),
      syncStatus: json['sync_status'] as String? ?? 'synced',
    );

Map<String, dynamic> _$FavoriteModelToJson(_FavoriteModel instance) =>
    <String, dynamic>{
      'wallpaper_id': instance.wallpaperId,
      'wallpaper': instance.wallpaper,
      'user_id': instance.userId,
      'favorited_at': instance.favoritedAt.toIso8601String(),
      'sync_status': instance.syncStatus,
    };
