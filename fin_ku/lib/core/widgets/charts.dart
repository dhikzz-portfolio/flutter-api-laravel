import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../models/report_model.dart';
import '../utils/format.dart';

/// Satu titik data pada [TrendLineChart], mis. satu bulan atau satu hari.
class ChartPoint {
  const ChartPoint({required this.label, required this.values});

  final String label;

  /// Nilai per seri, urutannya harus sama dengan [TrendLineChart.series].
  final List<double> values;
}

/// Satu seri data beserta warnanya, mis. Penjualan (indigo) dan Laba (hijau).
class ChartSeries {
  const ChartSeries({required this.label, required this.color});

  final String label;
  final Color color;
}

typedef ChartAxisFormatter = String Function(double value);
typedef ChartDetailBuilder = String Function(int index);

/// Grafik garis yang responsif.
///
/// Menggambar sumbu Y dengan label ringkas, garis bantu, label titik, garis
/// per seri, dukungan nilai negatif, dan rincian saat titik diketuk.
/// Dipakai dashboard owner (bulanan), kasir (tren omzet), dan admin
/// (pergerakan stok).
class TrendLineChart extends StatefulWidget {
  const TrendLineChart({
    required this.points,
    required this.series,
    this.height = 190,
    this.hint = 'Ketuk titik untuk melihat rincian.',
    this.emptyMessage = 'Belum ada data grafik.',
    this.axisFormatter = _compactNumber,
    this.detailBuilder,
    super.key,
  });

  final List<ChartPoint> points;
  final List<ChartSeries> series;
  final double height;
  final String hint;
  final String emptyMessage;
  final ChartAxisFormatter axisFormatter;
  final ChartDetailBuilder? detailBuilder;

  @override
  State<TrendLineChart> createState() => _TrendLineChartState();
}

class _TrendLineChartState extends State<TrendLineChart> {
  int? _selected;

  @override
  void didUpdateWidget(covariant TrendLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected != null && _selected! >= widget.points.length) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    if (points.isEmpty || widget.series.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            widget.emptyMessage,
            style: const TextStyle(
              fontSize: 12,
              color: FinKuColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final textScaler = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, widget.height);
              final metrics = _ChartMetrics.compute(
                points: points,
                size: size,
                textScaler: textScaler,
                axisFormatter: widget.axisFormatter,
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final index = metrics.plotWidth <= 0
                      ? -1
                      : ((details.localPosition.dx - metrics.plotLeft) /
                              metrics.slotWidth)
                          .floor();
                  setState(() {
                    if (index < 0 || index >= points.length) {
                      _selected = null;
                    } else {
                      _selected = _selected == index ? null : index;
                    }
                  });
                },
                child: CustomPaint(
                  size: size,
                  painter: _LinePainter(
                    points: points,
                    series: widget.series,
                    metrics: metrics,
                    selectedIndex: _selected,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 18,
          child: _selected == null
              ? Text(
                  widget.hint,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: FinKuColors.textSecondary,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _detailText(_selected!),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FinKuColors.textPrimary,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _detailText(int index) {
    final custom = widget.detailBuilder;
    if (custom != null) return custom(index);

    final point = widget.points[index];
    final parts = <String>[];
    for (var i = 0; i < widget.series.length && i < point.values.length; i++) {
      parts.add('${widget.series[i].label} ${Fmt.number(point.values[i])}');
    }
    return [point.label, ...parts].join(' · ');
  }
}

/// Grafik tren bulanan Penjualan & Laba Kotor pada laporan owner.
class MonthlyLineChart extends StatelessWidget {
  const MonthlyLineChart({
    required this.months,
    this.height = 190,
    super.key,
  });

  final List<MonthlyReport> months;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TrendLineChart(
      height: height,
      hint: 'Ketuk titik untuk melihat rincian bulan.',
      emptyMessage: 'Belum ada data grafik.',
      points: [
        for (final m in months)
          ChartPoint(
            label: _shortMonth(m.nama),
            values: [m.penjualan, m.laba],
          ),
      ],
      series: const [
        ChartSeries(label: 'Penjualan', color: FinKuColors.primary),
        ChartSeries(label: 'Laba Kotor', color: FinKuColors.success),
      ],
      detailBuilder: (index) {
        final m = months[index];
        return '${m.nama} · Penjualan ${Fmt.rupiah(m.penjualan)}'
            ' · Laba ${Fmt.rupiah(m.laba)}';
      },
    );
  }
}

class ChartLegendEntry {
  const ChartLegendEntry({required this.color, required this.label});

  final Color color;
  final String label;
}

/// Keterangan warna grafik, mis. Penjualan (indigo) dan Laba Kotor (hijau).
class ChartLegend extends StatelessWidget {
  const ChartLegend({required this.items, super.key});

  final List<ChartLegendEntry> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 3.5,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: FinKuColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ChartMetrics {
  _ChartMetrics({
    required this.plotLeft,
    required this.plotTop,
    required this.plotRight,
    required this.plotBottom,
    required this.ticks,
    required this.axisLabels,
    required this.minValue,
    required this.maxValue,
    required this.slotWidth,
    required this.axisFontSize,
    required this.pointFontSize,
    required this.showEveryOtherLabel,
    required this.hasData,
  });

  final double plotLeft;
  final double plotTop;
  final double plotRight;
  final double plotBottom;
  final List<double> ticks;
  final List<String> axisLabels;
  final double minValue;
  final double maxValue;
  final double slotWidth;
  final double axisFontSize;
  final double pointFontSize;
  final bool showEveryOtherLabel;
  final bool hasData;

  double get plotWidth => plotRight - plotLeft;
  double get plotHeight => plotBottom - plotTop;

  double xFor(int index) => plotLeft + slotWidth * (index + 0.5);

  double yFor(double value) {
    final range = maxValue - minValue;
    if (range <= 0) return plotBottom;
    return plotBottom - (value - minValue) / range * plotHeight;
  }

  static _ChartMetrics compute({
    required List<ChartPoint> points,
    required Size size,
    required TextScaler textScaler,
    required ChartAxisFormatter axisFormatter,
  }) {
    final axisFontSize = math.min(11.0, textScaler.scale(10));
    final pointFontSize = math.min(10.5, textScaler.scale(9.5));

    var maxValue = 0.0;
    var minValue = 0.0;
    for (final point in points) {
      for (final value in point.values) {
        maxValue = math.max(maxValue, value);
        minValue = math.min(minValue, value);
      }
    }
    final hasData = maxValue != 0 || minValue != 0;

    final ticks = _niceTicks(minValue, maxValue);
    final topValue = ticks.last;
    final bottomValue = ticks.first;

    var maxLabelWidth = 0.0;
    final axisLabels = <String>[];
    for (final tick in ticks) {
      final label = axisFormatter(tick);
      axisLabels.add(label);
      final painter = _textPainter(label, fontSize: axisFontSize);
      maxLabelWidth = math.max(maxLabelWidth, painter.width);
    }

    final plotLeft = maxLabelWidth + 8;
    final plotRight = size.width - 2;
    final plotTop = 8.0;
    final plotBottom = math.max(
      plotTop + 12,
      size.height - pointFontSize - 12,
    );
    final slotWidth = points.isEmpty
        ? 0.0
        : math.max(0.0, (plotRight - plotLeft) / points.length);

    return _ChartMetrics(
      plotLeft: plotLeft,
      plotTop: plotTop,
      plotRight: plotRight,
      plotBottom: plotBottom,
      ticks: ticks,
      axisLabels: axisLabels,
      minValue: bottomValue,
      maxValue: topValue,
      slotWidth: slotWidth,
      axisFontSize: axisFontSize,
      pointFontSize: pointFontSize,
      showEveryOtherLabel: slotWidth > 0 && slotWidth < 18,
      hasData: hasData,
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.points,
    required this.series,
    required this.metrics,
    required this.selectedIndex,
  });

  final List<ChartPoint> points;
  final List<ChartSeries> series;
  final _ChartMetrics metrics;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.plotWidth <= 0 || metrics.plotHeight <= 0) return;
    if (points.isEmpty) return;

    _drawGrid(canvas);

    if (!metrics.hasData) {
      final painter = _textPainter(
        'Belum ada transaksi pada periode ini.',
        fontSize: 11,
        color: FinKuColors.textSecondary,
      );
      painter.paint(
        canvas,
        Offset(
          metrics.plotLeft + (metrics.plotWidth - painter.width) / 2,
          metrics.plotTop + (metrics.plotHeight - painter.height) / 2,
        ),
      );
    } else {
      _drawSelectionGuide(canvas);
      _drawSeries(canvas);
    }

    _drawPointLabels(canvas);
  }

  void _drawGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = FinKuColors.cardBorder.withValues(alpha: 0.75)
      ..strokeWidth = 1;
    final zeroPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.2;
    final axisPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(metrics.plotLeft, metrics.plotTop),
      Offset(metrics.plotLeft, metrics.plotBottom),
      axisPaint,
    );

    for (var i = 0; i < metrics.ticks.length; i++) {
      final tick = metrics.ticks[i];
      final y = metrics.yFor(tick);
      if (tick == 0) {
        canvas.drawLine(
          Offset(metrics.plotLeft, y),
          Offset(metrics.plotRight, y),
          zeroPaint,
        );
      } else {
        _drawDashedLine(
          canvas,
          Offset(metrics.plotLeft, y),
          Offset(metrics.plotRight, y),
          gridPaint,
        );
      }
      final label = _textPainter(
        i < metrics.axisLabels.length
            ? metrics.axisLabels[i]
            : _compactNumber(tick),
        fontSize: metrics.axisFontSize,
      );
      label.paint(
        canvas,
        Offset(metrics.plotLeft - label.width - 6, y - label.height / 2),
      );
    }
  }

  void _drawSelectionGuide(Canvas canvas) {
    final index = selectedIndex;
    if (index == null) return;

    final guide = Paint()
      ..color = FinKuColors.primary.withValues(alpha: 0.35)
      ..strokeWidth = 1.1;
    final x = metrics.xFor(index);
    _drawDashedLine(
      canvas,
      Offset(x, metrics.plotTop),
      Offset(x, metrics.plotBottom),
      guide,
      dash: 3,
      gap: 3,
    );
  }

  void _drawSeries(Canvas canvas) {
    final zeroY = metrics.yFor(0);

    for (var s = 0; s < series.length; s++) {
      final color = series[s].color;
      final offsets = <Offset>[];
      final indices = <int>[];
      for (var i = 0; i < points.length; i++) {
        final values = points[i].values;
        if (s >= values.length) continue;
        offsets.add(Offset(metrics.xFor(i), metrics.yFor(values[s])));
        indices.add(i);
      }
      if (offsets.isEmpty) continue;

      final curve = _smoothPath(offsets);

      // Area bergradasi lembut di bawah garis.
      if (offsets.length > 1) {
        final area = Path.from(curve)
          ..lineTo(offsets.last.dx, zeroY)
          ..lineTo(offsets.first.dx, zeroY)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: series.length == 1 ? 0.24 : 0.13),
                color.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromLTRB(
                metrics.plotLeft,
                metrics.plotTop,
                metrics.plotRight,
                metrics.plotBottom,
              ),
            ),
        );
      }

      // Garis putih sebagai penyangga agar garis berwarna menonjol di grid.
      canvas.drawPath(
        curve,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        curve,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      final radius = metrics.slotWidth >= 18 ? 2.8 : 2.2;
      for (var i = 0; i < offsets.length; i++) {
        final isSelected = indices[i] == selectedIndex;
        if (isSelected) {
          canvas.drawCircle(
            offsets[i],
            radius + 5,
            Paint()..color = color.withValues(alpha: 0.16),
          );
          canvas.drawCircle(
            offsets[i],
            radius + 1.8,
            Paint()..color = Colors.white,
          );
          canvas.drawCircle(
            offsets[i],
            radius + 1.1,
            Paint()..color = color,
          );
        } else {
          // Halo putih agar titik tetap terlihat di atas garis.
          canvas.drawCircle(
            offsets[i],
            radius + 1.2,
            Paint()..color = Colors.white,
          );
          canvas.drawCircle(offsets[i], radius, Paint()..color = color);
        }
      }
    }
  }

  void _drawPointLabels(Canvas canvas) {
    for (var i = 0; i < points.length; i++) {
      if (metrics.showEveryOtherLabel && i.isOdd) continue;
      final isSelected = selectedIndex == i;
      final label = _textPainter(
        points[i].label,
        fontSize: metrics.pointFontSize,
        color: isSelected ? FinKuColors.primary : FinKuColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      );
      final center = metrics.xFor(i);
      final minX = metrics.plotLeft - 2;
      final maxX = metrics.plotRight - label.width;
      // Label bisa lebih lebar dari area plot pada layar sangat sempit.
      final x = maxX < minX
          ? metrics.plotLeft
          : (center - label.width / 2).clamp(minX, maxX).toDouble();
      label.paint(canvas, Offset(x, metrics.plotBottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.series != series ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.metrics != metrics;
  }
}

/// Garis putus-putus tipis untuk grid dan penanda seleksi.
void _drawDashedLine(
  Canvas canvas,
  Offset from,
  Offset to,
  Paint paint, {
  double dash = 4,
  double gap = 4,
}) {
  final total = (to - from).distance;
  if (total <= 0) return;
  final direction = (to - from) / total;
  var start = 0.0;
  while (start < total) {
    final end = math.min(start + dash, total);
    canvas.drawLine(from + direction * start, from + direction * end, paint);
    start = end + gap;
  }
}

/// Kurva halus (monotone cubic) yang tidak melewati titik ekstrem data.
Path _smoothPath(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  if (pts.length == 1) return path;

  final n = pts.length;
  final deltas = List<double>.filled(n - 1, 0);
  for (var i = 0; i < n - 1; i++) {
    final dx = pts[i + 1].dx - pts[i].dx;
    deltas[i] = dx == 0 ? 0 : (pts[i + 1].dy - pts[i].dy) / dx;
  }

  final tangents = List<double>.filled(n, 0);
  tangents[0] = deltas.first;
  tangents[n - 1] = deltas.last;
  for (var i = 1; i < n - 1; i++) {
    tangents[i] = deltas[i - 1] * deltas[i] <= 0
        ? 0
        : (deltas[i - 1] + deltas[i]) / 2;
  }

  // Batasi tangen (Fritsch-Carlson) agar kurva tidak melampaui data.
  for (var i = 0; i < n - 1; i++) {
    final delta = deltas[i];
    if (delta == 0) {
      tangents[i] = 0;
      tangents[i + 1] = 0;
      continue;
    }
    final a = tangents[i] / delta;
    final b = tangents[i + 1] / delta;
    final squared = a * a + b * b;
    if (squared > 9) {
      final scale = 3 / math.sqrt(squared);
      tangents[i] = scale * a * delta;
      tangents[i + 1] = scale * b * delta;
    }
  }

  for (var i = 0; i < n - 1; i++) {
    final p0 = pts[i];
    final p1 = pts[i + 1];
    final thirdX = (p1.dx - p0.dx) / 3;
    path.cubicTo(
      p0.dx + thirdX,
      p0.dy + tangents[i] * thirdX,
      p1.dx - thirdX,
      p1.dy - tangents[i + 1] * thirdX,
      p1.dx,
      p1.dy,
    );
  }
  return path;
}

TextPainter _textPainter(
  String text, {
  required double fontSize,
  Color color = FinKuColors.textSecondary,
  FontWeight fontWeight = FontWeight.w400,
}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
}

List<double> _niceTicks(double minValue, double maxValue) {
  if (minValue == 0 && maxValue == 0) return const [0, 1];

  final range = maxValue - minValue;
  final rawStep = range / 4;
  if (rawStep <= 0) return const [0, 1];

  final magnitude =
      math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
  final residual = rawStep / magnitude;
  final niceResidual =
      residual <= 1 ? 1.0 : residual <= 2 ? 2.0 : residual <= 5 ? 5.0 : 10.0;
  final step = niceResidual * magnitude;

  final start = (minValue / step).floor() * step;
  final end = (maxValue / step).ceil() * step;
  final count = ((end - start) / step).round();
  final ticks = <double>[];
  for (var i = 0; i <= count; i++) {
    final value = start + step * i;
    // Hindari -0.0 pada label.
    ticks.add(value.abs() < step / 1000 ? 0 : value);
  }
  if (ticks.length < 2) return [start, start + step];
  return ticks;
}

String _compactNumber(double value) {
  if (value.abs() < 0.5) return '0';
  final sign = value < 0 ? '-' : '';
  final abs = value.abs();
  final divisor = abs >= 1e9
      ? 1e9
      : abs >= 1e6
          ? 1e6
          : abs >= 1e3
              ? 1e3
              : 1.0;
  final unit = divisor == 1e9
      ? ' M'
      : divisor == 1e6
          ? ' jt'
          : divisor == 1e3
              ? ' rb'
              : '';
  final n = abs / divisor;
  final decimals = divisor == 1
      ? 0
      : n >= 10
          ? 0
          : n >= 1
              ? 1
              : 2;
  var text = n.toStringAsFixed(decimals);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
  return '$sign${text.replaceAll('.', ',')}$unit';
}

String _shortMonth(String nama) {
  final clean = nama.trim();
  if (clean.isEmpty) return '-';
  return clean.length <= 3 ? clean : clean.substring(0, 3);
}
