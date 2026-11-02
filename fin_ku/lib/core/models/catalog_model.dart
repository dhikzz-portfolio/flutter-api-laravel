import '../utils/format.dart';

class Category {
  Category({
    required this.id,
    required this.nama,
    required this.status,
    this.productsCount = 0,
  });

  final int id;
  final String nama;
  final String status;
  final int productsCount;

  bool get isActive => status == 'aktif';

  static Category fromJson(Map<String, dynamic> json) => Category(
        id: Fmt.intv(json['id']),
        nama: (json['nama'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        productsCount: Fmt.intv(json['products_count']),
      );
}

class Product {
  Product({
    required this.id,
    required this.categoryId,
    required this.nama,
    required this.hargaJual,
    required this.stok,
    required this.stokMinimum,
    required this.hppRataRata,
    required this.status,
    this.category,
  });

  final int id;
  final int categoryId;
  final String nama;
  final double hargaJual;
  final int stok;
  final int stokMinimum;
  final double hppRataRata;
  final String status;
  final Category? category;

  bool get isActive => status == 'aktif';
  bool get isLowStock => stok <= stokMinimum;
  String get categoryName => category?.nama ?? '-';

  static Product fromJson(Map<String, dynamic> json) => Product(
        id: Fmt.intv(json['id']),
        categoryId: Fmt.intv(json['category_id']),
        nama: (json['nama'] ?? '').toString(),
        hargaJual: Fmt.dec(json['harga_jual']),
        stok: Fmt.intv(json['stok']),
        stokMinimum: Fmt.intv(json['stok_minimum']),
        hppRataRata: Fmt.dec(json['hpp_rata_rata']),
        status: (json['status'] ?? '').toString(),
        category: json['category'] == null
            ? null
            : Category.fromJson(Map.from(json['category'] as Map)),
      );
}

class Distributor {
  Distributor({
    required this.id,
    required this.nama,
    required this.telepon,
    required this.alamat,
    this.purchasesCount = 0,
  });

  final int id;
  final String nama;
  final String telepon;
  final String alamat;
  final int purchasesCount;

  static Distributor fromJson(Map<String, dynamic> json) {
    final t = json['telepon'];
    final a = json['alamat'];
    return Distributor(
      id: Fmt.intv(json['id']),
      nama: (json['nama'] ?? '').toString(),
      telepon: t == null ? '' : t.toString(),
      alamat: a == null ? '' : a.toString(),
      purchasesCount: Fmt.intv(json['purchases_count']),
    );
  }
}
