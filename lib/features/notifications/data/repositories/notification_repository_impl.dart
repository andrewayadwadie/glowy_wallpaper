import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService service;
  NotificationRepositoryImpl(this.service);

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      final granted = await service.requestPermission();
      return Right(granted);
    } catch (e) {
      return Left(ServerFailure('Failed to request permission: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await service.getFcmToken();
      return Right(token);
    } catch (e) {
      return Left(NetworkFailure('Failed to obtain push token: $e'));
    }
  }

  @override
  Stream<String> get tokenRefreshes => service.onTokenRefresh;

  @override
  Stream<NotificationEntity> get taps => service.onNotificationTap;
}
