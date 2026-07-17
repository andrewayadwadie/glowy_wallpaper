import 'package:equatable/equatable.dart';
import '../../../categories/domain/entities/category_entity.dart';

class AppMetadataEntity extends Equatable {
  final String name;
  final String description;
  final String about;
  final String privacyPolicy;
  final String termsOfUse;
  final String androidShareLink;
  final String iphoneShareLink;
  final String contactEmail;
  final List<CategoryEntity> categories;

  const AppMetadataEntity({
    required this.name,
    required this.description,
    required this.about,
    required this.privacyPolicy,
    required this.termsOfUse,
    required this.androidShareLink,
    required this.iphoneShareLink,
    required this.contactEmail,
    required this.categories,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    about,
    privacyPolicy,
    termsOfUse,
    androidShareLink,
    iphoneShareLink,
    contactEmail,
    categories,
  ];
}
