import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/presentation/cubit/subscription_cubit.dart';
import '../../domain/entities/premium_product_entity.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/purchase_premium.dart';
import '../../domain/usecases/restore_purchases.dart';
import 'premium_state.dart';

class PremiumCubit extends Cubit<PremiumState> {
  final GetProducts _getProducts;
  final PurchasePremium _purchasePremium;
  final RestorePurchases _restorePurchases;
  final SubscriptionCubit _subscriptionCubit;
  final FirebaseAnalytics? _analytics;

  PremiumCubit({
    required GetProducts getProducts,
    required PurchasePremium purchasePremium,
    required RestorePurchases restorePurchases,
    required SubscriptionCubit subscriptionCubit,
    FirebaseAnalytics? analytics,
  }) : _getProducts = getProducts,
       _purchasePremium = purchasePremium,
       _restorePurchases = restorePurchases,
       _subscriptionCubit = subscriptionCubit,
       _analytics = analytics,
       super(const PremiumState());

  Future<void> loadProducts() async {
    emit(state.copyWith(productsStatus: Status.loading, errorMessage: null));

    final result = await _getProducts(NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          productsStatus: Status.error,
          errorMessage: failure.message,
        ),
      ),
      (products) {
        final selected = products.isNotEmpty ? products.first : null;
        emit(
          state.copyWith(
            productsStatus: products.isEmpty ? Status.empty : Status.success,
            products: products,
            selectedProduct: selected,
          ),
        );
      },
    );
  }

  void selectProduct(PremiumProductEntity product) {
    emit(state.copyWith(selectedProduct: product));
  }

  Future<void> purchase() async {
    final product = state.selectedProduct;
    if (product == null || state.isPurchasing) return;

    emit(state.copyWith(isPurchasing: true, errorMessage: null));
    _analytics?.logEvent(
      name: 'purchase_initiated',
      parameters: {'product_id': product.productId},
    );

    final result = await _purchasePremium(product);

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            state.copyWith(isPurchasing: false, errorMessage: failure.message),
          );
        }
      },
      (subscription) {
        if (!isClosed) {
          _subscriptionCubit.setPremiumFromSubscription(subscription);
          _analytics?.logEvent(
            name: 'purchase_succeeded',
            parameters: {'product_id': product.productId},
          );
          emit(
            state.copyWith(
              isPurchasing: false,
              purchasedSubscription: subscription,
              successMessage: 'Premium activated successfully!',
            ),
          );
        }
      },
    );
  }

  Future<void> restore() async {
    if (state.isRestoring) return;

    emit(
      state.copyWith(
        isRestoring: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await _restorePurchases(NoParams());

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            state.copyWith(isRestoring: false, errorMessage: failure.message),
          );
        }
      },
      (subscription) {
        if (!isClosed) {
          if (subscription.isPremium) {
            _subscriptionCubit.setPremiumFromSubscription(subscription);
            _analytics?.logEvent(name: 'restore_succeeded');
            emit(
              state.copyWith(
                isRestoring: false,
                purchasedSubscription: subscription,
                successMessage: 'Purchase restored successfully!',
              ),
            );
          } else {
            emit(
              state.copyWith(
                isRestoring: false,
                errorMessage: 'No active subscription found.',
              ),
            );
          }
        }
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
