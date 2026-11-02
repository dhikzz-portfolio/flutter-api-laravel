import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/catalog_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';
import '../transaksi/data/transaksi_repository.dart';

/// Koreksi stok (stok opname): daftar dokumen dan form selisih stok fisik.
class KoreksiStokScreen extends StatefulWidget {
  const KoreksiStokScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  State<KoreksiStokScreen> createState() => _KoreksiStokScreenState();
}

class _KoreksiStokScreenState extends State<KoreksiStokScreen> {
  final _repo = KatalogRepository(basePath: '/api/v1/admin');
  final _scroll = ScrollController();

  List<StockAdjustment> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';

  bool get _canLoadMore => _page < _lastPage && !_loadingMore;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final page = await _repo.koreksiStok();
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
      final next = await _repo.koreksiStok(page: _page + 1);
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

  Future<void> _openCreate() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const KoreksiStokFormScreen()),
    );
    if (saved == true) _load();
  }

  void _openDetail(StockAdjustment item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _KoreksiDetail(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koreksi Stok'),
        leading: widget.isEmbedded
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      backgroundColor: FinKuColors.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: FinKuColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.tune),
        label: const Text('Koreksi Baru'),
        onPressed: _openCreate,
      ),
      body: _loading
          ? const LoadingView()
          : _error.isNotEmpty
              ? ErrorView(message: _error, onRetry: _load)
              : _items.isEmpty
                  ? const EmptyView(
                      icon: Icons.tune,
                      title: 'Belum ada koreksi stok',
                      subtitle: 'Catat hasil stok opname fisik di sini.',
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
                          final item = _items[i];
                          final selisih =
                              item.details.fold<int>(0, (a, d) => a + d.selisih);
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openDetail(item),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
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
                                          Fmt.tanggal(item.tanggal),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                      StatusChip(
                                        label: '${item.details.length} PRODUK',
                                        color: FinKuColors.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'Total selisih: ${selisih >= 0 ? '+' : ''}$selisih unit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: selisih == 0
                                              ? FinKuColors.textSecondary
                                              : (selisih > 0
                                                  ? FinKuColors.success
                                                  : FinKuColors.danger),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item.userNama,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: FinKuColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _KoreksiDetail extends StatelessWidget {
  const _KoreksiDetail({required this.item});

  final StockAdjustment item;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Detail Koreksi Stok',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${Fmt.tanggal(item.tanggal)} · ${item.userNama}',
            style: const TextStyle(fontSize: 12.5, color: FinKuColors.textSecondary),
          ),
          const Divider(height: 24),
          for (final d in item.details)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: FinKuColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.namaProduk,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Metric(label: 'Sistem', value: '${d.stokSebelum}'),
                      _Metric(label: 'Fisik', value: '${d.stokFisik}'),
                      _Metric(
                        label: 'Selisih',
                        value: '${d.selisih >= 0 ? '+' : ''}${d.selisih}',
                        color: d.selisih == 0
                            ? FinKuColors.textPrimary
                            : (d.selisih > 0 ? FinKuColors.success : FinKuColors.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.alasan,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: FinKuColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: FinKuColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color ?? FinKuColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Form koreksi stok: selisih dihitung dari stok fisik - stok sistem.
class KoreksiStokFormScreen extends StatefulWidget {
  const KoreksiStokFormScreen({super.key});

  @override
  State<KoreksiStokFormScreen> createState() => _KoreksiStokFormScreenState();
}

class _KoreksiStokFormScreenState extends State<KoreksiStokFormScreen> {
  final _repo = AdminStokRepository();
  final _productRepo = KatalogRepository(basePath: '/api/v1/admin');

  List<Product> _products = [];
  final List<_KoreksiItem> _items = [];
  bool _loadingProducts = true;
  bool _submitting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    for (final i in _items) {
      i.stokFisik.dispose();
      i.alasan.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final page = await _productRepo.produk(perPage: 100);
      if (!mounted) return;
      setState(() => _products = page.items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  void _addItem() {
    if (_products.isEmpty) {
      showErrorSnack(context, 'Belum ada produk yang dapat dikoreksi.');
      return;
    }
    setState(() => _items.add(_KoreksiItem(_products.first)));
  }

  void _removeItem(int index) {
    setState(() {
      final item = _items.removeAt(index);
      item.stokFisik.dispose();
      item.alasan.dispose();
    });
  }

  Future<void> _submit() async {
    if (_items.isEmpty) {
      setState(() => _error = 'Tambahkan minimal satu produk yang dikoreksi.');
      return;
    }

    final payload = <CartProduct>[];
    for (final item in _items) {
      final fisik = int.tryParse(item.stokFisik.text.trim());
      if (fisik == null || fisik < 0) {
        setState(() => _error = 'Stok fisik ${item.product.nama} wajib angka >= 0.');
        return;
      }
      if (item.alasan.text.trim().isEmpty) {
        setState(() => _error = 'Alasan koreksi ${item.product.nama} wajib diisi.');
        return;
      }
      payload.add(CartProduct(
        productId: item.product.id,
        nama: item.product.nama,
        jumlah: 1,
        stokFisik: fisik,
        alasan: item.alasan.text.trim(),
      ));
    }

    setState(() {
      _submitting = true;
      _error = '';
    });
    try {
      await _repo.createKoreksiStok(items: payload);
      if (!mounted) return;
      showInfoSnack(context, 'Koreksi stok berhasil dicatat.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = errorText(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koreksi Stok Baru')),
      backgroundColor: FinKuColors.bg,
      body: _loadingProducts
          ? const LoadingView(message: 'Memuat produk...')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FinKuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Form Koreksi Stok',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Selisih = Stok Fisik - Stok Sistem',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: FinKuColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconicAction(
                            icon: Icons.add,
                            label: 'Tambah Item',
                            onTap: _addItem,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_items.isEmpty)
                        const EmptyView(
                          icon: Icons.list_alt,
                          title: 'Belum ada item',
                          subtitle: 'Tekan "Tambah Item" untuk memilih produk.',
                        ),
                      for (var i = 0; i < _items.length; i++)
                        _KoreksiItemCard(
                          key: ValueKey(_items[i]),
                          item: _items[i],
                          products: _products,
                          onChanged: () => setState(() {}),
                          onRemove: () => _removeItem(i),
                        ),
                    ],
                  ),
                ),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error,
                    style: const TextStyle(color: FinKuColors.danger, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Koreksi'),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _KoreksiItem {
  _KoreksiItem(this.product)
      : stokFisik = TextEditingController(),
        alasan = TextEditingController();

  Product product;
  final TextEditingController stokFisik;
  final TextEditingController alasan;

  int? get fisik => int.tryParse(stokFisik.text.trim());

  int? get selisih => fisik == null ? null : fisik! - product.stok;
}

class _KoreksiItemCard extends StatelessWidget {
  const _KoreksiItemCard({
    required this.item,
    required this.products,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final _KoreksiItem item;
  final List<Product> products;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selisih = item.selisih;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FinKuColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: item.product.id,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Produk',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final p in products)
                      DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          '${p.nama} (stok ${p.stok})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    final found = products.where((p) => p.id == v).toList();
                    if (found.isNotEmpty) {
                      item.product = found.first;
                      onChanged();
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: FinKuColors.danger, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Stok Sistem',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: Text('${item.product.stok}', style: const TextStyle(fontSize: 13.5)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: item.stokFisik,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Stok Fisik',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Selisih',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: Text(
                    selisih == null ? '-' : '${selisih >= 0 ? '+' : ''}$selisih',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: selisih == null
                          ? FinKuColors.textSecondary
                          : (selisih == 0
                              ? FinKuColors.textPrimary
                              : (selisih > 0 ? FinKuColors.success : FinKuColors.danger)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: item.alasan,
            decoration: const InputDecoration(
              labelText: 'Alasan koreksi',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
