import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/classification_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../datasources/category_local_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final CategoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      // Stale-while-revalidate: return cache immediately, refresh in background
      final cachedCategories = await localDataSource.getCachedCategories();

      if (cachedCategories != null) {
        final entities = cachedCategories.map((m) => m.toEntity()).toList();

        // If cache is stale, refresh in background
        if (localDataSource.isCacheStale() && await networkInfo.isConnected) {
          _refreshCategoriesInBackground();
        }

        return Right(entities);
      }

      // No cache — must fetch from network
      if (await networkInfo.isConnected) {
        final remoteCategories = await remoteDataSource.getCategories();
        await localDataSource.cacheCategories(remoteCategories);
        return Right(remoteCategories.map((m) => m.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return Left(ServerFailure('Request cancelled'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(CacheFailure('Cache error occurred'));
    }
  }

  Future<void> _refreshCategoriesInBackground() async {
    try {
      final remoteCategories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(remoteCategories);
    } catch (_) {
      // Silently fail — stale cache is still being served
    }
  }

  @override
  Future<Either<Failure, List<ClassificationEntity>>> getClassifications(
    String categoryId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final classifications = await remoteDataSource.getClassifications(
        categoryId,
      );
      return Right(classifications.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return Left(ServerFailure('Request cancelled'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Server error'));
    }
  }
}
