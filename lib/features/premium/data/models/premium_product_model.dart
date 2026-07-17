import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

part 'premium_product_model.freezed.dart';

@freezed
abstract class PremiumProductModel with _$PremiumProductModel {
  const PremiumProductModel._();

  const factory PremiumProductModel({
    required String productId,
    required String title,
    required String price,
    required BillingPeriod billingPeriod,
    required double rawPrice,
  }) = _PremiumProductModel;

  PremiumProductEntity toEntity() {
    return PremiumProductEntity(
      productId: productId,
      title: title,
      price: price,
      billingPeriod: billingPeriod,
      rawPrice: rawPrice,
    );
  }

  static PremiumProductModel fromProductDetails(ProductDetails details) {
    String period = 'monthly';
    if (details.id.contains('yearly') ||
        details.description.toLowerCase().contains('year')) {
      period = 'yearly';
    }

    return PremiumProductModel(
      productId: details.id,
      title: details.title,
      price: details.price,
      billingPeriod: period == 'yearly'
          ? BillingPeriod.yearly
          : BillingPeriod.monthly,
      rawPrice: details.rawPrice,
    );
  }

  static PremiumProductModel fromEntity(PremiumProductEntity entity) {
    return PremiumProductModel(
      productId: entity.productId,
      title: entity.title,
      price: entity.price,
      billingPeriod: entity.billingPeriod,
      rawPrice: entity.rawPrice,
    );
  }
}
