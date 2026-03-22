import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/get_categories.dart';
import '../../../categories/domain/usecases/get_classifications.dart';
import '../../../wallpapers/domain/usecases/get_wallpapers_by_category.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCategories getCategories;
  final GetWallpapersByCategory getWallpapersByCategory;
  final GetClassifications getClassifications;

  CancelToken? _activeCancelToken;

  HomeCubit({
    required this.getCategories,
    required this.getWallpapersByCategory,
    required this.getClassifications,
  }) : super(const HomeState());

  CategoryEntity? get selectedCategory => state.categories.isNotEmpty
      ? state.categories[state.selectedCategoryIndex]
      : null;

  Future<void> loadCategories() async {
    final result = await getCategories(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          categoriesStatus: Status.error,
          errorMessage: failure.message,
        ),
      ),
      (categories) {
        final sorted = List<CategoryEntity>.from(categories)
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        if (sorted.isEmpty) {
          emit(
            state.copyWith(categoriesStatus: Status.empty, categories: sorted),
          );
        } else {
          emit(
            state.copyWith(
              categoriesStatus: Status.success,
              categories: sorted,
            ),
          );
          _loadContentForSelectedCategory();
        }
      },
    );
  }

  void selectCategory(int index) {
    _activeCancelToken?.cancel();
    emit(
      state.copyWith(
        selectedCategoryIndex: index,
        contentStatus: Status.loading,
        wallpapers: const [],
        classifications: const [],
        currentPage: 1,
        hasReachedEnd: false,
        isLoadingMore: false,
      ),
    );
    _loadContentForSelectedCategory();
  }

  Future<void> _loadContentForSelectedCategory() async {
    final category = selectedCategory;
    if (category == null) return;

    switch (category.type) {
      case CategoryType.image:
      case CategoryType.video:
        await _loadWallpapers(category.id);
        break;
      case CategoryType.classification:
        await _loadClassifications(category.id);
        break;
    }
  }

  Future<void> _loadWallpapers(String categoryId) async {
    _activeCancelToken = CancelToken();
    final result = await getWallpapersByCategory(
      GetWallpapersByCategoryParams(
        categoryId: categoryId,
        page: state.currentPage,
        cancelToken: _activeCancelToken,
      ),
    );
    result.fold(
      (failure) {
        if (!failure.message.contains('cancelled')) {
          emit(
            state.copyWith(
              contentStatus: Status.error,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (response) {
        if (response.items.isEmpty && state.currentPage == 1) {
          emit(state.copyWith(contentStatus: Status.empty));
        } else {
          emit(
            state.copyWith(
              contentStatus: Status.success,
              wallpapers: [...state.wallpapers, ...response.items],
              hasReachedEnd: !response.hasMore,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }

  Future<void> _loadClassifications(String categoryId) async {
    final result = await getClassifications(categoryId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          contentStatus: Status.error,
          errorMessage: failure.message,
        ),
      ),
      (classifications) {
        if (classifications.isEmpty) {
          emit(state.copyWith(contentStatus: Status.empty));
        } else {
          emit(
            state.copyWith(
              contentStatus: Status.success,
              classifications: classifications,
            ),
          );
        }
      },
    );
  }

  void loadMore() {
    if (state.hasReachedEnd ||
        state.isLoadingMore ||
        state.contentStatus != Status.success) {
      return;
    }
    emit(
      state.copyWith(isLoadingMore: true, currentPage: state.currentPage + 1),
    );
    _loadWallpapers(selectedCategory!.id);
  }

  void retry() {
    if (state.categoriesStatus == Status.error) {
      loadCategories();
    } else {
      emit(state.copyWith(contentStatus: Status.loading));
      _loadContentForSelectedCategory();
    }
  }

  @override
  Future<void> close() {
    _activeCancelToken?.cancel();
    return super.close();
  }
}
