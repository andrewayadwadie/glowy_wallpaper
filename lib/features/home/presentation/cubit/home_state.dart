import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/status.dart';
import '../../../app/domain/entities/app_metadata_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/classification_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

export '../../../../core/enums/status.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(Status.loading) Status categoriesStatus,
    @Default([]) List<CategoryEntity> categories,
    @Default(0) int selectedCategoryIndex,
    @Default(Status.loading) Status contentStatus,
    @Default([]) List<WallpaperEntity> wallpapers,
    @Default([]) List<ClassificationEntity> classifications,
    @Default(1) int currentPage,
    @Default(false) bool hasReachedEnd,
    @Default(false) bool isLoadingMore,
    AppMetadataEntity? appMetadata,
    String? errorMessage,
  }) = _HomeState;
}
