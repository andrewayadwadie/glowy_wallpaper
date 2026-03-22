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
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'display_order') required int displayOrder,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    name: name,
    type: CategoryType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => CategoryType.image,
    ),
    thumbnailUrl: thumbnailUrl,
    displayOrder: displayOrder,
  );
}
