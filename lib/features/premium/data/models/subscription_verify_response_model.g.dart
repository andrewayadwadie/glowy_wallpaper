// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_verify_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionVerifyResponseModel _$SubscriptionVerifyResponseModelFromJson(
  Map<String, dynamic> json,
) => _SubscriptionVerifyResponseModel(
  verified: json['verified'] as bool,
  expiryDate: json['expiryDate'] as String?,
  productId: json['productId'] as String?,
);

Map<String, dynamic> _$SubscriptionVerifyResponseModelToJson(
  _SubscriptionVerifyResponseModel instance,
) => <String, dynamic>{
  'verified': instance.verified,
  'expiryDate': instance.expiryDate,
  'productId': instance.productId,
};
