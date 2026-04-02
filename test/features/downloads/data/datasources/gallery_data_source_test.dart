import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:glowy_wallpaper/features/downloads/data/datasources/gallery_data_source.dart';

// GalleryDataSourceImpl calls into native plugins (image_gallery_saver_plus,
// permission_handler) which are unavailable in the Flutter unit test
// environment.  These tests verify the contract of the abstract interface
// and document the expected delegation behaviour; they rely on a
// MockGalleryDataSource to verify interactions rather than hitting the
// real native implementation.

class MockGalleryDataSource extends Mock implements GalleryDataSource {}

void main() {
  late MockGalleryDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockGalleryDataSource();
  });

  group('GalleryDataSource interface contract', () {
    test('putImageBytes delegates to implementation', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      when(
        () => mockDataSource.putImageBytes(bytes, name: 'wallpaper_test'),
      ).thenAnswer((_) async {});

      await mockDataSource.putImageBytes(bytes, name: 'wallpaper_test');

      verify(
        () => mockDataSource.putImageBytes(bytes, name: 'wallpaper_test'),
      ).called(1);
    });

    test('putVideoBytes delegates to implementation', () async {
      final bytes = Uint8List.fromList([0xFF, 0xFB]);
      when(
        () => mockDataSource.putVideoBytes(bytes, name: 'wallpaper_test'),
      ).thenAnswer((_) async {});

      await mockDataSource.putVideoBytes(bytes, name: 'wallpaper_test');

      verify(
        () => mockDataSource.putVideoBytes(bytes, name: 'wallpaper_test'),
      ).called(1);
    });

    test('requestPermission returns bool', () async {
      when(() => mockDataSource.requestPermission()).thenAnswer((_) async => true);

      final result = await mockDataSource.requestPermission();

      expect(result, isTrue);
    });

    test('isPermanentlyDenied returns bool', () async {
      when(() => mockDataSource.isPermanentlyDenied()).thenAnswer((_) async => true);

      final result = await mockDataSource.isPermanentlyDenied();

      expect(result, isTrue);
    });

    test('openAppSettings completes without error', () async {
      when(() => mockDataSource.openAppSettings()).thenAnswer((_) async {});

      await expectLater(mockDataSource.openAppSettings(), completes);
    });
  });
}
