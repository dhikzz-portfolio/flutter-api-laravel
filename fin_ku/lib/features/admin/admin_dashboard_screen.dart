import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/report_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../transaksi/data/transaksi_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminStats? _stats;
  String _error = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final stats = await AdminStokRepository().dashboard();
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      backgroundColor: FinKuColors.bg,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading && _stats == null) ...[
              const FinKuCard(
                child: SizedBox(
                  height: 90,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                ),
              ),
            ] else if (_error.isNotEmpty) ...[
              ErrorView(message: _error, onRetry: _load),
              const SizedBox(height: 200),
            ] else if (_stats != null) ...[
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Pembelian Hari Ini',
                      value: Fmt.number(_stats!.pembelianHariIni),
                      icon: Icons.shopping_cart,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Barang Masuk',
                      value: Fmt.number(_stats!.barangMasuk),
                      icon: Icons.move_to_inbox_outlined,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Barang Keluar',
                      value: Fmt.number(_stats!.barangKeluar),
                      icon: Icons.outbound_outlined,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Stok Minimum',
                      value: Fmt.number(_stats!.produkStokMinimum.length),
                      icon: Icons.warning_amber_outlined,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FinKuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produk di Bawah Stok Minimum',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                    ),
                    const SizedBox(height: 10),
                    if (_stats!.produkStokMinimum.isEmpty)
                      Text(
                        'Semua stok aman di atas minimum.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      ..._stats!.produkStokMinimum.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.sync_problem_outlined,
                                size: 17,
                                color: Color(0xFFB45309),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p.nama,
                                  style: const TextStyle(fontSize: 13.5),
                                ),
                              ),
                              Text(
                                '${p.stok} / min ${p.stokMinimum}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
