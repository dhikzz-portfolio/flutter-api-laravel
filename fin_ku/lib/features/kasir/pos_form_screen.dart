import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';
import '../transaksi/data/transaksi_repository.dart';

/// Form transaksi penjualan (POS): pilih pembeli, tambahkan produk ke keranjang,
/// isi jumlah, dan kirim ke server. Validasi stok tetap di backend.
class PosFormScreen extends StatefulWidget {
  const PosFormScreen({super.key});

  @override
  State<PosFormScreen> createState() => _PosFormScreenState();
}

class _PosFormScreenState extends State<PosFormScreen> {
  final _pembeliRepo = KasirRepository();
  final _produkRepo = KasirProdukRepository();

  List<Buyer> _buyers = [];
  List<PosProduct> _products = [];
  final List<_CartItem> _cart = [];

  int? _buyerId;
  String _productSearch = '';
  bool _loadingBuyers = true;
  bool _loadingProducts = true;
  bool _submitting = false;
  String _error = '';
  String _searchError = '';

  @override
  void initState() {
    super.initState();
    _loadBuyers();
    _loadProducts();
  }

  Future<void> _loadBuyers() async {
    try {
      final page = await _pembeliRepo.pembeli(perPage: 100);
      if (!mounted) return;
      setState(() {
        _buyers = page.items;
        _loadingBuyers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBuyers = false;
        _error = 'Gagal memuat pembeli: ${errorText(e)}';
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final list = await _produkRepo.produkAktif(search: _productSearch);
      if (!mounted) return;
      setState(() {
        _products = list;
        _loadingProducts = false;
        _searchError = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _searchError = errorText(e);
      });
    }
  }

  double get _total {
    var sum = 0.0;
    for (final item in _cart) {
      sum += item.product.hargaJual * item.jumlah;
    }
    return sum;
  }

  void _addToCart(PosProduct p) {
    final existing = _cart.indexWhere((c) => c.product.id == p.id);
    if (existing >= 0) {
      _bumpJumlah(existing, 1);
      return;
    }
    if (p.stok <= 0) {
      setState(() => _error = 'Stok habis untuk produk ${p.nama}');
      return;
    }
    setState(() => _cart.add(_CartItem(product: p, controller: TextEditingController(text: '1'))));
  }

  void _bumpJumlah(int index, int delta) {
    final item = _cart[index];
    final stok = item.product.stok;
    final next = (item.jumlah + delta).clamp(0, stok);
    item.controller.text = '$next';
    setState(() => _cart[index] = _CartItem(product: item.product, controller: item.controller, jumlah: next));
  }

  void _setJumlah(int index, String raw) {
    final item = _cart[index];
    final parsed = int.tryParse(raw) ?? item.jumlah;
    final stok = item.product.stok;
    final clamped = parsed.clamp(0, stok);
    if ('$clamped' != raw) item.controller.text = '$clamped';
    setState(() => _cart[index] = _CartItem(product: item.product, controller: item.controller, jumlah: clamped));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_buyerId == null) {
      setState(() => _error = 'Pilih pembeli terlebih dahulu.');
      return;
    }
    if (_cart.isEmpty) {
      setState(() => _error = 'Tambahkan minimal satu produk.');
      return;
    }
    setState(() {
      _error = '';
      _submitting = true;
    });

    try {
      await _pembeliRepo.createPenjualan(
        buyerId: _buyerId!,
        items: _cart
            .map((c) => CartProduct(
                  productId: c.product.id,
                  nama: c.product.nama,
                  jumlah: c.jumlah,
                ))
            .toList(),
      );
      if (!mounted) return;
      showInfoSnack(context, 'Transaksi berhasil disimpan.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = errorText(e);
      });
    }
  }

  void _removeCart(int index) {
    setState(() {
      _cart[index].controller.dispose();
      _cart.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final c in _cart) {
      c.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Penjualan Baru')),
      backgroundColor: FinKuColors.bg,
      body: Column(
        children: [
          // ================== Info pembeli & total ==================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                _loadingBuyers
                    ? const InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Pembeli',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        child: SizedBox(
                          height: 14,
                          width: 14,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      )
                    : DropdownButtonFormField<int>(
                        initialValue: _buyerId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Pembeli',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        hint: const Text('Pilih pembeli'),
                        items: [
                          for (final b in _buyers)
                            DropdownMenuItem(value: b.id, child: Text(b.nama)),
                        ],
                        onChanged: (v) => setState(() => _buyerId = v),
                      ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Fmt.tanggalPanjang(DateTime.now()),
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                      ),
                    ),
                    Text(
                      'Total: ${Fmt.rupiah(_total)}',
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
          // ================== Pencarian & daftar produk ==================
          SizedBox(
            height: 236,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: TextField(
                    decoration: InputDecorationX.search(
                      hint: 'Cari produk aktif (stok tersedia)...',
                    ),
                    onChanged: (v) {
                      _productSearch = v.trim();
                    },
                    onSubmitted: (_) => _loadProducts(),
                  ),
                ),
                Expanded(
                  child: _loadingProducts
                      ? const LoadingView()
                      : _searchError.isNotEmpty
                          ? ErrorView(message: _searchError, onRetry: _loadProducts)
                          : _products.isEmpty
                              ? const EmptyView(
                                  icon: Icons.search_off,
                                  title: 'Produk tidak ditemukan',
                                  subtitle: 'Coba kata kunci lain.',
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  itemCount: _products.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                                  itemBuilder: (context, i) {
                                    final p = _products[i];
                                    final inCart =
                                        _cart.any((c) => c.product.id == p.id);
                                    return _ProductRow(
                                      product: p,
                                      inCart: inCart,
                                      onAdd: () => _addToCart(p),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ================== Keranjang ==================
          Expanded(
            child: _cart.isEmpty
                ? const EmptyView(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Keranjang kosong',
                    subtitle: 'Sentuh produk di atas untuk menambahkannya.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cart.length,
                    itemBuilder: (context, i) {
                      final c = _cart[i];
                      return FinKuCard(
                        padding: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.product.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    Text(
                                      '${Fmt.rupiah(c.product.hargaJual)} · stok ${c.product.stok}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _QtyBtn(
                                    icon: Icons.remove,
                                    onTap: () => _bumpJumlah(i, -1),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 56,
                                    child: TextField(
                                      controller: c.controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                      onChanged: (v) => _setJumlah(i, v),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _QtyBtn(
                                    icon: Icons.add,
                                    onTap: () => _bumpJumlah(i, 1),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Fmt.rupiah(c.product.hargaJual * c.jumlah),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _removeCart(i),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Color(0xFFDC2626),
                                      ),
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
          // ================== Error + submit ==================
          if (_error.isNotEmpty)
            Container(
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
                      : const Text('Simpan Transaksi'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: const Color(0xFF374151)),
        ),
      ),
    );
  }
}

class _CartItem {
  _CartItem({required this.product, required this.controller, this.jumlah = 1});

  final PosProduct product;
  final TextEditingController controller;
  int jumlah;
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.inCart,
    required this.onAdd,
  });

  final PosProduct product;
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
                const SizedBox(height: 2),
                Text(
                  '${product.categoryNama} · stok ${product.stok} · ${Fmt.rupiah(product.hargaJual)}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconicAction(
            icon: inCart ? Icons.check : Icons.add,
            label: inCart ? 'Ditambahkan' : 'Tambah',
            onTap: onAdd,
            color: inCart ? const Color(0xFF15803D) : const Color(0xFF4F46E5),
          ),
        ],
      ),
    );
  }
}
