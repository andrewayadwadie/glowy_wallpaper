import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../categories/domain/entities/category_entity.dart';
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
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../../../core/ads/managers/interstitial_ad_manager.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_loading.dart';

class WallpaperDetailPage extends StatefulWidget {
  final List<WallpaperEntity> wallpapers;
  final int initialIndex;
  final String? categoryId;
  final CategoryType categoryType;
  final String? classificationId;
  final bool showAppBarActions;

  const WallpaperDetailPage({
    super.key,
    required this.wallpapers,
    required this.initialIndex,
    this.categoryId,
    required this.categoryType,
    this.classificationId,
    this.showAppBarActions = true,
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
          return LoaderOverlay(
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.black,
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: AutoSizeText(
                    "${state.currentIndex + 1}/${state.wallpapers.length}",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    if (widget.showAppBarActions &&
                        state.wallpapers.isNotEmpty &&
                        state.wallpapers[state.currentIndex].mediaType ==
                            MediaType.video)
                      IconButton(
                        icon: Icon(
                          state.isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                        ),
                        tooltip: state.isMuted
                            ? AppStrings.unmute
                            : AppStrings.mute,
                        onPressed: () =>
                            context.read<WallpaperDetailCubit>().toggleMute(),
                      ),
                    if (widget.showAppBarActions && state.wallpapers.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                        ),
                        tooltip: AppStrings.similarWallpapers,
                        onPressed: () {
                          final cubit = context.read<WallpaperDetailCubit>();
                          cubit.loadSimilarWallpapers(
                            widget.categoryId ?? '',
                            widget.categoryType,
                            widget.classificationId ?? "",
                          );
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
                                  buildWhen: (prev, curr) =>
                                      prev.similarWallpapers !=
                                          curr.similarWallpapers ||
                                      prev.similarWallpapersStatus !=
                                          curr.similarWallpapersStatus,
                                  builder: (_, s) => SimilarWallpapersSheet(
                                    wallpapers: s.similarWallpapers,
                                    isLoading:
                                        s.similarWallpapersStatus ==
                                        Status.loading,
                                    errorMessage:
                                        s.similarWallpapersStatus ==
                                            Status.error
                                        ? s.errorMessage
                                        : null,
                                    onTap: (wallpaper) {
                                      Navigator.pop(context);
                                      cubit.switchToSimilarContext(
                                        s.similarWallpapers,
                                        s.similarWallpapers.indexOf(wallpaper),
                                      );
                                    },
                                    onRetry: () => cubit.loadSimilarWallpapers(
                                      widget.categoryId ?? '',
                                      widget.categoryType,
                                      widget.classificationId ?? "",
                                    ),
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
                      onPageChanged: (index) => context
                          .read<WallpaperDetailCubit>()
                          .onPageChanged(index),
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
                            // Cold-start rewarded-ad wait (~5s max): spinkit
                            // overlay while the gate resolves (US1, R3).
                            if (downloadState.isAdGateActive) {
                              AppLoading.show(context);
                            } else if (context.loaderOverlay.visible) {
                              AppLoading.hide(context);
                            }
                            if (downloadState.successMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(downloadState.successMessage!),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              context.read<DownloadCubit>().clearMessages();
                            } else if (downloadState.errorMessage != null) {
                              if (downloadState.errorMessage ==
                                  'permission_permanently_denied') {
                                context.read<DownloadCubit>().clearMessages();
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text(
                                      AppStrings.permissionRequired,
                                    ),
                                    content: Text(
                                      AppStrings.permissionPermanentlyDenied,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          ph.openAppSettings();
                                        },
                                        child: const Text('Open Settings'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
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
                                  downloadProgress:
                                      downloadState.downloadProgress,
                                  isToggling: favState.isToggling,
                                  onDownload: currentWallpaper == null
                                      ? () {}
                                      : () => context
                                            .read<DownloadCubit>()
                                            .download(currentWallpaper),
                                  onFavorite: currentWallpaper == null
                                      ? () {}
                                      : () {
                                          if (favState.isToggling) return;
                                          if (favState.isFavorite) {
                                            // Removing favorite — no ad
                                            context
                                                .read<FavoriteCubit>()
                                                .toggle(currentWallpaper);
                                          } else {
                                            // Adding favorite — show interstitial
                                            sl<InterstitialAdManager>()
                                                .showOnAction(
                                                  onComplete: () {
                                                    context
                                                        .read<FavoriteCubit>()
                                                        .toggle(
                                                          currentWallpaper,
                                                        );
                                                  },
                                                );
                                          }
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
                                              pageBuilder:
                                                  (
                                                    ctx,
                                                    anim,
                                                    secondary,
                                                  ) => PhoneFramePreview(
                                                    imageUrl:
                                                        currentWallpaper.url,
                                                    mediaType: currentWallpaper
                                                        .mediaType,
                                                    videoUrl:
                                                        currentWallpaper.url,
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
              ),
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
    if (wallpaper.mediaType == MediaType.video && isCurrentPage) {
      return _VideoPage(cubit: cubit, wallpaper: wallpaper);
    }
    return Hero(
      tag: 'wallpaper_${wallpaper.id}',
      child: AppCachedImage(
        imageUrl: wallpaper.url,
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
          imageUrl: widget.wallpaper.thumbUrl,
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
