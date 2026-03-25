import 'package:equatable/equatable.dart';

class ClassificationEntity extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String thumbnailUrl;
  final int itemCount;

  const ClassificationEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.thumbnailUrl,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [id, categoryId, name, thumbnailUrl, itemCount];
}
