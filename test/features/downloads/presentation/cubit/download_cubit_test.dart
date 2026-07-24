import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/core/errors/failure.dart';
import 'package:glowy_wallpaper/core/network/network_info.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/downloads/domain/entities/download_event.dart';
import 'package:glowy_wallpaper/features/downloads/domain/repositories/download_repository.dart';
import 'package:glowy_wallpaper/features/downloads/domain/usecases/download_wallpaper.dart';
import 'package:glowy_wallpaper/features/downloads/domain/usecases/get_download_history.dart';
import 'package:glowy_wallpaper/features/downloads/domain/usecases/watch_download_events.dart';
import 'package:glowy_wallpaper/features/downloads/presentation/cubit/download_cubit.dart';
import 'package:glowy_wallpaper/features/downloads/presentation/cubit/download_state.dart';
import 'package:glowy_wallpaper/features/wallpapers/domain/entities/wallpaper_entity.dart';

class MockDownloadWallpaper extends Mock implements DownloadWallpaper {}

class MockGetDownloadHistory extends Mock implements GetDownloadHistory {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockDownloadRepository extends Mock implements DownloadRepository {}

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
  late MockFirebaseAnalytics mockAnalytics;
  late MockDownloadRepository mockRepository;
  late StreamController<DownloadEvent> eventsController;
  late WatchDownloadEvents watchDownloadEvents;

  setUp(() {
    mockDownloadWallpaper = MockDownloadWallpaper();
    mockGetDownloadHistory = MockGetDownloadHistory();
    mockNetworkInfo = MockNetworkInfo();
    mockAnalytics = MockFirebaseAnalytics();
    mockRepository = MockDownloadRepository();
    eventsController = StreamController<DownloadEvent>.broadcast();
    when(
      () => mockRepository.events,
    ).thenAnswer((_) => eventsController.stream);
    watchDownloadEvents = WatchDownloadEvents(mockRepository);

    registerFallbackValue(NoParams());
    registerFallbackValue(DownloadWallpaperParams(wallpaper: _wallpaper));

    when(
      () => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    eventsController.close();
  });

  // TODO(ads-disabled-018): rewarded gate removed — no ad collaborator to mock or stub
  DownloadCubit buildCubit() => DownloadCubit(
    downloadWallpaper: mockDownloadWallpaper,
    getDownloadHistory: mockGetDownloadHistory,
    watchDownloadEvents: watchDownloadEvents,
    networkInfo: mockNetworkInfo,
    analytics: mockAnalytics,
  );

  group('connectivity guard', () {
    blocTest<DownloadCubit, DownloadState>(
      'emits errorMessage when offline; download use case never invoked',
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
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'accepted (Right): no ad step, no state emitted yet — the engine '
      'event stream drives isDownloading, not the accept call itself',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockDownloadWallpaper(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => <DownloadState>[],
      verify: (_) {
        verify(() => mockDownloadWallpaper(any())).called(1);
      },
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
  });

  group('event-driven download outcome (US3)', () {
    blocTest<DownloadCubit, DownloadState>(
      'Started -> Progressed -> Completed drives isDownloading, progress, '
      'success message, and analytics',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockDownloadWallpaper(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      act: (cubit) async {
        await cubit.download(_wallpaper);
        eventsController.add(DownloadStarted(_wallpaper.id));
        await pumpEventQueue();
        eventsController.add(DownloadProgressed(_wallpaper.id, 0.5));
        await pumpEventQueue();
        eventsController.add(DownloadCompleted(_wallpaper.id));
        await pumpEventQueue();
      },
      expect: () => [
        isA<DownloadState>()
            .having((s) => s.isDownloading, 'isDownloading', true)
            .having((s) => s.downloadProgress, 'downloadProgress', 0.0),
        isA<DownloadState>().having(
          (s) => s.downloadProgress,
          'downloadProgress',
          0.5,
        ),
        isA<DownloadState>()
            .having((s) => s.isDownloading, 'isDownloading', false)
            .having((s) => s.downloadProgress, 'downloadProgress', 1.0)
            .having(
              (s) => s.successMessage,
              'successMessage',
              AppStrings.wallpaperSaved,
            ),
      ],
      verify: (_) {
        verify(
          () => mockAnalytics.logEvent(
            name: 'download_wallpaper',
            parameters: {'wallpaper_id': _wallpaper.id},
          ),
        ).called(1);
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'DownloadFailed drives errorMessage and failure analytics',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockDownloadWallpaper(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      act: (cubit) async {
        await cubit.download(_wallpaper);
        eventsController.add(DownloadStarted(_wallpaper.id));
        await pumpEventQueue();
        eventsController.add(
          DownloadFailed(_wallpaper.id, NetworkFailure('connection dropped')),
        );
        await pumpEventQueue();
      },
      expect: () => [
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
              'connection dropped',
            ),
      ],
      verify: (_) {
        verify(
          () => mockAnalytics.logEvent(
            name: 'download_wallpaper_failed',
            parameters: {
              'wallpaper_id': _wallpaper.id,
              'reason': 'download_error',
            },
          ),
        ).called(1);
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'CU-3: ignores events for a wallpaper id other than the one this '
      'screen requested',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockDownloadWallpaper(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      act: (cubit) async {
        await cubit.download(_wallpaper);
        eventsController.add(DownloadStarted(_wallpaper.id));
        await pumpEventQueue();
        eventsController.add(const DownloadProgressed('some-other-id', 0.9));
        await pumpEventQueue();
      },
      expect: () => [
        isA<DownloadState>().having(
          (s) => s.isDownloading,
          'isDownloading',
          true,
        ),
      ],
    );
  });

  group('sync rejection (busy / permission denied)', () {
    blocTest<DownloadCubit, DownloadState>(
      'emits permission_permanently_denied error message directly, with no '
      'isDownloading transition (no job ever started)',
      build: buildCubit,
      setUp: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDownloadWallpaper(any())).thenAnswer(
          (_) async => Left(CacheFailure('permission_permanently_denied')),
        );
      },
      act: (cubit) => cubit.download(_wallpaper),
      expect: () => [
        isA<DownloadState>()
            .having((s) => s.isDownloading, 'isDownloading', false)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'permission_permanently_denied',
            ),
      ],
      verify: (_) {
        verify(
          () => mockAnalytics.logEvent(
            name: 'download_wallpaper_failed',
            parameters: {
              'wallpaper_id': _wallpaper.id,
              'reason': 'gallery_permission_denied',
            },
          ),
        ).called(1);
      },
    );
  });

  group('close() — CU-2, FR-018', () {
    test('cancels only this cubit\'s subscription; further events do not '
        'throw and are not observed', () async {
      final cubit = buildCubit();
      await cubit.close();

      expect(eventsController.hasListener, isFalse);
      // Must not throw even though the cubit is closed.
      eventsController.add(DownloadStarted(_wallpaper.id));
      await pumpEventQueue();
    });
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
