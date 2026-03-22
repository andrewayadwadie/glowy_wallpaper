import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ValidateToken extends UseCase<bool, NoParams> {
  final AuthRepository repository;

  ValidateToken(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.validateToken();
  }
}
