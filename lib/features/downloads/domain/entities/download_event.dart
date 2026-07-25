import '../../../../core/errors/failure.dart';

sealed class DownloadEvent {
  const DownloadEvent(this.wallpaperId);

  final String wallpaperId;
}

class DownloadStarted extends DownloadEvent {
  const DownloadStarted(super.wallpaperId);
}

class DownloadProgressed extends DownloadEvent {
  const DownloadProgressed(super.wallpaperId, this.progress);

  /// 0.0–1.0. Stays 0.0 while total length is unknown.
  final double progress;
}

class DownloadCompleted extends DownloadEvent {
  const DownloadCompleted(super.wallpaperId);
}

class DownloadFailed extends DownloadEvent {
  const DownloadFailed(super.wallpaperId, this.failure);

  final Failure failure;
}
