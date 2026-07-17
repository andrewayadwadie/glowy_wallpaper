import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/status.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

export '../../../../core/enums/status.dart';

part 'wallpaper_detail_state.freezed.dart';

@freezed
abstract class WallpaperDetailState with _$WallpaperDetailState {
  const factory WallpaperDetailState({
    @Default([]) List<WallpaperEntity> wallpapers,
    @Default(0) int currentIndex,
    @Default(0.0) double downloadProgress,
    @Default(Status.loading) Status similarWallpapersStatus,
    @Default([]) List<WallpaperEntity> similarWallpapers,
    String? errorMessage,
    @Default(false) bool isMuted,
  }) = _WallpaperDetailState;
}
