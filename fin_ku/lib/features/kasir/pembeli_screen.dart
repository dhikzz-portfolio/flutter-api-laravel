import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../transaksi/data/transaksi_repository.dart';

/// Manajemen pembeli (kasir): daftar, tambah, edit.
class PembeliScreen extends StatefulWidget {
  const PembeliScreen({super.key});

  @override
  State<PembeliScreen> createState() => _PembeliScreenState();
}

class _PembeliScreenState extends State<PembeliScreen> {
  final _repo = KasirRepository();
  final _scroll = ScrollController();

  List<Buyer> _items = [];
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
      final page = await _repo.pembeli(search: _search);
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
      final next = await _repo.pembeli(search: _search, page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(
          next.items.where((n) => _items.every((e) => e.id != n.id)),
        );
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

  Future<void> _openForm([Buyer? buyer]) async {
    final result = await showAppPopup<bool>(
      context,
      maxWidth: 480,
      builder: (_) => _PembeliForm(repo: _repo, buyer: buyer),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembeli')),
      backgroundColor: FinKuColors.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: FinKuColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Pembeli Baru'),
        onPressed: () => _openForm(),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: SearchField(
              hint: 'Cari nama / telepon pembeli...',
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
                    icon: Icons.people_alt_outlined,
                    title: 'Belum ada pembeli',
                    subtitle: 'Tekan "Pembeli Baru" untuk menambahkan.',
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
                        final b = _items[i];
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
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: FinKuColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                child: Text(
                                  Fmt.inisial(b.nama),
                                  style: const TextStyle(
                                    color: FinKuColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      (b.telepon.isEmpty ? '-' : b.telepon),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconicAction(
                                icon: Icons.edit_outlined,
                                label: 'Edit',
                                onTap: () => _openForm(b),
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

class _PembeliForm extends StatefulWidget {
  const _PembeliForm({required this.repo, required this.buyer});

  final KasirRepository repo;
  final Buyer? buyer;

  @override
  State<_PembeliForm> createState() => _PembeliFormState();
}

class _PembeliFormState extends State<_PembeliForm> {
  late final TextEditingController _nama;
  late final TextEditingController _telepon;
  late final TextEditingController _alamat;
  String _error = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.buyer?.nama ?? '');
    _telepon = TextEditingController(text: widget.buyer?.telepon ?? '');
    _alamat = TextEditingController(text: widget.buyer?.alamat ?? '');
  }

  @override
  void dispose() {
    _nama.dispose();
    _telepon.dispose();
    _alamat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nama.text.trim().isEmpty) {
      setState(() => _error = 'Nama pembeli wajib diisi.');
      return;
    }
    setState(() {
      _error = '';
      _saving = true;
    });
    try {
      if (widget.buyer == null) {
        await widget.repo.createPembeli(
          nama: _nama.text.trim(),
          telepon: _telepon.text.trim(),
          alamat: _alamat.text.trim(),
        );
      } else {
        await widget.repo.updatePembeli(
          widget.buyer!.id,
          nama: _nama.text.trim(),
          telepon: _telepon.text.trim(),
          alamat: _alamat.text.trim(),
        );
      }
      if (!mounted) return;
      showInfoSnack(
        context,
        widget.buyer == null
            ? 'Pembeli berhasil ditambahkan.'
            : 'Pembeli berhasil diupdate.',
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
                  widget.buyer == null ? 'Pembeli Baru' : 'Edit Pembeli',
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
              labelText: 'Nama Pembeli',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telepon,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telepon (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _alamat,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Alamat (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
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
