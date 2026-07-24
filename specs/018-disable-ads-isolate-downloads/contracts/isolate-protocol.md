# Contract: Isolate Message Protocol

**Feature**: 018-disable-ads-isolate-downloads

Wire format between the main isolate and the spawned download isolate. Both directions use plain
`Map<String, Object?>` with primitive values only — anything non-sendable (closures, plugin handles,
`BuildContext`, `Dio` instances) throws at `Isolate.spawn`.

---

## Spawn argument (main → isolate)

```dart
{
  'url':              String,   // absolute media URL
  'savePath':         String,   // absolute .part path, resolved on the main isolate
  'sendPort':         SendPort, // reply channel
  'connectTimeoutMs': int,
  'receiveTimeoutMs': int,
}
```

`savePath` is resolved before spawning precisely so the isolate never calls `path_provider`
(research R2). Its parent directory is guaranteed to exist.

---

## Reply messages (isolate → main)

### `progress`

```dart
{'type': 'progress', 'received': int, 'total': int}
```

- `total <= 0` means the server sent no content length; the UI holds at indeterminate.
- Throttled at the source: emitted only when the percentage advances ≥1 point or ≥100 ms has passed
  since the last emission (research R5).
- A final `progress` at 100% is always sent before `done`.

### `done`

```dart
{'type': 'done'}
```

Sent only after the response is fully written and flushed to `savePath`.

### `error`

```dart
{'type': 'error', 'kind': String, 'message': String}
```

| `kind` | Source | Maps to |
|---|---|---|
| `network` | `DioException` (timeout, connection, non-2xx) | `NetworkFailure` |
| `io` | `FileSystemException` (storage full, permission, path) | `CacheFailure` |
| `unknown` | anything else | `ServerFailure` |

`message` is the underlying exception message, used for logs and the existing failure snackbar.

---

## Isolate entrypoint

```dart
// lib/features/downloads/data/services/download_isolate_entry.dart
// Top-level function — required by Isolate.spawn.
Future<void> downloadIsolateEntry(Map<String, Object?> args) async { ... }
```

**Body contract**

1. Build a fresh `Dio` inside the isolate. Never send one across — `Dio` holds non-sendable state.
2. `dio.download(url, savePath, onReceiveProgress: throttled)` — streaming write, never
   `ResponseType.bytes` (FR-019).
3. On success: send a final `progress` at 100%, then `done`.
4. On `DioException` → `error/network`; on `FileSystemException` → `error/io`; on anything else →
   `error/unknown`.
5. Exactly one terminal message, always. The isolate then returns and exits.

**Forbidden inside the isolate**

- Any plugin channel call (`path_provider`, `gallery_saver_plus`, `permission_handler`, `hive`).
- Any Flutter binding or widget-layer reference.
- Passing the app's shared `Dio` singleton in.

---

## Main-isolate receive loop

```text
ReceivePort.listen:
  progress → clamp(received/total) → emit DownloadProgressed
  done     → rename .part → final
             GallerySaver.saveImage | saveVideo(final)
             delete temp file
             saveRecord (idempotent by wallpaperId)
             emit DownloadCompleted
             tear down
  error    → map kind → Failure
             delete .part
             emit DownloadFailed
             tear down
```

**Teardown**, on every path including error: close the `ReceivePort`, kill the isolate
(`Isolate.kill(priority: Isolate.immediate)` if still alive), clear `_activeId` and `_partPath`.
Leaking a port keeps the isolate alive and violates constitution VI.

---

## Failure modes and expected handling

| Scenario | Expected |
|---|---|
| Server returns 404/500 | `error/network` → `NetworkFailure` → existing failure snackbar, `.part` deleted, no history entry |
| Connection drops mid-transfer | `error/network`, partial `.part` deleted (FR-020) |
| Storage full during write | `error/io` → `CacheFailure`, partial `.part` deleted |
| Isolate dies without a terminal message | `ReceivePort` closes → treated as `unknown` error; job must not hang forever |
| User leaves the screen mid-download | Nothing changes — the engine owns the port, not the cubit (FR-018) |
| App backgrounded | Transfer continues while the process lives; OS process death is out of scope (no resume) |
| Second download requested while busy | Rejected by the engine before any spawn (FR-015) |
