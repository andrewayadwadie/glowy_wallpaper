import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status_model.freezed.dart';
part 'subscription_status_model.g.dart';

@freezed
abstract class SubscriptionStatusModel with _$SubscriptionStatusModel {
  const factory SubscriptionStatusModel({
    @JsonKey(name: 'is_premium') required bool isPremium,
  }) = _SubscriptionStatusModel;

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusModelFromJson(json);
}
