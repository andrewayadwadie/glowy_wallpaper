import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/classification_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

part 'home_state.freezed.dart';

enum Status { loading, success, error, empty }

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
    String? errorMessage,
  }) = _HomeState;
}
