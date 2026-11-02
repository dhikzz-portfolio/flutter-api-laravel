import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../transaksi/data/transaksi_repository.dart';
import 'penjualan_detail_screen.dart';
import 'pos_form_screen.dart';

/// Daftar transaksi penjualan kasir: pencarian, filter tanggal via dialog,
/// pemuatan bertahap (load more), detail, dan pembatalan transaksi.
class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final _repo = KasirRepository();
  final _scroll = ScrollController();

  List<Sale> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';
  String _search = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool get _canLoadMore => _page < _lastPage && !_loadingMore;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240 &&
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final page = await _repo.penjualan(
        search: _search,
        dateFrom: _dateFrom == null ? '' : _dateFrom!.toIso8601String().substring(0, 10),
        dateTo: _dateTo == null ? '' : _dateTo!.toIso8601String().substring(0, 10),
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
      final next = await _repo.penjualan(
        search: _search,
        dateFrom: _dateFrom == null ? '' : _dateFrom!.toIso8601String().substring(0, 10),
        dateTo: _dateTo == null ? '' : _dateTo!.toIso8601String().substring(0, 10),
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

  Future<void> _pickDateFilter() async {
    final now = DateTime.now();
    final initial = _dateFrom ?? DateTime(now.year, now.month, 1);
    final from = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Tanggal mulai',
    );
    if (from == null || !mounted) return;
    final to = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? from,
      firstDate: from,
      lastDate: DateTime(now.year + 5),
      helpText: 'Tanggal akhir',
    );
    if (!mounted) return;
    setState(() {
      _dateFrom = from;
      _dateTo = to ?? from;
    });
    _load();
  }

  /// Buka detail/nota; balikin true bila ada perubahan (pembatalan).
  Future<void> _openDetail(Sale sale) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SaleDetailScreen(saleId: sale.id)),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjualan'),
        actions: [
          IconButton(
            tooltip: 'Filter tanggal',
            icon: const Icon(Icons.filter_list),
            onPressed: _pickDateFilter,
          ),
        ],
      ),
      backgroundColor: FinKuColors.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: FinKuColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.point_of_sale),
        label: const Text('Transaksi Baru'),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PosFormScreen()),
          );
          if (created == true) _load();
        },
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                SearchField(
                  hint: 'Cari invoice / nama pembeli...',
                  onSubmitted: (v) {
                    _search = v;
                    _load();
                  },
                ),
                if (_dateFrom != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconIconsUtils.filterChip(
                        label: '${Fmt.tanggal(_dateFrom)} s/d ${Fmt.tanggal(_dateTo ?? _dateFrom)}',
                        onRemove: () {
                          setState(() {
                            _dateFrom = null;
                            _dateTo = null;
                          });
                          _load();
                        },
                      ),
                    ],
                  ),
                ],
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
                            icon: Icons.receipt_long,
                            title: 'Belum ada transaksi',
                            subtitle:
                                'Tekan "Transaksi Baru" untuk mencatat penjualan pertama.',
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
                                final sale = _items[i];
                                return _SaleTile(sale: sale, onTap: () => _openDetail(sale));
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/// Tile ringkasan penjualan (kartu putih, invoice + pembeli + total).
class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale, required this.onTap});

  final Sale sale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FinKuColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FinKuColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: FinKuColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sale.invoice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (sale.isCancelled)
                          const StatusChip(label: 'DIBATALKAN', color: Color(0xFFDC2626))
                        else
                          const StatusChip(label: 'AKTIF', color: Color(0xFF15803D)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sale.buyerNama,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Fmt.tanggal(sale.tanggal)}  ·  Kasir: ${sale.userNama}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Fmt.rupiah(sale.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Util kecil untuk chip filter agar tidak mengulang komponen.
class IconIconsUtils {
  static Widget filterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF4338CA), fontSize: 12),
          ),
          InkWell(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: Color(0xFF4338CA)),
            ),
          ),
        ],
      ),
    );
  }
}
