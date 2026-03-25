import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../categories/data/models/category_model.dart';
import '../../domain/entities/app_metadata_entity.dart';

part 'app_metadata_model.freezed.dart';
part 'app_metadata_model.g.dart';

@freezed
abstract class AppMetadataModel with _$AppMetadataModel {
  const AppMetadataModel._();

  const factory AppMetadataModel({
    required String name,
    required String description,
    required String about,
    required String privacyPolicy,
    required String termsOfUse,
    required String androidShareLink,
    required String iphoneShareLink,
    required String contactEmail,
    @Default([]) List<CategoryModel> categories,
  }) = _AppMetadataModel;

  factory AppMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$AppMetadataModelFromJson(json);

  AppMetadataEntity toEntity() {
    final sorted = List<CategoryModel>.from(categories)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return AppMetadataEntity(
      name: name,
      description: description,
      about: about,
      privacyPolicy: privacyPolicy,
      termsOfUse: termsOfUse,
      androidShareLink: androidShareLink,
      iphoneShareLink: iphoneShareLink,
      contactEmail: contactEmail,
      categories: sorted.map((c) => c.toEntity()).toList(),
    );
  }
}
