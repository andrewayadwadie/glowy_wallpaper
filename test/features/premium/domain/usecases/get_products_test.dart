import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/repositories/premium_repository.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/get_products.dart';

class MockPremiumRepository extends Mock implements PremiumRepository {}

void main() {
  late GetProducts useCase;
  late MockPremiumRepository mockRepository;

  setUp(() {
    mockRepository = MockPremiumRepository();
    useCase = GetProducts(mockRepository);
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

  test('should return list of products from the repository', () async {
    when(
      () => mockRepository.getProducts(),
    ).thenAnswer((_) async => const Right(tProducts));

    final result = await useCase(NoParams());

    expect(result, const Right(tProducts));
    verify(() => mockRepository.getProducts()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.getProducts(),
    ).thenAnswer((_) async => Left(ServerFailure('error')));

    final result = await useCase(NoParams());

    expect(result, isA<Left>());
    verify(() => mockRepository.getProducts()).called(1);
  });
}
