import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/app_metadata_entity.dart';

abstract class AppRepository {
  /// Fetch bootstrap data with stale-while-revalidate.
  /// Returns cached data immediately if available, then refreshes in background.
  Future<Either<Failure, AppMetadataEntity>> getAppData();
}
