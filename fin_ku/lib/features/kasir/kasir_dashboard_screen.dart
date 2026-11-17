import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/report_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
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

  /// Tren omzet 7 hari terakhir; null selama belum termuat / gagal.
  List<ChartPoint>? _trend;
  List<DateTime> _trendDates = const [];
  String _trendError = '';

  static const _trendDays = 7;

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
    await _loadTrend();
  }

  /// Omzet harian dihitung dari daftar penjualan 7 hari terakhir, karena
  /// endpoint dashboard kasir hanya mengirim angka hari ini.
  Future<void> _loadTrend() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: _trendDays - 1));
    final dates = [
      for (var i = 0; i < _trendDays; i++) start.add(Duration(days: i)),
    ];
    final totals = <String, double>{
      for (final d in dates) _dayKey(d): 0,
    };

    try {
      final repo = KasirRepository();
      var page = 1;
      var lastPage = 1;
      do {
        final result = await repo.penjualan(
          dateFrom: _isoDate(start),
          dateTo: _isoDate(today),
          page: page,
          perPage: 100,
        );
        for (final sale in result.items) {
          final tanggal = sale.tanggal;
          final key = tanggal == null ? '' : _dayKey(tanggal);
          if (!totals.containsKey(key)) continue;
          totals[key] = totals[key]! + sale.total;
        }
        lastPage = result.lastPage;
        page++;
        // Batasi jumlah permintaan agar dashboard tetap ringan.
      } while (page <= lastPage && page <= 5);

      if (!mounted) return;
      setState(() {
        _trendError = '';
        _trendDates = dates;
        _trend = [
          for (final d in dates)
            ChartPoint(
              label: '${d.day}',
              values: [totals[_dayKey(d)] ?? 0],
            ),
        ];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _trend = null;
        _trendError = 'Grafik penjualan tidak tersedia.';
      });
    }
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kasir'),
        actions: [
          if (wide) const AppBarDate(),
        ],
      ),
      backgroundColor: FinKuColors.bg,
      body: _loading && _stats == null
          ? const _Skeletons()
          : _error.isNotEmpty
              ? ErrorView(message: _error, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SectionHeader(
                        title: 'Ringkasan Hari Ini',
                        subtitle: 'Aktivitas penjualan dan stok terkini',
                      ),
                      const SizedBox(height: 12),
                      ResponsiveStatGrid(
                        children: [
                          StatCard(
                            label: 'Penjualan Hari Ini',
                            value: Fmt.number(_stats?.penjualanHariIni ?? 0),
                            hint: 'transaksi',
                            icon: Icons.receipt_long_outlined,
                            color: FinKuColors.success,
                          ),
                          StatCard(
                            label: 'Total Transaksi Hari Ini',
                            value: Fmt.rupiah(_stats?.totalTransaksi ?? 0),
                            hint: 'omzet',
                            icon: Icons.payments_outlined,
                            color: FinKuColors.primary,
                          ),
                          StatCard(
                            label: 'Stok Minimum',
                            value: Fmt.number(_stats?.stokMinimum ?? 0),
                            hint: 'produk perlu restok',
                            icon: Icons.warning_amber_outlined,
                            color: (_stats?.stokMinimum ?? 0) > 0
                                ? FinKuColors.warning
                                : FinKuColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTrendCard(),
                      const SizedBox(height: 20),
                      FinKuCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Aksi Cepat',
                              subtitle: 'Mulai pekerjaan tanpa pindah menu',
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                FilledButton.icon(
                                  onPressed: widget.onOpenPenjualan,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Transaksi Baru'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: widget.onOpenPembeli,
                                  icon: const Icon(
                                    Icons.person_add_alt_1_outlined,
                                    size: 18,
                                  ),
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

  Widget _buildTrendCard() {
    final trend = _trend;
    return FinKuCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Penjualan 7 Hari Terakhir',
            subtitle: 'Omzet harian dari transaksi tercatat',
          ),
          const SizedBox(height: 14),
          if (trend == null)
            SizedBox(
              height: 180,
              child: Center(
                child: _trendError.isEmpty
                    ? const CircularProgressIndicator(strokeWidth: 2.2)
                    : Text(
                        _trendError,
                        style: const TextStyle(
                          fontSize: 12,
                          color: FinKuColors.textSecondary,
                        ),
                      ),
              ),
            )
          else ...[
            TrendLineChart(
              points: trend,
              series: const [
                ChartSeries(label: 'Penjualan', color: FinKuColors.primary),
              ],
              height: 170,
              detailBuilder: (index) {
                final date = index < _trendDates.length
                    ? _trendDates[index]
                    : null;
                final value = trend[index].values.first;
                return '${Fmt.tanggal(date)} · Penjualan ${Fmt.rupiah(value)}';
              },
            ),
            const SizedBox(height: 8),
            const ChartLegend(
              items: [
                ChartLegendEntry(
                  color: FinKuColors.primary,
                  label: 'Penjualan',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Skeletons extends StatelessWidget {
  const _Skeletons();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _Box(width: 150, height: 13, radius: 4),
        SizedBox(height: 14),
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
      padding: EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(width: 84, height: 8, radius: 4),
                SizedBox(height: 8),
                _Box(width: 110, height: 18, radius: 4),
              ],
            ),
          ),
          SizedBox(width: 12),
          _Box(width: 46, height: 46, radius: 14),
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
