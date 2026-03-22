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
    final rows = <Widget>[];
    int i = 0;

    while (i < classifications.length) {
      // Large card (full width)
      final largeIndex = i;
      rows.add(
        ClassificationCard(
          classification: classifications[largeIndex],
          onTap: () => onClassificationTapped(classifications[largeIndex]),
          height: AppDimens.bentoLargeCardHeight,
        ),
      );
      i++;

      // Row of 2 small cards
      if (i < classifications.length) {
        final smallCards = <Widget>[];
        for (int j = 0; j < 2 && i < classifications.length; j++, i++) {
          final smallIndex = i;
          smallCards.add(
            Expanded(
              child: ClassificationCard(
                classification: classifications[smallIndex],
                onTap: () =>
                    onClassificationTapped(classifications[smallIndex]),
                height: AppDimens.bentoSmallCardHeight,
              ),
            ),
          );
          if (j == 0 && i + 1 < classifications.length) {
            smallCards.add(SizedBox(width: AppDimens.bentoCardGap));
          }
        }
        rows.add(Row(children: smallCards));
      }
    }

    return ListView.separated(
      itemCount: rows.length,
      itemBuilder: (_, index) => rows[index],
      separatorBuilder: (_, _) => SizedBox(height: AppDimens.bentoCardGap),
      padding: EdgeInsets.all(AppDimens.paddingM),
    );
  }
}
