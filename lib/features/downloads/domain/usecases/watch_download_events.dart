import '../entities/download_event.dart';
import '../repositories/download_repository.dart';

/// Continuous signal rather than a one-shot operation, so this does not
/// extend the [UseCase] base — there is no single result to await.
class WatchDownloadEvents {
  WatchDownloadEvents(this.repository);

  final DownloadRepository repository;

  Stream<DownloadEvent> call() => repository.events;
}
