import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_strings.dart';

class DetailActionBar extends StatelessWidget {
  final bool isFavorite;
  final bool isDownloading;
  final double downloadProgress;
  final bool isToggling;
  final VoidCallback onDownload;
  final VoidCallback onFavorite;
  final VoidCallback onPreview;

  const DetailActionBar({
    super.key,
    required this.isFavorite,
    required this.isDownloading,
    required this.downloadProgress,
    required this.isToggling,
    required this.onDownload,
    required this.onFavorite,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(100),
            Colors.black,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: isDownloading
                ? null
                : const Icon(Icons.download_rounded, color: Colors.white),
            label: AppStrings.download,
            onTap: isDownloading ? null : onDownload,
            child: isDownloading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      value: downloadProgress > 0 ? downloadProgress : null,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : null,
          ),
          _ActionButton(
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            label: isFavorite
                ? AppStrings.removeFromFavorites
                : AppStrings.addToFavorites,
            onTap: isToggling ? null : onFavorite,
          ),
          _ActionButton(
            icon: const Icon(Icons.phone_android_rounded, color: Colors.white),
            label: AppStrings.previewOnPhone,
            onTap: onPreview,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Icon? icon;
  final Widget? child;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    this.icon,
    this.child,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child ?? icon ?? const SizedBox.shrink(),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
