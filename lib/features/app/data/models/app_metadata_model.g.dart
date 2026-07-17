// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_metadata_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppMetadataModel _$AppMetadataModelFromJson(Map<String, dynamic> json) =>
    _AppMetadataModel(
      name: json['name'] as String,
      description: json['description'] as String,
      about: json['about'] as String,
      privacyPolicy: json['privacyPolicy'] as String,
      termsOfUse: json['termsOfUse'] as String,
      androidShareLink: json['androidShareLink'] as String,
      iphoneShareLink: json['iphoneShareLink'] as String,
      contactEmail: json['contactEmail'] as String,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AppMetadataModelToJson(_AppMetadataModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'about': instance.about,
      'privacyPolicy': instance.privacyPolicy,
      'termsOfUse': instance.termsOfUse,
      'androidShareLink': instance.androidShareLink,
      'iphoneShareLink': instance.iphoneShareLink,
      'contactEmail': instance.contactEmail,
      'categories': instance.categories,
    };
