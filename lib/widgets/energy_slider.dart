import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Slider from 20–1000 that snaps to the defined Hawkins levels, with a
/// gradient progress track.
class EnergySlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const EnergySlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final level = getLevelForScore(value);
    final percent = ((value - 20) / (1000 - 20)).clamp(0.0, 1.0);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Track background
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCCDB8).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Gradient fill
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 8,
                      width: w * percent,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [AppColors.lavender, level.auraOuter]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 18),
                      thumbShape: const _WhiteThumb(),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      min: 20,
                      max: 1000,
                      value: value.toDouble(),
                      onChanged: (v) => onChanged(snapToScale(v.round())),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('20', style: AppText.sans(size: 11, color: AppColors.muted2)),
            Text(s.energyThreshold,
                style: AppText.sans(
                    size: 11, weight: FontWeight.w600, color: AppColors.lavender)),
            Text('1000', style: AppText.sans(size: 11, color: AppColors.muted2)),
          ],
        ),
      ],
    );
  }
}

class _WhiteThumb extends SliderComponentShape {
  const _WhiteThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(22, 22);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 11,
        Paint()..color = AppColors.lavender.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(center, 11, Paint()..color = Colors.white);
    canvas.drawCircle(
        center,
        11,
        Paint()
          ..color = AppColors.lavender
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }
}
