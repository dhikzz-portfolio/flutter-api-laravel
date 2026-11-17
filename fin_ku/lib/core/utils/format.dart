import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static final NumberFormat _number = NumberFormat.decimalPattern('id');

  static String rupiah(num value) => 'Rp ${_number.format(value.round())}';

  static String number(num value) => _number.format(value);

  /// Backend mengirim nilai decimal sebagai string "55000.00", int biasa,
  /// atau double. Helper aman untuk ketiga bentuk tersebut.
  static double dec(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int intv(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return num.tryParse(value.toString())?.toInt() ?? 0;
  }

  static DateTime? date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String tanggal(dynamic value) {
    final d = date(value);
    if (d == null) return '-';
    return DateFormat('d MMM y', 'id').format(d);
  }

  static String tanggalPanjang(dynamic value) {
    final d = date(value);
    if (d == null) return '-';
    return DateFormat('EEEE, d MMMM y', 'id').format(d);
  }

  static String jam(dynamic value) {
    final d = date(value);
    if (d == null) return '-';
    return DateFormat('d MMM y, HH:mm', 'id').format(d);
  }

  static String namaBulan(int month) {
    const names = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  static String inisial(String nama) {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class InputDecorationX {
  InputDecorationX._();

  static InputDecoration field({
    String? label,
    String? hint,
    String? errorText,
    bool dense = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: (errorText == null || errorText.isEmpty) ? null : errorText,
      isDense: dense,
      border: OutlineInputBorder(),
    );
  }

  static InputDecoration search({
    required String hint,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: (errorText == null || errorText.isEmpty) ? null : errorText,
      prefixIcon: const Icon(Icons.search),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
