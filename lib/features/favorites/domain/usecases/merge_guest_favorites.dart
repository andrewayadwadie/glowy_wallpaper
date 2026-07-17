import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorite_repository.dart';

class MergeGuestFavoritesParams extends Equatable {
  final List<String> wallpaperIds;
  const MergeGuestFavoritesParams(this.wallpaperIds);

  @override
  List<Object?> get props => [wallpaperIds];
}

class MergeGuestFavorites extends UseCase<void, MergeGuestFavoritesParams> {
  final FavoriteRepository repository;
  MergeGuestFavorites(this.repository);

  @override
  Future<Either<Failure, void>> call(MergeGuestFavoritesParams params) =>
      repository.mergeGuestFavorites(params.wallpaperIds);
}
