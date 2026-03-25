import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/entities/download_record_entity.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_local_data_source.dart';
import '../datasources/gallery_data_source.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadLocalDataSource _localDataSource;
  final GalleryDataSource _galleryDataSource;
  final Dio _dio;

  DownloadRepositoryImpl(
    this._localDataSource,
    this._galleryDataSource,
    this._dio,
  );

  @override
  Future<Either<Failure, void>> downloadWallpaper(
    WallpaperEntity wallpaper, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final hasPermission = await _galleryDataSource.requestPermission();
      if (!hasPermission) {
        return Left(CacheFailure('Storage permission denied'));
      }

      final url = wallpaper.url;
      final isVideo = wallpaper.mediaType == MediaType.video;

      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onProgress,
      );

      if (response.data == null) {
        return Left(ServerFailure('Download failed: empty response'));
      }

      final bytes = Uint8List.fromList(response.data!);
      if (isVideo) {
        await _galleryDataSource.putVideoBytes(
          bytes,
          name: 'wallpaper_${wallpaper.id}',
        );
      } else {
        await _galleryDataSource.putImageBytes(
          bytes,
          name: 'wallpaper_${wallpaper.id}',
        );
      }

      final record = DownloadRecordEntity(
        wallpaperId: wallpaper.id,
        imageUrl: wallpaper.url,
        thumbnailUrl: wallpaper.thumbUrl,
        title: wallpaper.id,
        downloadedAt: DateTime.now(),
        fileType: isVideo ? WallpaperFileType.video : WallpaperFileType.image,
      );
      await _localDataSource.saveRecord(record);

      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Download failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DownloadRecordEntity>>>
  getDownloadHistory() async {
    try {
      final records = await _localDataSource.getAll();
      return Right(records);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isDownloaded(String wallpaperId) async {
    try {
      final result = await _localDataSource.isDownloaded(wallpaperId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
