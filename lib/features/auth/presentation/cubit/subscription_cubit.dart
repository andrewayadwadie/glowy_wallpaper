import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowy_wallpaper/features/auth/domain/usecases/validate_token.dart';
import 'package:glowy_wallpaper/features/auth/domain/usecases/get_cached_user.dart';
import 'package:glowy_wallpaper/features/auth/domain/usecases/unsubscribe.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/features/auth/domain/entities/user_entity.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final ValidateToken validateToken;
  final GetCachedUser getCachedUser;
  final Unsubscribe unsubscribe;

  SubscriptionCubit({
    required this.validateToken,
    required this.getCachedUser,
    required this.unsubscribe,
  }) : super(const SubscriptionState.guest());

  Future<void> checkStatus() async {
    emit(const SubscriptionState.loading());

    final result = await validateToken(NoParams());

    result.fold((failure) => emit(const SubscriptionState.guest()), (
      isPremium,
    ) async {
      if (isPremium) {
        final userResult = await getCachedUser(NoParams());
        userResult.fold((failure) => emit(const SubscriptionState.guest()), (
          user,
        ) {
          if (user != null) {
            emit(SubscriptionState.premium(user: user));
          } else {
            emit(const SubscriptionState.guest());
          }
        });
      } else {
        emit(const SubscriptionState.guest());
      }
    });
  }

  Future<void> performUnsubscribe() async {
    emit(const SubscriptionState.loading());

    final result = await unsubscribe(NoParams());

    result.fold((failure) {
      if (state is SubscriptionPremium) {
        emit(state);
      }
    }, (_) => emit(const SubscriptionState.guest()));
  }

  void setGuest() {
    emit(const SubscriptionState.guest());
  }

  void setPremium(UserEntity user) {
    emit(SubscriptionState.premium(user: user));
  }

  bool get isPremium => state is SubscriptionPremium;

  bool get shouldShowAds => !isPremium;
}
