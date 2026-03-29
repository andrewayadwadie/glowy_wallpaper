import 'package:dartz/dartz.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';

abstract class PremiumRepository {
  Future<Either<Failure, List<PremiumProductEntity>>> getProducts();

  Future<Either<Failure, SubscriptionEntity>> purchasePremium(
    PremiumProductEntity product,
  );

  Future<Either<Failure, SubscriptionEntity>> restorePurchases();

  Future<Either<Failure, SubscriptionEntity>> getSubscriptionStatus();

  Future<Either<Failure, SubscriptionEntity?>> getCachedSubscription();
}
