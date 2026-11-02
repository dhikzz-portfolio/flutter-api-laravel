import '../utils/format.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
    required this.status,
  });

  final int id;
  final String nama;
  final String username;
  final String role;
  final String status;

  bool get isActive => status == 'aktif';
  bool get isKasir => role == 'kasir';
  bool get isAdmin => role == 'admin';
  bool get isOwner => role == 'owner';

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: Fmt.intv(json['id']),
      nama: (json['nama'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'username': username,
        'role': role,
        'status': status,
      };
}

/// Halaman hasil list dengan meta pagination Laravel:
/// {data: [...], meta: {current_page, last_page, per_page, total}}
class ApiPage<T> {
  ApiPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get canLoadMore => currentPage < lastPage;

  static ApiPage<T> parse<T>(
    dynamic body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = (body is Map && body['data'] is List)
        ? body['data'] as List
        : <dynamic>[];
    final meta = body is Map && body['meta'] is Map
        ? body['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    final currentPage = meta['current_page'] != null ? Fmt.intv(meta['current_page']) : 1;
    final lastPage = meta['last_page'] != null ? Fmt.intv(meta['last_page']) : 1;
    final total = meta['total'] != null ? Fmt.intv(meta['total']) : 0;

    return ApiPage<T>(
      items: list.map((e) => fromJson(Map.from(e as Map))).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
    );
  }
}

class AppUserRow {
  AppUserRow({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
    required this.status,
  });

  final int id;
  final String nama;
  final String username;
  final String role;
  final String status;

  bool get isActive => status == 'aktif';

  static AppUserRow fromJson(Map<String, dynamic> json) => AppUserRow(
        id: Fmt.intv(json['id']),
        nama: (json['nama'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
      );
}
