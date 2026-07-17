import 'package:equatable/equatable.dart';

enum SubscriptionStatus { free, premium }

enum VerificationState { verified, pending, unverified }

class SubscriptionEntity extends Equatable {
  final SubscriptionStatus status;
  final String? productId;
  final String? purchaseToken;
  final VerificationState verificationState;
  final DateTime? expiryDate;
  final DateTime? lastVerifiedAt;

  const SubscriptionEntity({
    required this.status,
    this.productId,
    this.purchaseToken,
    required this.verificationState,
    this.expiryDate,
    this.lastVerifiedAt,
  });

  SubscriptionEntity copyWith({
    SubscriptionStatus? status,
    String? productId,
    String? purchaseToken,
    VerificationState? verificationState,
    DateTime? expiryDate,
    DateTime? lastVerifiedAt,
  }) {
    return SubscriptionEntity(
      status: status ?? this.status,
      productId: productId ?? this.productId,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      verificationState: verificationState ?? this.verificationState,
      expiryDate: expiryDate ?? this.expiryDate,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }

  bool get isPremium => status == SubscriptionStatus.premium;

  bool get isVerified => verificationState == VerificationState.verified;

  bool get needsVerification => verificationState == VerificationState.pending;

  bool isExpired() {
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate!);
  }

  @override
  List<Object?> get props => [
    status,
    productId,
    purchaseToken,
    verificationState,
    expiryDate,
    lastVerifiedAt,
  ];
}
