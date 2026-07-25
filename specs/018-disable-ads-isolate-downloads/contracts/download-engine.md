# Contract: Download Engine & Repository Surface

**Feature**: 018-disable-ads-isolate-downloads

Internal Dart contracts. Consumers: `DownloadRepositoryImpl`, `DownloadCubit`, unit tests.

---

## `DownloadRunner` (data layer — new)

The isolate abstraction. Real implementation spawns; the fake one lets tests script events without
an isolate.

```dart
abstract class DownloadRunner {
  /// Streams progress and ends with exactly one terminal event.
  /// Never throws — transport failures arrive as [RunnerError].
  Stream<RunnerMessage> run({
    required String url,
    required String savePath,
  });
}

sealed class RunnerMessage {}
class RunnerProgress extends RunnerMessage {
  RunnerProgress(this.received, this.total);
  final int received;
  final int total;
}
class RunnerDone extends RunnerMessage {}
class RunnerError extends RunnerMessage {
  RunnerError(this.kind, this.message);
  final String kind;    // network | io | unknown
  final String message;
}
```

**Guarantees**

| # | Guarantee |
|---|---|
| RN-1 | The returned stream is single-subscription and closes after the terminal message |
| RN-2 | Exactly one `RunnerDone` or `RunnerError` is emitted, never both |
| RN-3 | On `RunnerDone`, the complete file exists at `savePath` |
| RN-4 | No plugin channel is touched inside the isolate (research R2) |
| RN-5 | Progress is throttled: ≥1% delta or ≥100 ms apart, plus a guaranteed final emission |
| RN-6 | The isolate is killed and the port closed on every exit path, including error |

---

## `DownloadEngine` (data layer — new, session-scoped singleton)

```dart
class DownloadEngine {
  DownloadEngine(this._runner, this._gallery, this._local);

  /// Replays the last event to late subscribers, then forwards live events.
  Stream<DownloadEvent> get events;

  bool get isBusy;
  String? get activeWallpaperId;

  Future<Either<Failure, void>> start({
    required WallpaperEntity wallpaper,
    required String partPath,
    required String finalPath,
  });
}
```

**Guarantees**

| # | Guarantee | Requirement |
|---|---|---|
| EN-1 | At most one job in flight; `start` with a different id while busy returns `Left(...)` without disturbing the running job | FR-015 |
| EN-2 | `start` with the id already in flight joins it: returns `Right(null)`, starts nothing, writes no second file or history entry | FR-018 |
| EN-3 | Job lifetime is independent of any cubit; no consumer can cancel it by unsubscribing | FR-018 |
| EN-4 | `events` replays the last event on subscribe, so a rebuilt cubit resumes mid-progress | FR-018 |
| EN-5 | `DownloadCompleted` is emitted only after gallery save **and** history write both succeed | FR-008 |
| EN-6 | On any failure the `.part` file is deleted and no history entry is written | FR-020 |
| EN-7 | Errors map to typed failures: `network → NetworkFailure`, `io → CacheFailure`, `unknown → ServerFailure` | Constitution V |
| EN-8 | Never throws to callers; every path returns `Either` or emits `DownloadFailed` | Constitution V |
| EN-9 | The broadcast controller stays open for app lifetime; the engine holds no widget or `BuildContext` reference | Constitution VI |

**Ordering** — success: `Started → Progressed* → Completed`. Failure:
`Started → Progressed* → Failed`. Never both terminals.

---

## `DownloadRepository` (domain — modified)

```dart
abstract class DownloadRepository {
  /// Existing signature preserved. Now resolves permission + paths on the main
  /// isolate, then delegates to DownloadEngine. Returns once the job is
  /// accepted; the terminal outcome also arrives on [events].
  Future<Either<Failure, void>> downloadWallpaper(
    WallpaperEntity wallpaper, {
    void Function(int received, int total)? onProgress,
  });

  /// NEW — engine event stream, replayed on subscribe.
  Stream<DownloadEvent> get events;

  Future<Either<Failure, List<DownloadRecordEntity>>> getDownloadHistory();
  Future<Either<Failure, bool>> isDownloaded(String wallpaperId);
}
```

The `onProgress` callback is kept for source compatibility but is no longer the progress path — the
cubit reads `events`. Passing `null` is now the normal case.

**Pre-spawn responsibilities (main isolate, in order)**

1. `GalleryDataSource.requestPermission()`; on denial return `Left(CacheFailure('Storage permission denied'))`, or the existing `'permission_permanently_denied'` sentinel — messaging unchanged (FR-008).
2. Resolve the temp directory via `path_provider`.
3. Build `partPath = <tmp>/wallpaper_<id>.<ext>.part` and `finalPath = <tmp>/wallpaper_<id>.<ext>`, with `ext` = `mp4` for video, `jpg` for image.
4. Delegate to `DownloadEngine.start`.

---

## `WatchDownloadEvents` (domain use case — new)

```dart
class WatchDownloadEvents {
  WatchDownloadEvents(this.repository);
  final DownloadRepository repository;
  Stream<DownloadEvent> call() => repository.events;
}
```

Returns a stream rather than `Either`, so it does not extend the `UseCase<T, P>` base — consistent
with how a continuous signal differs from a one-shot operation.

---

## `DownloadCubit` (presentation — modified)

```dart
class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit({
    required DownloadWallpaper downloadWallpaper,
    required GetDownloadHistory getDownloadHistory,
    required WatchDownloadEvents watchDownloadEvents,   // NEW
    required NetworkInfo networkInfo,
    // TODO(ads-disabled-018): rewardedAdManager removed — download no longer ad-gated
    FirebaseAnalytics? analytics,
    NotificationService? notificationService,
  });
}
```

**Guarantees**

| # | Guarantee | Requirement |
|---|---|---|
| CU-1 | `download()` performs no ad step; after the connectivity check it goes straight to the use case | FR-001 |
| CU-2 | Subscribes to events in the constructor, cancels only its own subscription in `close()` | FR-018, Constitution VI |
| CU-3 | Ignores events whose `wallpaperId` is not the one this screen requested | FR-015 |
| CU-4 | Preserves existing outcomes: success/failure snackbar text, `download_wallpaper` and `download_wallpaper_failed` analytics, notification permission prompt on first success | FR-008 |
| CU-5 | `isClosed` is checked before every emit | existing |
| CU-6 | Offline check runs before anything else and short-circuits with `AppStrings.networkUnavailable` | FR-008 |

---

## Dependency injection (`injection_container.dart`)

```dart
sl.registerLazySingleton<DownloadRunner>(() => IsolateDownloadRunner());
sl.registerLazySingleton<DownloadEngine>(() => DownloadEngine(sl(), sl(), sl()));
sl.registerLazySingleton(() => WatchDownloadEvents(sl()));
// DownloadCubit stays registerFactory — per-route, subscribing to the singleton engine
```

Registering the engine as a lazy singleton is what makes FR-018 work: the job outlives every cubit
built from the factory.
