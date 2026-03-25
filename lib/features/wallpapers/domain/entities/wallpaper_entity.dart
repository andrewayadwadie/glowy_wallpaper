import 'package:equatable/equatable.dart';

enum MediaType { image, video }

class WallpaperEntity extends Equatable {
  final String id;
  final String url;
  final String thumbUrl;
  final bool isTopRated;
  final MediaType mediaType;
  final String? classificationId;
  final String? classificationName;
  final String? classificationThumbnailUrl;
  final DateTime createdAt;

  const WallpaperEntity({
    required this.id,
    required this.url,
    required this.thumbUrl,
    required this.isTopRated,
    required this.mediaType,
    this.classificationId,
    this.classificationName,
    this.classificationThumbnailUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    url,
    thumbUrl,
    isTopRated,
    mediaType,
    classificationId,
    classificationName,
    classificationThumbnailUrl,
    createdAt,
  ];
}
