import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_metadata_entity.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/bootstrap_remote_data_source.dart';
import '../datasources/bootstrap_local_data_source.dart';

class AppRepositoryImpl implements AppRepository {
  final BootstrapRemoteDataSource remoteDataSource;
  final BootstrapLocalDataSource localDataSource;

  /// Called when a background refresh completes with fresh app metadata.
  void Function(AppMetadataEntity)? onMetadataRefreshed;

  AppRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AppMetadataEntity>> getAppData() async {
    // Try cache first (stale-while-revalidate)
    try {
      final cached = localDataSource.getAppMetadata();
      if (cached != null) {
        final entity = cached.toEntity();
        _refreshInBackground();
        return Right(entity);
      }
    } catch (_) {
      // Cache corrupted — fall through to network fetch
    }

    // No cache or cache failed — fetch from network
    try {
      final model = await remoteDataSource.getAppData();
      try {
        await localDataSource.saveAppMetadata(model);
      } catch (_) {
        // Cache write failed — non-critical, data still returns
      }
      return Right(model.toEntity());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure('No internet connection'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Failed to load app data'));
    }
  }

  void _refreshInBackground() {
    remoteDataSource.getAppData().then((model) async {
      await localDataSource.saveAppMetadata(model);
      onMetadataRefreshed?.call(model.toEntity());
    }).catchError((_) {
      // Silently fail — stale cache continues to serve
    });
  }
}
