import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

enum AuraSize { sm, md, lg }

/// The glowing energy orb whose color reflects the current Hawkins level.
class AuraCircle extends StatefulWidget {
  final int score;
  final AuraSize size;
  const AuraCircle({super.key, required this.score, this.size = AuraSize.lg});

  @override
  State<AuraCircle> createState() => _AuraCircleState();
}

class _AuraCircleState extends State<AuraCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _px => switch (widget.size) {
        AuraSize.sm => 100,
        AuraSize.md => 160,
        AuraSize.lg => 220,
      };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final level = getLevelForScore(widget.score);
    final isAbove = widget.score >= 200;
    final px = _px;
    final hasScore = widget.score > 0;

    final levelName = s.levelName(level.name);
    final levelDesc = s.levelDescription(level.name);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: px + 48,
          height: px + 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated outer glow rings
              AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final t = _c.value;
                  return SizedBox(
                    width: px + 48,
                    height: px + 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _glow(px + 48, level.auraGlow, 0.16, 0.6 + t * 0.4, 1 + t * 0.04),
                        _glow(px + 24, level.auraGlow, 0.25, 0.6 + (1 - t) * 0.4, 1 + (1 - t) * 0.04),
                      ],
                    ),
                  );
                },
              ),
              // Core orb
              Container(
                width: px - 14,
                height: px - 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.2, -0.3),
                    radius: 0.95,
                    colors: [
                      level.auraOuter,
                      level.auraInner,
                      level.auraInner.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: level.auraGlow.withOpacity(0.45),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: level.auraGlow.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: _orbText(s, level, levelName, px, hasScore),
              ),
            ],
          ),
        ),
        if (widget.size == AuraSize.lg && hasScore) ...[
          const SizedBox(height: 12),
          _ThresholdBadge(isAbove: isAbove, s: s),
          const SizedBox(height: 6),
          SizedBox(
            width: 240,
            child: Text(
              levelDesc,
              textAlign: TextAlign.center,
              style: AppText.sans(size: 13, color: AppColors.muted, height: 1.4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _glow(double size, Color color, double opacity, double fade, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity * fade), Colors.transparent],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }

  Widget _orbText(s, HawkinsLevel level, String levelName, double px, bool hasScore) {
    switch (widget.size) {
      case AuraSize.lg:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasScore ? '${widget.score}' : '—',
              style: AppText.serif(size: 42, weight: FontWeight.w600, color: Colors.white),
            ),
            Text(
              hasScore ? levelName : s.auraNoScore,
              style: AppText.sans(size: 13, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        );
      case AuraSize.md:
        if (!hasScore) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.score}',
                style: AppText.serif(size: 28, weight: FontWeight.w600, color: Colors.white)),
            Text(levelName,
                style: AppText.sans(size: 11, color: Colors.white.withOpacity(0.85))),
          ],
        );
      case AuraSize.sm:
        if (!hasScore) return const SizedBox.shrink();
        return Text('${widget.score}',
            style: AppText.serif(size: 18, weight: FontWeight.w600, color: Colors.white));
    }
  }
}

class _ThresholdBadge extends StatelessWidget {
  final bool isAbove;
  final dynamic s;
  const _ThresholdBadge({required this.isAbove, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isAbove
            ? AppColors.tealSoft.withOpacity(0.25)
            : AppColors.lavender2.withOpacity(0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAbove
              ? AppColors.tealSoft.withOpacity(0.5)
              : AppColors.lavender2.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isAbove ? '✦' : '◦',
              style: TextStyle(color: isAbove ? AppColors.aboveText : AppColors.belowText)),
          const SizedBox(width: 6),
          Text(
            isAbove ? s.auraAbove : s.auraBelow,
            style: AppText.sans(
                size: 13,
                color: isAbove ? AppColors.aboveText : AppColors.belowText),
          ),
        ],
      ),
    );
  }
}
