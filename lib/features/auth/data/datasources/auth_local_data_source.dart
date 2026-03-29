import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final Box box;

  AuthLocalDataSourceImpl(this.secureStorage, this.box);

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await box.put('current_user', user.toJson());
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userData = box.get('current_user');
    if (userData != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await box.delete('current_user');
  }

  @override
  Future<bool> hasToken() async {
    return (await getToken()) != null;
  }
}
