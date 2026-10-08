import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'kobson_access_token';
  static const _refreshTokenKey = 'kobson_refresh_token';

  static const _lastIdentifierKey = 'kobson_last_identifier';
  static const _lastUserNameKey = 'kobson_last_user_name';

  static Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> saveLastUser({required String identifier, String? userName}) async {
    await _storage.write(key: _lastIdentifierKey, value: identifier);
    if (userName != null && userName.isNotEmpty) {
      await _storage.write(key: _lastUserNameKey, value: userName);
    }
  }

  static Future<String?> getLastIdentifier() async {
    return await _storage.read(key: _lastIdentifierKey);
  }

  static Future<String?> getLastUserName() async {
    return await _storage.read(key: _lastUserNameKey);
  }

  static Future<void> clearLastUser() async {
    await _storage.delete(key: _lastIdentifierKey);
    await _storage.delete(key: _lastUserNameKey);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
