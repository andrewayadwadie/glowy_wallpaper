import 'package:equatable/equatable.dart';

enum CategoryType { image, video, classification }

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final String? thumbnailUrl;
  final int displayOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.thumbnailUrl,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [id, name, type, thumbnailUrl, displayOrder];
}
