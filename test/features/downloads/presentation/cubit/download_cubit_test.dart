import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/ads/managers/rewarded_ad_manager.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/network/network_info.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/downloads/domain/usecases/download_wallpaper.dart';
import 'package:glowy_wallpaper/features/downloads/domain/usecases/get_download_history.dart';
import 'package:glowy_wallpaper/features/downloads/presentation/cubit/download_cubit.dart';
import 'package:glowy_wallpaper/features/downloads/presentation/cubit/download_state.dart';
import 'package:glowy_wallpaper/features/wallpapers/domain/entities/wallpaper_entity.dart';

class MockDownloadWallpaper extends Mock implements DownloadWallpaper {}

class MockGetDownloadHistory extends Mock implements GetDownloadHistory {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockRewardedAdManager extends Mock implements RewardedAdManager {}

final _wallpaper = WallpaperEntity(
  id: 'test_id',
  url: 'https://example.com/image.jpg',
  thumbUrl: 'https://example.com/thumb.jpg',
  isTopRated: false,
  mediaType: MediaType.image,
  createdAt: DateTime(2024),
);

void main() {
  late MockDownloadWallpaper mockDownloadWallpaper;
  late MockGetDownloadHistory mockGetDownloadHistory;
  late MockNetworkInfo mockNetworkInfo;
  late MockRewardedAdManager mockRewardedAdManager;

  setUp(() {
    mockDownloadWallpaper = MockDownloadWallpaper();
    mockGetDownloadHistory = MockGetDownloadHistory();
    mockNetworkInfo = MockNetworkInfo();
    mockRewardedAdManager = MockRewardedAdManager();

    registerFallbackValue(NoParams());
    registerFallbackValue(DownloadWallpaperParams(wallpaper: _wallpaper));
  });

  /// Stubs the rewarded gate to grant the reward immediately (ad watched,
  /// premium, or network-degraded — all grant paths look the same here).
  void stubAdGateGrants() {
    when(
      () => mockRewardedAdManager.showRewardedForDownload(
        onRewardGranted: any(named: 'onRewardGranted'),
        onDismissedWithoutReward: any(named: 'onDismissedWithoutReward'),
      ),
    ).thenAnswer((invocation) async {
      final grant = invocation.namedArguments[#onRewardGranted] as VoidCallback;
      grant();
    });
  }

  /// Stubs the rewarded gate to report an early dismissal without reward.
  void stubAdGateDismisses() {
    when(
      () => mockRewardedAdManager.showRewardedForDownload(
        onRewardGranted: any(named: 'onRewardGranted'),
        onDismissedWithoutReward: any(named: 'onDismissedWithoutReward'),
      ),
    ).thenAnswer((invocation) async {
      final dismiss =
          invocation.namedArguments[#onDismissedWithoutReward] as VoidCallback?;
      dismiss?.call();
    });
  }

  DownloadCubit buildCubit() => DownloadCubit(
    downloadWallpaper: mockDownloadWallpaper,
    getDownloadHistory: mockGetDownloadHistory,
    networkInfo: mockNetworkInfo,
    rewardedAdManager: mockRewardedAdManager,
  );

  group('connectivity guard', () {
    blocTest<DownloadCubit, DownloadState>(
      'emits errorMessage when offline; ad gate never invoked',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => [
        isA<DownloadState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          AppStrings.networkUnavailable,
        ),
      ],
      verify: (_) {
        verifyNever(() => mockDownloadWallpaper(any()));
        verifyNever(
          () => mockRewardedAdManager.showRewardedForDownload(
            onRewardGranted: any(named: 'onRewardGranted'),
            onDismissedWithoutReward: any(named: 'onDismissedWithoutReward'),
          ),
        );
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'proceeds past connectivity check when online',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        stubAdGateGrants();
        when(
          () => mockDownloadWallpaper(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => [
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          true,
        ),
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          false,
        ),
        isA<DownloadState>().having(
          (s) => s.isDownloading,
          'isDownloading',
          true,
        ),
        isA<DownloadState>().having(
          (s) => s.isDownloading,
          'isDownloading',
          false,
        ),
      ],
    );
  });

  group('duplicate download guard', () {
    blocTest<DownloadCubit, DownloadState>(
      'ignores second download tap while download in progress',
      build: buildCubit,
      seed: () => const DownloadState(isDownloading: true),
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => <DownloadState>[],
      verify: (_) {
        verifyNever(() => mockNetworkInfo.isConnected);
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'ignores second download tap while the ad gate is resolving',
      build: buildCubit,
      seed: () => const DownloadState(isAdGateActive: true),
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => <DownloadState>[],
      verify: (_) {
        verifyNever(() => mockNetworkInfo.isConnected);
      },
    );
  });

  group('rewarded ad gate (US1)', () {
    blocTest<DownloadCubit, DownloadState>(
      'reward granted: download runs',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        stubAdGateGrants();
        when(
          () => mockDownloadWallpaper(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => [
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          true,
        ),
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          false,
        ),
        isA<DownloadState>().having(
          (s) => s.isDownloading,
          'isDownloading',
          true,
        ),
        isA<DownloadState>()
            .having((s) => s.isDownloading, 'isDownloading', false)
            .having(
              (s) => s.successMessage,
              'successMessage',
              AppStrings.wallpaperSaved,
            ),
      ],
      verify: (_) {
        verify(() => mockDownloadWallpaper(any())).called(1);
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'dismissed without reward: no download (FR-004)',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        stubAdGateDismisses();
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => [
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          true,
        ),
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          false,
        ),
      ],
      verify: (_) {
        verifyNever(() => mockDownloadWallpaper(any()));
      },
    );
  });

  group('download failure', () {
    blocTest<DownloadCubit, DownloadState>(
      'emits errorMessage on download failure',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        stubAdGateGrants();
        when(
          () => mockDownloadWallpaper(any()),
        ).thenAnswer((_) async => Left(NetworkFailure('Download failed')));
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => [
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          true,
        ),
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          false,
        ),
        isA<DownloadState>().having(
          (s) => s.isDownloading,
          'isDownloading',
          true,
        ),
        isA<DownloadState>()
            .having((s) => s.isDownloading, 'isDownloading', false)
            .having((s) => s.errorMessage, 'errorMessage', 'Download failed'),
      ],
    );

    blocTest<DownloadCubit, DownloadState>(
      'emits permission_permanently_denied error message when gallery permission permanently denied',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        stubAdGateGrants();
        when(() => mockDownloadWallpaper(any())).thenAnswer(
          (_) async => Left(CacheFailure('permission_permanently_denied')),
        );
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => [
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          true,
        ),
        isA<DownloadState>().having(
          (s) => s.isAdGateActive,
          'isAdGateActive',
          false,
        ),
        isA<DownloadState>().having(
          (s) => s.isDownloading,
          'isDownloading',
          true,
        ),
        isA<DownloadState>()
            .having((s) => s.isDownloading, 'isDownloading', false)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'permission_permanently_denied',
            ),
      ],
    );
  });

  group('clearMessages', () {
    blocTest<DownloadCubit, DownloadState>(
      'clears error and success messages',
      build: buildCubit,
      seed: () => const DownloadState(
        errorMessage: 'some error',
        successMessage: 'some success',
      ),
      act: (cubit) => cubit.clearMessages(),
      expect: () => [
        isA<DownloadState>()
            .having((s) => s.errorMessage, 'errorMessage', isNull)
            .having((s) => s.successMessage, 'successMessage', isNull),
      ],
    );
  });
}
