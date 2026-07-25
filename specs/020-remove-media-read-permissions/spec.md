# Feature Specification: Remove Unnecessary Media Read Permissions (Google Play Policy Fix)

**Feature Branch**: `020-remove-media-read-permissions`  
**Created**: 2026-07-25  
**Status**: Draft  
**Input**: User description: "Fix Google Play policy rejection — the app requests READ_MEDIA_IMAGES / READ_MEDIA_VIDEO but only ever writes new downloaded wallpapers to the gallery; it never reads the user's existing photos or videos. Remove the unjustified permissions, keep saving working on all supported Android versions, and bump the version for resubmission."

## Context

Google Play rejected release version code 7 under the policy item **"Use alternative system pickers for photos/videos"**. The store's automated review saw broad photo/video read permissions declared while the app's only media need is *writing* newly downloaded wallpapers into the device gallery. Broad read access is not justified for that, and the store's suggested remedy (a system photo picker) does not apply — the app never picks existing user media. The correct remedy is to stop asking for read access at all.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Saving a wallpaper without any permission prompt on modern Android (Priority: P1)

A person browsing wallpapers on a current Android phone (Android 10 and newer) taps **Download** on a wallpaper. The file downloads and appears in their gallery. At no point are they asked to grant access to their photos or videos — the app never sees any media they already own.

**Why this priority**: This is the behavior the store rejection is about, and it is the app's core value loop. If saving breaks, the app is worthless; if the prompt remains, the release stays blocked.

**Independent Test**: Install on an Android 10+ device with a fresh profile, tap Download on one image wallpaper and one video wallpaper, and confirm both appear in the device gallery with no permission dialog shown at any point.

**Acceptance Scenarios**:

1. **Given** a freshly installed app on Android 13+ with no permissions granted, **When** the user downloads an image wallpaper, **Then** the image is saved to the gallery and no photo/video permission dialog appears.
2. **Given** a freshly installed app on Android 13+ with no permissions granted, **When** the user downloads a video wallpaper, **Then** the video is saved to the gallery and no photo/video permission dialog appears.
3. **Given** a freshly installed app on Android 10–12, **When** the user downloads a wallpaper, **Then** the file is saved to the gallery and no storage or media permission dialog appears.
4. **Given** the app's permission page in Android system settings, **When** the user opens it after downloading, **Then** no "Photos and videos" access entry is listed as requested by the app.

---

### User Story 2 - Store review passes with no photo/video read access declared (Priority: P1)

The publisher uploads a new release build. The store's pre-review permission scan finds no broad photo/video read access declared by the app or by anything bundled inside it, so the "alternative system pickers" policy item no longer applies.

**Why this priority**: The release is currently blocked. Removing the declaration from the *final shipped build* — not merely from the app's own source — is what unblocks publication, because bundled third-party components can reintroduce it.

**Independent Test**: Produce a release build and inspect the permission list of the final artifact; confirm no photo/video read access and no unrestricted storage read access is present.

**Acceptance Scenarios**:

1. **Given** a release build produced from this branch, **When** its final effective permission list is inspected, **Then** it contains no photos-read, no videos-read, no user-selected-visual-media, and no external storage read entry.
2. **Given** a bundled third-party component that would contribute such a permission, **When** the release build is produced, **Then** that contribution is suppressed or the component is removed, and the final permission list still shows none of the above.
3. **Given** the new release, **When** it is submitted for review, **Then** the "Use alternative system pickers for photos/videos" policy item is no longer raised.

---

### User Story 3 - Saving still works on older Android versions (Priority: P2)

A person on an older phone (Android 7 through 9) taps Download. Because those versions predate scoped storage, the app asks once for permission to write to storage, and after they allow it the wallpaper is saved. If they deny it, they get a clear explanation instead of a silent failure.

**Why this priority**: These versions are still within the app's supported range, and dropping their working save path to fix a policy issue would trade one broken experience for another. Lower than P1 because it affects a shrinking minority of devices.

**Independent Test**: On an Android 9 device, download a wallpaper and confirm a single write-storage prompt appears, granting it saves the file, and denying it produces a clear message.

**Acceptance Scenarios**:

1. **Given** an Android 9 device with no permission granted, **When** the user downloads a wallpaper and allows the prompt, **Then** the wallpaper is saved to the gallery.
2. **Given** an Android 9 device, **When** the user denies the prompt, **Then** the download stops and an understandable "permission needed" message is shown.
3. **Given** an Android 9 device where the user previously chose "don't ask again", **When** the user attempts a download, **Then** they are offered a route into system settings to grant it.
4. **Given** any Android 10+ device, **When** the user downloads a wallpaper, **Then** the permission-denied path from this story is never reachable.

---

### Edge Cases

- **Denial path unreachable on modern Android**: with no permission requested on Android 10+, the existing "permission denied" and "permanently denied → open settings" flows must not be triggerable there; they remain reachable only on Android 7–9.
- **Existing installs that already granted the old permissions**: an in-place update must keep saving working, with no re-prompt and no lost functionality, even though the app no longer holds media read access.
- **Repeat download of the same wallpaper**: still saves (or is recognised as already downloaded) with the same outcome as before this change.
- **Video vs image**: both media kinds save through the same permission-free path on Android 10+; neither kind reintroduces a prompt.
- **Download interrupted or failing**: network or write failures continue to report their existing errors, and must not be mislabelled as permission problems.
- **Gallery visibility**: a saved wallpaper is discoverable in the device gallery app, not only inside Glowy.
- **Future read-access need**: if any later feature genuinely needs to read user media, it must go through the system picker rather than a broad permission — recorded here as a constraint, not built now.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST NOT declare or request read access to the user's photos, videos, user-selected visual media, or general external storage — in its own configuration or in the final shipped release artifact.
- **FR-002**: On Android 10 (API 29) and newer, the app MUST save downloaded wallpapers to the device gallery without requesting any runtime media or storage permission.
- **FR-003**: On Android versions below 10, within the app's supported range (Android 7.0 / API 24 and up), the app MUST request only write access to storage, and MUST scope that declaration so it is not requested on Android 10 or newer.
- **FR-004**: Saved image and video wallpapers MUST be visible in the device's system gallery, on every supported Android version.
- **FR-005**: The download flow MUST NOT block, fail, or surface a permission error on Android 10+ for permission reasons; permission-gated failure paths MUST apply only to Android versions below 10.
- **FR-006**: The permission-denied and permanently-denied user messaging (including the route to system settings) MUST remain functional where a permission is still requested, and MUST NOT appear where none is requested.
- **FR-007**: Exactly one gallery-saving mechanism MUST be in use, and the project's dependency list and documentation MUST agree on which one; unused gallery-saving components MUST be removed so they cannot contribute permissions to the shipped build.
- **FR-008**: No feature outside the download-to-gallery flow may rely on media read access; this MUST be verified across the whole codebase before release.
- **FR-009**: The release version identifier MUST be incremented beyond the rejected version code 7 so the corrected build can be submitted.
- **FR-010**: Existing behavior outside the save-to-gallery permission path — download progress, download history, favorites, notifications, sharing — MUST be unchanged.
- **FR-011**: The layered structure of the codebase (domain / data / presentation separation) MUST be preserved; permission decisions stay inside the data layer and MUST NOT leak into domain or presentation code.

### Key Entities

- **Media save request**: an intent to place one downloaded wallpaper file (image or video) into the device gallery. Attributes: media kind, source file, target gallery. Its outcome is success or a failure reason.
- **Permission gate**: the decision point preceding a media save request. On Android 10+ it resolves to "allowed, nothing to ask"; below 10 it resolves to granted, denied, or permanently denied.
- **Declared permission set**: the effective list of permissions the shipped release asks the platform and the store to honor, including contributions from bundled third-party components. This is the artifact the store reviews.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The shipped release declares zero photo-read, video-read, user-selected-visual-media, and external-storage-read permissions — verified on the final build artifact, not just project source.
- **SC-002**: On Android 10 and newer, 100% of wallpaper downloads complete and appear in the gallery with zero permission dialogs shown.
- **SC-003**: On Android 7–9, wallpaper downloads still succeed after a single storage-write grant, and a denial produces an understandable message with a path to system settings.
- **SC-004**: The store review of the resubmitted build raises no "Use alternative system pickers for photos/videos" policy issue.
- **SC-005**: The submitted release carries a version identifier greater than the rejected version code 7.
- **SC-006**: Download-to-gallery success rate on Android 10+ is no lower after the change than before it, measured over a comparable set of manual test downloads covering both images and videos.
- **SC-007**: No user-visible regression in download progress, download history, favorites, notifications, or sharing.

## Assumptions

- **Supported range**: minimum supported platform is Android 7.0 (API 24) and the app targets API 36; the legacy write-permission path therefore covers API 24–28 only.
- **Write-only media use**: the app writes only files it downloaded itself and never enumerates, browses, or reads pre-existing user media. Codebase verification (FR-008) is expected to confirm this rather than discover exceptions.
- **Scoped-storage write model**: on Android 10+ the platform's media store accepts new-file writes from the app without a runtime permission; this is the mechanism relied on for FR-002.
- **Legacy declaration bound**: the write-storage declaration is capped at Android 9 (API 28). The current build caps it at API 29; that upper bound is tightened by one level as part of this work.
- **Gallery-saving mechanism mismatch**: the dependency list and the project documentation currently name two different gallery-saving components. FR-007 resolves this to a single one — the maintained option that writes via the platform media store without requiring media read access.
- **Notification permission untouched**: the app's notification permission is unrelated to this policy item and stays as is.
- **Version bump**: incrementing to the next patch version and version code 8 is sufficient; no other release-metadata change is implied.
- **Verification devices**: an Android 13+ target and an Android 9 (or 10) target are available for manual testing; automated store-review confirmation is out of scope until submission.

## Out of Scope

- Adding any photo/video picking, browsing, or importing capability.
- Migrating to a system photo picker (not applicable — nothing is picked).
- Changing download engine internals, download history storage, or the caching work from branch 019.
- Any change to notification, ads, authentication, or sharing behavior.
- iOS media-permission behavior (this rejection and fix are Android-specific); iOS behavior must simply not regress.
- Submitting the release to the store — this work ends with a verified, version-bumped build ready for submission.
