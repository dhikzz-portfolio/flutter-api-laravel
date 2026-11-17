import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/report_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
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
    final wide = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Owner'),
        actions: [
          if (wide) const AppBarDate(),
        ],
      ),
      backgroundColor: FinKuColors.bg,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            FinKuCard(
              padding: const EdgeInsets.all(14),
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
              const SectionHeader(
                title: 'Ringkasan Periode',
                subtitle: 'Penjualan, harga pokok, dan laba kotor',
              ),
              const SizedBox(height: 12),
              ResponsiveStatGrid(
                children: [
                  StatCard(
                    label: 'Total Penjualan',
                    value: Fmt.rupiah(_data!.totalPenjualan),
                    hint: 'periode ini',
                    icon: Icons.payments_outlined,
                    color: FinKuColors.primary,
                  ),
                  StatCard(
                    label: 'Total HPP',
                    value: Fmt.rupiah(_data!.totalHpp),
                    hint: 'harga pokok penjualan',
                    icon: Icons.inventory_outlined,
                    color: FinKuColors.warning,
                  ),
                  StatCard(
                    label: 'Laba Kotor ${Fmt.namaBulan(_month)} $_year',
                    value: Fmt.rupiah(_data!.labaKotor),
                    hint: 'setelah HPP',
                    icon: Icons.trending_up_rounded,
                    color: _data!.labaKotor >= 0
                        ? FinKuColors.success
                        : FinKuColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FinKuCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Grafik Bulanan $_year',
                      subtitle: 'Perbandingan penjualan dan laba kotor',
                    ),
                    const SizedBox(height: 14),
                    MonthlyLineChart(months: _data!.months),
                    const SizedBox(height: 10),
                    const ChartLegend(
                      items: [
                        ChartLegendEntry(
                          color: FinKuColors.primary,
                          label: 'Penjualan',
                        ),
                        ChartLegendEntry(
                          color: FinKuColors.success,
                          label: 'Laba Kotor',
                        ),
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

}
