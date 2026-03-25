import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../domain/entities/wallpaper_entity.dart';

class VideoThumbnail extends StatefulWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;
  final bool shouldAutoPlay;

  const VideoThumbnail({
    super.key,
    required this.wallpaper,
    required this.onTap,
    required this.shouldAutoPlay,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.shouldAutoPlay && widget.wallpaper.mediaType == MediaType.video) {
      _initializeController();
    }
  }

  void _initializeController() {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.wallpaper.url))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _controller!.setLooping(true);
              _controller!.setVolume(0.0);
              _controller!.play();
            }
          });
  }

  @override
  void didUpdateWidget(VideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldAutoPlay != widget.shouldAutoPlay) {
      if (widget.shouldAutoPlay && _controller != null) {
        _controller!.play();
      } else if (!widget.shouldAutoPlay && _controller != null) {
        _controller!.pause();
      } else if (widget.shouldAutoPlay &&
          _controller == null &&
          widget.wallpaper.mediaType == MediaType.video) {
        _initializeController();
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
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null &&
                _controller!.value.isInitialized &&
                widget.shouldAutoPlay)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              AppCachedImage(
                imageUrl: widget.wallpaper.thumbUrl,
                fit: BoxFit.cover,
              ),
            if (!widget.shouldAutoPlay ||
                _controller == null ||
                !_controller!.value.isInitialized)
              Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 40.sp,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
