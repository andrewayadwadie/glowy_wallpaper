import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/ad_gate_placeholder.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/usecases/download_wallpaper.dart';
import '../../domain/usecases/get_download_history.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final DownloadWallpaper _downloadWallpaper;
  final GetDownloadHistory _getDownloadHistory;
  final FirebaseAnalytics? _analytics;

  DownloadCubit({
    required DownloadWallpaper downloadWallpaper,
    required GetDownloadHistory getDownloadHistory,
    FirebaseAnalytics? analytics,
  }) : _downloadWallpaper = downloadWallpaper,
       _getDownloadHistory = getDownloadHistory,
       _analytics = analytics,
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

    final shouldProceed = await adGatePlaceholder(
      action: 'download',
      onProceed: () async {
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
              emit(
                state.copyWith(
                  isDownloading: false,
                  errorMessage: failure.message,
                ),
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
            }
          },
        );
      },
    );

    if (!shouldProceed) {
      return;
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
