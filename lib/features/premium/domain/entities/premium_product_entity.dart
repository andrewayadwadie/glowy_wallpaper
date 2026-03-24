import 'package:equatable/equatable.dart';

enum BillingPeriod { monthly, yearly }

class PremiumProductEntity extends Equatable {
  final String productId;
  final String title;
  final String price;
  final BillingPeriod billingPeriod;
  final double rawPrice;

  const PremiumProductEntity({
    required this.productId,
    required this.title,
    required this.price,
    required this.billingPeriod,
    required this.rawPrice,
  });

  @override
  List<Object?> get props => [productId, title, price, billingPeriod, rawPrice];
}
