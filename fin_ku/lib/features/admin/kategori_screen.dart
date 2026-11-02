import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/catalog_model.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';

/// Daftar kategori dengan form tambah/ubah (modal sheet).
/// Owner memakai layar ini dengan [readOnly] karena endpoint-nya baca saja.
class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key, this.readOnly = false, this.isEmbedded = false});

  final bool readOnly;
  final bool isEmbedded;

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  late final KatalogRepository _repo =
      KatalogRepository(basePath: widget.readOnly ? '/api/v1/owner' : '/api/v1/admin');
  final _scroll = ScrollController();

  List<Category> _items = [];
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
      final page = await _repo.kategori(
        search: _search,
        status: _statusFilter,
        perPage: 20,
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
      final next = await _repo.kategori(
        search: _search,
        status: _statusFilter,
        page: _page + 1,
        perPage: 20,
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

  Future<void> _openForm([Category? category]) async {
    if (widget.readOnly) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _KategoriForm(repo: _repo, category: category),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Kategori (Data Toko)' : 'Kategori'),
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
              icon: const Icon(Icons.add),
              label: const Text('Kategori Baru'),
              onPressed: () => _openForm(),
            ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Cari kategori...',
                    onSubmitted: (v) {
                      _search = v;
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 132,
                  child: DropdownButtonFormField<String>(
                    initialValue: _statusFilter,
                    isDense: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Semua')),
                      DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                      DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                    ],
                    onChanged: (v) {
                      _statusFilter = v ?? '';
                      _load();
                    },
                  ),
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
                            icon: Icons.category_outlined,
                            title: 'Belum ada kategori',
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
                                final c = _items[i];
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
                                            Text(
                                              c.nama,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                StatusChip(
                                                  label: c.isActive ? 'AKTIF' : 'NONAKTIF',
                                                  color: c.isActive
                                                      ? FinKuColors.success
                                                      : FinKuColors.textSecondary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${c.productsCount} produk',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: FinKuColors.textSecondary,
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
                                          onTap: () => _openForm(c),
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

class _KategoriForm extends StatefulWidget {
  const _KategoriForm({required this.repo, required this.category});

  final KatalogRepository repo;
  final Category? category;

  @override
  State<_KategoriForm> createState() => _KategoriFormState();
}

class _KategoriFormState extends State<_KategoriForm> {
  late final TextEditingController _nama;
  String _status = 'aktif';
  String _error = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.category?.nama ?? '');
    _status = widget.category?.status ?? 'aktif';
  }

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _nama.text.trim();
    if (nama.isEmpty) {
      setState(() => _error = 'Nama kategori wajib diisi.');
      return;
    }

    setState(() {
      _saving = true;
      _error = '';
    });
    try {
      if (widget.category == null) {
        await widget.repo.createKategori(nama);
      } else {
        await widget.repo.updateKategori(
          widget.category!.id,
          nama: nama,
          status: _status,
        );
      }
      if (!mounted) return;
      showInfoSnack(
        context,
        widget.category == null
            ? 'Kategori berhasil ditambahkan.'
            : 'Kategori berhasil diupdate.',
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
    final isEdit = widget.category != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit Kategori' : 'Kategori Baru',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
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
                style: const TextStyle(color: FinKuColors.danger, fontSize: 12.5),
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
      ),
    );
  }
}
