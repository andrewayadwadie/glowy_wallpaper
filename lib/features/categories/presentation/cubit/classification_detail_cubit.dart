import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../wallpapers/domain/usecases/get_wallpapers_by_classification.dart';
import '../../domain/entities/classification_entity.dart';
import 'classification_detail_state.dart';

class ClassificationDetailCubit extends Cubit<ClassificationDetailState> {
  final GetWallpapersByClassification getWallpapersByClassification;
  final ClassificationEntity classification;

  ClassificationDetailCubit({
    required this.getWallpapersByClassification,
    required this.classification,
  }) : super(ClassificationDetailState(classification: classification));

  Future<void> loadWallpapers() async {
    final result = await getWallpapersByClassification(
      GetWallpapersByClassificationParams(
        classificationId: classification.id,
        page: state.currentPage,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.error, errorMessage: failure.message),
      ),
      (response) {
        if (response.items.isEmpty && state.currentPage == 1) {
          emit(state.copyWith(status: Status.empty));
        } else {
          emit(
            state.copyWith(
              status: Status.success,
              wallpapers: [...state.wallpapers, ...response.items],
              hasReachedEnd: !response.hasMore,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }

  Future<void> loadMore() async {
    if (state.hasReachedEnd ||
        state.isLoadingMore ||
        state.status != Status.success) {
      return;
    }
    emit(
      state.copyWith(isLoadingMore: true, currentPage: state.currentPage + 1),
    );
    await loadWallpapers();
  }

  void retry() {
    emit(state.copyWith(status: Status.loading));
    loadWallpapers();
  }
}
