import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class Unsubscribe extends UseCase<void, NoParams> {
  final AuthRepository repository;

  Unsubscribe(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.unsubscribe();
  }
}
