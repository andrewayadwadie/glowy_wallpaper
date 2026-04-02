# Data Model: 011-download-connectivity-ux

**Date**: 2026-04-02

## Entities

### DownloadState (modified — existing Freezed state)

The existing `DownloadState` already tracks `isDownloading`, `downloadProgress`, `errorMessage`, and `successMessage`. No new fields required — the connectivity check and ad gate logic are procedural guards that execute before `isDownloading` transitions to `true`.

**Current fields** (no changes):
- `historyStatus: Status` — loading/error/empty/success for download history
- `history: List<DownloadRecordEntity>` — download history list
- `isDownloading: bool` — whether a download is in progress
- `downloadProgress: double` — 0.0 to 1.0 progress
- `errorMessage: String?` — transient error
- `successMessage: String?` — transient success

### NetworkInfo (extended — existing abstraction)

Location: `lib/core/network/network_info.dart`

**Current interface**:
- `Future<bool> get isConnected` — checks reachability via `InternetConnectionChecker`

**No interface change needed**: The existing `isConnected` already uses `InternetConnectionChecker.hasConnection` which performs DNS lookups (real reachability, not just radio status). The `DownloadCubit` will inject `NetworkInfo` and call `isConnected` before proceeding.

### GalleryDataSource (implementation swap — existing abstraction)

Location: `lib/features/downloads/data/datasources/gallery_data_source.dart`

**Abstract interface** (unchanged):
- `requestPermission() → Future<bool>`
- `checkPermission() → Future<bool>`
- `isPermanentlyDenied() → Future<bool>`
- `openAppSettings() → Future<void>`
- `putImageBytes(Uint8List, {String? name}) → Future<void>`
- `putVideoBytes(Uint8List, {String? name}) → Future<void>`

**Implementation change**: `GalleryDataSourceImpl` swaps `gal` calls for `image_gallery_saver_plus` calls. The abstract contract and all consumers are unaffected.

### GallerySaveResult (new — not persisted, used within repository flow)

A lightweight result type to distinguish gallery save outcomes. Not Freezed, not persisted — used as an internal domain signal within `DownloadRepositoryImpl`.

**Values**:
- `success`
- `permissionDenied`
- `permanentlyDenied`
- `storageFull`
- `unknownError(String message)`

## State Transitions

### Download Flow (revised)

```
idle
  → [user taps download]
  → checkConnectivity
    → NO  → emit error ("Network unavailable") → idle
    → YES → attemptAdGate
      → ad shown & dismissed → startDownload
      → ad error / timeout  → startDownload (bypass)
      → premium user        → startDownload (skip ad)
  → startDownload
    → emit isDownloading=true, progress=0.0
    → downloading (progress updates 0.0→1.0)
      → connection lost mid-download → emit error → idle
      → success → saveToGallery
        → permission granted → saved → emit success → idle
        → permission denied  → emit error → idle
        → permanently denied → show settings dialog → idle
      → dio error → emit error → idle
```

## Relationships

- `DownloadCubit` → depends on `NetworkInfo` (NEW dependency), `DownloadWallpaper`, `GetDownloadHistory`, `FirebaseAnalytics`, `NotificationService`
- `DownloadRepositoryImpl` → depends on `DownloadLocalDataSource`, `GalleryDataSource`, `Dio` (unchanged)
- `GalleryDataSourceImpl` → depends on `image_gallery_saver_plus` (changed from `gal`)
- `adGatePlaceholder` → consumed by `DownloadCubit`, modified to return `true` on ad failure
