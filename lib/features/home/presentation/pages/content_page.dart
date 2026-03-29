import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:glowy_wallpaper/core/enums/content_type.dart';
import 'package:glowy_wallpaper/core/utils/app_dimens.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';

class ContentPage extends StatelessWidget {
  final ContentType contentType;
  final String content;

  const ContentPage({
    super.key,
    required this.contentType,
    required this.content,
  });

  String get _title {
    switch (contentType) {
      case ContentType.about:
        return AppStrings.about;
      case ContentType.privacyPolicy:
        return AppStrings.privacyPolicy;
      case ContentType.termsOfUse:
        return AppStrings.termsOfUse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(_title, maxLines: 1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimens.paddingL),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ),
    );
  }
}
