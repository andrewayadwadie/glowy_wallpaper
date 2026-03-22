import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../../categories/domain/entities/classification_entity.dart';
import '../../../../core/enums/status.dart';

part 'classification_detail_state.freezed.dart';

@freezed
abstract class ClassificationDetailState with _$ClassificationDetailState {
  const factory ClassificationDetailState({
    required ClassificationEntity classification,
    @Default(Status.loading) Status status,
    @Default([]) List<WallpaperEntity> wallpapers,
    @Default(1) int currentPage,
    @Default(false) bool hasReachedEnd,
    @Default(false) bool isLoadingMore,
    String? errorMessage,
  }) = _ClassificationDetailState;
}
