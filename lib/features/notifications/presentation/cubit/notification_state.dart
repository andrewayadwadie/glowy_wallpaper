import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = NotificationInitial;
  const factory NotificationState.permissionRequesting() =
      NotificationPermissionRequesting;
  const factory NotificationState.permissionGranted({String? token}) =
      NotificationPermissionGranted;
  const factory NotificationState.permissionDenied() =
      NotificationPermissionDenied;
  const factory NotificationState.error({required Failure failure}) =
      NotificationError;
}
