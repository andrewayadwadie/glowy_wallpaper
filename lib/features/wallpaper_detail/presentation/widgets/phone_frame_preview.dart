import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_cached_image.dart';

class PhoneFramePreview extends StatelessWidget {
  final String imageUrl;

  const PhoneFramePreview({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withAlpha(200),
        body: Center(
          child: SizedBox(
            width: 0.55.sw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Phone frame image — defines the coordinate space
                Image.asset(
                  AppAssets.phoneFrame,
                  width: 0.55.sw,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) =>
                      const SizedBox.shrink(),
                ),
                // Wallpaper scaled inside the frame's screen area
                // Positioned as a fraction of the frame widget, not the screen
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(0.0, -0.04),
                    child: FractionallySizedBox(
                      widthFactor: 0.76,
                      heightFactor: 0.70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: AppCachedImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
