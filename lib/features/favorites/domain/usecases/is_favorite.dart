import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorite_repository.dart';

class IsFavoriteParams extends Equatable {
  final String wallpaperId;
  const IsFavoriteParams(this.wallpaperId);

  @override
  List<Object?> get props => [wallpaperId];
}

class IsFavorite extends UseCase<bool, IsFavoriteParams> {
  final FavoriteRepository repository;
  IsFavorite(this.repository);

  @override
  Future<Either<Failure, bool>> call(IsFavoriteParams params) =>
      repository.isFavorite(params.wallpaperId);
}
