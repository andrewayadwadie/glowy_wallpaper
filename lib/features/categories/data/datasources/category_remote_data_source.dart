import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../models/category_model.dart';
import '../models/classification_model.dart';

class CategoryRemoteDataSource {
  final Dio _dio;
  CategoryRemoteDataSource(this._dio);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get(
      '/api/v1/mobile/apps/${AppConfig.appId}/categories',
    );

    final data = response.data['data'] as Map<String, dynamic>;
    log("data of categories : ${data.toString()}");
    final items = data['items'] as List;
    return items
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClassificationModel>> getClassifications(
    String categoryId,
  ) async {
    final response = await _dio.get(
      '/api/v1/mobile/apps/${AppConfig.appId}/categories/$categoryId/classifications',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final classifications = data['classifications'] as List;
    return classifications
        .map((e) => ClassificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
