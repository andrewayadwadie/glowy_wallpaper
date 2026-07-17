import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/status.dart';
import '../../domain/entities/favorite_entity.dart';

export '../../../../core/enums/status.dart';

part 'favorite_state.freezed.dart';

@freezed
abstract class FavoriteState with _$FavoriteState {
  const factory FavoriteState({
    @Default(Status.loading) Status listStatus,
    @Default([]) List<FavoriteEntity> favorites,
    @Default(false) bool isFavorite,
    @Default(false) bool isToggling,
    String? errorMessage,
  }) = _FavoriteState;
}
