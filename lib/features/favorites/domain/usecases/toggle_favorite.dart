import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_entity.dart';
import '../repositories/favorite_repository.dart';

class ToggleFavoriteParams extends Equatable {
  final String wallpaperId;
  final FavoriteEntity? favoriteToAdd;

  const ToggleFavoriteParams({required this.wallpaperId, this.favoriteToAdd});

  @override
  List<Object?> get props => [wallpaperId, favoriteToAdd];
}

class ToggleFavorite extends UseCase<bool, ToggleFavoriteParams> {
  final FavoriteRepository repository;
  ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleFavoriteParams params) async {
    final isFavResult = await repository.isFavorite(params.wallpaperId);
    return isFavResult.fold((failure) => Left(failure), (isFav) async {
      if (isFav) {
        final result = await repository.removeFavorite(params.wallpaperId);
        return result.fold(
          (failure) => Left(failure),
          (_) => const Right(false),
        );
      } else {
        if (params.favoriteToAdd == null) {
          return Left(CacheFailure('No favorite entity provided to add'));
        }
        final result = await repository.addFavorite(params.favoriteToAdd!);
        return result.fold(
          (failure) => Left(failure),
          (_) => const Right(true),
        );
      }
    });
  }
}
