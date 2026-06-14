import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EnergyPoint {
  final String label;
  final int score;
  const EnergyPoint(this.label, this.score);
}

/// Simple area chart for the weekly Daily Energy trend, drawn by hand so the
/// app carries no extra charting dependency.
class EnergyChart extends StatelessWidget {
  final List<EnergyPoint> points;
  final String thresholdLabel;
  final double height;

  const EnergyChart({
    super.key,
    required this.points,
    required this.thresholdLabel,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _EnergyChartPainter(points, thresholdLabel),
      ),
    );
  }
}

class _EnergyChartPainter extends CustomPainter {
  final List<EnergyPoint> points;
  final String thresholdLabel;
  _EnergyChartPainter(this.points, this.thresholdLabel);

  static const double _maxY = 700;
  static const List<int> _yTicks = [0, 200, 400, 600];

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 30.0;
    const bottomPad = 22.0;
    const topPad = 10.0;
    final plotW = size.width - leftPad;
    final plotH = size.height - bottomPad - topPad;

    double xFor(int i) =>
        leftPad + (points.length == 1 ? plotW / 2 : plotW * i / (points.length - 1));
    double yFor(num score) =>
        topPad + plotH * (1 - (score.clamp(0, _maxY)) / _maxY);

    // Y grid + labels
    final gridPaint = Paint()
      ..color = AppColors.lavender.withOpacity(0.10)
      ..strokeWidth = 1;
    for (final tick in _yTicks) {
      final y = yFor(tick);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      _text(canvas, '$tick', Offset(0, y - 6),
          AppText.sans(size: 10, color: AppColors.muted2));
    }

    // Threshold line at 200
    final threshPaint = Paint()
      ..color = AppColors.tealSoft
      ..strokeWidth = 1.5;
    final ty = yFor(200);
    _dashedLine(canvas, Offset(leftPad, ty), Offset(size.width, ty), threshPaint);
    _text(canvas, thresholdLabel, Offset(size.width - 86, ty + 2),
        AppText.sans(size: 9, color: const Color(0xFF70A898)));

    if (points.isEmpty) return;

    // Area fill + line
    final linePath = Path();
    final areaPath = Path();
    for (var i = 0; i < points.length; i++) {
      final p = Offset(xFor(i), yFor(points[i].score));
      if (i == 0) {
        linePath.moveTo(p.dx, p.dy);
        areaPath.moveTo(p.dx, size.height - bottomPad);
        areaPath.lineTo(p.dx, p.dy);
      } else {
        linePath.lineTo(p.dx, p.dy);
        areaPath.lineTo(p.dx, p.dy);
      }
    }
    areaPath.lineTo(xFor(points.length - 1), size.height - bottomPad);
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lavender.withOpacity(0.4),
            AppColors.lavender.withOpacity(0.02),
          ],
        ).createShader(Rect.fromLTWH(0, topPad, size.width, plotH)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.lavender
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots + x labels
    for (var i = 0; i < points.length; i++) {
      final p = Offset(xFor(i), yFor(points[i].score));
      canvas.drawCircle(p, 4, Paint()..color = AppColors.lavender);
      final tp = TextPainter(
        text: TextSpan(
            text: points[i].label,
            style: AppText.sans(size: 10, color: AppColors.muted2)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(p.dx - tp.width / 2, size.height - bottomPad + 6));
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0, gap = 4.0;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * (d + dash).clamp(0, total).toDouble();
      canvas.drawLine(start, end, paint);
      d += dash + gap;
    }
  }

  void _text(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _EnergyChartPainter old) =>
      old.points != points || old.thresholdLabel != thresholdLabel;
}
