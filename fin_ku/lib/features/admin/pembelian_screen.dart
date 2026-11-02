import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/catalog_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';
import '../transaksi/data/transaksi_repository.dart';

/// Daftar transaksi pembelian (admin) + pembatalan.
class PembelianScreen extends StatefulWidget {
  const PembelianScreen({super.key});

  @override
  State<PembelianScreen> createState() => _PembelianScreenState();
}

class _PembelianScreenState extends State<PembelianScreen> {
  final _repo = PembelianRepository();
  final _scroll = ScrollController();

  List<Purchase> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';
  String _search = '';
  String _statusFilter = '';

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
      final page = await _repo.pembelian(search: _search, status: _statusFilter);
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
      final next = await _repo.pembelian(
        search: _search,
        status: _statusFilter,
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

  void _setStatusFilter(String value) {
    setState(() => _statusFilter = value);
    _load();
  }

  Future<void> _openDetail(Purchase p) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _PembelianDetail(purchase: p, repo: _repo, onChanged: () {
        Navigator.pop(context);
        _load();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembelian'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownMenu<String>(
              initialSelection: _statusFilter,
              width: 150,
              trailingIcon: const Icon(Icons.filter_list),
              onSelected: (String? value) => _setStatusFilter(value ?? ''),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: '', label: 'Semua Status'),
                DropdownMenuEntry(value: 'active', label: 'Aktif'),
                DropdownMenuEntry(value: 'dibatalkan', label: 'Dibatalkan'),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: FinKuColors.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: FinKuColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Pembelian Baru'),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PembelianFormScreen()),
          );
          if (created == true) _load();
        },
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: SearchField(
              hint: 'Cari invoice / distributor...',
              onSubmitted: (v) {
                _search = v;
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error.isNotEmpty
                    ? ErrorView(message: _error, onRetry: _load)
                    : _items.isEmpty
                        ? const EmptyView(
                            icon: Icons.shopping_cart_outlined,
                            title: 'Belum ada pembelian',
                            subtitle: 'Tekan "Pembelian Baru" untuk mencatat pembelian.',
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
                                        child:
                                            CircularProgressIndicator(strokeWidth: 2.2),
                                      ),
                                    ),
                                  );
                                }
                                final p = _items[i];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: FinKuColors.cardBorder),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _openDetail(p),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        p.invoice,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13.5,
                                                        ),
                                                      ),
                                                    ),
                                                    if (p.isCancelled)
                                                      const StatusChip(
                                                        label: 'DIBATALKAN',
                                                        color: Color(0xFFDC2626),
                                                      )
                                                    else
                                                      const StatusChip(
                                                        label: 'AKTIF',
                                                        color: Color(0xFF15803D),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  p.distributorNama,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF374151),
                                                  ),
                                                ),
                                                Text(
                                                  Fmt.tanggal(p.tanggal),
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            Fmt.rupiah(p.total),
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
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _PembelianDetail extends StatelessWidget {
  const _PembelianDetail({required this.purchase, required this.repo, required this.onChanged});

  final Purchase purchase;
  final PembelianRepository repo;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detail Pembelian',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                if (purchase.isCancelled)
                  const StatusChip(label: 'DIBATALKAN', color: Color(0xFFDC2626))
                else
                  const StatusChip(label: 'AKTIF', color: Color(0xFF15803D)),
              ],
            ),
            const SizedBox(height: 16),
            _row('Invoice', purchase.invoice),
            _row('Distributor', purchase.distributorNama),
            _row('Tanggal', Fmt.tanggalPanjang(purchase.tanggal)),
            _row('Admin', purchase.userNama),
            const SizedBox(height: 14),
            ...purchase.details.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
                            '${d.jumlah} x ${Fmt.rupiah(d.hargaBeli)}',
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
              ),
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(
                  Fmt.rupiah(purchase.total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (purchase.isActive) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                  onPressed: () async {
                    final ok = await showConfirmDialog(
                      context,
                      title: 'Batalkan Pembelian?',
                      message:
                          'Stok dan HPP akan disesuaikan oleh server bila aman untuk invoice ${purchase.invoice}.',
                      confirmLabel: 'Ya, Batalkan',
                      destructive: true,
                    );
                    if (!ok || !context.mounted) return;
                    try {
                      await repo.batalPembelian(purchase.id);
                      if (!context.mounted) return;
                      showInfoSnack(context, 'Pembelian berhasil dibatalkan.');
                      onChanged();
                    } catch (e) {
                      if (!context.mounted) return;
                      showErrorSnack(context, errorText(e));
                    }
                  },
                  child: const Text('Batalkan Pembelian'),
                ),
              ),
            ],
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

/// Form produk pilih + harga beli per item + distributor.
class PembelianFormScreen extends StatefulWidget {
  const PembelianFormScreen({super.key});

  @override
  State<PembelianFormScreen> createState() => _PembelianFormScreenState();
}

class _PembelianFormScreenState extends State<PembelianFormScreen> {
  final _pembelianRepo = PembelianRepository();
  final _katalogRepo = KatalogRepository(basePath: '/api/v1/admin');

  List<Distributor> _distributors = [];
  List<Product> _products = [];
  final List<_PurchaseCartItem> _cart = [];

  int? _distributorId;
  String _productSearch = '';
  bool _loadingDistributors = true;
  bool _loadingProducts = true;
  bool _submitting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDistributors();
    _loadProducts();
  }

  Future<void> _loadDistributors() async {
    try {
      final page = await _katalogRepo.distributor(perPage: 100);
      if (!mounted) return;
      setState(() {
        _distributors = page.items;
        _loadingDistributors = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDistributors = false;
        _error = 'Gagal memuat distributor: ${errorText(e)}';
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final page = await _katalogRepo.produk(
        status: 'aktif',
        search: _productSearch,
        perPage: 100,
      );
      if (!mounted) return;
      setState(() {
        _products = page.items;
        _loadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _error = errorText(e);
      });
    }
  }

  double get _total {
    var sum = 0.0;
    for (final item in _cart) {
      sum += double.parse(item.hargaBeliController.text) * int.parse(item.jumlahController.text);
    }
    return sum;
  }

  void _addToCart(Product p) {
    setState(() {
      _cart.add(_PurchaseCartItem(
        product: p,
        hargaBeliController: TextEditingController(
          text: p.hppRataRata > 0 ? p.hppRataRata.toStringAsFixed(0) : '',
        ),
        jumlahController: TextEditingController(text: '1'),
      ));
    });
  }

  void _removeCart(int index) {
    setState(() {
      _cart[index].hargaBeliController.dispose();
      _cart[index].jumlahController.dispose();
      _cart.removeAt(index);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_distributorId == null) {
      setState(() => _error = 'Pilih distributor terlebih dahulu.');
      return;
    }
    if (_cart.isEmpty) {
      setState(() => _error = 'Tambahkan minimal satu produk.');
      return;
    }
    for (final c in _cart) {
      final jml = int.tryParse(c.jumlahController.text) ?? 0;
      final hpp = double.tryParse(c.hargaBeliController.text) ?? 0;
      if (jml < 1 || hpp <= 0) {
        setState(
          () => _error = 'Jumlah dan harga beli harus lebih dari 0 untuk ${c.product.nama}.',
        );
        return;
      }
    }
    setState(() {
      _error = '';
      _submitting = true;
    });

    try {
      await _pembelianRepo.createPembelian(
        distributorId: _distributorId!,
        items: _cart
            .map(
              (c) => CartProduct(
                productId: c.product.id,
                nama: c.product.nama,
                jumlah: int.parse(c.jumlahController.text),
                hargaBeli: double.parse(c.hargaBeliController.text),
              ),
            )
            .toList(),
      );
      if (!mounted) return;
      showInfoSnack(context, 'Pembelian berhasil disimpan. Stok & HPP diperbarui.');
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
  void dispose() {
    for (final c in _cart) {
      c.hargaBeliController.dispose();
      c.jumlahController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Pembelian Baru')),
      backgroundColor: FinKuColors.bg,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                _loadingDistributors
                    ? const InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Distributor',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        child: SizedBox(
                          height: 14,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      )
                    : DropdownButtonFormField<int>(
                        initialValue: _distributorId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Distributor',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          for (final d in _distributors)
                            DropdownMenuItem(value: d.id, child: Text(d.nama)),
                        ],
                        onChanged: (v) => setState(() => _distributorId = v),
                      ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Total Pembelian',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                    ),
                    const Spacer(),
                    Text(
                      Fmt.rupiah(_total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              decoration: InputDecorationX.search(hint: 'Cari produk aktif...'),
              onChanged: (v) => _productSearch = v.trim(),
              onSubmitted: (_) => _loadProducts(),
            ),
          ),
          Expanded(
            flex: 2,
            child: _loadingProducts
                ? const LoadingView()
                : _products.isEmpty
                    ? const EmptyView(icon: Icons.search_off, title: 'Produk tidak ditemukan')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, i) {
                          final p = _products[i];
                          final inCart = _cart.any((c) => c.product.id == p.id);
                          return _ProductPickerRow(
                            product: p,
                            inCart: inCart,
                            onAdd: () => _addToCart(p),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _cart.isEmpty
                ? const EmptyView(
                    icon: Icons.list_alt,
                    title: 'Belum ada item',
                    subtitle: 'Pilih produk beserta harga beli & jumlah.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cart.length,
                    itemBuilder: (context, i) {
                      final c = _cart[i];
                      final product = c.product;
                      return FinKuCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _removeCart(i),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: c.hargaBeliController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Harga Beli / unit',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      prefixText: 'Rp ',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: c.jumlahController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Jumlah',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (_error.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error,
                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12.5),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
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
                      : const Text('Simpan Pembelian'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseCartItem {
  _PurchaseCartItem({
    required this.product,
    required this.hargaBeliController,
    required this.jumlahController,
  });

  final Product product;
  final TextEditingController hargaBeliController;
  final TextEditingController jumlahController;
}

class _ProductPickerRow extends StatelessWidget {
  const _ProductPickerRow({
    required this.product,
    required this.inCart,
    required this.onAdd,
  });

  final Product product;
  final bool inCart;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: inCart ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nama,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${product.categoryName} · stok ${product.stok} · HPP ${Fmt.rupiah(product.hppRataRata)}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconicAction(
            icon: inCart ? Icons.check : Icons.add,
            label: inCart ? 'Dipilih' : 'Tambah',
            onTap: onAdd,
            color: inCart ? const Color(0xFF15803D) : const Color(0xFF4F46E5),
          ),
        ],
      ),
    );
  }
}
