# API Contract: Download

Downloads are client-side operations — no dedicated API endpoint is needed. The client downloads wallpaper files directly from their CDN URLs (`imageUrl` or `videoUrl` on `WallpaperEntity`).

## Download Flow (Client-Side)

1. Client reads `wallpaper.imageUrl` (or `wallpaper.videoUrl` for video type)
2. Client uses Dio to download bytes from the CDN URL
3. Client saves bytes to device gallery via `gal` package
4. Client records download metadata in local Hive box

## CDN URL Pattern

- Images: `https://cdn.example.com/wallpapers/{filename}.{jpg|png|webp}`
- Videos: `https://cdn.example.com/wallpapers/{filename}.{mp4}`

## Notes

- No authentication header needed for CDN downloads (public URLs).
- Content-Type from CDN response determines file format for gallery save.
- Progress tracking via Dio's `onReceiveProgress(received, total)` callback.
- No server-side download tracking in this phase (download metadata is local-only).
