import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'subscription_state.freezed.dart';

@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.guest() = SubscriptionGuest;
  const factory SubscriptionState.premium({required UserEntity user}) =
      SubscriptionPremium;
  const factory SubscriptionState.loading() = SubscriptionLoading;
}
