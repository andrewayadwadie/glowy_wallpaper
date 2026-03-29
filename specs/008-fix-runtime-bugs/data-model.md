# Data Model: Fix Runtime Bugs

**Branch**: `008-fix-runtime-bugs` | **Date**: 2026-03-26

## Entities (no changes — bug fixes only)

This feature is a bug-fix pass. No new entities, fields, or relationships are introduced. All changes operate on existing data structures.

### Existing Entities Referenced

#### AppMetadataEntity
Already contains all fields needed for drawer content. No modifications required.

| Field | Type | Used By |
|-------|------|---------|
| name | String | Drawer header, Share App message |
| about | String | About page content (Bug 5 fix) |
| privacyPolicy | String | Privacy Policy page content (Bug 5 fix) |
| termsOfUse | String | Terms of Use page content (Bug 5 fix) |
| androidShareLink | String | Share App + Rate App on Android (Bug 5 fix) |
| iphoneShareLink | String | Share App + Rate App on iOS (Bug 5 fix) |
| contactEmail | String | Send Feedback action (Bug 5 fix) |
| categories | List\<CategoryEntity\> | Home category carousel |

#### WallpaperEntity
No changes. Used in the navigation parameter contract.

| Field | Type | Used By |
|-------|------|---------|
| id | String | Route path parameter |
| url | String | Detail page display |
| thumbUrl | String | Grid thumbnail |
| mediaType | MediaType | Grid type selection |

#### CategoryEntity
No changes. Type field determines grid behavior.

| Field | Type | Used By |
|-------|------|---------|
| id | String | Content/classification API calls |
| type | CategoryType | Grid switcher (IMAGES/VIDEOS/IMAGE_CLASSIFICATION) |

#### ClassificationEntity
No changes. Displayed in bento grid.

| Field | Type | Used By |
|-------|------|---------|
| id | String | Classification detail navigation |
| name | String | Bento card label |
| thumbnailUrl | String | Bento card background |

## Navigation Parameter Contract

The wallpaper detail route expects this data shape (existing, unchanged):

```
Route: /wallpaper/:id
Extra: Map<String, dynamic>
  - 'wallpapers': List<WallpaperEntity>  (required)
  - 'initialIndex': int                   (optional, defaults to 0)
```

All callers must conform to this contract. Bug 3 fix enforces this.
