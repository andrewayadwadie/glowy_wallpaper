import 'package:flutter/material.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../domain/entities/classification_entity.dart';
import 'classification_card.dart';

class ClassificationBentoGrid extends StatelessWidget {
  final List<ClassificationEntity> classifications;
  final ValueChanged<ClassificationEntity> onClassificationTapped;

  const ClassificationBentoGrid({
    super.key,
    required this.classifications,
    required this.onClassificationTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(AppDimens.paddingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.bentoCardGap,
        mainAxisSpacing: AppDimens.bentoCardGap,
        childAspectRatio: 1,
      ),
      itemCount: classifications.length,
      itemBuilder: (_, index) => ClassificationCard(
        classification: classifications[index],
        onTap: () => onClassificationTapped(classifications[index]),
      ),
    );
  }
}
