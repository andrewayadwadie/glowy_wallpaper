// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadRecordModel _$DownloadRecordModelFromJson(Map<String, dynamic> json) =>
    _DownloadRecordModel(
      wallpaperId: json['wallpaper_id'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String,
      title: json['title'] as String,
      downloadedAt: DateTime.parse(json['downloaded_at'] as String),
      fileType: json['file_type'] as String? ?? 'image',
      isTopRated: json['is_top_rated'] as bool? ?? false,
    );

Map<String, dynamic> _$DownloadRecordModelToJson(
  _DownloadRecordModel instance,
) => <String, dynamic>{
  'wallpaper_id': instance.wallpaperId,
  'image_url': instance.imageUrl,
  'thumbnail_url': instance.thumbnailUrl,
  'title': instance.title,
  'downloaded_at': instance.downloadedAt.toIso8601String(),
  'file_type': instance.fileType,
  'is_top_rated': instance.isTopRated,
};
