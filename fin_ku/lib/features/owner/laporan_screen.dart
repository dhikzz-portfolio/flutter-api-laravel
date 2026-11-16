import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/report_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/file_exporter.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../katalog/data/katalog_repository.dart';

/// Laporan Laba/Rugi owner, mengikuti halaman owner/laporan/index.blade.php:
/// filter tahun/bulan, ringkasan, breakdown bulanan, detail transaksi,
/// serta ekspor Excel & PDF.
class OwnerLaporanScreen extends StatefulWidget {
  const OwnerLaporanScreen({super.key});

  @override
  State<OwnerLaporanScreen> createState() => _OwnerLaporanScreenState();
}

class _OwnerLaporanScreenState extends State<OwnerLaporanScreen> {
  final _repo = OwnerRepository();

  late int _year = DateTime.now().year;
  int? _month;
  LaporanData? _data;
  bool _loading = true;
  bool _exporting = false;
  String _error = '';

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
      final data = await _repo.laporan(year: _year, month: _month);
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _periodeLabel => _month == null
      ? 'Seluruh Tahun $_year'
      : '${Fmt.namaBulan(_month!)} $_year';

  String get _fileSuffix => _month == null ? '$_year' : '${_year}_$_month';

  Future<void> _export(String jenis) async {
    final isExcel = jenis == 'excel';
    setState(() => _exporting = true);
    try {
      final bytes = await _repo.downloadExport(
        jenis: jenis,
        year: _year,
        month: _month,
      );
      final fileName =
          'Laporan_Laba_Rugi_$_fileSuffix.${isExcel ? 'xlsx' : 'pdf'}';
      await FileExporter.saveAndShare(
        bytes: Uint8List.fromList(bytes),
        fileName: fileName,
        mimeType: isExcel
            ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            : 'application/pdf',
      );
      if (!mounted) return;
      showInfoSnack(context, 'Laporan ${isExcel ? 'Excel' : 'PDF'} berhasil diunduh.');
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, errorText(e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Laba/Rugi')),
      backgroundColor: FinKuColors.bg,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildFilterCard(),
            const SizedBox(height: 16),
            if (_loading && _data == null)
              const FinKuCard(
                child: SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                ),
              )
            else if (_error.isNotEmpty) ...[
              ErrorView(message: _error, onRetry: _load),
              const SizedBox(height: 200),
            ] else if (_data != null) ...[
              _buildSummary(_data!),
              const SizedBox(height: 16),
              _buildMonthlyChart(_data!),
              const SizedBox(height: 16),
              _buildMonthlyBreakdown(_data!),
              const SizedBox(height: 16),
              _buildDetailTransaksi(_data!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    final currentYear = DateTime.now().year;
    return FinKuCard(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<int>(
              initialValue: _year,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Tahun',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: [
                for (var y = currentYear; y >= currentYear - 5; y--)
                  DropdownMenuItem(value: y, child: Text('$y')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _year = v);
              },
            ),
          ),
          SizedBox(
            width: 175,
            child: DropdownButtonFormField<int?>(
              initialValue: _month,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Bulan',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Semua Bulan')),
                for (var m = 1; m <= 12; m++)
                  DropdownMenuItem<int?>(value: m, child: Text(Fmt.namaBulan(m))),
              ],
              onChanged: (v) => setState(() => _month = v),
            ),
          ),
          FilledButton(
            onPressed: _loading ? null : _load,
            child: const Text('Filter'),
          ),
          SizedBox(width: 1, height: 1),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            onPressed: _exporting ? null : () => _export('excel'),
            icon: const Icon(Icons.download, size: 17),
            label: const Text('Excel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: FinKuColors.danger,
            ),
            onPressed: _exporting ? null : () => _export('pdf'),
            icon: const Icon(Icons.download, size: 17),
            label: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(LaporanData data) {
    final laba = data.labaKotor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Periode: $_periodeLabel',
          style: const TextStyle(fontSize: 12.5, color: FinKuColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _summaryCard('Total Penjualan', Fmt.rupiah(data.totalPenjualan)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _summaryCard('Total HPP', Fmt.rupiah(data.totalHpp)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _summaryCard(
                'Laba Kotor',
                Fmt.rupiah(laba),
                color: laba >= 0 ? FinKuColors.success : FinKuColors.danger,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, {Color? color}) {
    return FinKuCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: FinKuColors.textSecondary),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color ?? FinKuColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(LaporanData data) {
    return FinKuCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Bulanan $_year',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          MonthlyLineChart(months: data.monthlyData, height: 180),
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
    );
  }

  Widget _buildMonthlyBreakdown(LaporanData data) {
    return FinKuCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breakdown Bulanan $_year',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              headingRowHeight: 34,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              headingTextStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: FinKuColors.textSecondary,
              ),
              columns: const [
                DataColumn(label: Text('Bulan')),
                DataColumn(label: Text('Penjualan'), numeric: true),
                DataColumn(label: Text('HPP'), numeric: true),
                DataColumn(label: Text('Laba Kotor'), numeric: true),
              ],
              rows: data.monthlyData.map((m) {
                final isSelected = _month != null && _month == m.bulan;
                return DataRow(
                  color: isSelected
                      ? WidgetStatePropertyAll(
                          FinKuColors.primary.withValues(alpha: 0.08),
                        )
                      : null,
                  cells: [
                    DataCell(Text(Fmt.namaBulan(m.bulan),
                        style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(Fmt.rupiah(m.penjualan))),
                    DataCell(Text(Fmt.rupiah(m.hpp))),
                    DataCell(Text(
                      Fmt.rupiah(m.laba),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: m.laba >= 0
                            ? FinKuColors.success
                            : FinKuColors.danger,
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTransaksi(LaporanData data) {
    final items = data.penjualan;
    return FinKuCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Transaksi',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Tidak ada data transaksi untuk periode ini.',
                  style: TextStyle(color: FinKuColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowHeight: 34,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 40,
                headingTextStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FinKuColors.textSecondary,
                ),
                columns: const [
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Invoice')),
                  DataColumn(label: Text('Pembeli')),
                  DataColumn(label: Text('Total'), numeric: true),
                  DataColumn(label: Text('HPP'), numeric: true),
                  DataColumn(label: Text('Laba'), numeric: true),
                ],
                rows: items.map((Sale sale) {
                  final hpp = sale.totalHpp;
                  final laba = sale.total - hpp;
                  return DataRow(cells: [
                    DataCell(Text(
                      Fmt.tanggal(sale.tanggal),
                      style: const TextStyle(color: FinKuColors.textSecondary),
                    )),
                    DataCell(Text(
                      sale.invoice,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                      ),
                    )),
                    DataCell(Text(sale.buyerNama)),
                    DataCell(Text(
                      Fmt.rupiah(sale.total),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )),
                    DataCell(Text(
                      Fmt.rupiah(hpp),
                      style: const TextStyle(color: FinKuColors.textSecondary),
                    )),
                    DataCell(Text(
                      Fmt.rupiah(laba),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: laba >= 0
                            ? FinKuColors.success
                            : FinKuColors.danger,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
