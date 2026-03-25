import 'package:equatable/equatable.dart';

enum CategoryType { image, video, classification }

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final int displayOrder;
  final int imageCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.displayOrder,
    required this.imageCount,
  });

  @override
  List<Object?> get props => [id, name, type, displayOrder, imageCount];
}
