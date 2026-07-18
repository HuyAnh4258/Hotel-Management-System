import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _rolesKey = 'roles';
  static const _fullNameKey = 'full_name';

  Future<void> saveSession({
    required String accessToken,
    required String userId,
    required String username,
    required String roles,
    String? fullName,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _rolesKey, value: roles);
    if (fullName != null) {
      await _storage.write(key: _fullNameKey, value: fullName);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<String?> getUsername() => _storage.read(key: _usernameKey);

  Future<String?> getRoles() => _storage.read(key: _rolesKey);

  Future<String?> getFullName() => _storage.read(key: _fullNameKey);

  Future<void> clearAll() => _storage.deleteAll();
}
