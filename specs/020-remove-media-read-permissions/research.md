# Phase 0 Research: Remove Unnecessary Media Read Permissions

**Feature**: `020-remove-media-read-permissions` | **Date**: 2026-07-25

All findings below were verified against the actual repository and the local pub cache
(`%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev`) during planning — none are recalled or assumed.

---

## R1: Where do the offending permissions actually come from?

**Decision**: They are declared **only** in the app's own manifest. Deleting three lines from
`android/app/src/main/AndroidManifest.xml` removes them from the merged release manifest.

**Rationale**: Inspected the library manifests of every plugin that could plausibly contribute
media permissions:

| Package | `android/src/main/AndroidManifest.xml` contents |
|---|---|
| `gal-2.3.2` | `<manifest package="studio.midoridesign.gal">` — **empty**, zero `uses-permission` |
| `gallery_saver_plus-3.2.9` | `<manifest package="carnegietechnologies.gallery_saver">` — **empty** |
| `permission_handler_android-12.0.13` | `<manifest package="com.baseflow.permissionhandler">` — **empty** |

The long permission lists people associate with `permission_handler` live in its
`example/android/app/src/main/AndroidManifest.xml`, which is an example app and is never part of a
consumer's merge. The app's own manifest currently declares, at `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

The `debug` and `profile` manifests declare only `INTERNET`.

**Alternatives considered**:
- `tools:node="remove"` overrides — unnecessary given the above, and they add manifest noise that
  obscures intent. **Retained only as a contingency** if a future dependency reintroduces an entry;
  the merged-manifest check in `quickstart.md` is what would catch that.
- Removing `permission_handler` entirely — rejected; it contributes no permissions and is still
  needed for the app-settings deep link (see R6).

---

## R2: Which gallery-saving package, and does it need read permissions?

**Decision**: Use **`gal ^2.3.2`**. Remove `gallery_saver_plus ^3.2.9`.

**Rationale**: `gal`'s native `GalPlugin.java` implements exactly the permission split this feature
needs, in native code, with no read permissions anywhere:

```java
private static final String PERMISSION = Manifest.permission.WRITE_EXTERNAL_STORAGE;  // the only one
private static final boolean USE_EXTERNAL_STORAGE = Build.VERSION.SDK_INT <= 29;

private boolean hasAccess(boolean toAlbum) {
    if (Build.VERSION.SDK_INT < 23 || Build.VERSION.SDK_INT > 29) return true;
    if (Build.VERSION.SDK_INT == 29 && !toAlbum) return true;
    int status = ContextCompat.checkSelfPermission(context, PERMISSION);
    return status == PackageManager.PERMISSION_GRANTED;
}
```

`requestAccess` short-circuits on `hasAccess()` before ever calling
`ActivityCompat.requestPermissions`, so on API ≥ 30 **no runtime prompt can be raised at all** — this
is FR-002 enforced below the Dart layer rather than by app-side branching.

This also resolves the mismatch recorded in the spec's Assumptions: `pubspec.yaml:86` has
`gallery_saver_plus ^3.2.9` while `README.md:55,242` claims `gal 2.3.0`. The README described the
intended state; the code drifted. Adopting `gal` makes the README correct rather than editing the
README to document an unmaintained package.

**Alternatives considered**:
- Keep `gallery_saver_plus` and only edit the manifest — would satisfy the letter of the policy fix,
  but leaves an unmaintained dependency doing native gallery writes with no documented permission
  contract, and leaves the README wrong. Rejected.
- `image_gallery_saver_plus` (named in an older stale test comment) — not in `pubspec.yaml`, not
  imported anywhere. Dead reference; ignore.

---

## R3: `gal` has no `putVideoBytes` — API shape correction

**Decision**: `GalleryDataSource.putVideoBytes` keeps its signature but is implemented as
"write bytes to a temp file → `Gal.putVideo(path)` → delete temp file". Only
`putImageBytes` maps 1:1 onto `Gal.putImageBytes`.

**Rationale**: The complete public surface of `gal 2.3.2` (`lib/src/gal.dart`) is:

```
putVideo(String path, {String? album})
putImage(String path, {String? album})
putImageBytes(Uint8List bytes, {String? album, String? name})
open()
hasAccess({bool toAlbum = false})
requestAccess({bool toAlbum = false})
```

There is no `putVideoBytes` — grep across `gal-2.3.2/lib` returns nothing. The reason is visible in
the native code: the bytes path calls `Imaging.guessFormat(bytes)` and derives an image extension,
so it is structurally image-only.

This directly corrects the original task description's instruction to "migrate `putVideoBytes` to
`Gal.putVideoBytes`" — that method does not exist. The temp-file route is what the current
`gallery_saver_plus` implementation already does anyway (`gallery_data_source.dart:68-78`), so this
is not new complexity.

**Note**: `putImageBytes` and `putVideoBytes` currently have **no callers in `lib/`** — only
`download_engine.dart:99` calls `saveFile`, and the two bytes methods survive purely as tested
interface contract. They are kept (tests depend on them) but flagged: if a later cleanup wants to
shrink the contract, they and `checkPermission()` are the dead members.

---

## R4: Is the download engine's "save then delete temp file" still safe under `gal`?

**Decision**: Yes. No change to `download_engine.dart`.

**Rationale**: `download_engine.dart:99` calls `_gallery.saveFile(finalPath, isVideo:)` and then
deletes `finalPath`. This is only safe if the save **copies** the data rather than registering a
path reference. `gal`'s `writeData` does copy, on both branches:

```java
try (OutputStream out = resolver.openOutputStream(uri)) {
    byte[] buffer = new byte[8192];
    int bytesRead;
    while ((bytesRead = in.read(buffer)) != -1) out.write(buffer, 0, bytesRead);
}
```

The legacy branch (API ≤ 29) sets `MediaStore.MediaColumns.DATA` to a path under the public
Pictures/Movies directory and streams into it; the scoped branch (API ≥ 30) sets `RELATIVE_PATH`.
Either way the app's temp file is a source, never the stored artifact. Deleting it afterwards is
correct on every supported API level.

The 8 KB buffered stream also preserves Principle VI — no full-file buffering is introduced, and the
isolate-backed download path from branch 018 is untouched.

---

## R5: `WRITE_EXTERNAL_STORAGE` upper bound — 28 or 29?

**Decision**: `android:maxSdkVersion="28"` (down from the current `29`).

**Rationale**: `gal.hasAccess()` returns `true` on API 29 whenever `toAlbum` is false. The app never
passes an album (current calls are `saveImage(path)` / `saveVideo(path)` with no album, and the new
calls will be `Gal.putImage(path)` / `Gal.putVideo(path)` likewise). So API 29 never consults the
permission, and declaring it there is exactly the kind of unjustified breadth that caused the
rejection. Capping at 28 also matches FR-003 ("not requested on Android 10 or newer").

`gal`'s own *example* app caps at 29 and adds `requestLegacyExternalStorage="true"` — but that
example supports album saving, which is the one case where API 29 does need the permission.

**Residual risk and documented fallback**: on API 29 `gal` still takes the legacy branch and calls
`Environment.getExternalStoragePublicDirectory(...).mkdirs()` before inserting with a `DATA` value.
Under enforced scoped storage that `mkdirs()` can fail silently; the `MediaStore` insert is expected
to still succeed and create the file. **If API 29 verification fails**, the fix is to add
`android:requestLegacyExternalStorage="true"` to the `<application>` tag. That attribute is a
storage-behavior opt-out, **not** a permission — it declares nothing to the store, is ignored on
API 30+, and has no bearing on the "alternative system pickers" policy item. It is the only
sanctioned fallback; re-adding any `READ_*` permission is not.

**Alternatives considered**:
- Cap at 29 preemptively — rejected: declares a permission on an API level that provably never asks
  for it, which is the exact anti-pattern under review.
- Drop `WRITE_EXTERNAL_STORAGE` entirely — rejected: minSdk is 24, so API 24–28 devices are in the
  supported range and genuinely need it (US-3 / FR-003).

---

## R6: Does anything else in the app need media read access?

**Decision**: No. `permission_handler` is retained for one non-media purpose.

**Rationale**: Grepped `lib/` for every media-permission usage. Complete inventory:

| Location | Usage | Disposition |
|---|---|---|
| `gallery_data_source.dart:26,29` | `Permission.photos.request()`, `Permission.storage.request()` | **Removed** — replaced by `Gal.requestAccess()` |
| `gallery_data_source.dart:35-46` | `.photos.status`, `.storage.status` (check + permanently-denied) | **Reduced** — legacy-only via `Permission.storage.status` |
| `wallpaper_detail_page.dart:244` | `ph.openAppSettings()` | **Moved** into the data layer (FR-011) |
| `notification_service_impl.dart:190` | `FirebaseMessaging.instance.requestPermission()` | Untouched — not `permission_handler`, not media |

No profile-picture upload, no image picker, no gallery browsing, no `MANAGE_EXTERNAL_STORAGE`, no
`Permission.videos` anywhere. The spec's write-only assumption is confirmed, not merely assumed.

`permission_handler` therefore stays in `pubspec.yaml` for (a) the app-settings deep link and (b)
legacy permanently-denied detection, which `gal` does not expose. It contributes zero manifest
permissions (R1), so retaining it costs nothing against SC-001.

**Forward constraint** (spec edge case, not built now): any future feature that genuinely needs to
read user media must use the Android Photo Picker via `image_picker`, never a broad runtime
permission.

---

## R7: Version bump mechanics

**Decision**: `pubspec.yaml:19` — `version: 1.0.3+7` → `version: 1.0.4+8`. Nothing else to edit.

**Rationale**: `android/app/build.gradle.kts:49-50` reads `versionCode = flutter.versionCode` and
`versionName = flutter.versionName`, both sourced from the pubspec `version:` field. Editing
`build.gradle.kts` would be redundant and would create a second source of truth.

---

## R8: Platform baseline

**Decision**: Legacy path covers **API 24–28** exactly.

**Rationale**: `android/app/build.gradle.kts` uses `flutter.minSdkVersion` / `targetSdkVersion` /
`compileSdkVersion` with no overrides. Read from the installed SDK
(`flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`):

```kotlin
val compileSdkVersion: Int = 36
val minSdkVersion: Int = 24
val targetSdkVersion: Int = 36
```

So the supported floor is Android 7.0 (API 24) and the scoped-storage boundary is API 29 — the
legacy `WRITE_EXTERNAL_STORAGE` window is API 24–28, three API levels wide.

---

## Open items carried into implementation

| Item | Resolution path |
|---|---|
| API 29 legacy write behavior under enforced scoped storage | Emulator test in `quickstart.md`; fallback is `requestLegacyExternalStorage="true"` (R5) |
| Four existing test files assert the current permission behavior | Update, don't delete — enumerated in `plan.md` Project Structure |
| README states `gal 2.3.0` at lines 55 and 242 | Correct to `gal 2.3.2` as part of FR-007's "dependency list and documentation MUST agree" |
