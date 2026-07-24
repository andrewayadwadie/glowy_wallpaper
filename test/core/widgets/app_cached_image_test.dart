import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/file.dart' as pf;
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:glowy_wallpaper/core/widgets/app_cached_image.dart';

/// Minimal valid 1x1 transparent PNG — real, decodable bytes so a
/// cache-hit render can be told apart from a decode failure.
final Uint8List _onePixelPng = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY'
    '42YAAAAASUVORK5CYII=',
  ),
);

/// In-memory [FileSystem] for flutter_cache_manager — avoids path_provider
/// entirely so tests don't need platform-channel mocking.
class _MemoryCacheFileSystem implements FileSystem {
  _MemoryCacheFileSystem() {
    _fs.directory('/cache').createSync(recursive: true);
  }

  final _fs = MemoryFileSystem();

  @override
  Future<pf.File> createFile(String name) async => _fs.file('/cache/$name');
}

void main() {
  const testUrl = 'https://example.com/wallpaper.jpg';
  late CacheManager sharedManager;

  setUp(() {
    sharedManager = _StubCacheManager();
    GetIt.I.registerSingleton<CacheManager>(
      sharedManager,
      instanceName: 'wallpaperThumbnailCacheManager',
    );
  });

  tearDown(() {
    GetIt.I.unregister<CacheManager>(
      instanceName: 'wallpaperThumbnailCacheManager',
    );
  });

  group('AppCachedImage cacheManager wiring', () {
    testWidgets(
      'defaults to the shared GetIt CacheManager when none supplied',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: AppCachedImage(imageUrl: testUrl)),
          ),
        );

        final cachedImage = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        expect(cachedImage.cacheManager, same(sharedManager));
      },
    );

    testWidgets('honors an explicitly-passed cacheManager override', (
      tester,
    ) async {
      final override = _StubCacheManager();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCachedImage(imageUrl: testUrl, cacheManager: override),
          ),
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.cacheManager, same(override));
      expect(cachedImage.cacheManager, isNot(same(sharedManager)));
    });

    testWidgets('defaults fadeInDuration to 500ms and forwards an override', (
      tester,
    ) async {
      final manager = _EmptyStreamCacheManager();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCachedImage(imageUrl: testUrl, cacheManager: manager),
          ),
        ),
      );
      expect(
        tester
            .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
            .fadeInDuration,
        const Duration(milliseconds: 500),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCachedImage(
              imageUrl: testUrl,
              cacheManager: manager,
              fadeInDuration: Duration.zero,
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
            .fadeInDuration,
        Duration.zero,
      );
    });
  });

  group('AppCachedImage offline cache-hit rendering', () {
    testWidgets(
      'renders a pre-populated cache entry without hitting the network',
      (tester) async {
        final offlineManager = CacheManager(
          Config(
            'offlineRenderTestCache',
            repo: NonStoringObjectProvider(),
            fileSystem: _MemoryCacheFileSystem(),
          ),
        );
        const offlineUrl = 'https://example.com/never-fetched.png';
        await offlineManager.putFile(
          offlineUrl,
          _onePixelPng,
          fileExtension: 'png',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppCachedImage(
                imageUrl: offlineUrl,
                cacheManager: offlineManager,
              ),
            ),
          ),
        );
        // AppCachedImage's placeholder is an infinitely-repeating Shimmer, so
        // pumpAndSettle() would never converge; pump discrete frames instead
        // to give the (fully in-memory, synchronous) decode time to finish.
        // The final pump also flushes CacheStore's internal 10s cleanup
        // timer so it doesn't outlive the test.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(seconds: 11));

        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.broken_image), findsNothing);
      },
    );
  });
}

class _StubCacheManager implements CacheManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Returns an empty stream for image loads so [CachedNetworkImage] can build
/// and settle on its placeholder without throwing.
class _EmptyStreamCacheManager implements CacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
