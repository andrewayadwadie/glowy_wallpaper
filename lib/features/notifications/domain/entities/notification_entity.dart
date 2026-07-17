import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

/// A user-facing notification: what is shown and where a tap leads.
///
/// [deeplink] is honored only when it begins with `/`; otherwise navigation
/// falls back to Home. [imageUrl], when present, drives big-picture rendering.
@freezed
abstract class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    @Default('') String title,
    @Default('') String body,
    String? deeplink,
    String? imageUrl,
  }) = _NotificationEntity;
}
