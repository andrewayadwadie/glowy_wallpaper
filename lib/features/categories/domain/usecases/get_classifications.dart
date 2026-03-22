import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/classification_entity.dart';
import '../repositories/category_repository.dart';

class GetClassifications extends UseCase<List<ClassificationEntity>, String> {
  final CategoryRepository repository;
  GetClassifications(this.repository);

  @override
  Future<Either<Failure, List<ClassificationEntity>>> call(String categoryId) =>
      repository.getClassifications(categoryId);
}
