// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WallpaperModel _$WallpaperModelFromJson(Map<String, dynamic> json) =>
    _WallpaperModel(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbUrl: json['thumbUrl'] as String,
      isTopRated: json['isTopRated'] as bool,
      mediaType: json['mediaType'] as String,
      classificationId: json['classificationId'] as String?,
      classificationName: json['classificationName'] as String?,
      classificationThumbnailUrl: json['classificationThumbnailUrl'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$WallpaperModelToJson(_WallpaperModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'thumbUrl': instance.thumbUrl,
      'isTopRated': instance.isTopRated,
      'mediaType': instance.mediaType,
      'classificationId': instance.classificationId,
      'classificationName': instance.classificationName,
      'classificationThumbnailUrl': instance.classificationThumbnailUrl,
      'createdAt': instance.createdAt,
    };
