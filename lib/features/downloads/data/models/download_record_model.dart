import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/download_record_entity.dart';

part 'download_record_model.freezed.dart';
part 'download_record_model.g.dart';

@freezed
abstract class DownloadRecordModel with _$DownloadRecordModel {
  const DownloadRecordModel._();

  const factory DownloadRecordModel({
    @JsonKey(name: 'wallpaper_id') required String wallpaperId,
    @JsonKey(name: 'image_url') @Default('') String imageUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    required String title,
    @JsonKey(name: 'downloaded_at') required DateTime downloadedAt,
    @JsonKey(name: 'file_type') @Default('image') String fileType,
    @JsonKey(name: 'is_top_rated') @Default(false) bool isTopRated,
  }) = _DownloadRecordModel;

  factory DownloadRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadRecordModelFromJson(json);

  DownloadRecordEntity toEntity() => DownloadRecordEntity(
    wallpaperId: wallpaperId,
    imageUrl: imageUrl.isNotEmpty ? imageUrl : thumbnailUrl,
    thumbnailUrl: thumbnailUrl,
    title: title,
    downloadedAt: downloadedAt,
    fileType: fileType == 'video'
        ? WallpaperFileType.video
        : WallpaperFileType.image,
    isTopRated: isTopRated,
  );

  static DownloadRecordModel fromEntity(DownloadRecordEntity entity) =>
      DownloadRecordModel(
        wallpaperId: entity.wallpaperId,
        imageUrl: entity.imageUrl,
        thumbnailUrl: entity.thumbnailUrl,
        title: entity.title,
        downloadedAt: entity.downloadedAt,
        fileType: entity.fileType == WallpaperFileType.video
            ? 'video'
            : 'image',
        isTopRated: entity.isTopRated,
      );
}
