# Quickstart: Verifying the Permission Removal

**Feature**: `020-remove-media-read-permissions` | **Date**: 2026-07-25

Runbook for building and proving the fix. Steps 3 and 4 are what SC-001 and SC-002 are signed off
against — **step 3 is mandatory**, because checking only the source manifest does not prove anything
about the shipped artifact.

---

## 1. Install dependencies

```powershell
flutter pub get
```

Confirm `gal` resolved and `gallery_saver_plus` is gone:

```powershell
Select-String -Path pubspec.lock -Pattern "^  (gal|gallery_saver_plus):" -Context 0,2
```

Expected: a `gal` block, no `gallery_saver_plus` block.

---

## 2. Static checks

```powershell
dart format .
flutter analyze
flutter test
```

Gate: `flutter analyze` reports **zero** warnings (Principle VII). All tests pass, including the
four updated files under `test/features/downloads/` and `test/features/wallpaper_detail/`.

---

## 3. Build and inspect the merged manifest (mandatory — SC-001)

```powershell
flutter build apk --release
```

Then inspect the **merged** manifest, not the source one:

```powershell
$m = "build\app\intermediates\merged_manifest\release\AndroidManifest.xml"
Select-String -Path $m -Pattern "uses-permission"
```

**PASS criteria** — zero matches for any of:

```
READ_MEDIA_IMAGES
READ_MEDIA_VIDEO
READ_MEDIA_VISUAL_USER_SELECTED
READ_EXTERNAL_STORAGE
MANAGE_EXTERNAL_STORAGE
ACCESS_MEDIA_LOCATION
```

One-liner check:

```powershell
$hits = Select-String -Path $m -Pattern "READ_MEDIA_|READ_EXTERNAL_STORAGE|MANAGE_EXTERNAL_STORAGE|ACCESS_MEDIA_LOCATION"
if ($hits) { "FAIL"; $hits } else { "PASS - no read-media permissions in merged manifest" }
```

And confirm the one storage entry that should remain is correctly capped:

```powershell
Select-String -Path $m -Pattern "WRITE_EXTERNAL_STORAGE" -Context 0,1
```

Expected: present with `android:maxSdkVersion="28"`.

If the merged manifest path differs for this Gradle version, regenerate it directly:

```powershell
cd android; .\gradlew :app:processReleaseManifest
```

Cross-check against the built artifact itself (independent of Gradle intermediates):

```powershell
& "$env:ANDROID_HOME\build-tools\<version>\aapt2.exe" dump permissions build\app\outputs\flutter-apk\app-release.apk
```

Note: `build/app/outputs/apk/release/output-metadata.json` does **not** list permissions — it is not
a valid check for this.

---

## 4. Device verification (SC-002, SC-003)

### Android 13+ emulator (API 33 or higher) — no prompt expected

1. Install the release build on a **fresh** profile (no previously granted permissions):
   `adb install -r build\app\outputs\flutter-apk\app-release.apk`
2. Download one **image** wallpaper → saves, **no permission dialog at any point**.
3. Download one **video** wallpaper → saves, **no permission dialog**.
4. Open the system gallery app → both files are visible there, not only inside Glowy.
5. `adb shell dumpsys package com.<applicationId> | Select-String "READ_MEDIA|READ_EXTERNAL"` →
   no requested-permission entries.
6. Settings → Apps → Glowy → Permissions → **no "Photos and videos" entry**.

### Android 9 emulator (API 28) — one prompt expected

1. Install on a fresh profile.
2. Download a wallpaper → a **single** storage-write prompt appears.
3. Allow → the wallpaper saves and appears in the gallery.
4. Reinstall, deny → download stops with an understandable "permission needed" message
   (`AppStrings.permissionDenied`), not a silent failure.
5. Reinstall, deny with "don't ask again" → the permanently-denied dialog offers **Open Settings**
   and that button reaches the app's settings page.

### Android 10 emulator (API 29) — the boundary case, no prompt expected

1. Install on a fresh profile.
2. Download an image and a video → both save with **no prompt**.
3. Confirm both appear in the system gallery.

**If step 3 of the API-29 run fails** (files save without error but never appear in the gallery, or
the save throws): add `android:requestLegacyExternalStorage="true"` to the `<application>` tag in
`android/app/src/main/AndroidManifest.xml`, rebuild, and re-run. That attribute is a storage-behavior
opt-out, not a permission — it does not affect the step 3 permission check and is ignored on API 30+.
**Do not** re-add any `READ_*` permission; see `contracts/android-permissions.md`.

---

## 5. Regression sweep (SC-007)

On the API 33+ device, confirm unchanged behavior for:

- download progress reporting and cancellation,
- download history list,
- favorites add/remove,
- push notification receipt and tap-through,
- share sheet.

---

## 6. Version check (SC-005)

```powershell
Select-String -Path pubspec.yaml -Pattern "^version:"
```

Expected: `version: 1.0.4+8` — version code strictly greater than the rejected `7`.

Confirm it propagated into the build (`build.gradle.kts` reads `flutter.versionCode`, so no separate
Gradle edit should exist):

```powershell
Select-String -Path build\app\outputs\apk\release\output-metadata.json -Pattern "versionCode"
```

---

## Definition of done

| # | Check | Criterion |
|---|---|---|
| 1 | `flutter analyze` | zero warnings |
| 2 | `flutter test` | all pass |
| 3 | Merged manifest | zero read-media / read-storage permissions |
| 4 | Merged manifest | `WRITE_EXTERNAL_STORAGE` capped at `maxSdkVersion="28"` |
| 5 | API 33+ device | image and video save, zero prompts, visible in system gallery |
| 6 | API 29 device | image and video save, zero prompts, visible in system gallery |
| 7 | API 28 device | one prompt; allow saves, deny messages clearly, permanent-deny reaches settings |
| 8 | Regression sweep | progress, history, favorites, notifications, sharing unchanged |
| 9 | `pubspec.yaml` | `1.0.4+8` |
| 10 | `README.md` | gallery package documented matches `pubspec.yaml` |
