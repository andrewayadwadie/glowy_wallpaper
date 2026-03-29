import 'package:hive/hive.dart';
import '../../data/models/favorite_model.dart';
import '../../domain/entities/favorite_entity.dart';

abstract class FavoriteLocalDataSource {
  Future<void> add(FavoriteEntity favorite);
  Future<void> remove(String wallpaperId);
  Future<List<FavoriteEntity>> getAll();
  Future<bool> isFavorite(String wallpaperId);
  Future<List<FavoriteEntity>> getPending();
  Future<void> updateSyncStatus(String wallpaperId, FavoriteSyncStatus status);
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  final Box _box;

  FavoriteLocalDataSourceImpl(this._box);

  @override
  Future<void> add(FavoriteEntity favorite) async {
    final model = FavoriteModel.fromEntity(favorite);
    final json = model.toJson();
    // explicitToJson is not enabled, so nested WallpaperModel must be
    // serialized manually to avoid Hive failing on the raw Dart object.
    json['wallpaper'] = model.wallpaper.toJson();
    await _box.put(favorite.wallpaperId, json);
  }

  @override
  Future<void> remove(String wallpaperId) async {
    await _box.delete(wallpaperId);
  }

  @override
  Future<List<FavoriteEntity>> getAll() async {
    final entries = _box.values.toList();
    return entries.map((e) {
      final raw = Map<String, dynamic>.from(e as Map);
      // Hive stores nested maps as Map<dynamic, dynamic>; deep-convert wallpaper.
      if (raw['wallpaper'] is Map) {
        raw['wallpaper'] = Map<String, dynamic>.from(raw['wallpaper'] as Map);
      }
      return FavoriteModel.fromJson(raw).toEntity();
    }).toList();
  }

  @override
  Future<bool> isFavorite(String wallpaperId) async {
    return _box.containsKey(wallpaperId);
  }

  @override
  Future<List<FavoriteEntity>> getPending() async {
    final all = await getAll();
    return all
        .where((f) => f.syncStatus == FavoriteSyncStatus.pending)
        .toList();
  }

  @override
  Future<void> updateSyncStatus(
    String wallpaperId,
    FavoriteSyncStatus status,
  ) async {
    final existing = _box.get(wallpaperId);
    if (existing == null) return;
    final raw = Map<String, dynamic>.from(existing as Map);
    if (raw['wallpaper'] is Map) {
      raw['wallpaper'] = Map<String, dynamic>.from(raw['wallpaper'] as Map);
    }
    final model = FavoriteModel.fromJson(raw);
    final updated = model.copyWith(syncStatus: _syncStatusToString(status));
    final json = updated.toJson();
    json['wallpaper'] = updated.wallpaper.toJson();
    await _box.put(wallpaperId, json);
  }

  static String _syncStatusToString(FavoriteSyncStatus status) {
    switch (status) {
      case FavoriteSyncStatus.pending:
        return 'pending';
      case FavoriteSyncStatus.localOnly:
        return 'local_only';
      case FavoriteSyncStatus.synced:
        return 'synced';
    }
  }
}
