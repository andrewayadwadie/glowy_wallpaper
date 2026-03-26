import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_empty_state_widget.dart';
import '../../../../core/widgets/app_shimmer_widget.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallpapers/domain/entities/wallpaper_entity.dart';
import '../../domain/entities/download_record_entity.dart';
import '../cubit/download_cubit.dart';
import '../cubit/download_state.dart';
import '../widgets/downloads_grid.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DownloadCubit>().loadHistory();
  }

  void _onDownloadTapped(
    DownloadRecordEntity record,
    List<DownloadRecordEntity> all,
  ) {
    // Build minimal WallpaperEntity list from download records for navigation
    final categoryType = record.fileType == WallpaperFileType.video
        ? CategoryType.video
        : CategoryType.image;
    final wallpapers = all
        .map(
          (r) => WallpaperEntity(
            id: r.wallpaperId,
            url: r.imageUrl,
            thumbUrl: r.thumbnailUrl,
            isTopRated: false,
            mediaType: r.fileType == WallpaperFileType.video
                ? MediaType.video
                : MediaType.image,
            classificationId: null,
            classificationName: null,
            classificationThumbnailUrl: null,
            createdAt: r.downloadedAt,
          ),
        )
        .toList();
    final index = all.indexOf(record);
    context.push(
      AppRoutes.wallpaperDetail.replaceFirst(':id', record.wallpaperId),
      extra: {
        'wallpapers': wallpapers,
        'initialIndex': index,
        'categoryType': categoryType,
        'classificationId': null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AutoSizeText(AppStrings.myDownloads)),
      body: BlocBuilder<DownloadCubit, DownloadState>(
        builder: (context, state) {
          switch (state.historyStatus) {
            case Status.loading:
              return AppShimmerWidget(
                child: GridView.builder(
                  padding: EdgeInsets.all(AppDimens.paddingM),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimens.paddingS,
                    mainAxisSpacing: AppDimens.paddingS,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              );

            case Status.error:
              return AppErrorWidget(
                message: state.errorMessage ?? AppStrings.error,
                onRetry: () => context.read<DownloadCubit>().loadHistory(),
              );

            case Status.empty:
              return AppEmptyStateWidget(
                title: AppStrings.noDownloads,
                message: AppStrings.noDownloadsSubtitle,
                icon: Icons.download_outlined,
              );

            case Status.success:
              return DownloadsGrid(
                downloads: state.history,
                onTap: (record) => _onDownloadTapped(record, state.history),
              );
          }
        },
      ),
    );
  }
}
