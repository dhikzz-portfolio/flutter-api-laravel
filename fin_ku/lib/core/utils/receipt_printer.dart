import '../models/transaction_model.dart';
import 'receipt_printer_stub.dart'
    if (dart.library.html) 'receipt_printer_web.dart' as printer;

class ReceiptPrinter {
  ReceiptPrinter._();

  /// Mencetak nota belanja menggunakan dialog cetak bawaan sistem/browser
  /// atau membagikan teks struk pada platform mobile/desktop.
  static Future<void> printReceipt(Sale sale) async {
    await printer.printReceipt(sale);
  }

  /// Menghasilkan format struk teks polos (cocok untuk printer thermal & sharing).
  static String generatePlainReceipt(Sale sale) {
    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('            FIN-KU              ');
    buffer.writeln('   Sistem Informasi Keuangan    ');
    buffer.writeln('================================');
    buffer.writeln('Invoice : ${sale.invoice}');
    final d = sale.tanggal;
    final dateStr = d != null
        ? '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
        : '-';
    buffer.writeln('Tanggal : $dateStr');
    buffer.writeln('Pembeli : ${sale.buyerNama}');
    buffer.writeln('Kasir   : ${sale.userNama}');
    buffer.writeln('--------------------------------');
    for (final item in sale.details) {
      buffer.writeln(item.namaProduk);
      buffer.writeln(
        '  ${item.jumlah} x Rp ${_formatNum(item.hargaJual)} = Rp ${_formatNum(item.subtotal)}',
      );
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('TOTAL   : Rp ${_formatNum(sale.total)}');
    buffer.writeln('================================');
    buffer.writeln(' Terima kasih atas kunjungan Anda');
    buffer.writeln(' Barang yang sudah dibeli tidak ');
    buffer.writeln('       dapat dikembalikan       ');
    buffer.writeln('================================');
    return buffer.toString();
  }

  /// Menghasilkan format dokumen HTML nota belanja (persis nota.blade.php Laravel).
  static String generateHtmlReceipt(Sale sale) {
    final itemsHtml = sale.details.map((d) {
      return '''
            <div class="item">
                <div>
                    <p><strong>${_escape(d.namaProduk)}</strong></p>
                    <p>${d.jumlah} x Rp ${_formatNum(d.hargaJual)}</p>
                </div>
                <div>Rp ${_formatNum(d.subtotal)}</div>
            </div>
      ''';
    }).join('\n');

    final d = sale.tanggal;
    final dateStr = d != null
        ? '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
        : '-';

    return '''<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nota ${_escape(sale.invoice)}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Courier New', Courier, monospace; font-size: 12px; background: #f5f5f5; padding: 20px; }
        .nota { background: white; max-width: 300px; margin: 0 auto; padding: 15px; border: 1px solid #ddd; }
        .header { text-align: center; border-bottom: 2px dashed #333; padding-bottom: 10px; margin-bottom: 10px; }
        .header h1 { font-size: 16px; margin-bottom: 5px; letter-spacing: 0.5px; }
        .header p { font-size: 11px; color: #555; }
        .info { margin-bottom: 10px; font-size: 11.5px; }
        .info p { margin-bottom: 2px; }
        .items { border-top: 1px dashed #333; border-bottom: 1px dashed #333; padding: 10px 0; margin-bottom: 10px; }
        .item { display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 11.5px; }
        .item p { margin-bottom: 1px; }
        .total { text-align: right; font-weight: bold; font-size: 14px; margin-top: 10px; }
        .footer { text-align: center; margin-top: 15px; font-size: 10px; color: #666; line-height: 1.4; }
        .btn-print { display: block; max-width: 300px; margin: 20px auto; padding: 10px; background: #4f46e5; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-family: sans-serif; font-weight: bold; }
        @media print {
            body { background: white; padding: 0; }
            .btn-print { display: none; }
            .nota { border: none; max-width: 100%; width: 100%; padding: 0; }
        }
    </style>
</head>
<body>
    <div class="nota">
        <div class="header">
            <h1>FIN-KU</h1>
            <p>Sistem Informasi Keuangan</p>
        </div>

        <div class="info">
            <p><strong>Invoice:</strong> ${_escape(sale.invoice)}</p>
            <p><strong>Tanggal:</strong> $dateStr</p>
            <p><strong>Pembeli:</strong> ${_escape(sale.buyerNama)}</p>
            <p><strong>Kasir:</strong> ${_escape(sale.userNama)}</p>
        </div>

        <div class="items">
$itemsHtml
        </div>

        <div class="total">
            <p>TOTAL: Rp ${_formatNum(sale.total)}</p>
        </div>

        <div class="footer">
            <p>Terima kasih atas kunjungan Anda</p>
            <p>Barang yang sudah dibeli tidak dapat</p>
            <p>dikembalikan</p>
        </div>
    </div>
</body>
</html>''';
  }

  static String _formatNum(num value) {
    final str = value.round().toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  static String _escape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}
