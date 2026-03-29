# API Contract: Similar Wallpapers

## GET /wallpapers/{wallpaperId}/similar

Returns a list of wallpapers similar to the specified wallpaper.

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| wallpaperId | String | Yes | The unique ID of the source wallpaper |

### Response — 200 OK

```json
{
  "data": [
    {
      "id": "wp_456",
      "title": "Ocean Sunset",
      "image_url": "https://cdn.example.com/wallpapers/ocean_sunset.jpg",
      "thumbnail_url": "https://cdn.example.com/thumbs/ocean_sunset.jpg",
      "video_url": null,
      "is_premium": false,
      "category_id": "cat_01",
      "classification_ids": ["cls_nature", "cls_sunset"]
    }
  ]
}
```

### Response — 404 Not Found

Returned when `wallpaperId` does not exist.

```json
{
  "error": "Wallpaper not found"
}
```

### Notes

- Returns a flat list (not paginated). Expected count: 10-20 items.
- Response uses the same wallpaper schema as other wallpaper endpoints.
- Similar wallpapers may span different categories.
