import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/premium/data/datasources/iap_data_source.dart';
import 'package:glowy_wallpaper/features/premium/data/datasources/premium_local_source.dart';
import 'package:glowy_wallpaper/features/premium/data/datasources/premium_remote_source.dart';
import 'package:glowy_wallpaper/features/premium/data/models/subscription_cache_model.dart';
import 'package:glowy_wallpaper/features/premium/data/repositories/premium_repository_impl.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';

class MockIAPDataSource extends Mock implements IAPDataSource {}

class MockPremiumRemoteSource extends Mock implements PremiumRemoteSource {}

class MockPremiumLocalSource extends Mock implements PremiumLocalSource {}

class FakeSubscriptionCacheModel extends Fake
    implements SubscriptionCacheModel {}

void main() {
  late PremiumRepositoryImpl repository;
  late MockIAPDataSource mockIAPDataSource;
  late MockPremiumRemoteSource mockRemoteSource;
  late MockPremiumLocalSource mockLocalSource;

  setUpAll(() {
    registerFallbackValue(FakeSubscriptionCacheModel());
  });

  setUp(() {
    mockIAPDataSource = MockIAPDataSource();
    mockRemoteSource = MockPremiumRemoteSource();
    mockLocalSource = MockPremiumLocalSource();
    repository = PremiumRepositoryImpl(
      mockIAPDataSource,
      mockRemoteSource,
      mockLocalSource,
    );
  });

  group('getProducts', () {
    const tProducts = [
      PremiumProductEntity(
        productId: 'premium_monthly',
        title: 'Monthly',
        price: '\$4.99',
        billingPeriod: BillingPeriod.monthly,
        rawPrice: 4.99,
      ),
    ];

    test('should return products when IAP data source succeeds', () async {
      when(
        () => mockIAPDataSource.queryProducts(any()),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockIAPDataSource.convertToEntities(any()),
      ).thenReturn(tProducts);

      final result = await repository.getProducts();

      expect(result, const Right(tProducts));
    });

    test('should return failure when IAP data source fails', () async {
      when(
        () => mockIAPDataSource.queryProducts(any()),
      ).thenAnswer((_) async => Left(ServerFailure('error')));

      final result = await repository.getProducts();

      expect(result, isA<Left>());
    });
  });

  group('getSubscriptionStatus', () {
    test('should return free subscription when no cache exists', () async {
      when(
        () => mockLocalSource.getCachedSubscription(),
      ).thenAnswer((_) async => const Right(null));

      final result = await repository.getSubscriptionStatus();

      result.fold((failure) => fail('Expected Right'), (entity) {
        expect(entity.status, SubscriptionStatus.free);
        expect(entity.verificationState, VerificationState.unverified);
      });
    });

    test('should return cached subscription when cache is valid', () async {
      final cachedModel = SubscriptionCacheModel(
        status: 'premium',
        productId: 'premium_monthly',
        verificationState: 'verified',
        expiryDate: DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        lastVerifiedAt: DateTime.now().toIso8601String(),
      );

      when(
        () => mockLocalSource.getCachedSubscription(),
      ).thenAnswer((_) async => Right(cachedModel));

      final result = await repository.getSubscriptionStatus();

      result.fold((failure) => fail('Expected Right'), (entity) {
        expect(entity.status, SubscriptionStatus.premium);
        expect(entity.verificationState, VerificationState.verified);
      });
    });

    test(
      'should return free when cache is expired and server unreachable',
      () async {
        final expiredCachedModel = SubscriptionCacheModel(
          status: 'premium',
          productId: 'premium_monthly',
          verificationState: 'verified',
          expiryDate: DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String(),
          lastVerifiedAt: DateTime.now()
              .subtract(const Duration(days: 8))
              .toIso8601String(),
        );

        when(
          () => mockLocalSource.getCachedSubscription(),
        ).thenAnswer((_) async => Right(expiredCachedModel));
        when(
          () => mockRemoteSource.getSubscriptionStatus(),
        ).thenThrow(Exception('Network error'));

        final result = await repository.getSubscriptionStatus();

        result.fold((failure) => fail('Expected Right'), (entity) {
          expect(entity.status, SubscriptionStatus.free);
        });
      },
    );
  });

  group('getCachedSubscription', () {
    test('should return null when no cache exists', () async {
      when(
        () => mockLocalSource.getCachedSubscription(),
      ).thenAnswer((_) async => const Right(null));

      final result = await repository.getCachedSubscription();

      result.fold(
        (failure) => fail('Expected Right'),
        (entity) => expect(entity, isNull),
      );
    });

    test('should return failure when local source fails', () async {
      when(
        () => mockLocalSource.getCachedSubscription(),
      ).thenAnswer((_) async => Left(Exception('cache error')));

      final result = await repository.getCachedSubscription();

      expect(result, isA<Left>());
    });
  });
}
