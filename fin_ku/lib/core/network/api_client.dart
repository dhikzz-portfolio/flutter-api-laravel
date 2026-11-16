import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../errors/api_exception.dart';

class ApiResponse {
  ApiResponse(this.status, this.body);

  final int status;
  final dynamic body;

  dynamic get data => body is Map ? body['data'] : null;

  dynamic get meta => body is Map ? body['meta'] : null;

  String get message {
    if (body is Map && body['message'] is String) return body['message'] as String;
    return '';
  }
}

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();
  static void Function()? onUnauthorized;

  static Map<String, String> get _defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (ApiConfig.hasToken) 'Authorization': 'Bearer ${ApiConfig.token}',
      };

  static Uri uri(String path, [Map<String, String>? query]) {
    return Uri.parse(ApiConfig.url(path)).replace(
      queryParameters: _cleanQuery(query),
    );
  }

  static Map<String, String> _cleanQuery(Map<String, String>? query) {
    if (query == null) return const {};
    return Map.fromEntries(
      query.entries.where((e) => e.value.isNotEmpty),
    );
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final res = await _send(() => _client.get(uri(path, query), headers: _defaultHeaders));
    return res;
  }

  static Future<dynamic> post(String path, dynamic body) async {
    final res = await _send(
      () => _client.post(
        uri(path),
        headers: _defaultHeaders,
        body: jsonEncode(body ?? {}),
      ),
    );
    return res;
  }

  static Future<dynamic> put(String path, dynamic body) async {
    final res = await _send(
      () => _client.put(
        uri(path),
        headers: _defaultHeaders,
        body: jsonEncode(body ?? {}),
      ),
    );
    return res;
  }

  static Future<dynamic> delete(String path) async {
    final res = await _send(() => _client.delete(uri(path), headers: _defaultHeaders));
    return res;
  }

  /// Mengunduh file (mis. laporan excel/pdf) dengan header auth.
  static Future<List<int>> getBytes(
    String path, {
    Map<String, String>? query,
  }) async {
    final res = await _send(
      () => _client.get(uri(path, query), headers: _defaultHeaders),
      allowBytes: true,
    );
    if (res is List<int>) return res;
    throw ApiException(statusCode: 200, message: 'Format file tidak dikenali dari server.');
  }

  static Future<dynamic> _send(
    Future<http.Response> Function() request, {
    bool allowBytes = false,
  }) async {
    http.Response res;
    try {
      res = await request();
    } catch (_) {
      throw ApiException.network(-1);
    }

    if (res.statusCode == 401) {
      final cb = onUnauthorized;
      if (cb != null) cb();
      throw ApiException.unauthorized();
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (allowBytes) return res.bodyBytes;
      if (res.body.isEmpty) return const {};
      return jsonDecode(utf8.decode(res.bodyBytes));
    }

    dynamic body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      body = const {};
    }

    if (res.statusCode == 422) {
      final errors = <String, List<String>>{};
      if (body is Map && body['errors'] is Map) {
        (body['errors'] as Map).forEach((k, v) {
          if (v is List) {
            errors[k.toString()] = v.map((e) => e.toString()).toList();
          } else if (v != null) {
            errors[k.toString()] = [v.toString()];
          }
        });
      }
      throw ApiException(
        statusCode: res.statusCode,
        message: body is Map && body['message'] is String
            ? body['message'] as String
            : 'Data tidak valid.',
        fieldErrors: errors,
      );
    }

    throw ApiException(
      statusCode: res.statusCode,
      message: body is Map && body['message'] is String
          ? body['message'] as String
          : 'Terjadi kesalahan pada server (${res.statusCode}).',
    );
  }
}
