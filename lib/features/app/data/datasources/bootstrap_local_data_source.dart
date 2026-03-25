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
    final json = _box.get(_kAppMetadataKey);
    if (json == null) return null;
    return AppMetadataModel.fromJson(Map<String, dynamic>.from(json as Map));
  }

  @override
  Future<void> saveAppMetadata(AppMetadataModel model) async {
    await _box.put(_kAppMetadataKey, model.toJson());
  }
}
