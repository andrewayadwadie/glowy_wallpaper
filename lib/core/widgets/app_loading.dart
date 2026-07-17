import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: Theme.of(context).colorScheme.primary,
        size: 50.w,
      ),
    );
  }

  static void show(BuildContext context) {
    context.loaderOverlay.show(widgetBuilder: (_) => const AppLoading());
  }

  static void hide(BuildContext context) {
    context.loaderOverlay.hide();
  }
}
