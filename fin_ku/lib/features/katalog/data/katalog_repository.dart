import '../../../../core/errors/api_exception.dart';
import '../../../../core/models/catalog_model.dart';
import '../../../../core/models/report_model.dart';
import '../../../../core/models/transaction_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/format.dart';

/// Repositori master data. Endpoint admin dan owner memiliki payload
/// identik namun path berbeda, sehingga diabstraksi lewat [basePath].
class KatalogRepository {
  KatalogRepository({required this.basePath});

  /// "/api/v1/admin" atau "/api/v1/owner"
  final String basePath;

  // ===================== Produk =====================

  Future<ApiPage<Product>> produk({
    String search = '',
    String status = '',
    int categoryId = 0,
    int page = 1,
    int perPage = 15,
  }) async {
    final body = await ApiClient.get(
      '$basePath/produk',
      query: {
        'search': search,
        'status': status,
        'category_id': categoryId > 0 ? '$categoryId' : '',
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<Product>(body, Product.fromJson);
  }

  Future<Product> createProduk({
    required String nama,
    required int categoryId,
    required double hargaJual,
    required int stok,
    required int stokMinimum,
  }) async {
    final body = await ApiClient.post('$basePath/produk', {
      'nama': nama,
      'category_id': categoryId,
      'harga_jual': hargaJual,
      'stok': stok,
      'stok_minimum': stokMinimum,
    });
    return Product.fromJson(Map.from(body['data'] as Map));
  }

  Future<Product> updateProduk(
    int id, {
    required String nama,
    required int categoryId,
    required double hargaJual,
    required int stokMinimum,
    required String status,
  }) async {
    final body = await ApiClient.put('$basePath/produk/$id', {
      'nama': nama,
      'category_id': categoryId,
      'harga_jual': hargaJual,
      'stok_minimum': stokMinimum,
      'status': status,
    });
    return Product.fromJson(Map.from(body['data'] as Map));
  }

  // ===================== Kategori =====================

  Future<ApiPage<Category>> kategori({
    String search = '',
    String status = '',
    int page = 1,
    int perPage = 100,
  }) async {
    final body = await ApiClient.get(
      '$basePath/kategori',
      query: {
        'search': search,
        'status': status,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<Category>(body, Category.fromJson);
  }

  Future<Category> createKategori(String nama) async {
    final body = await ApiClient.post('$basePath/kategori', {'nama': nama});
    return Category.fromJson(Map.from(body['data'] as Map));
  }

  Future<Category> updateKategori(
    int id, {
    required String nama,
    required String status,
  }) async {
    final body = await ApiClient.put('$basePath/kategori/$id', {
      'nama': nama,
      'status': status,
    });
    return Category.fromJson(Map.from(body['data'] as Map));
  }

  // ===================== Distributor (admin) =====================

  Future<ApiPage<Distributor>> distributor({
    String search = '',
    int page = 1,
    int perPage = 15,
  }) async {
    final body = await ApiClient.get(
      '$basePath/distributor',
      query: {'search': search, 'page': '$page', 'per_page': '$perPage'},
    );
    return ApiPage.parse<Distributor>(body, Distributor.fromJson);
  }

  Future<Distributor> createDistributor({
    required String nama,
    required String telepon,
    required String alamat,
  }) async {
    final body = await ApiClient.post('$basePath/distributor', {
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
    });
    return Distributor.fromJson(Map.from(body['data'] as Map));
  }

  Future<Distributor> updateDistributor(
    int id, {
    required String nama,
    required String telepon,
    required String alamat,
  }) async {
    final body = await ApiClient.put('$basePath/distributor/$id', {
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
    });
    return Distributor.fromJson(Map.from(body['data'] as Map));
  }

  // ===================== Barang Keluar (admin & owner, view) =====================

  Future<ApiPage<StockOut>> barangKeluar({
    String dateFrom = '',
    String dateTo = '',
    int page = 1,
    int perPage = 15,
  }) async {
    final body = await ApiClient.get(
      '$basePath/barang-keluar',
      query: {
        'date_from': dateFrom,
        'date_to': dateTo,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<StockOut>(body, StockOut.fromJson);
  }

  // ===================== Riwayat Stok (admin & owner) =====================

  Future<ApiPage<StockMovement>> riwayatStok({
    int productId = 0,
    String jenis = '',
    String dateFrom = '',
    String dateTo = '',
    int page = 1,
    int perPage = 20,
  }) async {
    final body = await ApiClient.get(
      '$basePath/riwayat-stok',
      query: {
        'product_id': productId > 0 ? '$productId' : '',
        'jenis': jenis,
        'date_from': dateFrom,
        'date_to': dateTo,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<StockMovement>(body, StockMovement.fromJson);
  }

  // ===================== Koreksi stok list (admin) =====================

  Future<ApiPage<StockAdjustment>> koreksiStok({
    String dateFrom = '',
    String dateTo = '',
    int page = 1,
    int perPage = 15,
  }) async {
    final body = await ApiClient.get(
      '$basePath/koreksi-stok',
      query: {
        'date_from': dateFrom,
        'date_to': dateTo,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<StockAdjustment>(body, StockAdjustment.fromJson);
  }
}

/// Kasir: daftar produk aktif untuk POS (endpoint khusus kasir).
class KasirProdukRepository {
  Future<List<PosProduct>> produkAktif({String search = ''}) async {
    final body = await ApiClient.get(
      '/api/v1/kasir/produk',
      query: {'search': search},
    );
    if (body is! Map || body['data'] is! List) {
      throw ApiException(statusCode: 500, message: 'Format produk tidak dikenali.');
    }
    return (body['data'] as List)
        .map((e) => PosProduct.fromJson(Map.from(e as Map)))
        .toList();
  }
}

class PosProduct {
  PosProduct({
    required this.id,
    required this.nama,
    required this.hargaJual,
    required this.stok,
    required this.categoryId,
    this.categoryNama = '',
  });

  final int id;
  final String nama;
  final double hargaJual;
  final int stok;
  final int categoryId;
  final String categoryNama;

  static PosProduct fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    return PosProduct(
      id: Fmt.intv(json['id']),
      nama: (json['nama'] ?? '').toString(),
      hargaJual: Fmt.dec(json['harga_jual']),
      stok: Fmt.intv(json['stok']),
      categoryId: Fmt.intv(json['category_id']),
      categoryNama: cat == null ? '' : (cat['nama'] ?? '').toString(),
    );
  }
}

/// Owner: manajemen user & laporan.
class OwnerRepository {
  Future<ApiPage<AppUserRow>> users({
    String search = '',
    String role = '',
    int page = 1,
    int perPage = 50,
  }) async {
    final body = await ApiClient.get(
      '/api/v1/owner/user',
      query: {
        'search': search,
        'role': role,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<AppUserRow>(body, AppUserRow.fromJson);
  }

  Future<AppUserRow> createUser({
    required String nama,
    required String username,
    required String password,
    required String role,
    required String status,
  }) async {
    final body = await ApiClient.post('/api/v1/owner/user', {
      'nama': nama,
      'username': username,
      'password': password,
      'role': role,
      'status': status,
    });
    return AppUserRow.fromJson(Map.from(body['data'] as Map));
  }

  Future<AppUserRow> updateUser(
    int id, {
    required String nama,
    required String username,
    required String role,
    required String status,
    String password = '',
  }) async {
    final body = await ApiClient.put('/api/v1/owner/user/$id', {
      'nama': nama,
      'username': username,
      'role': role,
      'status': status,
      'password': password,
    });
    return AppUserRow.fromJson(Map.from(body['data'] as Map));
  }

  Future<void> deleteUser(int id) async {
    await ApiClient.delete('/api/v1/owner/user/$id');
  }

  Future<OwnerDashboardData> dashboard({required int year, required int month}) async {
    final body = await ApiClient.get(
      '/api/v1/owner/dashboard',
      query: {'year': '$year', 'month': '$month'},
    );
    return OwnerDashboardData.fromJson(Map.from(body['data'] as Map));
  }

  Future<LaporanData> laporan({required int year, int? month}) async {
    final body = await ApiClient.get(
      '/api/v1/owner/laporan',
      query: {'year': '$year', 'month': month == null ? '' : '$month'},
    );
    return LaporanData.fromJson(Map.from(body['data'] as Map));
  }

  /// Mengunduh file laporan (excel/pdf) biner ter-autentikasi.
  Future<List<int>> downloadExport({
    required String jenis,
    int? year,
    int? month,
  }) async {
    assert(jenis == 'excel' || jenis == 'pdf');
    return ApiClient.getBytes(
      '/api/v1/owner/laporan/export-$jenis',
      query: {
        'year': year == null ? '' : '$year',
        'month': month == null ? '' : '$month',
      },
    );
  }
}

/// Hasil unduhan laporan (path disimpan di tempat publik untuk berbagi).
class ExportedReport {
  ExportedReport({required this.fileName, required this.size, required this.path});

  final String fileName;
  final int size;
  final String path;
}