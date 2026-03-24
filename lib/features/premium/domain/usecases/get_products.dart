import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/premium_product_entity.dart';
import '../repositories/premium_repository.dart';

class GetProducts extends UseCase<List<PremiumProductEntity>, NoParams> {
  final PremiumRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<PremiumProductEntity>>> call(NoParams params) {
    return repository.getProducts();
  }
}
