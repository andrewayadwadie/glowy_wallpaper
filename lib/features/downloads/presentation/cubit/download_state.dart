import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/status.dart';
import '../../domain/entities/download_record_entity.dart';

export '../../../../core/enums/status.dart';

part 'download_state.freezed.dart';

@freezed
abstract class DownloadState with _$DownloadState {
  const factory DownloadState({
    @Default(Status.loading) Status historyStatus,
    @Default([]) List<DownloadRecordEntity> history,
    @Default(false) bool isDownloading,

    /// True while the rewarded ad gate is resolving (cold-start load wait).
    /// Drives the loading overlay on the detail page (US1, R3).
    @Default(false) bool isAdGateActive,
    @Default(0.0) double downloadProgress,
    String? errorMessage,
    String? successMessage,
  }) = _DownloadState;
}
