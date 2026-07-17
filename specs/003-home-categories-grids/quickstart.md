# Quickstart: Home, Categories & Content Grids

## Test Scenarios

### 1. Categories Load on Home Screen
1. Launch the app → splash → Home.
2. Verify horizontal category chips appear at the top.
3. Verify the first category is highlighted (selected).
4. Verify categories are sorted by display order.

### 2. Image Wallpaper Grid
1. Select an image-type category (e.g., "Nature").
2. Verify a responsive grid of image thumbnails appears (2 cols phone, 3 large, 4 tablet).
3. Scroll to the bottom → verify more wallpapers load automatically.
4. Continue scrolling until no more pages → verify loading indicator disappears.
5. Tap a wallpaper thumbnail → verify navigation to wallpaper detail screen.

### 3. Video Wallpaper Grid
1. Select a video-type category (e.g., "Live Scenes").
2. Verify video cells appear in the grid.
3. Verify the 2-3 most visible videos auto-play muted loops.
4. Verify remaining visible cells show a static thumbnail with play icon.
5. Scroll a playing video off-screen → verify it pauses.
6. Scroll back → verify it resumes (if under limit).
7. Tap a video cell → verify navigation to wallpaper detail.

### 4. Classification Bento Grid
1. Select a classification-type category (e.g., "Themes").
2. Verify a bento grid appears with large (2-col) and small (1-col) cards in repeating pattern.
3. Verify each card shows a thumbnail image with classification name on a gradient overlay.
4. Tap a classification card → verify navigation to Classification Detail page.

### 5. Classification Detail Page
1. From the bento grid, tap a classification (e.g., "Nature").
2. Verify ClassificationDetail page opens with the classification name in the AppBar.
3. Verify wallpapers from that classification load in a paginated grid.
4. Scroll to bottom → verify next page loads.
5. Tap back → verify return to Home with same category selected.

### 6. Category Switching
1. Select an image category → verify image grid.
2. Switch to a video category → verify video grid replaces image grid.
3. Switch to a classification category → verify bento grid replaces video grid.
4. Switch back to image category → verify image grid returns.
5. Rapidly tap between categories → verify no crashes, old content doesn't bleed through.

### 7. Navigation Drawer
1. Tap hamburger menu (or swipe from left) → verify drawer opens.
2. Verify all 9 menu items are present: Home, Favorites, My Downloads, Get Premium, Settings, About, Rate App, Share App, Send Feedback.
3. Tap Home → verify drawer closes, Home is shown.
4. Tap Favorites → verify navigation to Favorites (placeholder).
5. Tap Rate App → verify store URL opens in browser.
6. Tap Send Feedback → verify mailto: opens.

### 8. Premium Filtering
1. As a guest user: verify premium-only wallpapers are NOT visible in any grid.
2. As a premium user: verify ALL wallpapers are visible including premium items.
3. Verify no "Premium" badges or lock icons — premium items are simply absent for guests.

### 9. Error & Empty States
1. Disconnect network before launch → verify categories show error state with retry button.
2. If cached categories exist → verify cached categories show with offline indicator.
3. Select a category with no wallpapers → verify empty state: "No wallpapers in this category."
4. Tap retry on error → verify categories/content reload.

### 10. Offline Caching
1. Launch with network → categories load and display.
2. Kill network → force close and relaunch.
3. Verify cached categories appear immediately.
4. Verify content grid shows error (wallpapers are not cached).

## Key Files to Implement

### Domain Layer
| File | Layer | Purpose |
|------|-------|---------|
| `lib/features/categories/domain/entities/category_entity.dart` | Domain | CategoryEntity + CategoryType enum |
| `lib/features/categories/domain/entities/classification_entity.dart` | Domain | ClassificationEntity |
| `lib/features/wallpapers/domain/entities/wallpaper_entity.dart` | Domain | WallpaperEntity |
| `lib/features/categories/domain/repositories/category_repository.dart` | Domain | CategoryRepository contract |
| `lib/features/wallpapers/domain/repositories/wallpaper_repository.dart` | Domain | WallpaperRepository contract |
| `lib/features/categories/domain/usecases/get_categories.dart` | Domain | GetCategories use case |
| `lib/features/categories/domain/usecases/get_classifications.dart` | Domain | GetClassifications use case |
| `lib/features/wallpapers/domain/usecases/get_wallpapers_by_category.dart` | Domain | GetWallpapersByCategory use case |
| `lib/features/wallpapers/domain/usecases/get_wallpapers_by_classification.dart` | Domain | GetWallpapersByClassification use case |

### Data Layer
| File | Layer | Purpose |
|------|-------|---------|
| `lib/features/categories/data/models/category_model.dart` | Data | Freezed CategoryModel |
| `lib/features/categories/data/models/classification_model.dart` | Data | Freezed ClassificationModel |
| `lib/features/wallpapers/data/models/wallpaper_model.dart` | Data | Freezed WallpaperModel |
| `lib/features/wallpapers/data/models/paginated_response.dart` | Data | Generic PaginatedResponse |
| `lib/features/categories/data/datasources/category_remote_data_source.dart` | Data | Retrofit API calls |
| `lib/features/categories/data/datasources/category_local_data_source.dart` | Data | Hive category cache |
| `lib/features/wallpapers/data/datasources/wallpaper_remote_data_source.dart` | Data | Retrofit API calls |
| `lib/features/categories/data/repositories/category_repository_impl.dart` | Data | Stale-while-revalidate |
| `lib/features/wallpapers/data/repositories/wallpaper_repository_impl.dart` | Data | With NetworkInfo |

### Presentation Layer
| File | Layer | Purpose |
|------|-------|---------|
| `lib/features/home/presentation/cubit/home_cubit.dart` | Presentation | Categories + content state |
| `lib/features/home/presentation/cubit/home_state.dart` | Presentation | Freezed states |
| `lib/features/home/presentation/pages/home_page.dart` | Presentation | Full Home rewrite |
| `lib/features/home/presentation/widgets/category_selector.dart` | Presentation | Horizontal chips |
| `lib/features/home/presentation/widgets/content_switcher.dart` | Presentation | Dynamic grid switcher |
| `lib/features/home/presentation/widgets/home_drawer.dart` | Presentation | Navigation drawer |
| `lib/features/wallpapers/presentation/widgets/wallpaper_grid.dart` | Presentation | Image grid |
| `lib/features/wallpapers/presentation/widgets/wallpaper_thumbnail.dart` | Presentation | Image cell |
| `lib/features/wallpapers/presentation/widgets/video_grid.dart` | Presentation | Video grid |
| `lib/features/wallpapers/presentation/widgets/video_thumbnail.dart` | Presentation | Video cell with auto-play |
| `lib/features/categories/presentation/cubit/classification_detail_cubit.dart` | Presentation | ClassificationDetail state |
| `lib/features/categories/presentation/cubit/classification_detail_state.dart` | Presentation | Freezed states |
| `lib/features/categories/presentation/pages/classification_detail_page.dart` | Presentation | Full detail page |
| `lib/features/categories/presentation/widgets/classification_bento_grid.dart` | Presentation | Bento layout |
| `lib/features/categories/presentation/widgets/classification_card.dart` | Presentation | Single bento card |

### Core Updates
| File | Layer | Purpose |
|------|-------|---------|
| `lib/core/utils/app_strings.dart` | Core | Add Phase 3 string constants |
| `lib/core/utils/app_dimens.dart` | Core | Add category chip, bento card dimensions |
| `lib/core/api/server_strings.dart` | Core | Add category/classification/wallpaper endpoints |
| `lib/core/di/injection_container.dart` | Core | Register all new DI bindings |
| `lib/core/routes/routes.dart` | Core | Add classificationDetail route constant |
| `lib/core/routes/router.dart` | Core | Add GoRoute for ClassificationDetail |
| `pubspec.yaml` | Core | Add video_player, visibility_detector |
