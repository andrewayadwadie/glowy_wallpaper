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
    @JsonKey(name: 'thumbnailUrl') required String thumbnailUrl,
    @JsonKey(name: 'itemCount') required int itemCount,
  }) = _ClassificationModel;

  factory ClassificationModel.fromJson(Map<String, dynamic> json) =>
      _$ClassificationModelFromJson(json);

  ClassificationEntity toEntity({required String categoryId}) =>
      ClassificationEntity(
        id: id,
        categoryId: categoryId,
        name: name,
        thumbnailUrl: thumbnailUrl,
        itemCount: itemCount,
      );
}
