import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/wallpaper_entity.dart';

part 'wallpaper_model.freezed.dart';
part 'wallpaper_model.g.dart';

@freezed
abstract class WallpaperModel with _$WallpaperModel {
  const WallpaperModel._();

  const factory WallpaperModel({
    required String id,
    required String url,
    required String thumbUrl,
    required bool isTopRated,
    required String mediaType,
    String? classificationId,
    String? classificationName,
    String? classificationThumbnailUrl,
    required String createdAt,
  }) = _WallpaperModel;

  factory WallpaperModel.fromJson(Map<String, dynamic> json) =>
      _$WallpaperModelFromJson(json);

  WallpaperEntity toEntity() => WallpaperEntity(
    id: id,
    url: url,
    thumbUrl: thumbUrl,
    isTopRated: isTopRated,
    mediaType: mediaType == 'VIDEO' ? MediaType.video : MediaType.image,
    classificationId: classificationId,
    classificationName: classificationName,
    classificationThumbnailUrl: classificationThumbnailUrl,
    createdAt: DateTime.parse(createdAt),
  );
}
