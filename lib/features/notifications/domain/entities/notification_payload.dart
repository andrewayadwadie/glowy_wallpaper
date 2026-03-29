import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_payload.freezed.dart';

@freezed
abstract class NotificationPayload with _$NotificationPayload {
  const factory NotificationPayload({
    required String title,
    required String body,
    String? route,
    @Default({}) Map<String, String> data,
  }) = _NotificationPayload;
}
