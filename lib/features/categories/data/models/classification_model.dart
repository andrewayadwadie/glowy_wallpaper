import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/classification_entity.dart';

part 'classification_model.freezed.dart';
part 'classification_model.g.dart';

@freezed
abstract class ClassificationModel with _$ClassificationModel {
  const ClassificationModel._();

  const factory ClassificationModel({
    required String id,
    required String name,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'wallpaper_count') required int wallpaperCount,
  }) = _ClassificationModel;

  factory ClassificationModel.fromJson(Map<String, dynamic> json) =>
      _$ClassificationModelFromJson(json);

  ClassificationEntity toEntity() => ClassificationEntity(
    id: id,
    name: name,
    thumbnailUrl: thumbnailUrl,
    wallpaperCount: wallpaperCount,
  );
}
