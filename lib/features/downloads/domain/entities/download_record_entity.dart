import 'package:equatable/equatable.dart';

enum WallpaperFileType { image, video }

class DownloadRecordEntity extends Equatable {
  final String wallpaperId;
  final String imageUrl;
  final String thumbnailUrl;
  final String title;
  final DateTime downloadedAt;
  final WallpaperFileType fileType;
  final bool isTopRated;

  const DownloadRecordEntity({
    required this.wallpaperId,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.downloadedAt,
    required this.fileType,
    this.isTopRated = false,
  });

  @override
  List<Object?> get props => [
    wallpaperId,
    imageUrl,
    thumbnailUrl,
    title,
    downloadedAt,
    fileType,
    isTopRated,
  ];
}
