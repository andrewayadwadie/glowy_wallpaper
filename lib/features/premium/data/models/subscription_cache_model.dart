import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/subscription_entity.dart';

part 'subscription_cache_model.freezed.dart';
part 'subscription_cache_model.g.dart';

@freezed
abstract class SubscriptionCacheModel with _$SubscriptionCacheModel {
  const SubscriptionCacheModel._();

  const factory SubscriptionCacheModel({
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'purchase_token') String? purchaseToken,
    @JsonKey(name: 'verification_state') required String verificationState,
    @JsonKey(name: 'expiry_date') String? expiryDate,
    @JsonKey(name: 'last_verified_at') String? lastVerifiedAt,
  }) = _SubscriptionCacheModel;

  factory SubscriptionCacheModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionCacheModelFromJson(json);

  SubscriptionEntity toEntity() {
    return SubscriptionEntity(
      status: status == 'premium'
          ? SubscriptionStatus.premium
          : SubscriptionStatus.free,
      productId: productId,
      purchaseToken: purchaseToken,
      verificationState: _parseVerificationState(verificationState),
      expiryDate: expiryDate != null ? DateTime.parse(expiryDate!) : null,
      lastVerifiedAt: lastVerifiedAt != null
          ? DateTime.parse(lastVerifiedAt!)
          : null,
    );
  }

  static SubscriptionCacheModel fromEntity(SubscriptionEntity entity) {
    return SubscriptionCacheModel(
      status: entity.status.name,
      productId: entity.productId,
      purchaseToken: entity.purchaseToken,
      verificationState: entity.verificationState.name,
      expiryDate: entity.expiryDate?.toIso8601String(),
      lastVerifiedAt: entity.lastVerifiedAt?.toIso8601String(),
    );
  }

  VerificationState _parseVerificationState(String state) {
    switch (state) {
      case 'verified':
        return VerificationState.verified;
      case 'pending':
        return VerificationState.pending;
      case 'unverified':
        return VerificationState.unverified;
      default:
        return VerificationState.unverified;
    }
  }

  bool isExpired() {
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(DateTime.parse(expiryDate!));
  }

  bool isCacheExpired({int ttlDays = 7}) {
    if (lastVerifiedAt == null) return true;
    final expiryTime = DateTime.parse(
      lastVerifiedAt!,
    ).add(Duration(days: ttlDays));
    return DateTime.now().isAfter(expiryTime);
  }
}
