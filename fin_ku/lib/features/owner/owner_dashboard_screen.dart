import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/report_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';

/// Dashboard owner: ringkasan periode terpilih + grafik 12 bulan.
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key, this.onOpenLaporan});

  final VoidCallback? onOpenLaporan;

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _repo = OwnerRepository();
  OwnerDashboardData? _data;
  String _error = '';
  bool _loading = true;

  late int _year = DateTime.now().year;
  late int _month = DateTime.now().month;

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
      final data = await _repo.dashboard(year: _year, month: _month);
      if (!mounted) return;
      setState(() => _data = data);
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
      appBar: AppBar(title: const Text('Dashboard Owner')),
      backgroundColor: FinKuColors.bg,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            FinKuCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _month,
                      isDense: true,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Bulan',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: [
                        for (var m = 1; m <= 12; m++)
                          DropdownMenuItem(value: m, child: Text(Fmt.namaBulan(m))),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        _month = v;
                        _load();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 105,
                    child: DropdownButtonFormField<int>(
                      initialValue: _year,
                      isDense: true,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tahun',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: [
                        for (var y = DateTime.now().year; y >= DateTime.now().year - 5; y--)
                          DropdownMenuItem(value: y, child: Text('$y')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        _year = v;
                        _load();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_loading && _data == null)
              const FinKuCard(
                child: SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                ),
              )
            else if (_error.isNotEmpty)
              ...[
                ErrorView(message: _error, onRetry: _load),
                const SizedBox(height: 200),
              ]
            else if (_data != null) ...[
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total Penjualan',
                      value: Fmt.rupiah(_data!.totalPenjualan),
                      icon: Icons.payments_outlined,
                      color: FinKuColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Total HPP',
                      value: Fmt.rupiah(_data!.totalHpp),
                      icon: Icons.inventory_outlined,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StatCard(
                label: 'Laba Kotor ${Fmt.namaBulan(_month)} $_year',
                value: Fmt.rupiah(_data!.labaKotor),
                icon: Icons.trending_up,
                color: _data!.labaKotor >= 0
                    ? FinKuColors.success
                    : FinKuColors.danger,
              ),
              const SizedBox(height: 16),
              FinKuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Bulanan $_year',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MonthlyBars(months: _data!.months),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _legend(FinKuColors.primary, 'Penjualan'),
                        const SizedBox(width: 14),
                        _legend(FinKuColors.success, 'Laba Kotor'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (widget.onOpenLaporan != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onOpenLaporan,
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Lihat Laporan Lengkap'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: FinKuColors.textSecondary),
        ),
      ],
    );
  }
}

/// Bar chart horizontal sederhana, meniru grafik CSS pada dashboard web.
class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars({required this.months});

  final List<MonthlyReport> months;

  @override
  Widget build(BuildContext context) {
    final maxValue = months.fold<double>(
      1,
      (max, m) => m.penjualan > max ? m.penjualan : max,
    );

    return Column(
      children: [
        for (final m in months)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    m.nama,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: FinKuColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _bar(m.penjualan, maxValue, FinKuColors.primary),
                      const SizedBox(height: 2),
                      _bar(
                        m.laba < 0 ? 0 : m.laba,
                        maxValue,
                        FinKuColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 84,
                  child: Text(
                    Fmt.rupiah(m.penjualan),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      color: FinKuColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _bar(double value, double maxValue, Color color) {
    final ratio = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: 6,
        width: constraints.maxWidth * ratio,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
