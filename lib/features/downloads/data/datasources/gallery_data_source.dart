import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

abstract class GalleryDataSource {
  Future<bool> requestPermission();
  Future<bool> checkPermission();
  Future<bool> isPermanentlyDenied();
  Future<void> openAppSettings();
  Future<void> putImageBytes(Uint8List bytes, {String? name});
  Future<void> putVideoBytes(Uint8List bytes, {String? name});
}

class GalleryDataSourceImpl implements GalleryDataSource {
  @override
  Future<bool> requestPermission() async {
    final hasAccess = await Gal.hasAccess(toAlbum: false);
    if (hasAccess) return true;
    return Gal.requestAccess(toAlbum: false);
  }

  @override
  Future<bool> checkPermission() async {
    return Gal.hasAccess(toAlbum: false);
  }

  @override
  Future<bool> isPermanentlyDenied() async {
    final status = await ph.Permission.storage.status;
    return status.isPermanentlyDenied;
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  @override
  Future<void> putImageBytes(Uint8List bytes, {String? name}) async {
    await Gal.putImageBytes(bytes, name: name ?? 'wallpaper');
  }

  @override
  Future<void> putVideoBytes(Uint8List bytes, {String? name}) async {
    // gal only supports saving videos from file paths, so write to temp first
    final tmpDir = await getTemporaryDirectory();
    final fileName = '${name ?? 'wallpaper'}.mp4';
    final tmpFile = File('${tmpDir.path}/$fileName');
    await tmpFile.writeAsBytes(bytes);
    try {
      await Gal.putVideo(tmpFile.path);
    } finally {
      await tmpFile.delete();
    }
  }
}
