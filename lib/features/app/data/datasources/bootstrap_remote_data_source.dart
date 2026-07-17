import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../models/app_metadata_model.dart';

class BootstrapRemoteDataSource {
  final Dio _dio;
  BootstrapRemoteDataSource(this._dio);

  Future<AppMetadataModel> getAppData() async {
    final response = await _dio.get('/api/v1/mobile/apps/${AppConfig.appId}');
    final appJson =
        (response.data['data'] as Map<String, dynamic>)['app']
            as Map<String, dynamic>;
    return AppMetadataModel.fromJson(appJson);
  }
}
