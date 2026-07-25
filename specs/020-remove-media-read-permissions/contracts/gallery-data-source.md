# Contract: `GalleryDataSource`

**Feature**: `020-remove-media-read-permissions`
**File**: `lib/features/downloads/data/datasources/gallery_data_source.dart`
**Layer**: data (Clean Architecture — no domain or presentation imports)

The abstract interface is **unchanged**; only `GalleryDataSourceImpl` changes. Keeping the contract
stable means `DownloadRepositoryImpl`, `DownloadEngine`, and the existing mocktail mocks continue to
compile against it.

---

## Interface (unchanged)

```dart
abstract class GalleryDataSource {
  Future<bool> requestPermission();
  Future<bool> checkPermission();
  Future<bool> isPermanentlyDenied();
  Future<void> openAppSettings();
  Future<void> putImageBytes(Uint8List bytes, {String? name});
  Future<void> putVideoBytes(Uint8List bytes, {String? name});
  Future<void> saveFile(String path, {required bool isVideo});
}
```

---

## Required behavior per method

### `requestPermission() → Future<bool>`

| API level | Behavior | Returns |
|---|---|---|
| ≥ 29 | MUST NOT show any prompt | `true` |
| 24–28, already granted | MUST NOT re-prompt | `true` |
| 24–28, not granted | Prompts once for `WRITE_EXTERNAL_STORAGE` | grant result |

Implemented by delegating to `Gal.requestAccess()`, which enforces the API-level split natively
(it returns early on `hasAccess()`, so no prompt is reachable above API 28).

**Callers**: `download_repository_impl.dart:32`.

### `checkPermission() → Future<bool>`

Same table as `requestPermission()` but never prompts — delegates to `Gal.hasAccess()`.

**Callers**: none in `lib/` today. Retained on the contract; asserted by unit tests.

### `isPermanentlyDenied() → Future<bool>`

| API level | Returns |
|---|---|
| ≥ 29 | MUST be `false` — the state is unreachable when nothing is requested |
| 24–28 | `Permission.storage.status.isPermanentlyDenied` |

`gal` does not expose permanently-denied state, so `permission_handler` remains the source for the
legacy branch only.

**Callers**: `download_repository_impl.dart:34`.

### `openAppSettings() → Future<void>`

Opens the OS app-settings page via `permission_handler`'s `openAppSettings()`.

**Change required (FR-011)**: `wallpaper_detail_page.dart:244` currently calls
`ph.openAppSettings()` directly from the presentation layer, bypassing this method and importing
`permission_handler` into a widget file. Route that call through the cubit → repository → this
method, and drop the `permission_handler` import from the page.

**As implemented**: the chain is `DownloadCubit.openAppSettings()` → `OpenGallerySettings` use case
→ `DownloadRepository.openGallerySettings()` → this method. The repository method returns
`Future<Either<Failure, void>>`, not the bare `Future<void>` first sketched here — Constitution
Principle V requires every repository method to return `Either`. The data-source method below keeps
its `Future<void>` signature; the repository wraps it.

### `putImageBytes(Uint8List bytes, {String? name}) → Future<void>`

Delegates directly to `Gal.putImageBytes(bytes, name: name)`. No temp file needed — `gal` accepts
image bytes natively. Default name `'wallpaper'`.

### `putVideoBytes(Uint8List bytes, {String? name}) → Future<void>`

**`gal` has no `putVideoBytes`** — its bytes API is image-only (it format-sniffs with
`Imaging.guessFormat`). Implementation MUST therefore:

1. write `bytes` to a temp file `<tmp>/<name ?? 'wallpaper'>.mp4`,
2. `await Gal.putVideo(tmpFile.path)`,
3. delete the temp file in a `finally` block.

This mirrors what the current `gallery_saver_plus` implementation already does, so it is not added
complexity.

### `saveFile(String path, {required bool isVideo}) → Future<void>`

```dart
isVideo ? await Gal.putVideo(path) : await Gal.putImage(path);
```

**Album MUST NOT be passed.** Supplying an album flips `gal`'s API-29 gate from "always granted" to
"requires `WRITE_EXTERNAL_STORAGE`", which would force the manifest cap back to 29 and break FR-002.

**Caller**: `download_engine.dart:99`. The engine deletes `path` immediately after this returns —
safe, because `gal` copies the bytes into the MediaStore URI rather than referencing the path.

---

## Error propagation

`gal` throws `GalException` (with `GalExceptionType` including `accessDenied`, `notEnoughSpace`,
`notSupportedFormat`, `unexpected`). These MUST surface as exceptions from the data source and be
converted to typed `Failure`s by `DownloadRepositoryImpl` / `DownloadEngine` — no `try/catch` may
swallow one silently (Principle V).

Permission-shaped failures MUST NOT be reported for non-permission causes such as disk-full or
network errors (spec edge case: "Download interrupted or failing").

---

## Dependency direction

```
presentation (wallpaper_detail_page, download_cubit)
        │  no permission_handler import after this change
        ▼
domain (DownloadRepository contract)          ← no permission concepts, unchanged
        ▼
data (DownloadRepositoryImpl, DownloadEngine)
        ▼
data/datasources (GalleryDataSourceImpl)      ← the ONLY place gal + permission_handler are imported
```

Registered in `lib/core/di/injection_container.dart:297` as
`sl.registerLazySingleton<GalleryDataSource>(() => GalleryDataSourceImpl())` — registration shape
unchanged.
