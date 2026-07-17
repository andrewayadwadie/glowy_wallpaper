import 'package:flutter/material.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../domain/entities/classification_entity.dart';

class ClassificationCard extends StatelessWidget {
  final ClassificationEntity classification;
  final VoidCallback onTap;

  const ClassificationCard({
    super.key,
    required this.classification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: classification.name,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: LayoutBuilder(
            builder: (_, constraints) => AppCachedImage(
              imageUrl: classification.thumbnailUrl,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
