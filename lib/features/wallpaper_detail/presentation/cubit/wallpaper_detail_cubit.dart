import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/usecases/get_similar_wallpapers.dart';
import 'wallpaper_detail_state.dart';

class WallpaperDetailCubit extends Cubit<WallpaperDetailState> {
  final GetSimilarWallpapers? _getSimilarWallpapers;
  final FirebaseAnalytics? _analytics;
  VideoPlayerController? _videoController;

  WallpaperDetailCubit({
    GetSimilarWallpapers? getSimilarWallpapers,
    FirebaseAnalytics? analytics,
  }) : _getSimilarWallpapers = getSimilarWallpapers,
       _analytics = analytics,
       super(const WallpaperDetailState());

  void init({
    required List<WallpaperEntity> wallpapers,
    required int initialIndex,
  }) {
    emit(state.copyWith(wallpapers: wallpapers, currentIndex: initialIndex));
    _initVideoForIndex(initialIndex);
  }

  void onPageChanged(int index) {
    _disposeVideo();
    emit(state.copyWith(currentIndex: index));
    _initVideoForIndex(index);
  }

  void _initVideoForIndex(int index) {
    if (index < 0 || index >= state.wallpapers.length) return;
    final wallpaper = state.wallpapers[index];
    if (wallpaper.mediaType == MediaType.video) {
      debugPrint(
        'Initializing video for wallpaper ${wallpaper.id}: ${wallpaper.url}',
      );
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(wallpaper.url))
            ..initialize()
                .then((_) {
                  if (!isClosed) {
                    _videoController!
                      ..setLooping(true)
                      ..setVolume(0)
                      ..play();
                    debugPrint(
                      'Video initialized successfully for ${wallpaper.id}',
                    );
                  }
                })
                .catchError((error) {
                  debugPrint(
                    'Error initializing video for ${wallpaper.id}: $error',
                  );
                });
    }
  }

  VideoPlayerController? get videoController => _videoController;

  void toggleMute() {
    final muted = !state.isMuted;
    emit(state.copyWith(isMuted: muted));
    _videoController?.setVolume(muted ? 0 : 1);
  }

  void logPreviewWallpaper(String wallpaperId) {
    _analytics?.logEvent(
      name: 'preview_wallpaper',
      parameters: {'wallpaper_id': wallpaperId},
    );
  }

  Future<void> loadSimilarWallpapers(
    String wallpaperId,
    CategoryType categoryType,
    String classificationId,
  ) async {
    if (_getSimilarWallpapers == null) return;
    _analytics?.logEvent(
      name: 'view_similar_wallpapers',
      parameters: {
        'wallpaper_id': wallpaperId,
        'category_type': categoryType.name,
        'classification_id': classificationId,
      },
    );
    emit(
      state.copyWith(
        similarWallpapersStatus: Status.loading,
        similarWallpapers: const [],
      ),
    );
    final result = await _getSimilarWallpapers(
      GetSimilarWallpapersParams(wallpaperId, categoryType, classificationId),
    );
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            state.copyWith(
              similarWallpapersStatus: Status.error,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (wallpapers) {
        if (!isClosed) {
          emit(
            state.copyWith(
              similarWallpapers: wallpapers,
              similarWallpapersStatus: wallpapers.isEmpty
                  ? Status.empty
                  : Status.success,
            ),
          );
        }
      },
    );
  }

  void switchToSimilarContext(List<WallpaperEntity> wallpapers, int index) {
    _disposeVideo();
    emit(
      state.copyWith(
        wallpapers: wallpapers,
        currentIndex: index,
        similarWallpapers: const [],
        similarWallpapersStatus: Status.loading,
      ),
    );
    _initVideoForIndex(index);
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  Future<void> close() {
    _disposeVideo();
    return super.close();
  }
}
