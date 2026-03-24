import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_verify_response_model.freezed.dart';
part 'subscription_verify_response_model.g.dart';

@freezed
abstract class SubscriptionVerifyResponseModel
    with _$SubscriptionVerifyResponseModel {
  const SubscriptionVerifyResponseModel._();

  const factory SubscriptionVerifyResponseModel({
    required bool verified,
    String? expiryDate,
    String? productId,
  }) = _SubscriptionVerifyResponseModel;

  factory SubscriptionVerifyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionVerifyResponseModelFromJson(json);
}
