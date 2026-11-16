// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import '../models/transaction_model.dart';
import 'receipt_printer.dart';

Future<void> printReceipt(Sale sale) async {
  final htmlContent = ReceiptPrinter.generateHtmlReceipt(sale);

  // Sisipkan skrip auto-print agar dialog cetak langsung muncul
  final printHtml = htmlContent.replaceFirst(
    '</body>',
    '''
    <script>
      window.onload = function() {
        setTimeout(function() {
          window.focus();
          window.print();
        }, 150);
      };
    </script>
    </body>''',
  );

  final blob = html.Blob([printHtml], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Buka tab baru yang otomatis memunculkan dialog cetak.
  html.window.open(url, '_blank');
}
