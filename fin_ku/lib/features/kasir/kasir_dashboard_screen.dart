import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/report_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../transaksi/data/transaksi_repository.dart';

class KasirDashboardScreen extends StatefulWidget {
  const KasirDashboardScreen({
    super.key,
    this.onOpenPenjualan,
    this.onOpenPembeli,
  });

  /// Navigasi aksi cepat, disediakan oleh AppShell.
  final VoidCallback? onOpenPenjualan;
  final VoidCallback? onOpenPembeli;

  @override
  State<KasirDashboardScreen> createState() => _KasirDashboardScreenState();
}

class _KasirDashboardScreenState extends State<KasirDashboardScreen> {
  KasirStats? _stats;
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
      final stats = await KasirRepository().dashboard();
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
      appBar: AppBar(title: const Text('Dashboard Kasir')),
      backgroundColor: FinKuColors.bg,
      body: _loading && _stats == null
          ? const _Skeletons()
          : _error.isNotEmpty
              ? ErrorView(message: _error, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      StatCard(
                        label: 'Penjualan Hari Ini',
                        value: Fmt.number(_stats?.penjualanHariIni ?? 0),
                        icon: Icons.receipt,
                        color: const Color(0xFF15803D),
                      ),
                      const SizedBox(height: 12),
                      StatCard(
                        label: 'Total Transaksi Hari Ini',
                        value: Fmt.rupiah(_stats?.totalTransaksi ?? 0),
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF4F46E5),
                      ),
                      const SizedBox(height: 12),
                      StatCard(
                        label: 'Stok Minimum',
                        value: Fmt.number(_stats?.stokMinimum ?? 0),
                        icon: Icons.warning_amber_outlined,
                        color: (_stats?.stokMinimum ?? 0) > 0
                            ? const Color(0xFFB45309)
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 20),
                      FinKuCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aksi Cepat',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                FilledButton.icon(
                                  onPressed: widget.onOpenPenjualan,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Transaksi Baru'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: widget.onOpenPembeli,
                                  icon: const Icon(Icons.person_add_alt, size: 18),
                                  label: const Text('Data Pembeli'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _Skeletons extends StatelessWidget {
  const _Skeletons();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _StatSkeleton(),
        SizedBox(height: 12),
        _StatSkeleton(),
        SizedBox(height: 12),
        _StatSkeleton(),
      ],
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const FinKuCard(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          _Box(width: 40, height: 40, radius: 10),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Box(width: 64, height: 8, radius: 4),
              SizedBox(height: 6),
              _Box(width: 96, height: 14, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, required this.radius});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
