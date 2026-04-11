import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/ad_helper.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../features/notifications/domain/services/notification_service.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/usecases/download_wallpaper.dart';
import '../../domain/usecases/get_download_history.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final DownloadWallpaper _downloadWallpaper;
  final GetDownloadHistory _getDownloadHistory;
  final NetworkInfo _networkInfo;
  final FirebaseAnalytics? _analytics;
  final NotificationService? _notificationService;

  DownloadCubit({
    required DownloadWallpaper downloadWallpaper,
    required GetDownloadHistory getDownloadHistory,
    required NetworkInfo networkInfo,
    FirebaseAnalytics? analytics,
    NotificationService? notificationService,
  }) : _downloadWallpaper = downloadWallpaper,
       _getDownloadHistory = getDownloadHistory,
       _networkInfo = networkInfo,
       _analytics = analytics,
       _notificationService = notificationService,
       super(const DownloadState());

  Future<void> loadHistory() async {
    emit(state.copyWith(historyStatus: Status.loading));
    final result = await _getDownloadHistory(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          historyStatus: Status.error,
          errorMessage: failure.message,
        ),
      ),
      (history) => emit(
        state.copyWith(
          historyStatus: history.isEmpty ? Status.empty : Status.success,
          history: history,
        ),
      ),
    );
  }

  Future<void> download(WallpaperEntity wallpaper) async {
    if (state.isDownloading) return;

    // Step 1: Guard against no internet — check real reachability, not just radio.
    final hasConnection = await _networkInfo.isConnected;
    if (!hasConnection) {
      emit(state.copyWith(errorMessage: AppStrings.networkUnavailable));
      return;
    }

    // Step 2: Attempt the rewarded ad gate. Proceed with download regardless
    // of ad outcome — ad errors must never block core functionality.
    await AdHelper.instance.showRewardedInterstitialAd(action: 'download');

    // Step 2: Execute the download.
    emit(state.copyWith(isDownloading: true, downloadProgress: 0.0));

    final result = await _downloadWallpaper(
      DownloadWallpaperParams(
        wallpaper: wallpaper,
        onProgress: (received, total) {
          if (total > 0 && !isClosed) {
            emit(state.copyWith(downloadProgress: received / total));
          }
        },
      ),
    );

    result.fold(
      (failure) {
        if (!isClosed) {
          final reason = failure.message == 'permission_permanently_denied'
              ? 'gallery_permission_denied'
              : 'download_error';
          _analytics?.logEvent(
            name: 'download_wallpaper_failed',
            parameters: {'wallpaper_id': wallpaper.id, 'reason': reason},
          );
          emit(
            state.copyWith(isDownloading: false, errorMessage: failure.message),
          );
        }
      },
      (_) {
        if (!isClosed) {
          emit(
            state.copyWith(
              isDownloading: false,
              downloadProgress: 1.0,
              successMessage: AppStrings.wallpaperSaved,
            ),
          );
          _analytics?.logEvent(
            name: 'download_wallpaper',
            parameters: {'wallpaper_id': wallpaper.id},
          );
          if (_notificationService?.hasRequestedPermission == false) {
            _notificationService?.requestPermission();
          }
        }
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
