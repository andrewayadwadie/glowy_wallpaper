import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../wallpapers/data/models/wallpaper_model.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/entities/favorite_entity.dart';

part 'favorite_model.freezed.dart';
part 'favorite_model.g.dart';

@freezed
abstract class FavoriteModel with _$FavoriteModel {
  const FavoriteModel._();

  const factory FavoriteModel({
    @JsonKey(name: 'wallpaper_id') required String wallpaperId,
    required WallpaperModel wallpaper,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'favorited_at') required DateTime favoritedAt,
    @JsonKey(name: 'sync_status') @Default('synced') String syncStatus,
  }) = _FavoriteModel;

  factory FavoriteModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteModelFromJson(json);

  FavoriteEntity toEntity() => FavoriteEntity(
    wallpaperId: wallpaperId,
    wallpaper: wallpaper.toEntity(),
    userId: userId,
    favoritedAt: favoritedAt,
    syncStatus: _parseSyncStatus(syncStatus),
  );

  static FavoriteModel fromEntity(FavoriteEntity entity) => FavoriteModel(
    wallpaperId: entity.wallpaperId,
    wallpaper: WallpaperModel(
      id: entity.wallpaper.id,
      url: entity.wallpaper.url,
      thumbUrl: entity.wallpaper.thumbUrl,
      isTopRated: entity.wallpaper.isTopRated,
      mediaType: entity.wallpaper.mediaType == MediaType.video
          ? 'VIDEO'
          : 'IMAGE',
      classificationId: entity.wallpaper.classificationId,
      classificationName: entity.wallpaper.classificationName,
      classificationThumbnailUrl: entity.wallpaper.classificationThumbnailUrl,
      createdAt: entity.wallpaper.createdAt.toIso8601String(),
    ),
    userId: entity.userId,
    favoritedAt: entity.favoritedAt,
    syncStatus: _syncStatusToString(entity.syncStatus),
  );

  static FavoriteSyncStatus _parseSyncStatus(String status) {
    switch (status) {
      case 'pending':
        return FavoriteSyncStatus.pending;
      case 'local_only':
        return FavoriteSyncStatus.localOnly;
      default:
        return FavoriteSyncStatus.synced;
    }
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
