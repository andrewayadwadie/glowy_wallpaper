import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../domain/entities/classification_entity.dart';

class ClassificationCard extends StatelessWidget {
  final ClassificationEntity classification;
  final VoidCallback onTap;
  final double height;

  const ClassificationCard({
    super.key,
    required this.classification,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppCachedImage(
                imageUrl: classification.thumbnailUrl,
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(140)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: AppDimens.paddingM,
                bottom: AppDimens.paddingM,
                right: AppDimens.paddingM,
                child: AutoSizeText(
                  classification.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
