import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../repositories/download_repository.dart';

class DownloadWallpaperParams extends Equatable {
  final WallpaperEntity wallpaper;
  final void Function(int received, int total)? onProgress;

  const DownloadWallpaperParams({required this.wallpaper, this.onProgress});

  @override
  List<Object?> get props => [wallpaper];
}

class DownloadWallpaper extends UseCase<void, DownloadWallpaperParams> {
  final DownloadRepository repository;
  DownloadWallpaper(this.repository);

  @override
  Future<Either<Failure, void>> call(DownloadWallpaperParams params) =>
      repository.downloadWallpaper(
        params.wallpaper,
        onProgress: params.onProgress,
      );
}
