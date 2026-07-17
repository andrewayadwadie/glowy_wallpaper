import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/notification_entity.dart';

/// Domain contract for notification operations.
///
/// Token is exposed locally only — no backend upload (Clarification Q1).
abstract class NotificationRepository {
  /// Request OS notification permission. Returns granted state.
  Future<Either<Failure, bool>> requestPermission();

  /// Current device FCM token, or null if unavailable.
  Future<Either<Failure, String?>> getToken();

  /// Stream of refreshed FCM tokens (platform rotates the token over time).
  Stream<String> get tokenRefreshes;

  /// Stream of notification taps surfaced as domain entities.
  Stream<NotificationEntity> get taps;
}
