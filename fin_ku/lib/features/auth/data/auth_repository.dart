import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/api_config.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';

class TokenInfo {
  const TokenInfo(this.value);

  final String value;
}

class Session {
  const Session(this.token, this.user);

  final TokenInfo token;
  final AppUser user;
}

class AuthRepository {
  static const loginPath = '/api/v1/auth/login';

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user_json';

  static const FlutterSecureStorage _store = FlutterSecureStorage();

  Future<Session> login(String username, String password) async {
    final body = await ApiClient.post(loginPath, {
      'username': username,
      'password': password,
    });

    final data = body is Map ? body['data'] : null;
    if (data == null) {
      throw ApiException(statusCode: 500, message: 'Response login tidak valid.');
    }

    final token = (data['token'] ?? '').toString();
    final userJson = data['user'];
    if (token.isEmpty || userJson == null) {
      throw ApiException(statusCode: 500, message: 'Response login tidak lengkap.');
    }

    return Session(TokenInfo(token), AppUser.fromJson(Map.from(userJson as Map)));
  }

  Future<AppUser> me() async {
    final body = await ApiClient.get('/api/v1/auth/me');
    return AppUser.fromJson(Map.from((body['data'] as Map)));
  }

  /// Memulihkan sesi saat aplikasi dibuka kembali.
  /// Token divalidasi ulang ke backend via /auth/me.
  Future<Session?> restore() async {
    final token = await _store.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;

    ApiConfig.setToken(token);

    try {
      final user = await me();
      await _cacheUser(user);
      return Session(TokenInfo(token), user);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _store.delete(key: _tokenKey);
        await _store.delete(key: _userKey);
        ApiConfig.clearToken();
        return null;
      }
      // Server tidak terjangkau: pulihkan user terakhir agar UI tetap bisa
      // dibuka, request ulang akan gagal dengan pesan jaringan yang jelas.
      final cachedJson = await _store.read(key: _userKey);
      if (cachedJson == null) {
        ApiConfig.clearToken();
        return null;
      }
      final cached = AppUser.fromJson(
        jsonDecode(cachedJson) as Map<String, dynamic>,
      );
      return Session(TokenInfo(token), cached);
    }
  }

  Future<void> saveSession(Session session) async {
    await _store.write(key: _tokenKey, value: session.token.value);
    await _cacheUser(session.user);
  }

  Future<AppUser?> cachedUser() async {
    final raw = await _store.read(key: _userKey);
    if (raw == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheUser(AppUser user) async {
    await _store.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    ApiConfig.clearToken();
    await _store.delete(key: _tokenKey);
    await _store.delete(key: _userKey);
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/api/v1/auth/logout', {});
    } on ApiException catch (_) {
      // Token bisa saja sudah tidak valid; sesi tetap dibersihkan.
    } finally {
      await clearSession();
    }
  }
}
