import 'dart:io';
import 'dart:typed_data';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

abstract class GalleryDataSource {
  Future<bool> requestPermission();
  Future<bool> checkPermission();
  Future<bool> isPermanentlyDenied();
  Future<void> openAppSettings();
  Future<void> putImageBytes(Uint8List bytes, {String? name});
  Future<void> putVideoBytes(Uint8List bytes, {String? name});

  /// Saves a file already written to disk at [path] into the system
  /// gallery. Used by the isolate-backed download path, which streams
  /// straight to disk instead of buffering bytes in memory.
  Future<void> saveFile(String path, {required bool isVideo});
}

class GalleryDataSourceImpl implements GalleryDataSource {
  @override
  Future<bool> requestPermission() async {
    // On Android 13+ (API 33+), photos permission is used; on older versions
    // it's storage. permission_handler resolves the correct permission per SDK.
    final status = await ph.Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;
    // Fallback for Android < 13
    final storage = await ph.Permission.storage.request();
    return storage.isGranted;
  }

  @override
  Future<bool> checkPermission() async {
    final photos = await ph.Permission.photos.status;
    if (photos.isGranted || photos.isLimited) return true;
    final storage = await ph.Permission.storage.status;
    return storage.isGranted;
  }

  @override
  Future<bool> isPermanentlyDenied() async {
    final photos = await ph.Permission.photos.status;
    if (photos.isPermanentlyDenied) return true;
    final storage = await ph.Permission.storage.status;
    return storage.isPermanentlyDenied;
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  @override
  Future<void> putImageBytes(Uint8List bytes, {String? name}) async {
    final tmpDir = await getTemporaryDirectory();
    final fileName = '${name ?? 'wallpaper'}.jpg';
    final tmpFile = File('${tmpDir.path}/$fileName');
    await tmpFile.writeAsBytes(bytes);
    try {
      await GallerySaver.saveImage(tmpFile.path);
    } finally {
      await tmpFile.delete();
    }
  }

  @override
  Future<void> putVideoBytes(Uint8List bytes, {String? name}) async {
    final tmpDir = await getTemporaryDirectory();
    final fileName = '${name ?? 'wallpaper'}.mp4';
    final tmpFile = File('${tmpDir.path}/$fileName');
    await tmpFile.writeAsBytes(bytes);
    try {
      await GallerySaver.saveVideo(tmpFile.path);
    } finally {
      await tmpFile.delete();
    }
  }

  @override
  Future<void> saveFile(String path, {required bool isVideo}) async {
    if (isVideo) {
      await GallerySaver.saveVideo(path);
    } else {
      await GallerySaver.saveImage(path);
    }
  }
}
