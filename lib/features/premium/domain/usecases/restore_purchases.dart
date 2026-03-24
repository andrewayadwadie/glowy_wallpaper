import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/premium_repository.dart';

class RestorePurchases extends UseCase<SubscriptionEntity, NoParams> {
  final PremiumRepository repository;

  RestorePurchases(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(NoParams params) {
    return repository.restorePurchases();
  }
}
