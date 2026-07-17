import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/features/auth/domain/usecases/validate_token.dart';
import 'package:glowy_wallpaper/features/auth/domain/usecases/get_cached_user.dart';
import 'package:glowy_wallpaper/features/auth/domain/usecases/unsubscribe.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/get_products.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/purchase_premium.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/restore_purchases.dart';
import 'package:glowy_wallpaper/features/premium/presentation/cubit/premium_cubit.dart';
import 'package:glowy_wallpaper/features/premium/presentation/cubit/premium_state.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockPurchasePremium extends Mock implements PurchasePremium {}

class MockRestorePurchases extends Mock implements RestorePurchases {}

class MockValidateToken extends Mock implements ValidateToken {}

class MockGetCachedUser extends Mock implements GetCachedUser {}

class MockUnsubscribe extends Mock implements Unsubscribe {}

class FakeNoParams extends Fake implements NoParams {}

class FakePremiumProductEntity extends Fake implements PremiumProductEntity {}

void main() {
  late PremiumCubit cubit;
  late MockGetProducts mockGetProducts;
  late MockPurchasePremium mockPurchasePremium;
  late MockRestorePurchases mockRestorePurchases;
  late SubscriptionCubit subscriptionCubit;
  late MockValidateToken mockValidateToken;
  late MockGetCachedUser mockGetCachedUser;
  late MockUnsubscribe mockUnsubscribe;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakePremiumProductEntity());
  });

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockPurchasePremium = MockPurchasePremium();
    mockRestorePurchases = MockRestorePurchases();
    mockValidateToken = MockValidateToken();
    mockGetCachedUser = MockGetCachedUser();
    mockUnsubscribe = MockUnsubscribe();

    // Stub validateToken so setPremiumFromSubscription -> checkStatus works
    when(
      () => mockValidateToken(any()),
    ).thenAnswer((_) async => const Right(true));
    when(
      () => mockGetCachedUser(any()),
    ).thenAnswer((_) async => const Right(null));

    subscriptionCubit = SubscriptionCubit(
      validateToken: mockValidateToken,
      getCachedUser: mockGetCachedUser,
      unsubscribe: mockUnsubscribe,
    );
    cubit = PremiumCubit(
      getProducts: mockGetProducts,
      purchasePremium: mockPurchasePremium,
      restorePurchases: mockRestorePurchases,
      subscriptionCubit: subscriptionCubit,
    );
  });

  tearDown(() {
    cubit.close();
    subscriptionCubit.close();
  });

  const tProducts = [
    PremiumProductEntity(
      productId: 'premium_monthly',
      title: 'Monthly Premium',
      price: '\$4.99',
      billingPeriod: BillingPeriod.monthly,
      rawPrice: 4.99,
    ),
    PremiumProductEntity(
      productId: 'premium_yearly',
      title: 'Yearly Premium',
      price: '\$29.99',
      billingPeriod: BillingPeriod.yearly,
      rawPrice: 29.99,
    ),
  ];

  final tSubscription = SubscriptionEntity(
    status: SubscriptionStatus.premium,
    productId: 'premium_monthly',
    verificationState: VerificationState.verified,
    expiryDate: DateTime(2026, 4, 24),
    lastVerifiedAt: DateTime(2026, 3, 24),
  );

  group('loadProducts', () {
    blocTest<PremiumCubit, PremiumState>(
      'emits loading then success when products loaded',
      build: () {
        when(
          () => mockGetProducts(any()),
        ).thenAnswer((_) async => const Right(tProducts));
        return cubit;
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const PremiumState(productsStatus: Status.loading),
        PremiumState(
          productsStatus: Status.success,
          products: tProducts,
          selectedProduct: tProducts.first,
        ),
      ],
    );

    blocTest<PremiumCubit, PremiumState>(
      'emits loading then error when products fail to load',
      build: () {
        when(
          () => mockGetProducts(any()),
        ).thenAnswer((_) async => Left(ServerFailure('error')));
        return cubit;
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const PremiumState(productsStatus: Status.loading),
        const PremiumState(productsStatus: Status.error, errorMessage: 'error'),
      ],
    );

    blocTest<PremiumCubit, PremiumState>(
      'emits empty when no products available',
      build: () {
        when(
          () => mockGetProducts(any()),
        ).thenAnswer((_) async => const Right([]));
        return cubit;
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const PremiumState(productsStatus: Status.loading),
        const PremiumState(productsStatus: Status.empty),
      ],
    );
  });

  group('selectProduct', () {
    blocTest<PremiumCubit, PremiumState>(
      'emits state with selected product',
      build: () => cubit,
      act: (cubit) => cubit.selectProduct(tProducts[1]),
      expect: () => [PremiumState(selectedProduct: tProducts[1])],
    );
  });

  group('purchase', () {
    blocTest<PremiumCubit, PremiumState>(
      'emits purchasing then success on successful purchase',
      build: () {
        when(
          () => mockPurchasePremium(any()),
        ).thenAnswer((_) async => Right(tSubscription));
        return cubit;
      },
      seed: () => PremiumState(
        productsStatus: Status.success,
        products: tProducts,
        selectedProduct: tProducts.first,
      ),
      act: (cubit) => cubit.purchase(),
      expect: () => [
        PremiumState(
          productsStatus: Status.success,
          products: tProducts,
          selectedProduct: tProducts.first,
          isPurchasing: true,
        ),
        PremiumState(
          productsStatus: Status.success,
          products: tProducts,
          selectedProduct: tProducts.first,
          purchasedSubscription: tSubscription,
          successMessage: 'Premium activated successfully!',
        ),
      ],
    );

    blocTest<PremiumCubit, PremiumState>(
      'emits purchasing then error on failed purchase',
      build: () {
        when(
          () => mockPurchasePremium(any()),
        ).thenAnswer((_) async => Left(ServerFailure('Purchase failed')));
        return cubit;
      },
      seed: () => PremiumState(
        productsStatus: Status.success,
        products: tProducts,
        selectedProduct: tProducts.first,
      ),
      act: (cubit) => cubit.purchase(),
      expect: () => [
        PremiumState(
          productsStatus: Status.success,
          products: tProducts,
          selectedProduct: tProducts.first,
          isPurchasing: true,
        ),
        PremiumState(
          productsStatus: Status.success,
          products: tProducts,
          selectedProduct: tProducts.first,
          errorMessage: 'Purchase failed',
        ),
      ],
    );

    blocTest<PremiumCubit, PremiumState>(
      'does nothing when no product selected',
      build: () => cubit,
      act: (cubit) => cubit.purchase(),
      expect: () => [],
    );
  });

  group('restore', () {
    blocTest<PremiumCubit, PremiumState>(
      'emits restoring then success when restore finds subscription',
      build: () {
        when(
          () => mockRestorePurchases(any()),
        ).thenAnswer((_) async => Right(tSubscription));
        return cubit;
      },
      act: (cubit) => cubit.restore(),
      expect: () => [
        const PremiumState(isRestoring: true),
        PremiumState(
          purchasedSubscription: tSubscription,
          successMessage: 'Purchase restored successfully!',
        ),
      ],
    );

    blocTest<PremiumCubit, PremiumState>(
      'emits restoring then error when no subscription found',
      build: () {
        when(() => mockRestorePurchases(any())).thenAnswer(
          (_) async => const Right(
            SubscriptionEntity(
              status: SubscriptionStatus.free,
              verificationState: VerificationState.unverified,
            ),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.restore(),
      expect: () => [
        const PremiumState(isRestoring: true),
        const PremiumState(errorMessage: 'No active subscription found.'),
      ],
    );

    blocTest<PremiumCubit, PremiumState>(
      'emits restoring then error on failure',
      build: () {
        when(
          () => mockRestorePurchases(any()),
        ).thenAnswer((_) async => Left(ServerFailure('Network error')));
        return cubit;
      },
      act: (cubit) => cubit.restore(),
      expect: () => [
        const PremiumState(isRestoring: true),
        const PremiumState(errorMessage: 'Network error'),
      ],
    );
  });
}
