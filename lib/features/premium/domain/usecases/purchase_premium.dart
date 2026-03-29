import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/premium_product_entity.dart';
import '../entities/subscription_entity.dart';
import '../repositories/premium_repository.dart';

class PurchasePremium
    extends UseCase<SubscriptionEntity, PremiumProductEntity> {
  final PremiumRepository repository;

  PurchasePremium(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(
    PremiumProductEntity params,
  ) {
    return repository.purchasePremium(params);
  }
}
