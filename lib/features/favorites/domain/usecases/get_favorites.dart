import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_entity.dart';
import '../repositories/favorite_repository.dart';

class GetFavorites extends UseCase<List<FavoriteEntity>, NoParams> {
  final FavoriteRepository repository;
  GetFavorites(this.repository);

  @override
  Future<Either<Failure, List<FavoriteEntity>>> call(NoParams params) =>
      repository.getFavorites();
}
