import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../errors/api_exception.dart';
import '../utils/format.dart';

/// Panel putih dengan border halus dan bayangan tipis, penanda gaya kartu
/// halaman web Laravel (`rounded-xl border bg-white shadow-sm`).
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
        color: FinKuColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: FinKuColors.cardBorder),
        boxShadow: FinKuColors.cardShadow,
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
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            if (message != null) ...[
              const SizedBox(height: 14),
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
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: FinKuColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: FinKuColors.primary),
            ),
            const SizedBox(height: 14),
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
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: FinKuCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: FinKuColors.dangerSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 30,
                    color: FinKuColors.danger,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Gagal memuat data',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu statistik dashboard, mengikuti pola web Laravel: label kecil,
/// angka besar, keterangan satuan, dan ikon beraksen di sisi kanan.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.hint,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  /// Keterangan kecil di bawah angka, mis. "transaksi" atau "unit".
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return FinKuCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: FinKuColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                      color: FinKuColors.textPrimary,
                    ),
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hint!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: FinKuColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
        ],
      ),
    );
  }
}

/// Tanggal hari ini di kanan AppBar, meniru topbar web Laravel.
class AppBarDate extends StatelessWidget {
  const AppBarDate({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: FinKuColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: FinKuColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: FinKuColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              Fmt.tanggalPanjang(DateTime.now()),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: FinKuColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid kartu statistik yang menyesuaikan lebar: 1 kolom di ponsel,
/// 2 kolom di tablet, dan hingga 4 kolom di desktop seperti dashboard web.
class ResponsiveStatGrid extends StatelessWidget {
  const ResponsiveStatGrid({required this.children, this.gap = 12, super.key});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = children.isEmpty
            ? 1
            : width >= 1000
                ? math.min(4, children.length)
                : width >= 860 && children.length == 3
                    ? 3
                    : width >= 620
                        ? math.min(2, children.length)
                        : 1;
        final itemWidth = columns <= 1
            ? width
            : (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Judul bagian dengan subjudul dan aksi opsional, dipakai di dalam kartu
/// maupun antar-kartu agar hierarki halaman konsisten.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: FinKuColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: FinKuColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
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
      title: Row(
        children: [
          Icon(
            destructive
                ? Icons.warning_amber_rounded
                : Icons.help_outline_rounded,
            size: 22,
            color: destructive ? FinKuColors.danger : FinKuColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(
            foregroundColor: FinKuColors.textSecondary,
          ),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive
                ? FinKuColors.danger
                : FinKuColors.primary,
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
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: Color(0xFF86EFAC),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: Color(0xFFFCA5A5),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: FinKuColors.danger,
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
      color: c.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
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
