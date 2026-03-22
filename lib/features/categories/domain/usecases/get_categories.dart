import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategories extends UseCase<List<CategoryEntity>, NoParams> {
  final CategoryRepository repository;
  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) =>
      repository.getCategories();
}
