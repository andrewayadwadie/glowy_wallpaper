# Phase 1 Data Model: Disable Ads & Isolate-Backed Downloads

**Feature**: 018-disable-ads-isolate-downloads
**Date**: 2026-07-24

No persisted schema changes. The Hive `downloads` box and `DownloadRecordModel` keep their current
shape. Everything below is in-memory transport and state.

---

## 1. `DownloadEvent` (domain entity — new)

`lib/features/downloads/domain/entities/download_event.dart`

Pure Dart, no Flutter imports. A sealed class so the cubit's handling is exhaustive.

```dart
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
```

| Field | Type | Rule |
|---|---|---|
| `wallpaperId` | `String` | non-empty; identifies the job across all events |
| `progress` | `double` | clamped to `0.0..1.0`; `0.0` when `total <= 0` |
| `failure` | `Failure` | existing typed failure (`NetworkFailure`, `CacheFailure`, `ServerFailure`) |

**Lifecycle** — exactly one terminal event per job:

```text
Started ──> Progressed* ──> Completed
                └────────> Failed
```

Rules:

- `Progressed` never follows a terminal event for the same `wallpaperId`.
- Progress is monotonically non-decreasing within a job.
- A `Completed` event is emitted only after the file is in the gallery **and** the history record is
  written — never before (FR-008, FR-020).

---

## 2. Engine job state (in-memory — new)

Held by `DownloadEngine`, never persisted.

| Field | Type | Purpose |
|---|---|---|
| `_activeId` | `String?` | wallpaper id of the in-flight job; `null` when idle. Backs the single-flight guard (FR-015) |
| `_last` | `DownloadEvent?` | most recent event, replayed to late subscribers so a rebuilt cubit resumes mid-progress (FR-018) |
| `_controller` | `StreamController<DownloadEvent>.broadcast()` | fan-out to any number of cubits |
| `_partPath` | `String?` | path of the `.part` file, so cleanup works from any failure branch (FR-020) |

**State machine**:

```text
idle ──start()──> running ──done────> idle   (gallery save + history write, then Completed)
                     └────error/throw─> idle  (delete .part, no history, then Failed)
```

Invariants:

- `_activeId != null` ⇔ a runner job is in flight.
- `start()` while `_activeId == wallpaperId` → join the existing job, emit nothing new, return
  success (no duplicate file, no duplicate history entry — FR-018).
- `start()` while `_activeId` is a *different* id → rejected as busy (FR-015).
- `_partPath` is deleted on every exit path except a successful rename.

---

## 3. Isolate messages (transport — new)

Plain `Map<String, Object?>` in both directions. Primitives only — no closures, no plugin handles,
nothing that fails `Isolate.spawn` sendability.

**Spawn argument (main → isolate)**

| Key | Type | Notes |
|---|---|---|
| `url` | `String` | absolute media URL |
| `savePath` | `String` | absolute `.part` path, resolved on the main isolate |
| `sendPort` | `SendPort` | reply channel |
| `connectTimeoutMs` | `int` | mirrors the app's Dio config |
| `receiveTimeoutMs` | `int` | mirrors the app's Dio config |

**Reply messages (isolate → main)**

| `type` | Extra keys | Meaning |
|---|---|---|
| `progress` | `received: int`, `total: int` | throttled; `total <= 0` means unknown length |
| `done` | — | bytes fully written to `savePath` |
| `error` | `kind: String` (`network` \| `io` \| `unknown`), `message: String` | terminal failure |

`kind` maps to typed failures on the main isolate: `network → NetworkFailure`,
`io → CacheFailure`, `unknown → ServerFailure` (constitution V).

Exactly one `done` or `error` per job; the isolate then closes its port and exits.

---

## 4. `DownloadState` (presentation — modified)

`lib/features/downloads/presentation/cubit/download_state.dart`

| Field | Change |
|---|---|
| `historyStatus` | unchanged |
| `history` | unchanged |
| `isDownloading` | unchanged — now driven by engine events rather than a local await |
| `isAdGateActive` | **commented out** with the marker; the ad-gate overlay it drove is removed |
| `downloadProgress` | unchanged (`0.0–1.0`) |
| `errorMessage` | unchanged |
| `successMessage` | unchanged |

Removing `isAdGateActive` breaks its readers in `wallpaper_detail_page.dart`, so those are commented
in the same change (see plan, Ad disable mechanics).

---

## 5. `DownloadRecordEntity` / Hive box — unchanged

No field changes. One behavioural rule added: `DownloadLocalDataSource.saveRecord` must be
idempotent per `wallpaperId` — re-saving an already-recorded wallpaper updates the existing entry
instead of appending a second one (FR-018, research R10).

---

## 6. Ad-layer entities — unchanged, dormant

`AdGatekeeper.shouldShowAds`, ad unit ids in `env.g.dart`, and the managers' in-memory
frequency/cooldown state are all commented out rather than altered. Nothing is migrated, nothing is
deleted, and no stored value changes — restoring the ad layer restores its state model exactly as it
was.
