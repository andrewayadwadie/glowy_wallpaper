import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../categories/domain/entities/category_entity.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryEntity> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: AppDimens.categorySelectorHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == selectedIndex;

          return Semantics(
            button: true,
            selected: isSelected,
            label: category.name,
            child: GestureDetector(
              onTap: () => onCategorySelected(index),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  left: index == 0 ? AppDimens.paddingM : 0,
                  right: AppDimens.categoryChipGap,
                  top: AppDimens.paddingS,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.categoryChipPaddingH,
                  vertical: AppDimens.categoryChipPaddingV,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                child: AutoSizeText(
                  category.name,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
