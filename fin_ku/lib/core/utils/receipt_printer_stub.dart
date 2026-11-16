import 'package:share_plus/share_plus.dart';

import '../models/transaction_model.dart';
import 'receipt_printer.dart';

Future<void> printReceipt(Sale sale) async {
  final text = ReceiptPrinter.generatePlainReceipt(sale);
  await SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: 'Nota Belanja ${sale.invoice}',
    ),
  );
}
