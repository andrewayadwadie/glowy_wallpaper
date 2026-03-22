import 'package:equatable/equatable.dart';

class ClassificationEntity extends Equatable {
  final String id;
  final String name;
  final String thumbnailUrl;
  final int wallpaperCount;

  const ClassificationEntity({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.wallpaperCount,
  });

  @override
  List<Object?> get props => [id, name, thumbnailUrl, wallpaperCount];
}
