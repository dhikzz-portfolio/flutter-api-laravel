import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Semua format tanggal di aplikasi memakai locale 'id'. Data simbol locale
  // harus dimuat lebih dulu, jika tidak DateFormat('...', 'id') melempar
  // LocaleDataException saat runtime.
  await initializeDateFormatting('id');

  runApp(const FinKuApp());
}
