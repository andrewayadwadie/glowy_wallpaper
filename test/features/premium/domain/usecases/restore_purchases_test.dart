import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/repositories/premium_repository.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/restore_purchases.dart';

class MockPremiumRepository extends Mock implements PremiumRepository {}

void main() {
  late RestorePurchases useCase;
  late MockPremiumRepository mockRepository;

  setUp(() {
    mockRepository = MockPremiumRepository();
    useCase = RestorePurchases(mockRepository);
  });

  final tSubscription = SubscriptionEntity(
    status: SubscriptionStatus.premium,
    productId: 'premium_monthly',
    verificationState: VerificationState.verified,
    expiryDate: DateTime(2026, 4, 24),
    lastVerifiedAt: DateTime(2026, 3, 24),
  );

  test('should return subscription entity on successful restore', () async {
    when(
      () => mockRepository.restorePurchases(),
    ).thenAnswer((_) async => Right(tSubscription));

    final result = await useCase(NoParams());

    expect(result, Right(tSubscription));
    verify(() => mockRepository.restorePurchases()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when restore fails', () async {
    when(
      () => mockRepository.restorePurchases(),
    ).thenAnswer((_) async => Left(ServerFailure('Restore failed')));

    final result = await useCase(NoParams());

    expect(result, isA<Left>());
    verify(() => mockRepository.restorePurchases()).called(1);
  });
}
