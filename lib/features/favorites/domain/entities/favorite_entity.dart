import 'package:equatable/equatable.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

enum FavoriteSyncStatus { synced, pending, localOnly }

class FavoriteEntity extends Equatable {
  final String wallpaperId;
  final WallpaperEntity wallpaper;
  final String? userId;
  final DateTime favoritedAt;
  final FavoriteSyncStatus syncStatus;

  const FavoriteEntity({
    required this.wallpaperId,
    required this.wallpaper,
    this.userId,
    required this.favoritedAt,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [
    wallpaperId,
    wallpaper,
    userId,
    favoritedAt,
    syncStatus,
  ];
}
