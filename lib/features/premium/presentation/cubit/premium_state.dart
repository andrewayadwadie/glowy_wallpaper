import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/status.dart';
import '../../domain/entities/premium_product_entity.dart';
import '../../domain/entities/subscription_entity.dart';

export '../../../../core/enums/status.dart';

part 'premium_state.freezed.dart';

@freezed
abstract class PremiumState with _$PremiumState {
  const factory PremiumState({
    @Default(Status.loading) Status productsStatus,
    @Default([]) List<PremiumProductEntity> products,
    PremiumProductEntity? selectedProduct,
    @Default(false) bool isPurchasing,
    @Default(false) bool isRestoring,
    SubscriptionEntity? purchasedSubscription,
    String? errorMessage,
    String? successMessage,
  }) = _PremiumState;
}
