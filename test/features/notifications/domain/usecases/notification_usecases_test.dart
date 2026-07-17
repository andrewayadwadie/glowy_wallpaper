import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/features/notifications/domain/repositories/notification_repository.dart';
import 'package:glowy_wallpaper/features/notifications/domain/usecases/get_fcm_token.dart';
import 'package:glowy_wallpaper/features/notifications/domain/usecases/request_notification_permission.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;

  setUp(() => repository = MockNotificationRepository());

  group('RequestNotificationPermission', () {
    test('delegates to repository.requestPermission', () async {
      when(
        () => repository.requestPermission(),
      ).thenAnswer((_) async => const Right(true));
      final usecase = RequestNotificationPermission(repository);
      final result = await usecase(NoParams());
      expect(result, const Right<Failure, bool>(true));
      verify(() => repository.requestPermission()).called(1);
    });
  });

  group('GetFcmToken', () {
    test('delegates to repository.getToken', () async {
      when(
        () => repository.getToken(),
      ).thenAnswer((_) async => const Right('tok'));
      final usecase = GetFcmToken(repository);
      final result = await usecase(NoParams());
      expect(result, const Right<Failure, String?>('tok'));
      verify(() => repository.getToken()).called(1);
    });
  });
}
