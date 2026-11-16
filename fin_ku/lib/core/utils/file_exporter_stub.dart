import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<void> saveAndShare({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  final file = XFile.fromData(
    bytes,
    name: fileName,
    mimeType: mimeType,
  );

  await SharePlus.instance.share(
    ShareParams(
      files: [file],
      fileNameOverrides: [fileName],
      subject: fileName,
    ),
  );
}
