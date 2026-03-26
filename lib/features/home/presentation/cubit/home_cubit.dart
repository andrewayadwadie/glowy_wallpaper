import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../app/data/repositories/app_repository_impl.dart';
import '../../../app/domain/entities/app_metadata_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/get_classifications.dart';
import '../../../wallpapers/domain/usecases/get_wallpapers_by_category.dart';
import '../../../app/domain/usecases/get_app_data.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetAppData getAppData;
  final GetWallpapersByCategory getWallpapersByCategory;
  final GetClassifications getClassifications;
  final AppRepositoryImpl? _appRepo;

  CancelToken? _activeCancelToken;

  HomeCubit({
    required this.getAppData,
    required this.getWallpapersByCategory,
    required this.getClassifications,
    AppRepositoryImpl? appRepo,
  }) : _appRepo = appRepo,
       super(const HomeState()) {
    _appRepo?.onMetadataRefreshed = _onAppDataRefreshed;
  }

  void _onAppDataRefreshed(AppMetadataEntity freshMetadata) {
    if (isClosed) return;
    emit(
      state.copyWith(
        appMetadata: freshMetadata,
        categories: freshMetadata.categories,
      ),
    );
  }

  CategoryEntity? get selectedCategory => state.categories.isNotEmpty
      ? state.categories[state.selectedCategoryIndex]
      : null;

  String get selectedCategoryId =>
      state.categories.isNotEmpty
          ? state.categories[state.selectedCategoryIndex].id
          : '';

  Future<void> loadAppData() async {
    final result = await getAppData(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          categoriesStatus: Status.error,
          errorMessage: failure.message,
        ),
      ),
      (metadata) {
        final categories = metadata.categories;
        if (categories.isEmpty) {
          emit(
            state.copyWith(
              appMetadata: metadata,
              categoriesStatus: Status.empty,
              categories: const [],
            ),
          );
        } else {
          emit(
            state.copyWith(
              appMetadata: metadata,
              categoriesStatus: Status.success,
              categories: categories,
              selectedCategoryIndex: 0,
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

  Future<void> _loadWallpapers(String categoryId, {String? classificationId}) async {
    _activeCancelToken = CancelToken();
    final result = await getWallpapersByCategory(
      GetWallpapersByCategoryParams(
        categoryId: categoryId,
        page: state.currentPage,
        classificationId: classificationId,
        cancelToken: _activeCancelToken,
      ),
    );
    result.fold(
      (failure) {
        if (failure is! CancelledFailure) {
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
              hasReachedEnd: response.hasReachedEnd,
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

  Future<void> loadMore() async {
    if (state.hasReachedEnd ||
        state.isLoadingMore ||
        state.contentStatus != Status.success) {
      return;
    }
    emit(
      state.copyWith(isLoadingMore: true, currentPage: state.currentPage + 1),
    );
    await _loadWallpapers(selectedCategory!.id);
  }

  void retry() {
    if (state.categoriesStatus == Status.error) {
      loadAppData();
    } else {
      emit(state.copyWith(contentStatus: Status.loading));
      _loadContentForSelectedCategory();
    }
  }

  @override
  Future<void> close() {
    _activeCancelToken?.cancel();
    _appRepo?.onMetadataRefreshed = null;
    return super.close();
  }
}
