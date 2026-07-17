import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:glowy_wallpaper/features/notifications/domain/services/notification_service.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService service;
  late NotificationRepositoryImpl repository;

  setUp(() {
    service = MockNotificationService();
    repository = NotificationRepositoryImpl(service);
  });

  group('requestPermission', () {
    test('returns Right(true) when service grants', () async {
      when(() => service.requestPermission()).thenAnswer((_) async => true);
      final result = await repository.requestPermission();
      expect(result, const Right<Failure, bool>(true));
    });

    test('returns Left(ServerFailure) when service throws', () async {
      when(() => service.requestPermission()).thenThrow(Exception('boom'));
      final result = await repository.requestPermission();
      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<ServerFailure>()), (_) => fail('right'));
    });
  });

  group('getToken', () {
    test('returns Right(token) on success', () async {
      when(() => service.getFcmToken()).thenAnswer((_) async => 'abc');
      final result = await repository.getToken();
      expect(result, const Right<Failure, String?>('abc'));
    });

    test('returns Left(NetworkFailure) when service throws', () async {
      when(() => service.getFcmToken()).thenThrow(Exception('net'));
      final result = await repository.getToken();
      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (_) => fail('right'),
      );
    });
  });
}
