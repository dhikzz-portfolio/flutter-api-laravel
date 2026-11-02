import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/common.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/api_exception.dart';

String rupiah(num value) {
  final formatted = NumberFormat.decimalPattern('id').format(value.round());
  return 'Rp $formatted';
}

String namaBulan(int month) {
  const names = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return names[(month - 1).clamp(0, 11)];
}

class OwnerLaporanScreen extends StatefulWidget {
  const OwnerLaporanScreen({super.key});

  @override
  State<OwnerLaporanScreen> createState() => _OwnerLaporanScreenState();
}

class _OwnerLaporanScreenState extends State<OwnerLaporanScreen> {
  // Filter periode
  int _selectedYear = 0;
  int? _selectedMonth;
  final TextEditingController _yearController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _hasValidYear = false;

  // Summary data
  double _totalPenjualan = 0.0;
  double _totalHpp = 0.0;
  double _labaKotor = 0.0;

  // Monthly data
  List<Map<String, dynamic>> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    _initCurrentYear();
    _loadLaporan();
  }

  Future<void> _initCurrentYear() async {
    _selectedYear = DateTime.now().year;
    _yearController.text = _selectedYear.toString();
    if (_selectedYear > DateTime.now().year) {
      _selectedYear = DateTime.now().year;
      _yearController.text = _selectedYear.toString();
    }
  }

  Future<void> _loadLaporan() async {
    if (_selectedYear <= 0) {
      setState(() => _error = 'Tahun harus diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiClient.get(
        '/api/v1/owner/laporan',
        query: {
          'year': _selectedYear.toString(),
          if (_selectedMonth != null) 'month': _selectedMonth.toString(),
        },
      );
      final data = response['data'] as Map<String, dynamic>? ?? {};

      setState(() {
        _hasValidYear = true;
        _totalPenjualan = (data['total_penjualan'] ?? 0).toDouble();
        _totalHpp = (data['total_hpp'] ?? 0).toDouble();
        _labaKotor = (data['laba_kotor'] ?? 0).toDouble();
        _monthlyData = List<Map<String, dynamic>>.from(data['monthly_data'] ?? []);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectMonth(int month) {
    setState(() {
      _selectedMonth = month;
    });
    _loadLaporan();
  }

  bool _isExporting = false;

  Future<void> _exportExcel() async {
    if (!_hasValidYear) {
      _showError('Pilih tahun terlebih dahulu');
      return;
    }

    setState(() => _isExporting = true);

    try {
      await ApiClient.getBytes(
        '/api/v1/owner/laporan/export-excel',
        query: {
          'year': _selectedYear.toString(),
          if (_selectedMonth != null) 'month': _selectedMonth.toString(),
        },
      );
      _showInfo('Excel berhasil di-export');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal ekspor: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPdf() async {
    if (!_hasValidYear) {
      _showError('Pilih tahun terlebih dahulu');
      return;
    }

    setState(() => _isExporting = true);

    try {
      await ApiClient.getBytes(
        '/api/v1/owner/laporan/export-pdf',
        query: {
          'year': _selectedYear.toString(),
          if (_selectedMonth != null) 'month': _selectedMonth.toString(),
        },
      );
      _showInfo('PDF berhasil di-export');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal ekspor: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // --- Widget Build ---
  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AppUser>().isOwner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [],
      ),
      body: _buildBody(isOwner),
    );
  }

  Widget _buildBody(bool isOwner) {
    if (!_hasValidYear) {
      return _buildEmptyState(
        'Pilih tahun laporan menggunakan field di bawah ini',
        Icons.calendar_today,
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    return _buildContent();
  }

  Widget _buildContent() {
    final monthDisplay =
        _selectedMonth != null
            ? '${namaBulan(_selectedMonth!)} $_selectedYear'
            : 'Seluruh Tahun $_selectedYear';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          _buildFilterSection(monthDisplay),

          const SizedBox(height: 24),

          // Summary Cards
          _buildSummaryCards(),

          const SizedBox(height: 24),

          // Export Buttons
          _buildExportButtons(),

          const SizedBox(height: 24),

          // Monthly Breakdown
          _buildMonthlyBreakdown(),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String monthDisplay) {
    return FinKuCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Periode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: 'Tahun',
                    hintText: 'Contoh: 2024',
                    border: OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _applyFilter(),
                ),
              ),
              const SizedBox(width: 12),
              // Bulan dropdown
              _buildMonthDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonth,
          hint: const Text('Bulan'),
          icon: const Icon(Icons.arrow_drop_down),
          items: List.generate(12, (i) => i + 1).map((month) => DropdownMenuItem<int>(
            value: month,
            child: Text(namaBulan(month)),
          )).toList(),
          onChanged: (val) => _selectMonth(val!),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: FinKuCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Penjualan',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(rupiah(_totalPenjualan),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FinKuCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('HPP', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(rupiah(_totalHpp),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FinKuCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Laba Kotor',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(rupiah(_labaKotor),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown() {
    if (_monthlyData.isEmpty) {
      return const FinKuCard(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Tidak ada data bulan'),
        ),
      );
    }

    return FinKuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekap Bulanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => const Color(0xFFF1F8FF)),
              headingTextStyle:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              columns: const [
                DataColumn(label: Text('Bulan')),
                DataColumn(label: Text('Penjualan')),
                DataColumn(label: Text('HPP')),
                DataColumn(label: Text('Laba')),
              ],
              rows: _monthlyData.map((item) {
                final bulan = (item['bulan'] ?? 0).toInt() ?? 0;
                final namaBl = namaBulan(bulan);
                final penjualan = (item['penjualan'] ?? 0).toDouble();
                final hpp = (item['hpp'] ?? 0).toDouble();
                final laba = (item['laba'] ?? 0).toDouble();
                return DataRow(cells: [
                  DataCell(Text(namaBl)),
                  DataCell(Text(rupiah(penjualan))),
                  DataCell(Text(rupiah(hpp))),
                  DataCell(Text(rupiah(laba))),
                ]);
              }).toList()
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportExcel,
            icon: const Icon(Icons.remove),
            label: const Text('Export Excel'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String subtitle, IconData icon) {
    return Center(
      child: FinKuCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        color: const Color(0xFFFEF3F2),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadLaporan(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Action handlers ---
  Future<void> _applyFilter() async {
    final text = _yearController.text.trim();
    if (text.isEmpty) {
      _showError('Tahun wajib diisi');
      return;
    }
    final year = int.tryParse(text);
    if (year == null || year < 2000 || year > 2100) {
      _showError('Tahun tidak valid');
      return;
    }
    setState(() {
      _selectedYear = year;
      _selectedMonth = null;
    });
    _loadLaporan();
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }
}