import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/repositories/premium_repository.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/purchase_premium.dart';

class MockPremiumRepository extends Mock implements PremiumRepository {}

void main() {
  late PurchasePremium useCase;
  late MockPremiumRepository mockRepository;

  setUp(() {
    mockRepository = MockPremiumRepository();
    useCase = PurchasePremium(mockRepository);
  });

  const tProduct = PremiumProductEntity(
    productId: 'premium_monthly',
    title: 'Monthly Premium',
    price: '\$4.99',
    billingPeriod: BillingPeriod.monthly,
    rawPrice: 4.99,
  );

  final tSubscription = SubscriptionEntity(
    status: SubscriptionStatus.premium,
    productId: 'premium_monthly',
    verificationState: VerificationState.verified,
    expiryDate: DateTime(2026, 4, 24),
    lastVerifiedAt: DateTime(2026, 3, 24),
  );

  test('should return subscription entity on successful purchase', () async {
    when(
      () => mockRepository.purchasePremium(tProduct),
    ).thenAnswer((_) async => Right(tSubscription));

    final result = await useCase(tProduct);

    expect(result, Right(tSubscription));
    verify(() => mockRepository.purchasePremium(tProduct)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when purchase fails', () async {
    when(
      () => mockRepository.purchasePremium(tProduct),
    ).thenAnswer((_) async => Left(ServerFailure('Purchase failed')));

    final result = await useCase(tProduct);

    expect(result, isA<Left>());
    verify(() => mockRepository.purchasePremium(tProduct)).called(1);
  });
}
