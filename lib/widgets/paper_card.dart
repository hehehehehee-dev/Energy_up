import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A warm, tactile "paper" card — solid cream surface, hairline warm border and
/// a soft warm shadow. Replaces the cold translucent-white glassmorphism so the
/// app feels like a physical journal rather than a generated mockup.
class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  /// Small rotation (radians) for a hand-placed, sticker-like feel.
  final double tilt;

  /// Optional accent that tints the surface and border very slightly.
  final Color? accent;

  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 22,
    this.tilt = 0,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = accent;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: a == null ? const Color(0xFFFFFBF4) : Color.alphaBlend(a.withOpacity(0.06), const Color(0xFFFFFBF4)),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: (a ?? AppColors.gold).withOpacity(0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A5A20).withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF7A5A20).withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );

    final tilted = tilt == 0 ? card : Transform.rotate(angle: tilt, child: card);
    return margin == null ? tilted : Padding(padding: margin!, child: tilted);
  }
}
