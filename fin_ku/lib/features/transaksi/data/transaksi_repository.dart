import '../../../../core/models/report_model.dart';
import '../../../../core/models/transaction_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/network/api_client.dart';

class KasirRepository {
  Future<KasirStats> dashboard() async {
    final body = await ApiClient.get('/api/v1/kasir/dashboard');
    return KasirStats.fromJson(Map.from(body['data'] as Map));
  }

  Future<ApiPage<Sale>> penjualan({
    String search = '',
    String dateFrom = '',
    String dateTo = '',
    int page = 1,
    int perPage = 15,
  }) async {
    final body = await ApiClient.get(
      '/api/v1/kasir/penjualan',
      query: {
        'search': search,
        'date_from': dateFrom,
        'date_to': dateTo,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<Sale>(body, Sale.fromJson);
  }

  Future<Sale> penjualanDetail(int id) async {
    final body = await ApiClient.get('/api/v1/kasir/penjualan/$id');
    return Sale.fromJson(Map.from(body['data'] as Map));
  }

  Future<Sale> createPenjualan({
    required int buyerId,
    required List<CartProduct> items,
  }) async {
    final body = await ApiClient.post('/api/v1/kasir/penjualan', {
      'buyer_id': buyerId,
      'items': items
          .map((e) => {'product_id': e.productId, 'jumlah': e.jumlah})
          .toList(),
    });
    return Sale.fromJson(Map.from(body['data'] as Map));
  }

  /// Pembatalan transaksi: stok dikembalikan di server.
  Future<void> batalPenjualan(int id) async {
    await ApiClient.post('/api/v1/kasir/penjualan/$id/batal', {});
  }

  Future<ApiPage<Buyer>> pembeli({String search = '', int page = 1, int perPage = 15}) async {
    final body = await ApiClient.get(
      '/api/v1/kasir/pembeli',
      query: {'search': search, 'page': '$page', 'per_page': '$perPage'},
    );
    return ApiPage.parse<Buyer>(body, Buyer.fromJson);
  }

  Future<Buyer> createPembeli({
    required String nama,
    required String telepon,
    required String alamat,
  }) async {
    final body = await ApiClient.post('/api/v1/kasir/pembeli', {
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
    });
    return Buyer.fromJson(Map.from(body['data'] as Map));
  }

  Future<Buyer> updatePembeli(
    int id, {
    required String nama,
    required String telepon,
    required String alamat,
  }) async {
    final body = await ApiClient.put('/api/v1/kasir/pembeli/$id', {
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
    });
    return Buyer.fromJson(Map.from(body['data'] as Map));
  }
}

class PembelianRepository {
  Future<ApiPage<Purchase>> pembelian({
    String search = '',
    String status = '',
    String dateFrom = '',
    String dateTo = '',
    int page = 1,
    int perPage = 15,
  }) async {
    final body = await ApiClient.get(
      '/api/v1/admin/pembelian',
      query: {
        'search': search,
        'status': status,
        'date_from': dateFrom,
        'date_to': dateTo,
        'page': '$page',
        'per_page': '$perPage',
      },
    );
    return ApiPage.parse<Purchase>(body, Purchase.fromJson);
  }

  Future<Purchase> createPembelian({
    required int distributorId,
    required List<CartProduct> items,
  }) async {
    final body = await ApiClient.post('/api/v1/admin/pembelian', {
      'distributor_id': distributorId,
      'items': items
          .map((e) => {
                'product_id': e.productId,
                'jumlah': e.jumlah,
                'harga_beli': e.hargaBeli ?? 0,
              })
          .toList(),
    });
    return Purchase.fromJson(Map.from(body['data'] as Map));
  }

  Future<void> batalPembelian(int id) async {
    await ApiClient.post('/api/v1/admin/pembelian/$id/batal', {});
  }
}

class AdminStokRepository {
  AdminStokRepository({this.dashboardPath = '/api/v1/admin'});

  final String dashboardPath;

  Future<AdminStats> dashboard() async {
    final body = await ApiClient.get('$dashboardPath/dashboard');
    return AdminStats.fromJson(Map.from(body['data'] as Map));
  }

  Future<StockOut> createBarangKeluar({
    required String keterangan,
    required List<CartProduct> items,
  }) async {
    final body = await ApiClient.post('/api/v1/admin/barang-keluar', {
      'keterangan': keterangan,
      'items': items
          .map((e) => {
                'product_id': e.productId,
                'jumlah': e.jumlah,
                'jenis': e.jenis,
                'keterangan_item': e.keteranganItem,
              })
          .toList(),
    });
    return StockOut.fromJson(Map.from(body['data'] as Map));
  }

  Future<StockAdjustment> createKoreksiStok({
    required List<CartProduct> items,
  }) async {
    final body = await ApiClient.post('/api/v1/admin/koreksi-stok', {
      'items': items
          .map((e) => {
                'product_id': e.productId,
                'stok_fisik': e.stokFisik ?? 0,
                'alasan': e.alasan,
              })
          .toList(),
    });
    return StockAdjustment.fromJson(Map.from(body['data'] as Map));
  }
}
