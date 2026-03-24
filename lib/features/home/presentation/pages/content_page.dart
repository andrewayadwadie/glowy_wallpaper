import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_wallpaper/core/enums/content_type.dart';

class ContentPage extends StatelessWidget {
  final ContentType contentType;

  const ContentPage({super.key, required this.contentType});

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

  String get _body {
    switch (contentType) {
      case ContentType.about:
        return 'Glowy Wallpapers is a curated collection of high-quality glowing, neon, and ambient wallpapers for your device.\n\nVersion 1.0.0';
      case ContentType.privacyPolicy:
        return 'Your privacy is important to us. Glowy Wallpapers collects only the minimum data necessary to provide the service. We do not sell your personal information to third parties.\n\nFor the full privacy policy, please visit our website.';
      case ContentType.termsOfUse:
        return 'By using Glowy Wallpapers, you agree to use the app for personal, non-commercial purposes only. Wallpaper images are provided for personal device use.\n\nFor full terms of use, please visit our website.';
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
        child: Text(_body, style: TextStyle(fontSize: 15.sp, height: 1.6)),
      ),
    );
  }
}
