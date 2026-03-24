import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/app_strings.dart';
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
    final wallpapers = all
        .map(
          (r) => WallpaperEntity(
            id: r.wallpaperId,
            title: r.title,
            imageUrl: r.imageUrl,
            thumbnailUrl: r.thumbnailUrl,
            isPremium: false,
            categoryId: '',
          ),
        )
        .toList();
    final index = all.indexOf(record);
    context.push(
      AppRoutes.wallpaperDetail.replaceFirst(':id', record.wallpaperId),
      extra: {'wallpapers': wallpapers, 'initialIndex': index},
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
              return const Center(child: CircularProgressIndicator());

            case Status.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(state.errorMessage ?? AppStrings.error),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<DownloadCubit>().loadHistory(),
                      child: const AutoSizeText(AppStrings.retry),
                    ),
                  ],
                ),
              );

            case Status.empty:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_outlined, size: 64),
                    SizedBox(height: 16),
                    AutoSizeText(AppStrings.noDownloads),
                    SizedBox(height: 8),
                    AutoSizeText(AppStrings.noDownloadsSubtitle),
                  ],
                ),
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
