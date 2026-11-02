import '../utils/format.dart';
import 'catalog_model.dart';
import 'transaction_model.dart';

class KasirStats {
  KasirStats({
    required this.penjualanHariIni,
    required this.totalTransaksi,
    required this.stokMinimum,
  });

  final int penjualanHariIni;
  final double totalTransaksi;
  final int stokMinimum;

  static KasirStats fromJson(Map<String, dynamic> json) => KasirStats(
        penjualanHariIni: Fmt.intv(json['penjualan_hari_ini']),
        totalTransaksi: Fmt.dec(json['total_transaksi']),
        stokMinimum: Fmt.intv(json['stok_minimum']),
      );
}

class AdminStats {
  AdminStats({
    required this.pembelianHariIni,
    required this.barangMasuk,
    required this.barangKeluar,
    required this.produkStokMinimum,
  });

  final int pembelianHariIni;
  final int barangMasuk;
  final int barangKeluar;
  final List<Product> produkStokMinimum;

  static AdminStats fromJson(Map<String, dynamic> json) {
    final list = json['produk_stok_minimum'] is List
        ? json['produk_stok_minimum'] as List
        : <dynamic>[];
    return AdminStats(
      pembelianHariIni: Fmt.intv(json['pembelian_hari_ini']),
      barangMasuk: Fmt.intv(json['barang_masuk']),
      barangKeluar: Fmt.intv(json['barang_keluar']),
      produkStokMinimum:
          list.map((e) => Product.fromJson(Map.from(e as Map))).toList(),
    );
  }
}

class MonthlyReport {
  MonthlyReport({
    required this.bulan,
    required this.nama,
    required this.penjualan,
    required this.hpp,
    required this.laba,
  });

  final int bulan;
  final String nama;
  final double penjualan;
  final double hpp;
  final double laba;

  static MonthlyReport fromJson(Map<String, dynamic> json) => MonthlyReport(
        bulan: Fmt.intv(json['bulan']),
        nama: (json['nama'] ?? '').toString(),
        penjualan: Fmt.dec(json['penjualan']),
        hpp: Fmt.dec(json['hpp']),
        laba: Fmt.dec(json['laba']),
      );
}

class OwnerDashboardData {
  OwnerDashboardData({
    required this.year,
    required this.month,
    required this.totalPenjualan,
    required this.totalHpp,
    required this.labaKotor,
    required this.months,
  });

  final int year;
  final int month;
  final double totalPenjualan;
  final double totalHpp;
  final double labaKotor;
  final List<MonthlyReport> months;

  static OwnerDashboardData fromJson(Map<String, dynamic> json) {
    final list = json['months'] is List ? json['months'] as List : <dynamic>[];
    return OwnerDashboardData(
      year: Fmt.intv(json['year']),
      month: Fmt.intv(json['month']),
      totalPenjualan: Fmt.dec(json['total_penjualan']),
      totalHpp: Fmt.dec(json['total_hpp']),
      labaKotor: Fmt.dec(json['laba_kotor']),
      months: list.map((e) => MonthlyReport.fromJson(Map.from(e as Map))).toList(),
    );
  }
}

class LaporanData {
  LaporanData({
    required this.year,
    required this.month,
    required this.penjualan,
    required this.totalPenjualan,
    required this.totalHpp,
    required this.labaKotor,
    required this.monthlyData,
  });

  final int year;
  final int? month;
  final List<Sale> penjualan;
  final double totalPenjualan;
  final double totalHpp;
  final double labaKotor;
  final List<MonthlyReport> monthlyData;

  static LaporanData fromJson(Map<String, dynamic> json) {
    final list = json['penjualan'] is List ? json['penjualan'] as List : <dynamic>[];
    final months = json['monthly_data'] is List
        ? json['monthly_data'] as List
        : <dynamic>[];
    final m = json['month'];
    return LaporanData(
      year: Fmt.intv(json['year']),
      month: m == null ? null : Fmt.intv(m),
      penjualan: list.map((e) => Sale.fromJson(Map.from(e as Map))).toList(),
      totalPenjualan: Fmt.dec(json['total_penjualan']),
      totalHpp: Fmt.dec(json['total_hpp']),
      labaKotor: Fmt.dec(json['laba_kotor']),
      monthlyData: months.map((e) => MonthlyReport.fromJson(Map.from(e as Map))).toList(),
    );
  }
}
