import 'package:hive/hive.dart';
import '../../data/models/download_record_model.dart';
import '../../domain/entities/download_record_entity.dart';

abstract class DownloadLocalDataSource {
  Future<void> saveRecord(DownloadRecordEntity record);
  Future<List<DownloadRecordEntity>> getAll();
  Future<bool> isDownloaded(String wallpaperId);
}

class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  final Box _box;

  DownloadLocalDataSourceImpl(this._box);

  @override
  Future<void> saveRecord(DownloadRecordEntity record) async {
    final model = DownloadRecordModel.fromEntity(record);
    await _box.put(record.wallpaperId, model.toJson());
  }

  @override
  Future<List<DownloadRecordEntity>> getAll() async {
    final entries = _box.values.toList();
    final models = entries
        .map(
          (e) =>
              DownloadRecordModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    models.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<bool> isDownloaded(String wallpaperId) async {
    return _box.containsKey(wallpaperId);
  }
}
