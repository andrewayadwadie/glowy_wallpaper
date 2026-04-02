import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_data_source.dart';
import '../datasources/favorite_remote_data_source.dart';
import '../models/favorite_request_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _local;
  final FavoriteRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  FavoriteRepositoryImpl(this._local, this._remote, this._networkInfo);

  @override
  Future<Either<Failure, void>> addFavorite(FavoriteEntity favorite) async {
    try {
      // Optimistic: save locally first with pending sync status
      await _local.add(favorite);

      // Fire-and-forget background sync for authenticated users
      if (favorite.userId != null && await _networkInfo.isConnected) {
        _syncAdd(favorite.wallpaperId).ignore();
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _syncAdd(String wallpaperId) async {
    try {
      await _remote.addFavorite(FavoriteRequestModel(wallpaperId: wallpaperId));
      await _local.updateSyncStatus(wallpaperId, FavoriteSyncStatus.synced);
    } catch (_) {
      // Leave as pending — will be retried on next sync
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String wallpaperId) async {
    try {
      // Check sync status before removal — only call server if it was synced
      final locals = await _local.getAll();
      final wasServerSynced = locals
          .where((f) => f.wallpaperId == wallpaperId)
          .any((f) => f.syncStatus == FavoriteSyncStatus.synced);

      await _local.remove(wallpaperId);

      if (wasServerSynced && await _networkInfo.isConnected) {
        _syncRemove(wallpaperId).ignore();
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _syncRemove(String wallpaperId) async {
    try {
      await _remote.removeFavorite(wallpaperId);
    } catch (_) {
      // Best-effort
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String wallpaperId) async {
    try {
      final result = await _local.isFavorite(wallpaperId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites() async {
    try {
      final locals = await _local.getAll();
      return Right(locals);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingFavorites() async {
    try {
      if (!await _networkInfo.isConnected) return const Right(null);

      final pending = await _local.getPending();
      for (final fav in pending) {
        try {
          await _remote.addFavorite(
            FavoriteRequestModel(wallpaperId: fav.wallpaperId),
          );
          await _local.updateSyncStatus(
            fav.wallpaperId,
            FavoriteSyncStatus.synced,
          );
        } catch (_) {
          // Keep as pending
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> mergeGuestFavorites(
    List<String> wallpaperIds,
  ) async {
    try {
      await _remote.mergeFavorites(
        MergeFavoritesRequestModel(wallpaperIds: wallpaperIds),
      );
      for (final id in wallpaperIds) {
        await _local.updateSyncStatus(id, FavoriteSyncStatus.synced);
      }
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Merge failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteEntity>>> refreshFromServer() async {
    try {
      if (!await _networkInfo.isConnected) {
        final locals = await _local.getAll();
        return Right(locals);
      }

      final serverFavorites = await _remote.getFavorites();
      // Server-wins: replace local data with server data
      final locals = await _local.getAll();
      final localIds = locals.map((f) => f.wallpaperId).toSet();
      final serverIds = serverFavorites.map((f) => f.wallpaperId).toSet();

      // Remove stale local entries not on server
      for (final id in localIds.difference(serverIds)) {
        await _local.remove(id);
      }

      // Add/update server entries
      for (final serverModel in serverFavorites) {
        final updatedModel = serverModel.copyWith(syncStatus: 'synced');
        await _local.add(updatedModel.toEntity());
      }

      final updated = await _local.getAll();
      return Right(updated);
    } on DioException catch (_) {
      final locals = await _local.getAll();
      return Right(locals); // Fall back to local on network error
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
