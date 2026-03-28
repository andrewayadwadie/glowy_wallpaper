import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../utils/app_dimens.dart';
import '../utils/app_strings.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.error_outline,
                size: 64.w,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Gap(AppDimens.paddingM),
            AutoSizeText(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            Gap(AppDimens.paddingL),
            ElevatedButton(
              onPressed: onRetry,
              child: AutoSizeText(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
