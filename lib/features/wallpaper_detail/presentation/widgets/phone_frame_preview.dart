import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';

class PhoneFramePreview extends StatefulWidget {
  final String imageUrl;
  final MediaType mediaType;
  final String videoUrl;

  const PhoneFramePreview({
    super.key,
    required this.imageUrl,
    required this.mediaType,
    required this.videoUrl,
  });

  @override
  State<PhoneFramePreview> createState() => _PhoneFramePreviewState();
}

class _PhoneFramePreviewState extends State<PhoneFramePreview> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == MediaType.video) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0);
      await _controller!.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isInitialized = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frameWidth = 0.55.sw;
    final frameHeight = frameWidth * 2.05;
    final screenRadius = BorderRadius.circular(24.r);
    final isIOS = Platform.isIOS;

    return Semantics(
      button: true,
      label: AppStrings.closePreview,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.black.withAlpha(200),
          body: Center(
            child: Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: const Color(0xFF333333), width: 3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(120),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
                child: Column(
                  children: [
                    // Top notch / dynamic island
                    SizedBox(height: 8.h),
                    if (isIOS)
                      Container(
                        width: 72.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      )
                    else
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF111111),
                          shape: BoxShape.circle,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    // Screen area
                    Expanded(
                      child: ClipRRect(
                        borderRadius: screenRadius,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildWallpaper(),
                            if (isIOS)
                              _IOSHomeOverlay()
                            else
                              _AndroidHomeOverlay(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Bottom bar
                    Container(
                      width: 100.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF444444),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWallpaper() {
    if (widget.mediaType == MediaType.video) {
      if (!_isInitialized || _controller == null) {
        return const Center(
          child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
        );
      }
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    }
    return AppCachedImage(imageUrl: widget.imageUrl, fit: BoxFit.cover);
  }
}

// ---------------------------------------------------------------------------
// Android-style home screen overlay
// ---------------------------------------------------------------------------
class _AndroidHomeOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Status bar ──
        _AndroidStatusBar(),
        SizedBox(height: 10.h),

        // ── Clock + date widget ──
        _AndroidClockWidget(),
        SizedBox(height: 14.h),

        // ── Google search bar ──
        _AndroidSearchBar(),

        const Spacer(),

        // ── Dock ──
        _AndroidDock(),
        SizedBox(height: 6.h),

        // ── Navigation bar ──
        _AndroidNavBar(),
        SizedBox(height: 4.h),
      ],
    );
  }
}

class _AndroidStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: 7.sp,
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('12:30', style: style),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, color: Colors.white, size: 8.sp),
              SizedBox(width: 3.w),
              Icon(Icons.wifi, color: Colors.white, size: 8.sp),
              SizedBox(width: 3.w),
              Icon(Icons.battery_full, color: Colors.white, size: 8.sp),
            ],
          ),
        ],
      ),
    );
  }
}

class _AndroidClockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(60),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            '12:30',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w200,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Thursday, Mar 27',
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 7.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _AndroidSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.h,
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(55),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Text(
            'G',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Icon(Icons.mic_none_rounded, color: Colors.white70, size: 10.sp),
        ],
      ),
    );
  }
}

class _AndroidDock extends StatelessWidget {
  static const _icons = [
    Icons.phone,
    Icons.message_rounded,
    Icons.camera_alt_rounded,
    Icons.public_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(60),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _icons.map((icon) => _AppIcon(icon: icon)).toList(),
      ),
    );
  }
}

class _AndroidNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Container(
        height: 3.h,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(140),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// iOS-style home screen overlay
// ---------------------------------------------------------------------------
class _IOSHomeOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Status bar ──
        _IOSStatusBar(),
        SizedBox(height: 10.h),

        // ── Date + clock widget ──
        _IOSClockWidget(),
        SizedBox(height: 14.h),

        // ── Weather widget ──
        _IOSWeatherWidget(),

        const Spacer(),

        // ── Dock ──
        _IOSDock(),
        SizedBox(height: 6.h),

        // ── Home indicator ──
        _IOSHomeIndicator(),
        SizedBox(height: 4.h),
      ],
    );
  }
}

class _IOSStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: 7.sp,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('12:30', style: style),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, color: Colors.white, size: 8.sp),
              SizedBox(width: 3.w),
              Icon(Icons.wifi, color: Colors.white, size: 8.sp),
              SizedBox(width: 3.w),
              _IOSBattery(),
            ],
          ),
        ],
      ),
    );
  }
}

class _IOSBattery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14.w,
      height: 7.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 0.8),
        borderRadius: BorderRadius.circular(2.r),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(1),
      child: FractionallySizedBox(
        widthFactor: 0.75,
        heightFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(1.r),
          ),
        ),
      ),
    );
  }
}

class _IOSClockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Thursday, March 27',
          style: TextStyle(
            color: Colors.white.withAlpha(220),
            fontSize: 7.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          '12:30',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.sp,
            fontWeight: FontWeight.w300,
            height: 1.1,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _IOSWeatherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 16.sp),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 6.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Sunny',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 5.sp,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '24°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _IOSDock extends StatelessWidget {
  static const _icons = [
    Icons.phone,
    Icons.chat_bubble_rounded,
    Icons.public_rounded,
    Icons.music_note_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _icons.map((icon) => _AppIcon(icon: icon)).toList(),
      ),
    );
  }
}

class _IOSHomeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Container(
        height: 3.h,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(140),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared app icon used by both platform docks
// ---------------------------------------------------------------------------
class _AppIcon extends StatelessWidget {
  final IconData icon;

  const _AppIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, color: Colors.white, size: 12.sp),
    );
  }
}
