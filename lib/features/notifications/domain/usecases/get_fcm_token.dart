import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// Retrieves the current device FCM token (local only — no backend upload).
class GetFcmToken extends UseCase<String?, NoParams> {
  final NotificationRepository repository;
  GetFcmToken(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) =>
      repository.getToken();
}
