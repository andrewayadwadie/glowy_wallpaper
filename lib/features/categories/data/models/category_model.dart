import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const CategoryModel._();

  const factory CategoryModel({
    required String id,
    required String name,
    required String type,
    @JsonKey(name: 'displayOrder') required int displayOrder,
    @JsonKey(name: 'imageCount') required int imageCount,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    name: name,
    type: _parseType(type),
    displayOrder: displayOrder,
    imageCount: imageCount,
  );

  static CategoryType _parseType(String type) {
    switch (type) {
      case 'IMAGES':
        return CategoryType.image;
      case 'VIDEOS':
        return CategoryType.video;
      case 'IMAGE_CLASSIFICATION':
        return CategoryType.classification;
      default:
        return CategoryType.image;
    }
  }
}
