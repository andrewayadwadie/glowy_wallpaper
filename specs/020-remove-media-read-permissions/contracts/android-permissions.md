# Contract: Declared Android Permission Set

**Feature**: `020-remove-media-read-permissions` | **Consumer**: Google Play policy review, Android runtime

This is the contract SC-001 and FR-001 are verified against. It governs the **merged release
manifest**, not the source manifest — a bundled dependency can add rows without any source change.

---

## Allowed set (exhaustive)

The merged release manifest MUST contain exactly these `uses-permission` entries and no others:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

Google Play Services and Firebase may additionally merge in their own standard entries
(e.g. `com.google.android.c2dm.permission.RECEIVE`, `AD_ID`). Those are pre-existing, unrelated to
this policy item, and out of scope — but they MUST NOT include anything from the forbidden set below.

---

## Forbidden set (hard failure)

Any of the following in the merged release manifest fails the contract:

| Permission | Why forbidden |
|---|---|
| `android.permission.READ_MEDIA_IMAGES` | The rejection trigger. App never reads user images |
| `android.permission.READ_MEDIA_VIDEO` | The rejection trigger. App never reads user videos |
| `android.permission.READ_MEDIA_VISUAL_USER_SELECTED` | Partial-access variant of the same broad read capability |
| `android.permission.READ_EXTERNAL_STORAGE` | Broad read access; app is write-only |
| `android.permission.MANAGE_EXTERNAL_STORAGE` | All-files access; far broader, separate policy declaration required |
| `android.permission.ACCESS_MEDIA_LOCATION` | Reads EXIF location from user media; read-adjacent, unjustified |

There is no `maxSdkVersion` value that makes any of these acceptable. Scoping a read permission to
old API levels does not remove it from the store's review surface.

---

## Constrained attribute

| Attribute | Value | Rule |
|---|---|---|
| `WRITE_EXTERNAL_STORAGE` → `android:maxSdkVersion` | `28` | MUST be exactly 28. `29` over-declares (API 29 provably never consults it for non-album saves); omitting the cap declares it on all API levels |

---

## Permitted contingency

If and only if API 29 gallery-save verification fails, the following MAY be added to `<application>`:

```xml
android:requestLegacyExternalStorage="true"
```

This is a storage-behavior opt-out attribute, **not** a permission. It declares nothing to the store,
is ignored on API 30+, and does not affect this contract's allowed or forbidden sets. It is the only
sanctioned remedy for an API 29 save failure — re-adding any forbidden permission is not.

---

## Verification

Source of truth for verification is the merged manifest produced by a release build:

```
build/app/intermediates/merged_manifest/release/AndroidManifest.xml
```

Checking `android/app/src/main/AndroidManifest.xml` alone is **insufficient** and does not satisfy
SC-001. Procedure in [../quickstart.md](../quickstart.md).

Runtime cross-check: after install, the app's entry in Android system settings → Permissions MUST
show no "Photos and videos" (API 33+) or "Files and media" read entry (API 30–32).
