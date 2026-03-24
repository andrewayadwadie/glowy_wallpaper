import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../auth/presentation/cubit/subscription_cubit.dart';
import '../../../auth/presentation/cubit/subscription_state.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../cubit/wallpaper_detail_cubit.dart';
import '../cubit/wallpaper_detail_state.dart';
import '../widgets/detail_action_bar.dart';
import '../widgets/phone_frame_preview.dart';
import '../widgets/similar_wallpapers_sheet.dart';
import '../../../downloads/presentation/cubit/download_cubit.dart';
import '../../../downloads/presentation/cubit/download_state.dart';
import '../../../favorites/presentation/cubit/favorite_cubit.dart';
import '../../../favorites/presentation/cubit/favorite_state.dart';

class WallpaperDetailPage extends StatefulWidget {
  final List<WallpaperEntity> wallpapers;
  final int initialIndex;

  const WallpaperDetailPage({
    super.key,
    required this.wallpapers,
    required this.initialIndex,
  });

  @override
  State<WallpaperDetailPage> createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WallpaperDetailCubit, WallpaperDetailState>(
      listenWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
      listener: (context, state) {
        if (state.wallpapers.isNotEmpty) {
          context.read<FavoriteCubit>().checkIsFavorite(
            state.wallpapers[state.currentIndex].id,
          );
        }
      },
      child: BlocBuilder<WallpaperDetailCubit, WallpaperDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (state.wallpapers.isNotEmpty &&
                    state.wallpapers[state.currentIndex].videoUrl != null)
                  IconButton(
                    icon: Icon(
                      state.isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        context.read<WallpaperDetailCubit>().toggleMute(),
                  ),
                if (state.wallpapers.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                    ),
                    tooltip: AppStrings.similarWallpapers,
                    onPressed: () {
                      final cubit = context.read<WallpaperDetailCubit>();
                      final wallpaperId =
                          state.wallpapers[state.currentIndex].id;
                      cubit.loadSimilarWallpapers(wallpaperId);
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            BlocBuilder<
                              WallpaperDetailCubit,
                              WallpaperDetailState
                            >(
                              bloc: cubit,
                              builder: (_, s) => SimilarWallpapersSheet(
                                wallpapers: s.similarWallpapers,
                                isLoading:
                                    s.similarWallpapersStatus == Status.loading,
                                errorMessage:
                                    s.similarWallpapersStatus == Status.error
                                    ? s.errorMessage
                                    : null,
                                onTap: (wallpaper) {
                                  Navigator.pop(context);
                                  cubit.switchToSimilarContext(
                                    s.similarWallpapers,
                                    s.similarWallpapers.indexOf(wallpaper),
                                  );
                                },
                                onRetry: () =>
                                    cubit.loadSimilarWallpapers(wallpaperId),
                              ),
                            ),
                      );
                    },
                  ),
              ],
            ),
            body: Stack(
              children: [
                PageView.builder(
                  itemCount: state.wallpapers.length,
                  controller: _pageController,
                  onPageChanged: (index) =>
                      context.read<WallpaperDetailCubit>().onPageChanged(index),
                  itemBuilder: (context, index) {
                    final wallpaper = state.wallpapers[index];
                    return _WallpaperPage(
                      wallpaper: wallpaper,
                      cubit: context.read<WallpaperDetailCubit>(),
                      isCurrentPage: index == state.currentIndex,
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: BlocConsumer<DownloadCubit, DownloadState>(
                      listener: (context, downloadState) {
                        if (downloadState.successMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(downloadState.successMessage!),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          context.read<DownloadCubit>().clearMessages();
                        } else if (downloadState.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(downloadState.errorMessage!),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          context.read<DownloadCubit>().clearMessages();
                        }
                      },
                      builder: (context, downloadState) {
                        final currentWallpaper = state.wallpapers.isNotEmpty
                            ? state.wallpapers[state.currentIndex]
                            : null;
                        return BlocBuilder<FavoriteCubit, FavoriteState>(
                          builder: (context, favState) {
                            return DetailActionBar(
                              isFavorite: favState.isFavorite,
                              isDownloading: downloadState.isDownloading,
                              downloadProgress: downloadState.downloadProgress,
                              onDownload: currentWallpaper == null
                                  ? () {}
                                  : () => context
                                        .read<DownloadCubit>()
                                        .download(currentWallpaper),
                              onFavorite: currentWallpaper == null
                                  ? () {}
                                  : () {
                                      final subState = context
                                          .read<SubscriptionCubit>()
                                          .state;
                                      final userId =
                                          subState is SubscriptionPremium
                                          ? subState.user.id
                                          : null;
                                      context.read<FavoriteCubit>().toggle(
                                        currentWallpaper,
                                        userId,
                                      );
                                    },
                              onPreview: currentWallpaper == null
                                  ? () {}
                                  : () {
                                      context
                                          .read<WallpaperDetailCubit>()
                                          .logPreviewWallpaper(
                                            currentWallpaper.id,
                                          );
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          opaque: false,
                                          pageBuilder: (ctx, anim, secondary) =>
                                              PhoneFramePreview(
                                                imageUrl:
                                                    currentWallpaper.imageUrl,
                                              ),
                                        ),
                                      );
                                    },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WallpaperPage extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final WallpaperDetailCubit cubit;
  final bool isCurrentPage;

  const _WallpaperPage({
    required this.wallpaper,
    required this.cubit,
    required this.isCurrentPage,
  });

  @override
  Widget build(BuildContext context) {
    if (wallpaper.videoUrl != null && isCurrentPage) {
      return _VideoPage(cubit: cubit, wallpaper: wallpaper);
    }
    return Hero(
      tag: 'wallpaper_${wallpaper.id}',
      child: AppCachedImage(
        imageUrl: wallpaper.imageUrl,
        width: 1.sw,
        height: 1.sh,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _VideoPage extends StatefulWidget {
  final WallpaperDetailCubit cubit;
  final WallpaperEntity wallpaper;

  const _VideoPage({required this.cubit, required this.wallpaper});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    final controller = widget.cubit.videoController;
    if (controller == null) return;
    _controller = controller;
    if (!controller.value.isInitialized) {
      controller.addListener(_onControllerUpdate);
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
    if (_controller?.value.isInitialized == true) {
      _controller?.removeListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Hero(
        tag: 'wallpaper_${widget.wallpaper.id}',
        child: AppCachedImage(
          imageUrl: widget.wallpaper.thumbnailUrl,
          width: 1.sw,
          height: 1.sh,
          fit: BoxFit.cover,
        ),
      );
    }
    return Hero(
      tag: 'wallpaper_${widget.wallpaper.id}',
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
