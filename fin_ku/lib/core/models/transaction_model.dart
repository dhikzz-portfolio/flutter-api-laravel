import '../utils/format.dart';
import 'user_model.dart';

class Buyer {
  Buyer({
    required this.id,
    required this.nama,
    required this.telepon,
    required this.alamat,
  });

  final int id;
  final String nama;
  final String telepon;
  final String alamat;

  static Buyer fromJson(Map<String, dynamic> json) {
    final t = json['telepon'];
    final a = json['alamat'];
    return Buyer(
      id: Fmt.intv(json['id']),
      nama: (json['nama'] ?? '').toString(),
      telepon: t == null ? '' : t.toString(),
      alamat: a == null ? '' : a.toString(),
    );
  }
}

class CartProduct {
  CartProduct({
    required this.productId,
    required this.nama,
    required this.jumlah,
    this.hargaBeli,
    this.jenis,
    this.stokFisik,
    this.keteranganItem,
    this.alasan,
  });

  final int productId;
  final String nama;
  final int jumlah;
  final double? hargaBeli;
  final String? jenis;
  final int? stokFisik;
  final String? keteranganItem;
  final String? alasan;

  double get subtotal => (hargaBeli ?? 0) * jumlah;
}

class SaleDetail {
  SaleDetail({
    required this.id,
    required this.productId,
    required this.namaProduk,
    required this.hargaJual,
    required this.jumlah,
    required this.subtotal,
  });

  final int id;
  final int productId;
  final String namaProduk;
  final double hargaJual;
  final int jumlah;
  final double subtotal;

  static SaleDetail fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    return SaleDetail(
      id: Fmt.intv(json['id']),
      productId: Fmt.intv(json['product_id']),
      namaProduk: p == null ? '-' : (p['nama'] ?? '-').toString(),
      hargaJual: Fmt.dec(json['harga_jual']),
      jumlah: Fmt.intv(json['jumlah']),
      subtotal: Fmt.dec(json['subtotal']),
    );
  }
}

class Sale {
  Sale({
    required this.id,
    required this.invoice,
    required this.buyerId,
    required this.userId,
    required this.tanggal,
    required this.total,
    required this.status,
    required this.buyerNama,
    required this.userNama,
    this.buyer,
    this.user,
    this.details = const [],
  });

  final int id;
  final String invoice;
  final int buyerId;
  final int userId;
  final DateTime? tanggal;
  final double total;
  final String status;
  final String buyerNama;
  final String userNama;
  final Buyer? buyer;
  final AppUser? user;
  final List<SaleDetail> details;

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'dibatalkan';

  static Sale fromJson(Map<String, dynamic> json) {
    final buyer = json['buyer'];
    final user = json['user'];
    final detailList = json['sale_details'] is List
        ? json['sale_details'] as List
        : <dynamic>[];

    return Sale(
      id: Fmt.intv(json['id']),
      invoice: (json['invoice'] ?? '').toString(),
      buyerId: Fmt.intv(json['buyer_id']),
      userId: Fmt.intv(json['user_id']),
      tanggal: Fmt.date(json['tanggal']),
      total: Fmt.dec(json['total']),
      status: (json['status'] ?? '').toString(),
      buyerNama: buyer == null ? '-' : (buyer['nama'] ?? '-').toString(),
      userNama: user == null ? '-' : (user['nama'] ?? '-').toString(),
      buyer: buyer == null ? null : Buyer.fromJson(Map.from(buyer as Map)),
      user: user == null ? null : AppUser.fromJson(Map.from(user as Map)),
      details: detailList.map((e) => SaleDetail.fromJson(Map.from(e as Map))).toList(),
    );
  }
}

class PurchaseDetail {
  PurchaseDetail({
    required this.id,
    required this.productId,
    required this.namaProduk,
    required this.hargaBeli,
    required this.jumlah,
    required this.subtotal,
  });

  final int id;
  final int productId;
  final String namaProduk;
  final double hargaBeli;
  final int jumlah;
  final double subtotal;

  static PurchaseDetail fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    return PurchaseDetail(
      id: Fmt.intv(json['id']),
      productId: Fmt.intv(json['product_id']),
      namaProduk: p == null ? '-' : (p['nama'] ?? '-').toString(),
      hargaBeli: Fmt.dec(json['harga_beli']),
      jumlah: Fmt.intv(json['jumlah']),
      subtotal: Fmt.dec(json['subtotal']),
    );
  }
}

class Purchase {
  Purchase({
    required this.id,
    required this.invoice,
    required this.distributorId,
    required this.userId,
    required this.tanggal,
    required this.total,
    required this.status,
    required this.distributorNama,
    required this.userNama,
    this.details = const [],
  });

  final int id;
  final String invoice;
  final int distributorId;
  final int userId;
  final DateTime? tanggal;
  final double total;
  final String status;
  final String distributorNama;
  final String userNama;
  final List<PurchaseDetail> details;

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'dibatalkan';

  static Purchase fromJson(Map<String, dynamic> json) {
    final distributor = json['distributor'];
    final user = json['user'];
    final detailList = json['purchase_details'] is List
        ? json['purchase_details'] as List
        : <dynamic>[];

    return Purchase(
      id: Fmt.intv(json['id']),
      invoice: (json['invoice'] ?? '').toString(),
      distributorId: Fmt.intv(json['distributor_id']),
      userId: Fmt.intv(json['user_id']),
      tanggal: Fmt.date(json['tanggal']),
      total: Fmt.dec(json['total']),
      status: (json['status'] ?? '').toString(),
      distributorNama:
          distributor == null ? '-' : (distributor['nama'] ?? '-').toString(),
      userNama: user == null ? '-' : (user['nama'] ?? '-').toString(),
      details: detailList.map((e) => PurchaseDetail.fromJson(Map.from(e as Map))).toList(),
    );
  }
}

class StockOutDetail {
  StockOutDetail({
    required this.id,
    required this.productId,
    required this.namaProduk,
    required this.jenis,
    required this.jumlah,
    required this.keterangan,
  });

  final int id;
  final int productId;
  final String namaProduk;
  final String jenis;
  final int jumlah;
  final String keterangan;

  static StockOutDetail fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    final k = json['keterangan'];
    return StockOutDetail(
      id: Fmt.intv(json['id']),
      productId: Fmt.intv(json['product_id']),
      namaProduk: p == null ? '-' : (p['nama'] ?? '-').toString(),
      jenis: (json['jenis'] ?? '').toString(),
      jumlah: Fmt.intv(json['jumlah']),
      keterangan: k == null ? '' : k.toString(),
    );
  }
}

class StockOut {
  StockOut({
    required this.id,
    required this.tanggal,
    required this.keterangan,
    required this.userNama,
    required this.details,
  });

  final int id;
  final DateTime? tanggal;
  final String keterangan;
  final String userNama;
  final List<StockOutDetail> details;

  static StockOut fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final keterangan = json['keterangan'];
    final detailList = json['stock_out_details'] is List
        ? json['stock_out_details'] as List
        : <dynamic>[];

    return StockOut(
      id: Fmt.intv(json['id']),
      tanggal: Fmt.date(json['tanggal']),
      keterangan: keterangan == null ? '' : keterangan.toString(),
      userNama: user == null ? '-' : (user['nama'] ?? '-').toString(),
      details: detailList.map((e) => StockOutDetail.fromJson(Map.from(e as Map))).toList(),
    );
  }
}

class StockAdjustmentDetail {
  StockAdjustmentDetail({
    required this.id,
    required this.productId,
    required this.namaProduk,
    required this.stokSebelum,
    required this.stokFisik,
    required this.selisih,
    required this.alasan,
  });

  final int id;
  final int productId;
  final String namaProduk;
  final int stokSebelum;
  final int stokFisik;
  final int selisih;
  final String alasan;

  static StockAdjustmentDetail fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    final a = json['alasan'];
    return StockAdjustmentDetail(
      id: Fmt.intv(json['id']),
      productId: Fmt.intv(json['product_id']),
      namaProduk: p == null ? '-' : (p['nama'] ?? '-').toString(),
      stokSebelum: Fmt.intv(json['stok_sebelum']),
      stokFisik: Fmt.intv(json['stok_fisik']),
      selisih: Fmt.intv(json['selisih']),
      alasan: a == null ? '' : a.toString(),
    );
  }
}

class StockAdjustment {
  StockAdjustment({
    required this.id,
    required this.tanggal,
    required this.userNama,
    required this.details,
  });

  final int id;
  final DateTime? tanggal;
  final String userNama;
  final List<StockAdjustmentDetail> details;

  static StockAdjustment fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final detailList = json['stock_adjustment_details'] is List
        ? json['stock_adjustment_details'] as List
        : <dynamic>[];

    return StockAdjustment(
      id: Fmt.intv(json['id']),
      tanggal: Fmt.date(json['tanggal']),
      userNama: user == null ? '-' : (user['nama'] ?? '-').toString(),
      details: detailList
          .map((e) => StockAdjustmentDetail.fromJson(Map.from(e as Map)))
          .toList(),
    );
  }
}

class StockMovement {
  StockMovement({
    required this.id,
    required this.namaProduk,
    required this.jenis,
    required this.jumlah,
    required this.stokSebelum,
    required this.stokSesudah,
    required this.keterangan,
    required this.tanggal,
    required this.userNama,
  });

  final int id;
  final String namaProduk;
  final String jenis;
  final int jumlah;
  final int stokSebelum;
  final int stokSesudah;
  final String keterangan;
  final DateTime? tanggal;
  final String userNama;

  static StockMovement fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    final user = json['user'];
    final k = json['keterangan'];
    return StockMovement(
      id: Fmt.intv(json['id']),
      namaProduk: p == null ? '-' : (p['nama'] ?? '-').toString(),
      jenis: (json['jenis'] ?? '').toString(),
      jumlah: Fmt.intv(json['jumlah']),
      stokSebelum: Fmt.intv(json['stok_sebelum']),
      stokSesudah: Fmt.intv(json['stok_sesudah']),
      keterangan: k == null ? '' : k.toString(),
      tanggal: Fmt.date(json['tanggal']),
      userNama: user == null ? '-' : (user['nama'] ?? '-').toString(),
    );
  }
}
