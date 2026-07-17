import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>?> getCachedCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
  bool isCacheStale({Duration maxAge = const Duration(minutes: 30)});
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box box;
  CategoryLocalDataSourceImpl(this.box);

  static const String _categoriesKey = 'categories_cache';
  static const String _categoriesTimestampKey = 'categories_timestamp';

  @override
  Future<List<CategoryModel>?> getCachedCategories() async {
    final jsonString = box.get(_categoriesKey) as String?;
    if (jsonString == null) return null;
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
    await box.put(_categoriesKey, jsonString);
    await box.put(
      _categoriesTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool isCacheStale({Duration maxAge = const Duration(minutes: 30)}) {
    final timestamp = box.get(_categoriesTimestampKey) as int?;
    if (timestamp == null) return true;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedAt) > maxAge;
  }
}
