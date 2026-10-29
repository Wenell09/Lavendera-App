import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSource({required this._secureStorage});

  Future<void> saveSession({
    required String id,
    required String token,
    required String role,
  }) async {
    await _secureStorage.write(key: 'id', value: id);
    await _secureStorage.write(key: 'role', value: role);
    await _secureStorage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: 'token');
  }

  Future<String?> getRole() async {
    return _secureStorage.read(key: 'role');
  }

  Future<String?> getUserId() async {
    return _secureStorage.read(key: 'id');
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'id');
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'role');
  }
}
