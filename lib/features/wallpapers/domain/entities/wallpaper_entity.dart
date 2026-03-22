import 'package:equatable/equatable.dart';

class WallpaperEntity extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String thumbnailUrl;
  final String? videoUrl;
  final bool isPremium;
  final String categoryId;
  final List<String> classificationIds;

  const WallpaperEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.videoUrl,
    required this.isPremium,
    required this.categoryId,
    this.classificationIds = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    imageUrl,
    thumbnailUrl,
    videoUrl,
    isPremium,
    categoryId,
    classificationIds,
  ];
}
