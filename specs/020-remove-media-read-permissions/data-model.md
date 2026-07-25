# Phase 1 Data Model: Remove Unnecessary Media Read Permissions

**Feature**: `020-remove-media-read-permissions` | **Date**: 2026-07-25

This feature introduces **no persisted entities, no Hive schema change, and no new domain models**.
The Hive `downloads` box and `DownloadRecordEntity` are untouched. The "entities" below are the
conceptual objects from the spec, mapped to the concrete code and configuration that realizes them.

---

## E1: Media Save Request

One downloaded wallpaper being placed into the device gallery.

| Attribute | Type | Source | Notes |
|---|---|---|---|
| `path` | `String` | `download_engine.dart` `finalPath` | App-private temp file, deleted after save |
| `isVideo` | `bool` | `wallpaper.mediaType == MediaType.video` | Selects image vs video MediaStore collection |
| `bytes` | `Uint8List` | `putImageBytes` / `putVideoBytes` callers | Alternate entry point; **currently no caller in `lib/`** |
| `name` | `String?` | optional | Defaults to `'wallpaper'` |
| `album` | — | **not used** | Deliberately never set — passing an album would make API 29 require `WRITE_EXTERNAL_STORAGE` (see research R5) |

**Outcome**: success, or an exception surfaced as a `Failure` by the repository.

**Lifecycle**: `download engine completes` → `rename .part → final` → `saveFile()` → `MediaStore copy`
→ `delete temp file` → `Hive record written`. Unchanged by this feature; verified safe under `gal`
because `gal` copies bytes rather than referencing the path (research R4).

**Realized by**: `GalleryDataSource.saveFile` / `.putImageBytes` / `.putVideoBytes`
(`lib/features/downloads/data/datasources/gallery_data_source.dart`).

---

## E2: Permission Gate

The decision point evaluated before a Media Save Request. This is the entity this feature actually
changes.

### State by API level

| API level | Android | Gate resolves to | Permission consulted | Prompt shown |
|---|---|---|---|---|
| 24–28 | 7.0 – 9 | granted / denied / permanently denied | `WRITE_EXTERNAL_STORAGE` | Yes, once |
| 29 | 10 | **always granted** | none (album never used) | No |
| 30–32 | 11 – 12L | **always granted** | none | No |
| 33+ | 13+ | **always granted** | none | No |

Enforced natively inside `gal`'s `hasAccess()` / `requestAccess()`, not by Dart-side branching —
`requestAccess` returns early on `hasAccess()`, so `ActivityCompat.requestPermissions` is
unreachable above API 28.

### States and transitions

```
                    API >= 29
   [evaluate] ─────────────────────► GRANTED  (no prompt, no permission held)
        │
        │ API 24-28, not yet granted
        ▼
   [prompt once] ──── allow ───────► GRANTED
        │
        ├──────────── deny ────────► DENIED              → CacheFailure(AppStrings.permissionDenied)
        │
        └── deny + "don't ask again" ► PERMANENTLY_DENIED → CacheFailure(sentinel) → settings dialog
```

**Validation rules**:
- `DENIED` and `PERMANENTLY_DENIED` MUST be unreachable on API ≥ 29 (FR-005, US-1 scenario 4).
- The `PERMANENTLY_DENIED` sentinel MUST be a single shared constant, not a string literal
  duplicated across layers (Principle II).
- The gate MUST NOT be evaluated in the domain or presentation layer (FR-011).

**Realized by**: `GalleryDataSource.requestPermission()` / `.checkPermission()` /
`.isPermanentlyDenied()` / `.openAppSettings()`, consumed by
`DownloadRepositoryImpl.downloadWallpaper` (`download_repository_impl.dart:32-42`).

---

## E3: Declared Permission Set

The effective permission list of the shipped release — the artifact Google Play reviews. Not a
runtime object; its "schema" is the merged manifest.

| Permission | Current (rejected v7) | Target (v8) | Reason |
|---|---|---|---|
| `INTERNET` | present | **keep** | API and media fetch |
| `ACCESS_NETWORK_STATE` | present | **keep** | Connectivity checks |
| `POST_NOTIFICATIONS` | present | **keep** | FCM — unrelated to this policy item |
| `VIBRATE` | present | **keep** | Local notifications |
| `RECEIVE_BOOT_COMPLETED` | present | **keep** | Notification rescheduling |
| `WRITE_EXTERNAL_STORAGE` | `maxSdkVersion="29"` | **`maxSdkVersion="28"`** | Legacy save path only (API 24–28) |
| `READ_EXTERNAL_STORAGE` | `maxSdkVersion="32"` | **REMOVED** | App never reads user storage |
| `READ_MEDIA_IMAGES` | present | **REMOVED** | App never reads user images |
| `READ_MEDIA_VIDEO` | present | **REMOVED** | App never reads user videos |
| `READ_MEDIA_VISUAL_USER_SELECTED` | absent | **stays absent** | Must never be added |

**Invariant**: the merged release manifest contains zero permissions matching `READ_MEDIA_*` or
`READ_EXTERNAL_STORAGE`. This is the single assertion behind SC-001 and is verified against the
merged manifest, not the source manifest (see `quickstart.md`).

**Realized by**: `android/app/src/main/AndroidManifest.xml` plus the merge contributions of all
bundled plugins — verified empty for `gal`, `gallery_saver_plus`, and `permission_handler_android`
(research R1).

---

## Cross-entity constraints

1. E2's legacy branch is the **only** justification for E3's `WRITE_EXTERNAL_STORAGE` entry. If
   minSdk ever rises to 29+, that entry must be deleted with it.
2. E1 must never populate `album`; doing so would force E2's API-29 row from "always granted" to
   "prompt", which would in turn require widening E3's `maxSdkVersion` back to 29.
3. E3 is verified on the build output, never on the source file alone — a plugin added later could
   reintroduce a removed row without any change to `lib/` or the app manifest.
