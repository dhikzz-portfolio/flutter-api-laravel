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
    final wide = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
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
            if (_loading && _stats == null) ...[
              const FinKuCard(
                child: SizedBox(
                  height: 90,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
            ] else if (_error.isNotEmpty) ...[
              ErrorView(message: _error, onRetry: _load),
              const SizedBox(height: 200),
            ] else if (_stats != null) ...[
              const SectionHeader(
                title: 'Ringkasan Hari Ini',
                subtitle: 'Pembelian dan pergerakan stok terkini',
              ),
              const SizedBox(height: 12),
              ResponsiveStatGrid(
                children: [
                  StatCard(
                    label: 'Pembelian Hari Ini',
                    value: Fmt.number(_stats!.pembelianHariIni),
                    hint: 'transaksi',
                    icon: Icons.shopping_bag_outlined,
                    color: FinKuColors.info,
                  ),
                  StatCard(
                    label: 'Barang Masuk',
                    value: Fmt.number(_stats!.barangMasuk),
                    hint: 'unit',
                    icon: Icons.move_to_inbox_outlined,
                    color: FinKuColors.success,
                  ),
                  StatCard(
                    label: 'Barang Keluar',
                    value: Fmt.number(_stats!.barangKeluar),
                    hint: 'unit',
                    icon: Icons.outbox_outlined,
                    color: FinKuColors.warning,
                  ),
                  StatCard(
                    label: 'Stok Minimum',
                    value: Fmt.number(_stats!.produkStokMinimum.length),
                    hint: 'produk perlu restok',
                    icon: Icons.warning_amber_outlined,
                    color: FinKuColors.danger,
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
                    SectionHeader(
                      title: 'Produk di Bawah Stok Minimum',
                      subtitle: _stats!.produkStokMinimum.isEmpty
                          ? 'Semua stok aman di atas batas minimum'
                          : '${_stats!.produkStokMinimum.length} produk perlu segera direstok',
                    ),
                    const SizedBox(height: 12),
                    if (_stats!.produkStokMinimum.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Tidak ada produk yang menipis. Stok aman.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: FinKuColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      for (final p in _stats!.produkStokMinimum)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: FinKuColors.bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: FinKuColors.borderSoft,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: FinKuColors.warningSoft,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(
                                  Icons.sync_problem_outlined,
                                  size: 17,
                                  color: FinKuColors.warning,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: FinKuColors.textBody,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: FinKuColors.dangerSoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${p.stok} / min ${p.stokMinimum}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: FinKuColors.danger,
                                  ),
                                ),
                              ),
                            ],
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Pergerakan Stok 7 Hari Terakhir',
            subtitle: 'Barang masuk dan keluar per hari',
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
