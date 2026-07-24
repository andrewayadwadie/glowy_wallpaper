import 'dart:async';
import 'dart:isolate';

import 'download_isolate_entry.dart';

/// The isolate abstraction. [IsolateDownloadRunner] spawns a real isolate; a
/// fake implementation lets tests script events without one.
abstract class DownloadRunner {
  /// Streams progress and ends with exactly one terminal event. Never
  /// throws — transport failures arrive as [RunnerError]. The returned
  /// stream is single-subscription and closes after the terminal message.
  Stream<RunnerMessage> run({required String url, required String savePath});
}

sealed class RunnerMessage {}

class RunnerProgress extends RunnerMessage {
  RunnerProgress(this.received, this.total);

  final int received;
  final int total;
}

class RunnerDone extends RunnerMessage {}

class RunnerError extends RunnerMessage {
  RunnerError(this.kind, this.message);

  /// `network` | `io` | `unknown`.
  final String kind;
  final String message;
}

/// Spawns [downloadIsolateEntry] and relays its wire-format messages as
/// [RunnerMessage]s. Closes the port and kills the isolate on every exit
/// path, including error, so nothing is ever leaked (constitution VI).
class IsolateDownloadRunner implements DownloadRunner {
  @override
  Stream<RunnerMessage> run({required String url, required String savePath}) {
    late final StreamController<RunnerMessage> controller;
    ReceivePort? receivePort;
    Isolate? isolate;
    StreamSubscription<dynamic>? portSubscription;

    Future<void> teardown() async {
      await portSubscription?.cancel();
      receivePort?.close();
      isolate?.kill(priority: Isolate.immediate);
      receivePort = null;
      isolate = null;
    }

    controller = StreamController<RunnerMessage>(
      onListen: () async {
        final port = ReceivePort();
        receivePort = port;
        try {
          isolate = await Isolate.spawn<Map<String, Object?>>(
            downloadIsolateEntry,
            <String, Object?>{
              'url': url,
              'savePath': savePath,
              'sendPort': port.sendPort,
              'connectTimeoutMs': const Duration(seconds: 30).inMilliseconds,
              'receiveTimeoutMs': const Duration(seconds: 30).inMilliseconds,
            },
          );
        } catch (e) {
          controller.add(RunnerError('unknown', e.toString()));
          await teardown();
          await controller.close();
          return;
        }

        portSubscription = port.listen((dynamic raw) async {
          final message = raw as Map<String, Object?>;
          switch (message['type']) {
            case 'progress':
              controller.add(
                RunnerProgress(
                  message['received']! as int,
                  message['total']! as int,
                ),
              );
            case 'done':
              controller.add(RunnerDone());
              await teardown();
              await controller.close();
            case 'error':
              controller.add(
                RunnerError(
                  message['kind']! as String,
                  message['message']! as String,
                ),
              );
              await teardown();
              await controller.close();
          }
        });
      },
      onCancel: () async {
        await teardown();
      },
    );

    return controller.stream;
  }
}
