// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_cache_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionCacheModel _$SubscriptionCacheModelFromJson(
  Map<String, dynamic> json,
) => _SubscriptionCacheModel(
  status: json['status'] as String,
  productId: json['product_id'] as String?,
  purchaseToken: json['purchase_token'] as String?,
  verificationState: json['verification_state'] as String,
  expiryDate: json['expiry_date'] as String?,
  lastVerifiedAt: json['last_verified_at'] as String?,
);

Map<String, dynamic> _$SubscriptionCacheModelToJson(
  _SubscriptionCacheModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'product_id': instance.productId,
  'purchase_token': instance.purchaseToken,
  'verification_state': instance.verificationState,
  'expiry_date': instance.expiryDate,
  'last_verified_at': instance.lastVerifiedAt,
};
