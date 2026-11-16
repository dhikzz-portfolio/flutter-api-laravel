import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/catalog_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';

/// Produk CRUD admin; dimatikan fitur tambah saat dipakai owner (read-only).
class ProdukScreen extends StatefulWidget {
  const ProdukScreen({
    super.key,
    this.readOnly = false,
    this.isEmbedded = false,
  });

  /// Owner menggunakan endpoint /owner dengan akses baca.
  /// [basePath] masih /admin; owner memakai produkOwner sedangkan kasir tidak.
  final bool readOnly;
  final bool isEmbedded;

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  late final KatalogRepository _repo = KatalogRepository(
    basePath: widget.readOnly ? '/api/v1/owner' : '/api/v1/admin',
  );
  final _scroll = ScrollController();

  List<Product> _items = [];
  List<Category> _categories = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';
  String _search = '';
  String _statusFilter = '';
  int _categoryFilter = 0;

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
      final page = await _repo.produk(
        search: _search,
        status: _statusFilter,
        categoryId: _categoryFilter,
      );
      final cats = await _repo.kategori(status: 'aktif', perPage: 100);
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _page = page.currentPage;
        _lastPage = page.lastPage;
        _categories = cats.items;
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
      final page = await _repo.produk(
        search: _search,
        status: _statusFilter,
        categoryId: _categoryFilter,
        page: _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(
          page.items.where((n) => _items.every((e) => e.id != n.id)),
        );
        _page = page.currentPage;
        _lastPage = page.lastPage;
      });
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, errorText(e));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openForm([Product? product]) async {
    if (widget.readOnly) return;
    final result = await showAppPopup<bool>(
      context,
      maxWidth: 480,
      builder: (_) =>
          _ProdukForm(repo: _repo, categories: _categories, product: product),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.readOnly ? 'Produk (Lihat Saja)' : 'Produk';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.isEmbedded,
        leading: widget.isEmbedded
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(title),
      ),
      backgroundColor: FinKuColors.bg,
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              backgroundColor: FinKuColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Produk Baru'),
              onPressed: () => _openForm(),
            ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SearchField(
                  hint: 'Cari nama produk / kategori...',
                  onSubmitted: (v) {
                    _search = v;
                    _load();
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _statusFilter,
                        isDense: true,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text('Semua Status'),
                          ),
                          DropdownMenuItem(
                            value: 'aktif',
                            child: Text('Aktif'),
                          ),
                          DropdownMenuItem(
                            value: 'nonaktif',
                            child: Text('Nonaktif'),
                          ),
                        ],
                        onChanged: (v) {
                          _statusFilter = v ?? '';
                          _load();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _categoryFilter,
                        isDense: true,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Semua Kategori'),
                          ),
                          for (final c in _categories)
                            DropdownMenuItem(value: c.id, child: Text(c.nama)),
                        ],
                        onChanged: (v) {
                          _categoryFilter = v ?? 0;
                          _load();
                        },
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
                    icon: Icons.inventory_2,
                    title: 'Produk tidak ditemukan',
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            ),
                          );
                        }
                        final p = _items[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: FinKuColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            p.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                        if (p.isActive)
                                          const StatusChip(
                                            label: 'AKTIF',
                                            color: Color(0xFF15803D),
                                          )
                                        else
                                          const StatusChip(
                                            label: 'NONAKTIF',
                                            color: Color(0xFF6B7280),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      p.categoryName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          Fmt.rupiah(p.hargaJual),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: Color(0xFF4F46E5),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'stok ${p.stok}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: p.isLowStock
                                                ? const Color(0xFFB45309)
                                                : const Color(0xFF6B7280),
                                            fontWeight: p.isLowStock
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!widget.readOnly)
                                IconicAction(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit',
                                  onTap: () => _openForm(p),
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

class _ProdukForm extends StatefulWidget {
  const _ProdukForm({
    required this.repo,
    required this.categories,
    required this.product,
  });

  final KatalogRepository repo;
  final List<Category> categories;
  final Product? product;

  @override
  State<_ProdukForm> createState() => _ProdukFormState();
}

class _ProdukFormState extends State<_ProdukForm> {
  late final TextEditingController _nama;
  late final TextEditingController _harga;
  late final TextEditingController _stok;
  late final TextEditingController _stokMinimum;
  int? _categoryId;
  String _status = 'aktif';
  String _error = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nama = TextEditingController(text: p?.nama ?? '');
    _harga = TextEditingController(
      text: p == null ? '' : p.hargaJual.toStringAsFixed(0),
    );
    _stok = TextEditingController(text: p == null ? '' : '${p.stok}');
    _stokMinimum = TextEditingController(
      text: p == null ? '' : '${p.stokMinimum}',
    );
    _categoryId = p?.categoryId;
    _status = p?.status ?? 'aktif';
  }

  @override
  void dispose() {
    _nama.dispose();
    _harga.dispose();
    _stok.dispose();
    _stokMinimum.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _nama.text.trim();
    final harga = double.tryParse(_harga.text.trim()) ?? -1;
    final stok = int.tryParse(_stok.text.trim()) ?? -1;
    final stokMin = int.tryParse(_stokMinimum.text.trim()) ?? -1;

    if (nama.isEmpty || _categoryId == null || harga < 0) {
      setState(
        () => _error = 'Lengkapi nama, kategori, dan harga jual yang valid.',
      );
      return;
    }
    final isCreate = widget.product == null;
    if (isCreate && stok < 0) {
      setState(() => _error = 'Stok awal wajib diisi angka >= 0.');
      return;
    }
    if (stokMin < 0) {
      setState(() => _error = 'Stok minimum wajib diisi angka >= 0.');
      return;
    }

    setState(() {
      _error = '';
      _saving = true;
    });
    try {
      if (isCreate) {
        await widget.repo.createProduk(
          nama: nama,
          categoryId: _categoryId!,
          hargaJual: harga,
          stok: stok,
          stokMinimum: stokMin,
        );
      } else {
        await widget.repo.updateProduk(
          widget.product!.id,
          nama: nama,
          categoryId: _categoryId!,
          hargaJual: harga,
          stokMinimum: stokMin,
          status: _status,
        );
      }
      if (!mounted) return;
      showInfoSnack(
        context,
        isCreate ? 'Produk berhasil ditambahkan.' : 'Produk berhasil diupdate.',
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = errorText(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isEdit ? 'Edit Produk' : 'Produk Baru',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Tutup',
                visualDensity: VisualDensity.compact,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nama,
            decoration: const InputDecoration(
              labelText: 'Nama Produk',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _categoryId,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final c in widget.categories)
                DropdownMenuItem(value: c.id, child: Text(c.nama)),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _harga,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Harga Jual',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stok,
                  enabled: !isEdit,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isEdit ? 'Stok (server)' : 'Stok Awal',
                    border: OutlineInputBorder(),
                    helperText: isEdit ? 'Diubah via pembelian/stok' : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _stokMinimum,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok Minimum',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          if (isEdit) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'aktif'),
            ),
          ],
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _error,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
