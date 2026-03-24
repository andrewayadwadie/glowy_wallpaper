import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:glowy_wallpaper/features/premium/data/models/subscription_cache_model.dart';

class PremiumLocalSource {
  final Box<String> _subscriptionCacheBox;
  final Box<String> _adFrequencyBox;

  PremiumLocalSource(this._subscriptionCacheBox, this._adFrequencyBox);

  static const String _cacheKey = 'current';
  static const String _lastAppOpenKey = 'last_app_open_shown';

  Future<Either<Exception, SubscriptionCacheModel?>>
  getCachedSubscription() async {
    try {
      final data = _subscriptionCacheBox.get(_cacheKey);
      if (data == null) {
        return const Right(null);
      }
      final jsonMap = jsonDecode(data) as Map<String, dynamic>;
      final model = SubscriptionCacheModel.fromJson(jsonMap);
      return Right(model);
    } catch (e) {
      return Left(e as Exception);
    }
  }

  Future<Either<Exception, void>> saveSubscription(
    SubscriptionCacheModel subscription,
  ) async {
    try {
      final jsonData = jsonEncode(subscription.toJson());
      await _subscriptionCacheBox.put(_cacheKey, jsonData);
      return const Right(null);
    } catch (e) {
      return Left(e as Exception);
    }
  }

  Future<Either<Exception, void>> clearSubscription() async {
    try {
      await _subscriptionCacheBox.delete(_cacheKey);
      return const Right(null);
    } catch (e) {
      return Left(e as Exception);
    }
  }

  Future<Either<Exception, DateTime?>> getLastAppOpenShown() async {
    try {
      final data = _adFrequencyBox.get(_lastAppOpenKey);
      if (data == null) {
        return const Right(null);
      }
      return Right(DateTime.parse(data));
    } catch (e) {
      return Left(e as Exception);
    }
  }

  Future<Either<Exception, void>> saveLastAppOpenShown(
    DateTime dateTime,
  ) async {
    try {
      await _adFrequencyBox.put(_lastAppOpenKey, dateTime.toIso8601String());
      return const Right(null);
    } catch (e) {
      return Left(e as Exception);
    }
  }

  Future<Either<Exception, bool>> canShowAppOpenAd({
    int minHoursBetweenAds = 4,
  }) async {
    try {
      final result = await getLastAppOpenShown();
      return result.fold((error) => Left(error), (lastShown) {
        if (lastShown == null) {
          return const Right(true);
        }
        final nextAllowedTime = lastShown.add(
          Duration(hours: minHoursBetweenAds),
        );
        return Right(DateTime.now().isAfter(nextAllowedTime));
      });
    } catch (e) {
      return Left(e as Exception);
    }
  }
}
