import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/repositories/premium_repository.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/get_subscription_status.dart';

class MockPremiumRepository extends Mock implements PremiumRepository {}

void main() {
  late GetSubscriptionStatus useCase;
  late MockPremiumRepository mockRepository;

  setUp(() {
    mockRepository = MockPremiumRepository();
    useCase = GetSubscriptionStatus(mockRepository);
  });

  final tSubscription = SubscriptionEntity(
    status: SubscriptionStatus.premium,
    productId: 'premium_monthly',
    verificationState: VerificationState.verified,
    expiryDate: DateTime(2026, 4, 24),
    lastVerifiedAt: DateTime(2026, 3, 24),
  );

  test('should return subscription status from repository', () async {
    when(
      () => mockRepository.getSubscriptionStatus(),
    ).thenAnswer((_) async => Right(tSubscription));

    final result = await useCase(NoParams());

    expect(result, Right(tSubscription));
    verify(() => mockRepository.getSubscriptionStatus()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.getSubscriptionStatus(),
    ).thenAnswer((_) async => Left(ServerFailure('error')));

    final result = await useCase(NoParams());

    expect(result, isA<Left>());
    verify(() => mockRepository.getSubscriptionStatus()).called(1);
  });
}
