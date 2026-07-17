import 'package:dartz/dartz.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/premium/data/datasources/iap_data_source.dart';
import 'package:glowy_wallpaper/features/premium/data/datasources/premium_local_source.dart';
import 'package:glowy_wallpaper/features/premium/data/datasources/premium_remote_source.dart';
import 'package:glowy_wallpaper/features/premium/data/models/subscription_cache_model.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/repositories/premium_repository.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final IAPDataSource _iapDataSource;
  final PremiumRemoteSource _remoteSource;
  final PremiumLocalSource _localSource;

  PremiumRepositoryImpl(
    this._iapDataSource,
    this._remoteSource,
    this._localSource,
  );

  @override
  Future<Either<Failure, List<PremiumProductEntity>>> getProducts() async {
    try {
      final productIds = {'premium_monthly', 'premium_yearly'};

      final result = await _iapDataSource.queryProducts(productIds);
      return result.fold((failure) => Left(failure), (productDetails) {
        final entities = _iapDataSource.convertToEntities(productDetails);
        return Right(entities);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> purchasePremium(
    PremiumProductEntity product,
  ) async {
    try {
      final productDetailsList = await _iapDataSource.queryProducts({
        product.productId,
      });

      return await productDetailsList.fold((failure) async => Left(failure), (
        productDetails,
      ) async {
        if (productDetails.isEmpty) {
          return Left(ServerFailure('Product not found'));
        }

        final purchaseResult = await _iapDataSource.buySubscription(
          productDetails.first,
        );

        return await purchaseResult.fold((failure) async => Left(failure), (
          purchaseSuccess,
        ) async {
          final purchaseEntity = SubscriptionEntity(
            status: SubscriptionStatus.premium,
            productId: product.productId,
            purchaseToken: null,
            verificationState: VerificationState.pending,
            expiryDate: null,
            lastVerifiedAt: DateTime.now(),
          );

          final cacheModel = SubscriptionCacheModel.fromEntity(purchaseEntity);
          await _localSource.saveSubscription(cacheModel);

          try {
            final response = await _remoteSource.verifySubscription({
              'product_id': product.productId,
              'purchase_token': 'dummy_token',
            });

            final verified = response.data.verified;
            final expiryDateStr = response.data.expiryDate;

            final verifiedEntity = purchaseEntity.copyWith(
              verificationState: verified
                  ? VerificationState.verified
                  : VerificationState.unverified,
              expiryDate: expiryDateStr != null
                  ? DateTime.parse(expiryDateStr)
                  : null,
              lastVerifiedAt: DateTime.now(),
            );

            final verifiedCacheModel = SubscriptionCacheModel.fromEntity(
              verifiedEntity,
            );
            await _localSource.saveSubscription(verifiedCacheModel);

            return Right(verifiedEntity);
          } catch (e) {
            return Right(
              purchaseEntity.copyWith(
                verificationState: VerificationState.pending,
              ),
            );
          }
        });
      });
    } catch (e) {
      return Left(ServerFailure('Purchase failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> restorePurchases() async {
    try {
      final restoreResult = await _iapDataSource.restorePurchases();

      return await restoreResult.fold((failure) async => Left(failure), (
        _,
      ) async {
        final subscriptionStream = _iapDataSource.purchaseStream;

        final purchases = await subscriptionStream.first;
        final successfulPurchase = purchases.firstWhere(
          (purchase) =>
              purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored,
          orElse: () => throw Exception('No active purchase found'),
        );

        try {
          final response = await _remoteSource.verifySubscription({
            'product_id': successfulPurchase.productID,
            'purchase_token': successfulPurchase.purchaseID ?? '',
          });

          final verified = response.data.verified;
          final expiryDateStr = response.data.expiryDate;

          final entity = SubscriptionEntity(
            status: verified
                ? SubscriptionStatus.premium
                : SubscriptionStatus.free,
            productId: successfulPurchase.productID,
            purchaseToken: successfulPurchase.purchaseID,
            verificationState: verified
                ? VerificationState.verified
                : VerificationState.unverified,
            expiryDate: expiryDateStr != null
                ? DateTime.parse(expiryDateStr)
                : null,
            lastVerifiedAt: DateTime.now(),
          );

          final cacheModel = SubscriptionCacheModel.fromEntity(entity);
          await _localSource.saveSubscription(cacheModel);

          return Right(entity);
        } catch (e) {
          final entity = SubscriptionEntity(
            status: SubscriptionStatus.premium,
            productId: successfulPurchase.productID,
            purchaseToken: successfulPurchase.purchaseID,
            verificationState: VerificationState.pending,
            expiryDate: null,
            lastVerifiedAt: DateTime.now(),
          );

          final cacheModel = SubscriptionCacheModel.fromEntity(entity);
          await _localSource.saveSubscription(cacheModel);

          return Right(entity);
        }
      });
    } catch (e) {
      return Left(ServerFailure('Restore failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> getSubscriptionStatus() async {
    try {
      final cachedResult = await _localSource.getCachedSubscription();

      return await cachedResult.fold(
        (failure) async => Left(ServerFailure(failure.toString())),
        (cachedModel) async {
          if (cachedModel == null) {
            return Right(_createFreeSubscription());
          }

          if (cachedModel.isCacheExpired()) {
            try {
              final response = await _remoteSource.getSubscriptionStatus();
              final isActive = response.data.isActive;
              final expiryDateStr = response.data.expiryDate;

              final entity = SubscriptionEntity(
                status: isActive
                    ? SubscriptionStatus.premium
                    : SubscriptionStatus.free,
                productId: cachedModel.productId,
                purchaseToken: cachedModel.purchaseToken,
                verificationState: isActive
                    ? VerificationState.verified
                    : VerificationState.unverified,
                expiryDate: expiryDateStr != null
                    ? DateTime.parse(expiryDateStr)
                    : null,
                lastVerifiedAt: DateTime.now(),
              );

              final cacheModel = SubscriptionCacheModel.fromEntity(entity);
              await _localSource.saveSubscription(cacheModel);

              return Right(entity);
            } catch (e) {
              return Right(_createFreeSubscription());
            }
          }

          final entity = cachedModel.toEntity();

          if (entity.verificationState == VerificationState.pending) {
            try {
              final response = await _remoteSource.verifySubscription({
                'product_id': entity.productId ?? '',
                'purchase_token': entity.purchaseToken ?? '',
              });

              final verified = response.data.verified;
              final expiryDateStr = response.data.expiryDate;

              final updatedEntity = entity.copyWith(
                status: verified
                    ? SubscriptionStatus.premium
                    : SubscriptionStatus.free,
                verificationState: verified
                    ? VerificationState.verified
                    : VerificationState.unverified,
                expiryDate: expiryDateStr != null
                    ? DateTime.parse(expiryDateStr)
                    : null,
                lastVerifiedAt: DateTime.now(),
              );

              final updatedCacheModel = SubscriptionCacheModel.fromEntity(
                updatedEntity,
              );
              await _localSource.saveSubscription(updatedCacheModel);

              return Right(updatedEntity);
            } catch (e) {
              return Right(
                entity.copyWith(
                  status: entity.isExpired()
                      ? SubscriptionStatus.free
                      : entity.status,
                ),
              );
            }
          }

          return Right(entity);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to get subscription status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> getCachedSubscription() async {
    try {
      final result = await _localSource.getCachedSubscription();
      return result.fold(
        (failure) => Left(ServerFailure(failure.toString())),
        (cachedModel) => Right(cachedModel?.toEntity()),
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to get cached subscription: ${e.toString()}'),
      );
    }
  }

  SubscriptionEntity _createFreeSubscription() {
    return const SubscriptionEntity(
      status: SubscriptionStatus.free,
      productId: null,
      purchaseToken: null,
      verificationState: VerificationState.unverified,
      expiryDate: null,
      lastVerifiedAt: null,
    );
  }
}
