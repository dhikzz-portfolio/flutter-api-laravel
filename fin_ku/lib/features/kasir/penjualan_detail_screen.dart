import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/utils/receipt_printer.dart';
import '../../core/widgets/common.dart';
import '../transaksi/data/transaksi_repository.dart';

/// Nota/detail transaksi penjualan (menyerupai halaman nota web).
/// Mengembalikan `true` bila transaksi dibatalkan.
class SaleDetailScreen extends StatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId});

  final int saleId;

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  final _repo = KasirRepository();
  Sale? _sale;
  String _error = '';
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final sale = await _repo.penjualanDetail(widget.saleId);
      if (!mounted) return;
      setState(() => _sale = sale);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmCancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Batalkan Transaksi?',
      message: 'Stok produk akan dikembalikan oleh server dan transaksi '
          '$saleInvoice ditandai dibatalkan.',
      confirmLabel: 'Ya, Batalkan',
      destructive: true,
    );
    if (!ok || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await _repo.batalPenjualan(widget.saleId);
      if (!mounted) return;
      showInfoSnack(context, 'Penjualan berhasil dibatalkan.');
      await _load();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      showErrorSnack(context, errorText(e));
    }
  }

  String get saleInvoice => _sale?.invoice ?? 'transaksi ini';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penjualan'),
        actions: [
          IconButton(
            tooltip: 'Cetak Nota',
            icon: const Icon(Icons.print_outlined),
            onPressed: _sale == null
                ? null
                : () => ReceiptPrinter.printReceipt(_sale!),
          ),
        ],
      ),
      backgroundColor: FinKuColors.bg,
      body: _loading
          ? const LoadingView()
          : _error.isNotEmpty
              ? ErrorView(message: _error, onRetry: _load)
              : _buildNota(context),
      bottomNavigationBar: (_sale != null && _sale!.isActive)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: FinKuColors.danger),
                    onPressed: _cancelling ? null : _confirmCancel,
                    child: _cancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Batalkan Transaksi'),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildNota(BuildContext context) {
    final sale = _sale!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          FinKuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nota Transaksi',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                    if (sale.isCancelled)
                      const StatusChip(label: 'DIBATALKAN', color: Color(0xFFDC2626))
                    else
                      const StatusChip(label: 'AKTIF', color: Color(0xFF15803D)),
                  ],
                ),
                const Divider(height: 22),
                _infoRow('Invoice', sale.invoice),
                _infoRow('Tanggal', Fmt.tanggalPanjang(sale.tanggal)),
                _infoRow('Pembeli', sale.buyerNama),
                _infoRow('Kasir', sale.userNama),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FinKuCard(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sale.details.length,
              separatorBuilder: (_, _) => const Divider(height: 18),
              itemBuilder: (context, i) {
                final d = sale.details[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.namaProduk,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              '${d.jumlah} x ${Fmt.rupiah(d.hargaJual)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Fmt.rupiah(d.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          FinKuCard(
            child: Row(
              children: [
                const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600))),
                Text(
                  Fmt.rupiah(sale.total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}
