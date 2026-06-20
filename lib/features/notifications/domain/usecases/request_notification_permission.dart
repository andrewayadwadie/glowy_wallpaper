import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// Requests OS notification permission. Returns whether it was granted.
class RequestNotificationPermission extends UseCase<bool, NoParams> {
  final NotificationRepository repository;
  RequestNotificationPermission(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repository.requestPermission();
}
