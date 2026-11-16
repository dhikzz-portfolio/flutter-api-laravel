import 'dart:typed_data';

import 'file_exporter_stub.dart'
    if (dart.library.html) 'file_exporter_web.dart' as exporter;

/// Menyimpan/membagikan file unduhan (Excel/PDF) hasil ekspor laporan.
/// Di web file langsung diunduh, di desktop/mobile dibagikan lewat share sheet.
class FileExporter {
  FileExporter._();

  static Future<void> saveAndShare({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    await exporter.saveAndShare(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
