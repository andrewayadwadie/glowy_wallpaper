import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_wallpaper/core/enums/content_type.dart';

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
        return 'About';
      case ContentType.privacyPolicy:
        return 'Privacy Policy';
      case ContentType.termsOfUse:
        return 'Terms of Use';
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
        padding: EdgeInsets.all(20.w),
        child: Text(content, style: TextStyle(fontSize: 15.sp, height: 1.6)),
      ),
    );
  }
}
