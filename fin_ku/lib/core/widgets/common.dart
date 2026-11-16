import 'package:flutter/material.dart';

import '../errors/api_exception.dart';
import '../utils/format.dart';

/// Panel putih dengan border, penanda gaya kartu halaman web.
class FinKuCard extends StatelessWidget {
  const FinKuCard({
    required this.child,
    this.padding,
    this.radius = 14,
    super.key,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

/// Status baris list: label chip berwarna.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    // Scroll view mencegah overflow saat area yang tersedia pendek, misalnya
    // di dalam panel kecil atau ketika keyboard terbuka.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 2.4),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.icon,
    required this.title,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: const Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 44, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu statistik dashboard menyerupai panel web berwarna aksen.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FinKuCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar filter rentang tanggal, dipakai halaman admin/owner yang di web
/// memakai input date_from & date_to.
class DateRangeFilterBar extends StatelessWidget {
  const DateRangeFilterBar({
    required this.from,
    required this.to,
    required this.onChanged,
    super.key,
  });

  final DateTime? from;
  final DateTime? to;
  final void Function(DateTime? from, DateTime? to) onChanged;

  Future<void> _pick(BuildContext context, bool isFrom) async {
    final now = DateTime.now();
    final initial = (isFrom ? from : to) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: isFrom ? 'Tanggal mulai' : 'Tanggal akhir',
    );
    if (picked == null) return;

    if (isFrom) {
      final end = (to != null && to!.isBefore(picked)) ? picked : to;
      onChanged(picked, end);
    } else {
      final start = (from != null && from!.isAfter(picked)) ? picked : from;
      onChanged(start, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = from != null || to != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => _pick(context, true),
          icon: const Icon(Icons.calendar_today, size: 15),
          label: Text(from == null ? 'Dari tanggal' : Fmt.tanggal(from)),
        ),
        OutlinedButton.icon(
          onPressed: () => _pick(context, false),
          icon: const Icon(Icons.calendar_today, size: 15),
          label: Text(to == null ? 'Sampai tanggal' : Fmt.tanggal(to)),
        ),
        if (hasFilter)
          IconButton(
            tooltip: 'Hapus filter tanggal',
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => onChanged(null, null),
          ),
      ],
    );
  }
}

/// Bidang pencarian dengan debounce sederhana via submit.
class SearchField extends StatefulWidget {
  const SearchField({required this.hint, required this.onSubmitted, super.key});

  final String hint;
  final ValueChanged<String> onSubmitted;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_syncClearButton);
  }

  /// Tombol hapus hanya perlu dibangun ulang saat isi berubah kosong/terisi.
  void _syncClearButton() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (v) => widget.onSubmitted(v.trim()),
      decoration: InputDecorationX.search(hint: widget.hint).copyWith(
        suffixIcon: !_hasText
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _controller.clear();
                  widget.onSubmitted('');
                },
              ),
      ),
    );
  }
}

/// Dialog konfirmasi untuk aksi penting (pembatalan transaksi, hapus data).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya, Lanjutkan',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive
                ? const Color(0xFFDC2626)
                : const Color(0xFF4F46E5),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

/// Popup detail terpusat yang konsisten di seluruh aplikasi.
Future<T?> showAppPopup<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double maxWidth = 560,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.82,
        ),
        child: builder(ctx),
      ),
    ),
  );
}

void showInfoSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
}

String errorText(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return 'Terjadi kesalahan. Coba lagi atau periksa koneksi.';
}

/// Chip aksi kecil untuk row list.
class IconicAction extends StatelessWidget {
  const IconicAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF4F46E5);
    return Material(
      color: c.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: c),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
