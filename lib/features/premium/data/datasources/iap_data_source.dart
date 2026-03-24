import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/features/premium/data/models/premium_product_model.dart';
import 'package:glowy_wallpaper/features/premium/domain/entities/premium_product_entity.dart';

class IAPDataSource {
  final InAppPurchase _inAppPurchase;

  IAPDataSource(this._inAppPurchase);

  Stream<List<PurchaseDetails>> get purchaseStream {
    return _inAppPurchase.purchaseStream;
  }

  Future<Either<Failure, List<ProductDetails>>> queryProducts(
    Set<String> productIds,
  ) async {
    try {
      final response = await _inAppPurchase.queryProductDetails(productIds);
      if (response.notFoundIDs.isNotEmpty) {
        return Left(
          ServerFailure(
            'Some products not found: ${response.notFoundIDs.join(", ")}',
          ),
        );
      }
      if (response.productDetails.isEmpty) {
        return Left(ServerFailure('No products available'));
      }
      return Right(response.productDetails);
    } catch (e) {
      return Left(ServerFailure('Failed to query products: ${e.toString()}'));
    }
  }

  Future<Either<Failure, bool>> buySubscription(
    ProductDetails productDetails,
  ) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      final response = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure('Purchase failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Restore failed: ${e.toString()}'));
    }
  }

  List<PremiumProductEntity> convertToEntities(
    List<ProductDetails> productDetails,
  ) {
    return productDetails
        .map(
          (details) =>
              PremiumProductModel.fromProductDetails(details).toEntity(),
        )
        .toList();
  }
}
