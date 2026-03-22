# API Contracts: Home, Categories & Content Grids

## GET /categories

Fetch all available categories sorted by display order.

### Request

```
GET /categories
Authorization: Bearer <token> (optional — works for guest and premium)
```

### Response — 200 OK

```json
{
  "items": [
    {
      "id": "cat-001",
      "name": "Nature",
      "type": "image",
      "thumbnail_url": "https://api.example.com/thumbnails/nature.jpg",
      "display_order": 1
    },
    {
      "id": "cat-002",
      "name": "Live Scenes",
      "type": "video",
      "thumbnail_url": "https://api.example.com/thumbnails/live.jpg",
      "display_order": 2
    },
    {
      "id": "cat-003",
      "name": "Themes",
      "type": "classification",
      "thumbnail_url": "https://api.example.com/thumbnails/themes.jpg",
      "display_order": 3
    }
  ]
}
```

### Response — 500 Server Error

```json
{
  "error": "Internal server error",
  "message": "Failed to fetch categories"
}
```

---

## GET /categories/:id/wallpapers

Fetch paginated wallpapers for a specific category (image or video type).

### Request

```
GET /categories/{category_id}/wallpapers?page=1&per_page=20
Authorization: Bearer <token> (optional)
```

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | int | 1 | Page number (1-indexed) |
| per_page | int | 20 | Items per page (max 50) |

### Response — 200 OK

```json
{
  "items": [
    {
      "id": "wp-001",
      "title": "Mountain Sunset",
      "image_url": "https://api.example.com/wallpapers/mountain-sunset-full.jpg",
      "thumbnail_url": "https://api.example.com/wallpapers/mountain-sunset-thumb.jpg",
      "video_url": null,
      "is_premium": false,
      "category_id": "cat-001",
      "classification_ids": ["cls-001", "cls-003"]
    },
    {
      "id": "wp-002",
      "title": "Ocean Wave Loop",
      "image_url": "https://api.example.com/wallpapers/ocean-wave-full.jpg",
      "thumbnail_url": "https://api.example.com/wallpapers/ocean-wave-thumb.jpg",
      "video_url": "https://api.example.com/wallpapers/ocean-wave.mp4",
      "is_premium": true,
      "category_id": "cat-002",
      "classification_ids": ["cls-002"]
    }
  ],
  "page": 1,
  "per_page": 20,
  "has_more": true,
  "total_count": 156
}
```

### Response — 404 Not Found

```json
{
  "error": "Not found",
  "message": "Category not found"
}
```

---

## GET /categories/:id/classifications

Fetch classifications for a classification-type category.

### Request

```
GET /categories/{category_id}/classifications
Authorization: Bearer <token> (optional)
```

### Response — 200 OK

```json
{
  "items": [
    {
      "id": "cls-001",
      "name": "Nature",
      "thumbnail_url": "https://api.example.com/classifications/nature.jpg",
      "wallpaper_count": 45
    },
    {
      "id": "cls-002",
      "name": "Abstract",
      "thumbnail_url": "https://api.example.com/classifications/abstract.jpg",
      "wallpaper_count": 32
    },
    {
      "id": "cls-003",
      "name": "Dark & Moody",
      "thumbnail_url": "https://api.example.com/classifications/dark.jpg",
      "wallpaper_count": 28
    }
  ]
}
```

---

## GET /classifications/:id/wallpapers

Fetch paginated wallpapers within a specific classification.

### Request

```
GET /classifications/{classification_id}/wallpapers?page=1&per_page=20
Authorization: Bearer <token> (optional)
```

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | int | 1 | Page number (1-indexed) |
| per_page | int | 20 | Items per page (max 50) |

### Response — 200 OK

```json
{
  "items": [
    {
      "id": "wp-010",
      "title": "Forest Path",
      "image_url": "https://api.example.com/wallpapers/forest-path-full.jpg",
      "thumbnail_url": "https://api.example.com/wallpapers/forest-path-thumb.jpg",
      "video_url": null,
      "is_premium": false,
      "category_id": "cat-001",
      "classification_ids": ["cls-001"]
    }
  ],
  "page": 1,
  "per_page": 20,
  "has_more": false,
  "total_count": 18
}
```
