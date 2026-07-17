import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/features/notifications/domain/repositories/notification_repository.dart';
import 'package:glowy_wallpaper/features/notifications/domain/usecases/get_fcm_token.dart';
import 'package:glowy_wallpaper/features/notifications/domain/usecases/request_notification_permission.dart';
import 'package:glowy_wallpaper/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:glowy_wallpaper/features/notifications/presentation/cubit/notification_state.dart';

class MockRequestPermission extends Mock
    implements RequestNotificationPermission {}

class MockGetFcmToken extends Mock implements GetFcmToken {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockRequestPermission requestPermission;
  late MockGetFcmToken getFcmToken;
  late MockNotificationRepository repository;

  setUp(() {
    requestPermission = MockRequestPermission();
    getFcmToken = MockGetFcmToken();
    repository = MockNotificationRepository();

    registerFallbackValue(NoParams());
    // No taps → no navigation in tests.
    when(() => repository.taps).thenAnswer((_) => const Stream.empty());
  });

  NotificationCubit build() => NotificationCubit(
    requestPermission: requestPermission,
    getFcmToken: getFcmToken,
    repository: repository,
  );

  blocTest<NotificationCubit, NotificationState>(
    'granted → requesting then permissionGranted(token)',
    setUp: () {
      when(
        () => requestPermission(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => getFcmToken(any()),
      ).thenAnswer((_) async => const Right('tok123'));
    },
    build: build,
    act: (c) => c.initNotifications(),
    expect: () => const [
      NotificationState.permissionRequesting(),
      NotificationState.permissionGranted(token: 'tok123'),
    ],
  );

  blocTest<NotificationCubit, NotificationState>(
    'denied → requesting then permissionDenied',
    setUp: () {
      when(
        () => requestPermission(any()),
      ).thenAnswer((_) async => const Right(false));
    },
    build: build,
    act: (c) => c.initNotifications(),
    expect: () => const [
      NotificationState.permissionRequesting(),
      NotificationState.permissionDenied(),
    ],
  );

  blocTest<NotificationCubit, NotificationState>(
    'permission failure → requesting then error',
    setUp: () {
      when(
        () => requestPermission(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('nope')));
    },
    build: build,
    act: (c) => c.initNotifications(),
    expect: () => const [
      NotificationState.permissionRequesting(),
      NotificationState.error(failure: ServerFailure('nope')),
    ],
  );
}
