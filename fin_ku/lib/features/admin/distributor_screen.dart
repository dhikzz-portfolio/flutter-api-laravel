import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/catalog_model.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';

/// Distributor (supplier) CRUD untuk admin.
class DistributorScreen extends StatefulWidget {
  const DistributorScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  State<DistributorScreen> createState() => _DistributorScreenState();
}

class _DistributorScreenState extends State<DistributorScreen> {
  final _repo = KatalogRepository(basePath: '/api/v1/admin');
  final _scroll = ScrollController();

  List<Distributor> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';
  String _search = '';

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
      final page = await _repo.distributor(search: _search);
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
      final next = await _repo.distributor(search: _search, page: _page + 1);
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

  Future<void> _openForm([Distributor? distributor]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _DistributorForm(repo: _repo, distributor: distributor),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distributor'),
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
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Distributor Baru'),
        onPressed: () => _openForm(),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: SearchField(
              hint: 'Cari nama / telepon distributor...',
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
                            icon: Icons.local_shipping_outlined,
                            title: 'Belum ada distributor',
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
                                final d = _items[i];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: FinKuColors.cardBorder),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.nama,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                            if (d.telepon.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.phone_outlined,
                                                      size: 13,
                                                      color: FinKuColors.textSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      d.telepon,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: FinKuColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (d.alamat.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3),
                                                child: Text(
                                                  d.alamat,
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: FinKuColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${d.purchasesCount} transaksi pembelian',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: FinKuColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconicAction(
                                        icon: Icons.edit_outlined,
                                        label: 'Edit',
                                        onTap: () => _openForm(d),
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

class _DistributorForm extends StatefulWidget {
  const _DistributorForm({required this.repo, required this.distributor});

  final KatalogRepository repo;
  final Distributor? distributor;

  @override
  State<_DistributorForm> createState() => _DistributorFormState();
}

class _DistributorFormState extends State<_DistributorForm> {
  late final TextEditingController _nama;
  late final TextEditingController _telepon;
  late final TextEditingController _alamat;
  String _error = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.distributor;
    _nama = TextEditingController(text: d?.nama ?? '');
    _telepon = TextEditingController(text: d?.telepon ?? '');
    _alamat = TextEditingController(text: d?.alamat ?? '');
  }

  @override
  void dispose() {
    _nama.dispose();
    _telepon.dispose();
    _alamat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _nama.text.trim();
    if (nama.isEmpty) {
      setState(() => _error = 'Nama distributor wajib diisi.');
      return;
    }

    setState(() {
      _saving = true;
      _error = '';
    });
    try {
      if (widget.distributor == null) {
        await widget.repo.createDistributor(
          nama: nama,
          telepon: _telepon.text.trim(),
          alamat: _alamat.text.trim(),
        );
      } else {
        await widget.repo.updateDistributor(
          widget.distributor!.id,
          nama: nama,
          telepon: _telepon.text.trim(),
          alamat: _alamat.text.trim(),
        );
      }
      if (!mounted) return;
      showInfoSnack(
        context,
        widget.distributor == null
            ? 'Distributor berhasil ditambahkan.'
            : 'Distributor berhasil diupdate.',
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
    final isEdit = widget.distributor != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit Distributor' : 'Distributor Baru',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama Distributor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telepon,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telepon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _alamat,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
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
