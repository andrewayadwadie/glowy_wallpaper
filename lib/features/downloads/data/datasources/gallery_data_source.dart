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

  /// Saves a file already written to disk at [path] into the system
  /// gallery. Used by the isolate-backed download path, which streams
  /// straight to disk instead of buffering bytes in memory.
  Future<void> saveFile(String path, {required bool isVideo});
}

/// Writes downloaded wallpapers into the system gallery via MediaStore.
///
/// The app only ever writes files it downloaded itself; it never reads the
/// user's existing media. Saving new media through MediaStore needs no
/// runtime permission on API 29+, so no READ_MEDIA_* permission is requested
/// or declared. Only API 24-28 still needs WRITE_EXTERNAL_STORAGE, and `gal`
/// resolves that split natively — its `hasAccess` returns true above API 29
/// and short-circuits `requestAccess`, so no prompt is reachable there.
class GalleryDataSourceImpl implements GalleryDataSource {
  static const String _defaultName = 'wallpaper';

  @override
  Future<bool> requestPermission() => Gal.requestAccess();

  @override
  Future<bool> checkPermission() => Gal.hasAccess();

  @override
  Future<bool> isPermanentlyDenied() async {
    // Only reachable on API < 29, where requestPermission delegates to the
    // WRITE_EXTERNAL_STORAGE grant. Above that nothing is requested, so the
    // status stays denied-but-not-permanently and this returns false.
    final storage = await ph.Permission.storage.status;
    return storage.isPermanentlyDenied;
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  @override
  Future<void> putImageBytes(Uint8List bytes, {String? name}) async {
    await Gal.putImageBytes(bytes, name: name ?? _defaultName);
  }

  @override
  Future<void> putVideoBytes(Uint8List bytes, {String? name}) async {
    // `gal` has no putVideoBytes — its bytes API sniffs an image format and
    // is image-only. Video bytes go to a temp file and take the path API.
    final tmpDir = await getTemporaryDirectory();
    final tmpFile = File('${tmpDir.path}/${name ?? _defaultName}.mp4');
    await tmpFile.writeAsBytes(bytes);
    try {
      await Gal.putVideo(tmpFile.path);
    } finally {
      await tmpFile.delete();
    }
  }

  @override
  Future<void> saveFile(String path, {required bool isVideo}) async {
    // No album argument: naming an album makes gal require
    // WRITE_EXTERNAL_STORAGE on API 29, which would force the manifest
    // declaration back up to maxSdkVersion 29.
    if (isVideo) {
      await Gal.putVideo(path);
    } else {
      await Gal.putImage(path);
    }
  }
}
