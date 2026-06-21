import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A warm screen background: a soft top-tint gradient, two organic "blob"
/// shapes and a faint paper grain. Wrap a screen's body in this instead of a
/// flat pastel gradient to add the hand-made, textured feel.
class PaperBackground extends StatelessWidget {
  final Widget child;

  /// Top tint colour that melts into the cream canvas.
  final Color tint;

  /// Secondary blob colour (defaults to a soft sage).
  final Color? blob;

  const PaperBackground({
    super.key,
    required this.child,
    this.tint = const Color(0xFFF4E6D2),
    this.blob,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tint, AppColors.canvas],
          stops: const [0, 0.5],
        ),
      ),
      child: CustomPaint(
        painter: _BlobGrainPainter(
          tint: tint,
          blob: blob ?? AppColors.tealSoft,
        ),
        child: child,
      ),
    );
  }
}

class _BlobGrainPainter extends CustomPainter {
  final Color tint;
  final Color blob;

  _BlobGrainPainter({required this.tint, required this.blob});

  @override
  void paint(Canvas canvas, Size size) {
    // Two soft organic blobs.
    final p1 = Paint()
      ..color = tint.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 120, p1);

    final p2 = Paint()
      ..color = blob.withOpacity(0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.5), 140, p2);

    // Faint paper grain — deterministic so it doesn't shimmer on rebuild.
    final rnd = math.Random(7);
    final grain = Paint();
    final count = (size.width * size.height / 1400).clamp(0, 1600).toInt();
    for (var i = 0; i < count; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final dark = rnd.nextBool();
      grain.color = (dark ? const Color(0xFF6B4E2A) : Colors.white)
          .withOpacity(dark ? 0.025 : 0.05);
      canvas.drawCircle(Offset(dx, dy), 0.6, grain);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobGrainPainter old) =>
      old.tint != tint || old.blob != blob;
}
