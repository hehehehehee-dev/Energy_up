import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../models/hawkins.dart';
import '../models/suggestions.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';

/// The full "Map of Consciousness" energy funnel — a vertical tube running
/// from Alpha (suffering, red) at the bottom to Omega (supreme wisdom, violet)
/// at the top, with all 18 Hawkins levels labelled down the left side.
class EnergyFunnel extends StatelessWidget {
  final Strings s;

  /// The user's most recent check-in score today. Bolds the matching level on
  /// the left and draws a dashed marker line across the cone. Optional.
  final int? currentScore;

  /// The user's average score for today. Draws a second, solid marker line
  /// across the cone so it reads distinctly from [currentScore]. Optional.
  final int? avgScore;

  const EnergyFunnel({super.key, required this.s, this.currentScore, this.avgScore});

  bool get _vi => s.lang == Lang.vi;

  // Zone labels painted inside the tube, top -> bottom, with their vertical
  // placement as a fraction of the tube height.
  List<_Zone> get _zones => [
        _Zone(_vi ? 'Trí tuệ tối cao' : 'Supreme Wisdom', 0.06),
        _Zone(_vi ? 'Thanh khiết' : 'Purity', 0.21),
        _Zone(_vi ? 'Sảng khoái' : 'Bliss', 0.37),
        _Zone(_vi ? 'Tạm ổn' : 'Neutral', 0.60),
        _Zone(_vi ? 'Đau khổ' : 'Suffering', 0.80),
      ];

  @override
  Widget build(BuildContext context) {
    // Highest level first so the top of the column matches the top of the tube.
    final levels = hawkinsLevels.reversed.toList();
    final highlightLevel =
        currentScore == null ? null : getLevelForScore(currentScore!);

    const tubeHeight = 560.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Omega cap
        Center(
          child: Text(
            'Omega',
            style: AppText.serif(
                size: 17, weight: FontWeight.w700, color: const Color(0xFF7A3FA0)),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: tubeHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: level labels
              SizedBox(
                width: 124,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: levels.map((l) {
                    final on = highlightLevel?.score == l.score;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showSuggestion(context, l),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              s.levelName(l.name),
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              style: AppText.sans(
                                size: 13,
                                height: 1.1,
                                weight: on ? FontWeight.w800 : FontWeight.w600,
                                color: on ? AppColors.text : AppColors.textSoft,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: l.auraInner.withOpacity(on ? 0.95 : 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${l.score}',
                              style: AppText.sans(
                                size: 11.5,
                                weight: FontWeight.w700,
                                color: on ? Colors.white : l.auraInner,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 6),
              // Center: the tube + zone labels
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _TubePainter()),
                    ),
                    for (final z in _zones)
                      Align(
                        alignment: Alignment(-0.22, z.frac * 2 - 1),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // White outline so the label stays legible against every
                            // hue in the tube, regardless of how light the gradient is.
                            Text(
                              z.label,
                              textAlign: TextAlign.center,
                              style: AppText.serif(
                                size: z.frac < 0.5 ? 18 : 16,
                                weight: FontWeight.w700,
                              ).copyWith(
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3.4
                                  ..color = Colors.white,
                              ),
                            ),
                            Text(
                              z.label,
                              textAlign: TextAlign.center,
                              style: AppText.serif(
                                size: z.frac < 0.5 ? 18 : 16,
                                weight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (avgScore != null)
                      ..._markerWidgets(
                        top: _fracForScore(avgScore!) * tubeHeight,
                        color: AppColors.text,
                        label: _vi ? 'TB cả ngày' : 'Day avg',
                        dashed: false,
                        chipAbove: false,
                      ),
                    if (currentScore != null)
                      ..._markerWidgets(
                        top: _fracForScore(currentScore!) * tubeHeight,
                        color: AppColors.pink,
                        label: _vi ? 'Hiện tại' : 'Current',
                        dashed: true,
                        chipAbove: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Right: rising / declining
              SizedBox(
                width: 46,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Direction(
                      icon: Icons.arrow_upward_rounded,
                      label: _vi ? 'Tăng' : 'Up',
                      color: AppColors.teal,
                    ),
                    _Direction(
                      icon: Icons.arrow_downward_rounded,
                      label: _vi ? 'Giảm' : 'Down',
                      color: AppColors.pink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Alpha cap
        Center(
          child: Text(
            'Alpha',
            style: AppText.serif(
                size: 17, weight: FontWeight.w700, color: const Color(0xFFC23B2C)),
          ),
        ),
        const SizedBox(height: 12),
        // Marker legend
        if (currentScore != null || avgScore != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentScore != null)
                  _LegendSwatch(
                      dashed: true,
                      color: AppColors.pink,
                      label: _vi ? 'Hiện tại' : 'Current'),
                if (currentScore != null && avgScore != null) const SizedBox(width: 16),
                if (avgScore != null)
                  _LegendSwatch(
                      dashed: false,
                      color: AppColors.text,
                      label: _vi ? 'TB cả ngày' : 'Day avg'),
              ],
            ),
          ),
        // Tap hint
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app_rounded, size: 16, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              _vi ? 'Chạm vào một mức để xem gợi ý' : 'Tap a level for a suggestion',
              style: AppText.sans(
                  size: 13.5, weight: FontWeight.w500, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }

  void _showSuggestion(BuildContext context, HawkinsLevel l) {
    final isAbove = l.score >= 200;
    final accent = l.auraInner;
    final label = isAbove
        ? (_vi ? 'GỢI Ý DUY TRÌ & PHÁT TRIỂN' : 'TO SUSTAIN & GROW')
        : (_vi ? 'GỢI Ý ĐỂ NÂNG LÊN' : 'TO GENTLY RISE');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF4),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: accent.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF7A5A20).withOpacity(0.14),
                blurRadius: 24,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.muted3,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(0.4), width: 1.4),
                  ),
                  child: Icon(AppIcons.level(l.name), color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.levelName(l.name),
                          style: AppText.serif(size: 22, color: AppColors.text)),
                      Text(
                        '${l.score} · ${isAbove ? (_vi ? 'Trên ngưỡng 200' : 'Above 200') : (_vi ? 'Dưới ngưỡng 200' : 'Below 200')}',
                        style: AppText.sans(size: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(s.levelDescription(l.name),
                style: AppText.sans(
                    size: 14, color: AppColors.textSoft, height: 1.6, style: FontStyle.italic)),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(isAbove ? Icons.spa_rounded : Icons.trending_up_rounded,
                    size: 15, color: accent),
                const SizedBox(width: 6),
                Text(label,
                    style: AppText.sans(
                        size: 11,
                        weight: FontWeight.w700,
                        color: accent,
                        letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 8),
            Text(suggestionFor(l.name, s.lang),
                style: AppText.sans(size: 15, color: AppColors.text, height: 1.7)),
          ],
        ),
      ),
    );
  }
}

/// Maps an arbitrary score to a vertical fraction (0 = top/Omega, 1 =
/// bottom/Alpha) consistent with how the level labels are evenly spaced down
/// the left column, interpolating between the two nearest defined levels.
double _fracForScore(int score) {
  final levels = hawkinsLevels; // ascending by score
  final n = levels.length;
  if (score <= levels.first.score) return 1.0;
  if (score >= levels.last.score) return 0.0;
  for (var i = 0; i < n - 1; i++) {
    final lo = levels[i];
    final hi = levels[i + 1];
    if (score >= lo.score && score <= hi.score) {
      final t = (score - lo.score) / (hi.score - lo.score);
      final idx = i + t;
      return 1 - idx / (n - 1);
    }
  }
  return 0.5;
}

class _Zone {
  final String label;
  final double frac;
  const _Zone(this.label, this.frac);
}

/// Builds the two pieces of a marker — a full-width line with a white halo
/// (so it stays visible against every color in the tube's rainbow gradient)
/// and a dark, always-readable label chip offset above or below the line so
/// two markers at the same score don't collide.
List<Widget> _markerWidgets({
  required double top,
  required Color color,
  required String label,
  required bool dashed,
  required bool chipAbove,
}) {
  return [
    Positioned(
      top: top - 2,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 4,
        child: CustomPaint(
          size: Size.infinite,
          painter: _MarkerLinePainter(color, dashed: dashed),
        ),
      ),
    ),
    Positioned(
      top: top + (chipAbove ? -24 : 8),
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xE6232323),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(label, style: AppText.sans(size: 10, weight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    ),
  ];
}

/// Draws a marker line with a white halo behind the colored stroke so it
/// reads clearly against every hue in the tube's rainbow gradient.
class _MarkerLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _MarkerLinePainter(this.color, {required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final halo = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    final core = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), halo);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), core);
      return;
    }
    const dash = 6.0, gap = 4.0;
    for (final paint in [halo, core]) {
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset((x + dash).clamp(0, size.width), y), paint);
        x += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}

/// Small legend swatch shown beneath the cone explaining a marker line —
/// drawn as plain colored shapes (no halo) so it reads correctly at tiny size.
class _LegendSwatch extends StatelessWidget {
  final bool dashed;
  final Color color;
  final String label;
  const _LegendSwatch({required this.dashed, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dashed)
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Container(width: 4, height: 2, color: color),
              ),
            ),
          )
        else
          Container(width: 18, height: 2, color: color),
        const SizedBox(width: 6),
        Text(label, style: AppText.sans(size: 11.5, weight: FontWeight.w500, color: AppColors.muted)),
      ],
    );
  }
}

class _Direction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Direction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.sans(size: 11, weight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

/// Paints a vertical, rainbow-gradient tube — constant width with rounded
/// caps top (Omega) and bottom (Alpha), like a thermometer for energy.
class _TubePainter extends CustomPainter {
  // Top (Omega) -> bottom (Alpha).
  static const _stops = [0.0, 0.14, 0.28, 0.42, 0.56, 0.68, 0.80, 0.90, 1.0];
  static const _colors = [
    Color(0xFF5E2A84), // violet
    Color(0xFF3B3F9E), // indigo
    Color(0xFF2E6FC9), // blue
    Color(0xFF2BA7B5), // teal
    Color(0xFF5FBE52), // green
    Color(0xFFAEC83C), // yellow-green
    Color(0xFFF2D43B), // yellow
    Color(0xFFEE8B33), // orange
    Color(0xFFE23B2C), // red
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final inset = w * 0.08;
    final tubeWidth = w - inset * 2;
    final capRadius = tubeWidth / 2;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(inset, 0, tubeWidth, h),
        Radius.circular(capRadius),
      ));

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _colors,
        stops: _stops,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fill);

    // Soft inner shading on the right edge for a 3-D tube feel.
    final shade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.white.withOpacity(0.12), Colors.black.withOpacity(0.14)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), shade);
    canvas.restore();

    // Glass-tube rim outline.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withOpacity(0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(inset, 0, tubeWidth, h), Radius.circular(capRadius)),
      rim,
    );
  }

  @override
  bool shouldRepaint(covariant _TubePainter oldDelegate) => false;
}
