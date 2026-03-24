import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/favorite_entity.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, void>> addFavorite(FavoriteEntity favorite);
  Future<Either<Failure, void>> removeFavorite(String wallpaperId);
  Future<Either<Failure, bool>> isFavorite(String wallpaperId);
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites();
  Future<Either<Failure, void>> syncPendingFavorites();
  Future<Either<Failure, void>> mergeGuestFavorites(List<String> wallpaperIds);
  Future<Either<Failure, List<FavoriteEntity>>> refreshFromServer();
}
