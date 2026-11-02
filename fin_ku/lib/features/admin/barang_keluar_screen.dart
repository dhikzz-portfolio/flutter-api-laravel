import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/catalog_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';
import '../transaksi/data/transaksi_repository.dart';

/// Barang keluar: daftar dokumen dan pencatatan barang rusak/expired/keluar.
class BarangKeluarScreen extends StatefulWidget {
  const BarangKeluarScreen({super.key, this.readOnly = false, this.isEmbedded = false});

  final bool readOnly;
  final bool isEmbedded;

  @override
  State<BarangKeluarScreen> createState() => _BarangKeluarScreenState();
}

class _BarangKeluarScreenState extends State<BarangKeluarScreen> {
  late final KatalogRepository _repo =
      KatalogRepository(basePath: widget.readOnly ? '/api/v1/owner' : '/api/v1/admin');
  final _scroll = ScrollController();

  List<StockOut> _items = [];
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
      final page = await _repo.barangKeluar();
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
      final next = await _repo.barangKeluar(page: _page + 1);
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
      MaterialPageRoute(builder: (_) => const BarangKeluarFormScreen()),
    );
    if (saved == true) _load();
  }

  void _openDetail(StockOut item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _BarangKeluarDetail(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Barang Keluar (Data Toko)' : 'Barang Keluar'),
        leading: widget.isEmbedded
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      backgroundColor: FinKuColors.bg,
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              backgroundColor: FinKuColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.outbound_outlined),
              label: const Text('Catat Keluar'),
              onPressed: _openCreate,
            ),
      body: _loading
          ? const LoadingView()
          : _error.isNotEmpty
              ? ErrorView(message: _error, onRetry: _load)
              : _items.isEmpty
                  ? const EmptyView(
                      icon: Icons.outbox_outlined,
                      title: 'Belum ada barang keluar',
                      subtitle: 'Catat barang rusak, expired, atau diberikan.',
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
                          final totalQty = item.details.fold<int>(0, (a, d) => a + d.jumlah);
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
                                  if (item.keterangan.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.keterangan,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: FinKuColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    'Total keluar $totalQty unit · oleh ${item.userNama}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: FinKuColors.textSecondary,
                                    ),
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

class _BarangKeluarDetail extends StatelessWidget {
  const _BarangKeluarDetail({required this.item});

  final StockOut item;

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
            'Detail Barang Keluar',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${Fmt.tanggal(item.tanggal)} · ${item.userNama}',
            style: const TextStyle(fontSize: 12.5, color: FinKuColors.textSecondary),
          ),
          if (item.keterangan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.keterangan, style: const TextStyle(fontSize: 13)),
          ],
          const Divider(height: 24),
          for (final d in item.details)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.namaProduk,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d.keterangan.isEmpty ? d.jenis : '${d.jenis} · ${d.keterangan}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: FinKuColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${d.jumlah} unit',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: FinKuColors.danger,
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

/// Form pencatatan barang keluar dengan banyak item.
class BarangKeluarFormScreen extends StatefulWidget {
  const BarangKeluarFormScreen({super.key});

  @override
  State<BarangKeluarFormScreen> createState() => _BarangKeluarFormScreenState();
}

class _BarangKeluarFormScreenState extends State<BarangKeluarFormScreen> {
  final _keterangan = TextEditingController();
  final _repo = AdminStokRepository();
  final _productRepo = KatalogRepository(basePath: '/api/v1/admin');

  List<Product> _products = [];
  final List<_KeluarItem> _items = [];
  bool _loadingProducts = true;
  bool _submitting = false;
  String _error = '';

  static const _jenisOptions = {
    'RUSAK': 'Rusak',
    'EXPIRED': 'Expired',
    'DIBERIKAN': 'Diberikan',
    'LAINNYA': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _keterangan.dispose();
    for (final i in _items) {
      i.jumlah.dispose();
      i.keterangan.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final page = await _productRepo.produk(perPage: 100, status: 'aktif');
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
      showErrorSnack(context, 'Belum ada produk aktif yang dapat dipilih.');
      return;
    }
    setState(() {
      _items.add(_KeluarItem(_products.first));
    });
  }

  void _removeItem(int index) {
    setState(() {
      final item = _items.removeAt(index);
      item.jumlah.dispose();
      item.keterangan.dispose();
    });
  }

  Future<void> _submit() async {
    if (_items.isEmpty) {
      setState(() => _error = 'Tambahkan minimal satu item barang keluar.');
      return;
    }

    final payload = <CartProduct>[];
    for (final item in _items) {
      final jumlah = int.tryParse(item.jumlah.text.trim()) ?? 0;
      if (jumlah < 1) {
        setState(() => _error = 'Jumlah setiap item minimal 1.');
        return;
      }
      if (jumlah > item.product.stok) {
        setState(() => _error = 'Jumlah ${item.product.nama} melebihi stok ${item.product.stok}.');
        return;
      }
      payload.add(CartProduct(
        productId: item.product.id,
        nama: item.product.nama,
        jumlah: jumlah,
        jenis: item.jenis,
        keteranganItem: item.keterangan.text.trim(),
      ));
    }

    setState(() {
      _submitting = true;
      _error = '';
    });
    try {
      await _repo.createBarangKeluar(
        keterangan: _keterangan.text.trim(),
        items: payload,
      );
      if (!mounted) return;
      showInfoSnack(context, 'Barang keluar berhasil dicatat.');
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
      appBar: AppBar(title: const Text('Barang Keluar Baru')),
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
                      const Text(
                        'Keterangan Umum',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _keterangan,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Catatan umum (opsional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FinKuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Detail Barang Keluar',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
                        _KeluarItemCard(
                          key: ValueKey(_items[i]),
                          item: _items[i],
                          products: _products,
                          jenisOptions: _jenisOptions,
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
                      : const Text('Simpan Barang Keluar'),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _KeluarItem {
  _KeluarItem(this.product)
      : jumlah = TextEditingController(),
        keterangan = TextEditingController();

  Product product;
  String jenis = 'RUSAK';
  final TextEditingController jumlah;
  final TextEditingController keterangan;
}

class _KeluarItemCard extends StatelessWidget {
  const _KeluarItemCard({
    required this.item,
    required this.products,
    required this.jenisOptions,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final _KeluarItem item;
  final List<Product> products;
  final Map<String, String> jenisOptions;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
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
                  isDense: true,
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
                child: TextField(
                  controller: item.jumlah,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: item.jenis,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Jenis',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final e in jenisOptions.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) {
                    item.jenis = v ?? 'RUSAK';
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: item.keterangan,
            decoration: const InputDecoration(
              labelText: 'Keterangan item',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
