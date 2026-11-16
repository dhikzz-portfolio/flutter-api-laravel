import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/report_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';
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

  /// Pergerakan stok 7 hari terakhir; null selama belum termuat / gagal.
  List<ChartPoint>? _trend;
  List<DateTime> _trendDates = const [];
  String _trendError = '';

  static const _trendDays = 7;
  static const _barangKeluarColor = Color(0xFFB45309);

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
    await _loadTrend();
  }

  /// Barang masuk/keluar harian dihitung dari riwayat stok 7 hari terakhir,
  /// karena endpoint dashboard admin hanya mengirim angka hari ini.
  Future<void> _loadTrend() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: _trendDays - 1));
    final dates = [
      for (var i = 0; i < _trendDays; i++) start.add(Duration(days: i)),
    ];
    final masuk = <String, int>{for (final d in dates) _dayKey(d): 0};
    final keluar = <String, int>{for (final d in dates) _dayKey(d): 0};

    try {
      final repo = KatalogRepository(basePath: '/api/v1/admin');
      var page = 1;
      var lastPage = 1;
      do {
        final result = await repo.riwayatStok(
          dateFrom: _isoDate(start),
          dateTo: _isoDate(today),
          page: page,
          perPage: 100,
        );
        for (final movement in result.items) {
          final tanggal = movement.tanggal;
          final key = tanggal == null ? '' : _dayKey(tanggal);
          if (!masuk.containsKey(key)) continue;
          if (movement.jumlah >= 0) {
            masuk[key] = masuk[key]! + movement.jumlah;
          } else {
            keluar[key] = keluar[key]! - movement.jumlah;
          }
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
              values: [
                (masuk[_dayKey(d)] ?? 0).toDouble(),
                (keluar[_dayKey(d)] ?? 0).toDouble(),
              ],
            ),
        ];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _trend = null;
        _trendError = 'Grafik pergerakan stok tidak tersedia.';
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
              _buildTrendCard(),
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

  Widget _buildTrendCard() {
    final trend = _trend;
    return FinKuCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pergerakan Stok 7 Hari Terakhir',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
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
                ChartSeries(label: 'Barang Masuk', color: FinKuColors.success),
                ChartSeries(
                  label: 'Barang Keluar',
                  color: _barangKeluarColor,
                ),
              ],
              height: 170,
              detailBuilder: (index) {
                final date = index < _trendDates.length
                    ? _trendDates[index]
                    : null;
                final masuk = trend[index].values[0].round();
                final keluar = trend[index].values[1].round();
                return '${Fmt.tanggal(date)} · Masuk ${Fmt.number(masuk)} unit'
                    ' · Keluar ${Fmt.number(keluar)} unit';
              },
            ),
            const SizedBox(height: 8),
            const ChartLegend(
              items: [
                ChartLegendEntry(
                  color: FinKuColors.success,
                  label: 'Barang Masuk',
                ),
                ChartLegendEntry(
                  color: _barangKeluarColor,
                  label: 'Barang Keluar',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
