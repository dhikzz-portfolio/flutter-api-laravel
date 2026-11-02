import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  ApiConfig._();

  static const _storageKey = 'api_base_url';
  static const devPort = '8000';

  /// Override saat build/run, contoh:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Base URL default dipilih berdasarkan platform target:
  /// - Override --dart-define (bila diisi)
  /// - Android emulator   : 10.0.2.2 = loopback host machine
  /// - Perangkat lain     : loopback lokal (desktop / emulator non-Android)
  ///
  /// Perangkat Android fisik tidak dapat menjangkau 10.0.2.2; ganti alamat
  /// melalui halaman Profil atau --dart-define.
  static String get defaultBaseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:$devPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$devPort';
    return 'http://127.0.0.1:$devPort';
  }

  static String _currentBaseUrl = defaultBaseUrl;

  static String get baseUrl => _currentBaseUrl;

  static String _token = '';

  static String? get token => _token.isEmpty ? null : _token;

  static bool get hasToken => _token.isNotEmpty;

  static void setToken(String value) {
    _token = value;
  }

  static void clearToken() {
    _token = '';
  }

  static String url(String path) => '$baseUrl$path';

  static Future<void> loadCachedBaseUrl() async {
    final stored = await _storage.read(key: _storageKey);
    _currentBaseUrl = (stored == null || stored.isEmpty) ? defaultBaseUrl : stored;
  }

  static Future<void> saveBaseUrl(String value) async {
    var cleaned = value.trim();
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    _currentBaseUrl = cleaned.isEmpty ? defaultBaseUrl : cleaned;
    if (cleaned.isEmpty) {
      await _storage.delete(key: _storageKey);
      return;
    }
    await _storage.write(key: _storageKey, value: _currentBaseUrl);
  }

  static Future<void> removeBaseUrl() async {
    _currentBaseUrl = defaultBaseUrl;
    await _storage.delete(key: _storageKey);
  }
}
