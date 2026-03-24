# API Contract: Favorites

## GET /favorites

Returns the authenticated user's list of favorited wallpapers.

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |

### Response — 200 OK

```json
{
  "data": [
    {
      "wallpaper_id": "wp_123",
      "favorited_at": "2026-03-24T10:30:00Z",
      "wallpaper": {
        "id": "wp_123",
        "title": "Mountain Dawn",
        "image_url": "https://cdn.example.com/wallpapers/mountain_dawn.jpg",
        "thumbnail_url": "https://cdn.example.com/thumbs/mountain_dawn.jpg",
        "video_url": null,
        "is_premium": false,
        "category_id": "cat_02",
        "classification_ids": ["cls_nature"]
      }
    }
  ]
}
```

### Response — 401 Unauthorized

Returned when token is missing or invalid.

---

## POST /favorites

Add a wallpaper to the authenticated user's favorites.

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |

### Request Body

```json
{
  "wallpaper_id": "wp_123"
}
```

### Response — 201 Created

```json
{
  "wallpaper_id": "wp_123",
  "favorited_at": "2026-03-24T10:30:00Z"
}
```

### Response — 409 Conflict

Returned when wallpaper is already favorited (idempotent — treat as success client-side).

---

## DELETE /favorites/{wallpaperId}

Remove a wallpaper from the authenticated user's favorites.

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| wallpaperId | String | Yes | The wallpaper ID to unfavorite |

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |

### Response — 204 No Content

Successfully removed.

### Response — 404 Not Found

Wallpaper was not in favorites (idempotent — treat as success client-side).

---

## POST /favorites/merge

Merge guest favorites into the authenticated user's account after login.

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer token |

### Request Body

```json
{
  "wallpaper_ids": ["wp_123", "wp_456", "wp_789"]
}
```

### Response — 200 OK

```json
{
  "merged_count": 3,
  "duplicates_skipped": 1
}
```

### Notes

- Duplicates (already favorited on server) are silently skipped.
- Client should update local sync status to `synced` for all merged entries.
