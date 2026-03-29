import 'dart:convert';

import 'package:hive/hive.dart';
import '../models/app_metadata_model.dart';

const _kAppMetadataKey = 'app_metadata';

abstract class BootstrapLocalDataSource {
  AppMetadataModel? getAppMetadata();
  Future<void> saveAppMetadata(AppMetadataModel model);
}

class BootstrapLocalDataSourceImpl implements BootstrapLocalDataSource {
  final Box _box;
  BootstrapLocalDataSourceImpl(this._box);

  @override
  AppMetadataModel? getAppMetadata() {
    final raw = _box.get(_kAppMetadataKey);
    if (raw == null) return null;
    // Stored as JSON string to avoid Hive Map<dynamic,dynamic> issues
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    return AppMetadataModel.fromJson(json);
  }

  @override
  Future<void> saveAppMetadata(AppMetadataModel model) async {
    // jsonEncode calls toJson() on nested objects (CategoryModel etc.),
    // ensuring full serialization. Raw model.toJson() leaves nested
    // freezed objects un-serialized, which Hive cannot persist.
    await _box.put(_kAppMetadataKey, jsonEncode(model.toJson()));
  }
}
