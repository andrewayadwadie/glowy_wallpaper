import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';

/// Top-level function — required by [Isolate.spawn]. Runs entirely off the
/// main isolate: builds its own [Dio] (never sent across, since it holds
/// non-sendable state), streams the response straight to [savePath] via
/// `dio.download` (never `ResponseType.bytes` — that is the double-buffer
/// memory bug this feature fixes), and reports throttled progress.
///
/// Touches no plugin channel (`path_provider`, `gallery_saver_plus`,
/// `permission_handler`, `hive`) and no Flutter binding — [savePath] is
/// resolved on the main isolate before spawning.
///
/// Sends exactly one terminal message (`done` or `error`), always preceded
/// by a final 100% `progress` on success, then returns and the isolate
/// exits.
Future<void> downloadIsolateEntry(Map<String, Object?> args) async {
  final url = args['url']! as String;
  final savePath = args['savePath']! as String;
  final sendPort = args['sendPort']! as SendPort;
  final connectTimeoutMs = args['connectTimeoutMs']! as int;
  final receiveTimeoutMs = args['receiveTimeoutMs']! as int;

  final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(milliseconds: connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
    ),
  );

  var lastPercent = -1;
  var lastEmitAt = DateTime.fromMillisecondsSinceEpoch(0);

  void emitProgress(int received, int total) {
    final now = DateTime.now();
    final percent = total > 0 ? ((received / total) * 100).floor() : -1;
    final percentAdvanced = percent != lastPercent;
    final timeAdvanced =
        now.difference(lastEmitAt) >= const Duration(milliseconds: 100);
    if (percentAdvanced || timeAdvanced) {
      lastPercent = percent;
      lastEmitAt = now;
      sendPort.send(<String, Object?>{
        'type': 'progress',
        'received': received,
        'total': total,
      });
    }
  }

  try {
    await dio.download(url, savePath, onReceiveProgress: emitProgress);
    sendPort.send(<String, Object?>{
      'type': 'progress',
      'received': 100,
      'total': 100,
    });
    sendPort.send(<String, Object?>{'type': 'done'});
  } on DioException catch (e) {
    sendPort.send(<String, Object?>{
      'type': 'error',
      'kind': 'network',
      'message': e.message ?? 'Download failed',
    });
  } on FileSystemException catch (e) {
    sendPort.send(<String, Object?>{
      'type': 'error',
      'kind': 'io',
      'message': e.toString(),
    });
  } catch (e) {
    sendPort.send(<String, Object?>{
      'type': 'error',
      'kind': 'unknown',
      'message': e.toString(),
    });
  }
}
