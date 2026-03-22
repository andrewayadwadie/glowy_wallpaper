import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        throw const NetworkException('No internet connection');
      }

      final response = await remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );

      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        throw const NetworkException('No internet connection');
      }

      final response = await remoteDataSource.register(
        RegisterRequestModel(
          displayName: displayName,
          email: email,
          password: password,
        ),
      );

      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      // Local-first: ignore remote errors, always clear local data
    } finally {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> validateToken() async {
    try {
      if (!(await hasToken())) {
        return const Right(false);
      }

      final response = await remoteDataSource.getSubscriptionStatus();

      if (response.isPremium) {
        return const Right(true);
      } else {
        return const Right(false);
      }
    } on UnauthorizedException {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await localDataSource.clearToken();
        await localDataSource.clearUser();
        return const Right(false);
      }

      // Try cached user on network errors
      final cachedUserResult = await getCachedUser();
      return cachedUserResult.fold(
        (failure) => const Right(false),
        (user) => Right(user?.isPremium ?? false),
      );
    } on NetworkException {
      final cachedUserResult = await getCachedUser();
      return cachedUserResult.fold(
        (failure) => const Right(false),
        (user) => Right(user?.isPremium ?? false),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user?.toEntity());
    } catch (e) {
      return const Left(CacheFailure('Failed to get cached user'));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribe() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        throw const NetworkException('No internet connection');
      }

      await remoteDataSource.unsubscribe();
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<bool> hasToken() async {
    return await localDataSource.hasToken();
  }
}
