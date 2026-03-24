import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status_response_model.freezed.dart';
part 'subscription_status_response_model.g.dart';

@freezed
abstract class SubscriptionStatusResponseModel
    with _$SubscriptionStatusResponseModel {
  const SubscriptionStatusResponseModel._();

  const factory SubscriptionStatusResponseModel({
    required bool isActive,
    String? expiryDate,
    String? productId,
    String? status,
  }) = _SubscriptionStatusResponseModel;

  factory SubscriptionStatusResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusResponseModelFromJson(json);
}
