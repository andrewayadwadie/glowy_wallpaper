import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// TODO(ads-disabled-018): rewarded gate removed — download no longer ad-dependent
// import '../../../../core/ads/managers/rewarded_ad_manager.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../features/notifications/domain/services/notification_service.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/entities/download_event.dart';
import '../../domain/usecases/download_wallpaper.dart';
import '../../domain/usecases/get_download_history.dart';
import '../../domain/usecases/watch_download_events.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final DownloadWallpaper _downloadWallpaper;
  final GetDownloadHistory _getDownloadHistory;
  final NetworkInfo _networkInfo;
  // TODO(ads-disabled-018): rewarded gate removed — download no longer ad-dependent
  // final RewardedAdManager _rewardedAdManager;
  final FirebaseAnalytics? _analytics;
  final NotificationService? _notificationService;
  late final StreamSubscription<DownloadEvent> _eventSubscription;

  /// The wallpaper this screen is currently downloading or watching, either
  /// because it requested the download itself or because it adopted an
  /// already-in-flight job from the replayed last event (FR-018). Events for
  /// any other wallpaper id are ignored (CU-3).
  String? _trackedWallpaperId;

  DownloadCubit({
    required DownloadWallpaper downloadWallpaper,
    required GetDownloadHistory getDownloadHistory,
    required WatchDownloadEvents watchDownloadEvents,
    required NetworkInfo networkInfo,
    // TODO(ads-disabled-018): rewarded gate removed — download no longer ad-dependent
    // required RewardedAdManager rewardedAdManager,
    FirebaseAnalytics? analytics,
    NotificationService? notificationService,
  }) : _downloadWallpaper = downloadWallpaper,
       _getDownloadHistory = getDownloadHistory,
       _networkInfo = networkInfo,
       // TODO(ads-disabled-018): rewarded gate removed — download no longer ad-dependent
       // _rewardedAdManager = rewardedAdManager,
       _analytics = analytics,
       _notificationService = notificationService,
       super(const DownloadState()) {
    _eventSubscription = watchDownloadEvents().listen(_onDownloadEvent);
  }

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

    // TODO(ads-disabled-018): rewarded ad gate removed — download no longer
    // ad-dependent, goes straight to the engine via the use case. Progress
    // and the terminal outcome now arrive on the event subscription rather
    // than from this call's return value. NOTE: this method was rewritten
    // twice (US1 then US3's event-driven redesign) — restoring the gate is
    // not a pure uncomment; it needs re-wiring into the event-driven flow
    // below. The original integration, preserved for reference:
    // // Step 2: Rewarded ad gate (US1). The reward — or a network-related ad
    // // failure — grants the download; a non-network early dismissal does not.
    // // The gate is bounded (~5s cold-start wait) and never blocks the user.
    // emit(state.copyWith(isAdGateActive: true));
    // await _rewardedAdManager.showRewardedForDownload(
    //   onRewardGranted: () {
    //     if (isClosed) return;
    //     emit(state.copyWith(isAdGateActive: false));
    //     _performDownload(wallpaper);
    //   },
    //   onDismissedWithoutReward: () {
    //     if (isClosed) return;
    //     emit(state.copyWith(isAdGateActive: false));
    //   },
    // );
    final result = await _downloadWallpaper(
      DownloadWallpaperParams(wallpaper: wallpaper),
    );

    result.fold((failure) {
      if (!isClosed) {
        final reason = failure.message == 'permission_permanently_denied'
            ? 'gallery_permission_denied'
            : 'download_error';
        _analytics?.logEvent(
          name: 'download_wallpaper_failed',
          parameters: {'wallpaper_id': wallpaper.id, 'reason': reason},
        );
        emit(state.copyWith(errorMessage: failure.message));
      }
    }, (_) => _trackedWallpaperId = wallpaper.id);
  }

  void _onDownloadEvent(DownloadEvent event) {
    if (isClosed) return;
    _trackedWallpaperId ??= event.wallpaperId;
    if (event.wallpaperId != _trackedWallpaperId) return;

    switch (event) {
      case DownloadStarted():
        emit(state.copyWith(isDownloading: true, downloadProgress: 0.0));
      case DownloadProgressed(:final progress):
        emit(state.copyWith(downloadProgress: progress));
      case DownloadCompleted():
        emit(
          state.copyWith(
            isDownloading: false,
            downloadProgress: 1.0,
            successMessage: AppStrings.wallpaperSaved,
          ),
        );
        _analytics?.logEvent(
          name: 'download_wallpaper',
          parameters: {'wallpaper_id': event.wallpaperId},
        );
        if (_notificationService?.hasRequestedPermission == false) {
          _notificationService?.requestPermission();
        }
        _trackedWallpaperId = null;
      case DownloadFailed(:final failure):
        final reason = failure.message == 'permission_permanently_denied'
            ? 'gallery_permission_denied'
            : 'download_error';
        _analytics?.logEvent(
          name: 'download_wallpaper_failed',
          parameters: {'wallpaper_id': event.wallpaperId, 'reason': reason},
        );
        emit(
          state.copyWith(isDownloading: false, errorMessage: failure.message),
        );
        _trackedWallpaperId = null;
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  @override
  Future<void> close() {
    // Cancels only this cubit's subscription — the job itself lives on the
    // engine and keeps running after this screen closes (FR-018).
    unawaited(_eventSubscription.cancel());
    return super.close();
  }
}
