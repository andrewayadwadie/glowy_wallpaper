import 'dart:math';
import 'package:hive/hive.dart';

class DeviceIdService {
  static const _key = 'device_id';
  final Box _box;

  DeviceIdService(this._box);

  String getDeviceId() {
    final existing = _box.get(_key) as String?;
    if (existing != null) return existing;

    final id = _generateId();
    _box.put(_key, id);
    return id;
  }

  static String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
