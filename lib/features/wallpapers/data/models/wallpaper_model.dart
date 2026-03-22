import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/wallpaper_entity.dart';

part 'wallpaper_model.freezed.dart';
part 'wallpaper_model.g.dart';

@freezed
abstract class WallpaperModel with _$WallpaperModel {
  const WallpaperModel._();

  const factory WallpaperModel({
    required String id,
    required String title,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'is_premium') required bool isPremium,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'classification_ids')
    @Default([])
    List<String> classificationIds,
  }) = _WallpaperModel;

  factory WallpaperModel.fromJson(Map<String, dynamic> json) =>
      _$WallpaperModelFromJson(json);

  WallpaperEntity toEntity() => WallpaperEntity(
    id: id,
    title: title,
    imageUrl: imageUrl,
    thumbnailUrl: thumbnailUrl,
    videoUrl: videoUrl,
    isPremium: isPremium,
    categoryId: categoryId,
    classificationIds: classificationIds,
  );
}
