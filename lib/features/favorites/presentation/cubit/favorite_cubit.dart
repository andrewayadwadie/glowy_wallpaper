import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../features/notifications/domain/services/notification_service.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/is_favorite.dart';
import '../../domain/usecases/toggle_favorite.dart';
import 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final ToggleFavorite _toggleFavorite;
  final IsFavorite _isFavorite;
  final GetFavorites _getFavorites;
  final DeviceIdService _deviceIdService;
  final FirebaseAnalytics? _analytics;
  final NotificationService? _notificationService;

  FavoriteCubit({
    required ToggleFavorite toggleFavorite,
    required IsFavorite isFavorite,
    required GetFavorites getFavorites,
    required DeviceIdService deviceIdService,
    FirebaseAnalytics? analytics,
    NotificationService? notificationService,
  }) : _toggleFavorite = toggleFavorite,
       _isFavorite = isFavorite,
       _getFavorites = getFavorites,
       _deviceIdService = deviceIdService,
       _analytics = analytics,
       _notificationService = notificationService,
       super(const FavoriteState());

  Future<void> checkIsFavorite(String wallpaperId) async {
    final result = await _isFavorite(IsFavoriteParams(wallpaperId));
    result.fold((_) {}, (isFav) => emit(state.copyWith(isFavorite: isFav)));
  }

  Future<void> toggle(WallpaperEntity wallpaper) async {
    if (state.isToggling) return;

    final deviceId = _deviceIdService.getDeviceId();

    // Optimistic update
    final previousState = state.isFavorite;
    emit(state.copyWith(isFavorite: !previousState, isToggling: true));

    final favoriteToAdd = !previousState
        ? FavoriteEntity(
            wallpaperId: wallpaper.id,
            wallpaper: wallpaper,
            userId: deviceId,
            favoritedAt: DateTime.now(),
            syncStatus: FavoriteSyncStatus.localOnly,
          )
        : null;

    final result = await _toggleFavorite(
      ToggleFavoriteParams(
        wallpaperId: wallpaper.id,
        favoriteToAdd: favoriteToAdd,
      ),
    );

    result.fold(
      (failure) {
        // Revert on failure
        emit(
          state.copyWith(
            isFavorite: previousState,
            isToggling: false,
            errorMessage: failure.message,
          ),
        );
      },
      (newIsFav) {
        emit(
          state.copyWith(
            isFavorite: newIsFav,
            isToggling: false,
            errorMessage: null,
          ),
        );
        _analytics?.logEvent(
          name: 'toggle_favorite',
          parameters: {
            'wallpaper_id': wallpaper.id,
            'action': newIsFav ? 'add' : 'remove',
          },
        );
        if (newIsFav && _notificationService?.hasRequestedPermission == false) {
          _notificationService?.requestPermission();
        }
      },
    );
  }

  Future<void> loadFavorites() async {
    emit(state.copyWith(listStatus: Status.loading));
    final result = await _getFavorites(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(listStatus: Status.error, errorMessage: failure.message),
      ),
      (favorites) => emit(
        state.copyWith(
          listStatus: favorites.isEmpty ? Status.empty : Status.success,
          favorites: favorites,
        ),
      ),
    );
  }

  void clearError() => emit(state.copyWith(errorMessage: null));
}
