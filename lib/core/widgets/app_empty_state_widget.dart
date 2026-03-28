import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../utils/app_dimens.dart';

class AppEmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;

  const AppEmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.image_not_supported_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: 64.w,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
              ),
            ),
            Gap(AppDimens.paddingM),
            if (title != null) ...[
              AutoSizeText(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              Gap(AppDimens.paddingS),
            ],
            AutoSizeText(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
