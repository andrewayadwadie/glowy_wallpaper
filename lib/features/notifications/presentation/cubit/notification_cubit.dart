import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_fcm_token.dart';
import '../../domain/usecases/request_notification_permission.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final RequestNotificationPermission _requestPermission;
  final GetFcmToken _getFcmToken;
  final NotificationRepository _repository;
  final FirebaseAnalytics? _analytics;

  StreamSubscription<NotificationEntity>? _tapSub;

  NotificationCubit({
    required RequestNotificationPermission requestPermission,
    required GetFcmToken getFcmToken,
    required NotificationRepository repository,
    FirebaseAnalytics? analytics,
  }) : _requestPermission = requestPermission,
       _getFcmToken = getFcmToken,
       _repository = repository,
       _analytics = analytics,
       super(const NotificationState.initial());

  /// Request permission, fetch token on grant, and wire tap navigation.
  Future<void> initNotifications() async {
    _listenForTaps();

    emit(const NotificationState.permissionRequesting());
    final permissionResult = await _requestPermission(NoParams());

    await permissionResult.fold(
      (failure) async => emit(NotificationState.error(failure: failure)),
      (granted) async {
        if (!granted) {
          emit(const NotificationState.permissionDenied());
          return;
        }
        final tokenResult = await _getFcmToken(NoParams());
        tokenResult.fold(
          (failure) => emit(NotificationState.error(failure: failure)),
          (token) => emit(NotificationState.permissionGranted(token: token)),
        );
      },
    );
    // Terminated-launch deep links are consumed by SplashPage (auth-gated),
    // not here — the Cubit only handles live foreground/background taps.
  }

  void _listenForTaps() {
    _tapSub ??= _repository.taps.listen(_navigate);
  }

  void _navigate(NotificationEntity notification) {
    _analytics?.logEvent(name: 'notification_tap');
    final deeplink = notification.deeplink;
    final target = (deeplink != null && deeplink.startsWith('/'))
        ? deeplink
        : AppRoutes.home;
    AppRouter.router.go(target);
  }

  @override
  Future<void> close() {
    _tapSub?.cancel();
    return super.close();
  }
}
