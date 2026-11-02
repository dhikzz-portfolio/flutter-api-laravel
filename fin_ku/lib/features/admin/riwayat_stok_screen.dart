import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/models/catalog_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';

/// Riwayat pergerakan stok. Dipakai admin (bisa difilter) dan owner (baca).
class RiwayatStokScreen extends StatefulWidget {
  const RiwayatStokScreen({super.key, this.readOnly = false, this.isEmbedded = false});

  final bool readOnly;
  final bool isEmbedded;

  @override
  State<RiwayatStokScreen> createState() => _RiwayatStokScreenState();
}

class _RiwayatStokScreenState extends State<RiwayatStokScreen> {
  late final KatalogRepository _repo =
      KatalogRepository(basePath: widget.readOnly ? '/api/v1/owner' : '/api/v1/admin');
  final _scroll = ScrollController();

  List<StockMovement> _items = [];
  List<Product> _products = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';

  int _productId = 0;
  String _jenis = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  bool get _canLoadMore => _page < _lastPage && !_loadingMore;

  static const _jenisOptions = [
    ('', 'Semua Jenis'),
    ('PEMBELIAN', 'Pembelian'),
    ('PENJUALAN', 'Penjualan'),
    ('BARANG_KELUAR', 'Barang Keluar'),
    ('KOREKSI', 'Koreksi'),
    ('PEMBATALAN_PEMBELIAN', 'Pembatalan Pembelian'),
    ('PEMBATALAN_PENJUALAN', 'Pembatalan Penjualan'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _loadProducts();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
          _canLoadMore &&
          !_loading) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String get _dateFromParam =>
      _dateFrom == null ? '' : DateFormat('yyyy-MM-dd').format(_dateFrom!);

  String get _dateToParam =>
      _dateTo == null ? '' : DateFormat('yyyy-MM-dd').format(_dateTo!);

  Future<void> _loadProducts() async {
    try {
      final page = await KatalogRepository(basePath: '/api/v1/admin')
          .produk(perPage: 100);
      if (!mounted) return;
      setState(() => _products = page.items);
    } catch (_) {
      // Filter produk bersifat opsional; kegagalan tidak menghalangi riwayat.
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final page = await _repo.riwayatStok(
        productId: _productId,
        jenis: _jenis,
        dateFrom: _dateFromParam,
        dateTo: _dateToParam,
      );
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _page = page.currentPage;
        _lastPage = page.lastPage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final next = await _repo.riwayatStok(
        productId: _productId,
        jenis: _jenis,
        dateFrom: _dateFromParam,
        dateTo: _dateToParam,
        page: _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(next.items.where((n) => _items.every((e) => e.id != n.id)));
        _page = next.currentPage;
        _lastPage = next.lastPage;
      });
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, errorText(e));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _pickDate({required bool from}) async {
    final now = DateTime.now();
    final initial = (from ? _dateFrom : _dateTo) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      helpText: from ? 'Tanggal mulai' : 'Tanggal akhir',
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
    _load();
  }

  void _clearFilters() {
    setState(() {
      _productId = 0;
      _jenis = '';
      _dateFrom = null;
      _dateTo = null;
    });
    _load();
  }

  Color _jenisColor(String jenis) {
    switch (jenis) {
      case 'PEMBELIAN':
        return FinKuColors.success;
      case 'PENJUALAN':
        return const Color(0xFF1D4ED8);
      case 'BARANG_KELUAR':
        return const Color(0xFFB45309);
      case 'KOREKSI':
        return const Color(0xFFA16207);
      case 'PEMBATALAN_PEMBELIAN':
        return FinKuColors.danger;
      case 'PEMBATALAN_PENJUALAN':
        return const Color(0xFF7E22CE);
      default:
        return FinKuColors.textSecondary;
    }
  }

  String _jenisLabel(String jenis) => jenis.replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Riwayat Stok (Data Toko)' : 'Riwayat Stok'),
        leading: widget.isEmbedded
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Reset filter',
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
        ],
      ),
      backgroundColor: FinKuColors.bg,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _productId,
                        isExpanded: true,
                        itemHeight: null,
                        decoration: const InputDecoration(
                          labelText: 'Produk',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: 0, child: Text('Semua Produk')),
                          for (final p in _products)
                            DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nama, overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (v) {
                          _productId = v ?? 0;
                          _load();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _jenis,
                        isExpanded: true,
                        itemHeight: null,
                        decoration: const InputDecoration(
                          labelText: 'Jenis',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          for (final j in _jenisOptions)
                            DropdownMenuItem(
                              value: j.$1,
                              child: Text(j.$2, overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (v) {
                          _jenis = v ?? '';
                          _load();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(from: true),
                        icon: const Icon(Icons.event, size: 16),
                        label: Text(
                          _dateFrom == null ? 'Dari tanggal' : Fmt.tanggal(_dateFrom),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(from: false),
                        icon: const Icon(Icons.event, size: 16),
                        label: Text(
                          _dateTo == null ? 'Sampai tanggal' : Fmt.tanggal(_dateTo),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error.isNotEmpty
                    ? ErrorView(message: _error, onRetry: _load)
                    : _items.isEmpty
                        ? const EmptyView(
                            icon: Icons.history,
                            title: 'Belum ada riwayat stok',
                            subtitle: 'Coba ubah filter produk, jenis, atau tanggal.',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              controller: _scroll,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _items.length + (_canLoadMore ? 1 : 0),
                              itemBuilder: (context, i) {
                                if (i >= _items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2.2),
                                      ),
                                    ),
                                  );
                                }
                                final m = _items[i];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: FinKuColors.cardBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              m.namaProduk,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ),
                                          StatusChip(
                                            label: _jenisLabel(m.jenis),
                                            color: _jenisColor(m.jenis),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            '${m.stokSebelum} → ${m.stokSesudah}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: FinKuColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${m.jumlah >= 0 ? '+' : ''}${m.jumlah}',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: m.jumlah >= 0
                                                  ? FinKuColors.success
                                                  : FinKuColors.danger,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            Fmt.tanggal(m.tanggal),
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: FinKuColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (m.keterangan.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          m.keterangan,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: FinKuColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 2),
                                      Text(
                                        'oleh ${m.userNama}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
