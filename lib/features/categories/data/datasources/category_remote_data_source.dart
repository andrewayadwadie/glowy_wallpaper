import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../models/classification_model.dart';

class CategoryRemoteDataSource {
  final Dio _dio;
  CategoryRemoteDataSource(this._dio);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('/categories');
    final items = response.data['items'] as List;
    return items
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClassificationModel>> getClassifications(
    String categoryId,
  ) async {
    final response = await _dio.get('/categories/$categoryId/classifications');
    final items = response.data['items'] as List;
    return items
        .map((e) => ClassificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
