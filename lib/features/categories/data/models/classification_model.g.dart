// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassificationModel _$ClassificationModelFromJson(Map<String, dynamic> json) =>
    _ClassificationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      itemCount: (json['itemCount'] as num).toInt(),
    );

Map<String, dynamic> _$ClassificationModelToJson(
  _ClassificationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'thumbnailUrl': instance.thumbnailUrl,
  'itemCount': instance.itemCount,
};
