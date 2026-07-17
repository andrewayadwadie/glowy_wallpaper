// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionStatusResponseModel _$SubscriptionStatusResponseModelFromJson(
  Map<String, dynamic> json,
) => _SubscriptionStatusResponseModel(
  isActive: json['isActive'] as bool,
  expiryDate: json['expiryDate'] as String?,
  productId: json['productId'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$SubscriptionStatusResponseModelToJson(
  _SubscriptionStatusResponseModel instance,
) => <String, dynamic>{
  'isActive': instance.isActive,
  'expiryDate': instance.expiryDate,
  'productId': instance.productId,
  'status': instance.status,
};
