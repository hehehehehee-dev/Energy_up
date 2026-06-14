import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  static const _bgs = [
    [Color(0xFFE8E4F4), Color(0xFFF5EFE0), Color(0xFFFEF0F5)],
    [Color(0xFFFEF0F5), Color(0xFFE8E4F4)],
    [Color(0xFFE6F4F0), Color(0xFFE8E4F4)],
  ];

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.read<AppState>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _bgs[_step],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _step;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.lavender
                        : AppColors.lavender.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Center(
                    child: switch (_step) {
                      0 => _WelcomeSlide(s: s),
                      1 => _DisclaimerSlide(s: s),
                      _ => _ScaleSlide(s: s),
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
              child: GradientButton(
                colors: const [AppColors.lavender, AppColors.lavenderLight],
                shadow: [
                  BoxShadow(
                      color: AppColors.lavender.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8)),
                ],
                onTap: _next,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_step < 2 ? s.onbContinue : s.onbBegin,
                        style: AppText.sans(
                            size: 16, weight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  final dynamic s;
  const _WelcomeSlide({required this.s});

  @override
  Widget build(BuildContext context) {
    final steps = [
      [s.onbCheckin, '🌿', const Color(0xFFE8E4F4)],
      [s.onbReflect, '📖', const Color(0xFFFEF0F5)],
      [s.onbGrow, '✨', const Color(0xFFE6F4F0)],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFC4B8E8), Color(0xFFE8BFCC)],
            ),
            boxShadow: [
              BoxShadow(color: AppColors.lavender2.withOpacity(0.2), spreadRadius: 8),
              BoxShadow(color: AppColors.lavender2.withOpacity(0.1), spreadRadius: 16),
            ],
          ),
          child: const Center(child: Text('🕊', style: TextStyle(fontSize: 40))),
        ),
        const SizedBox(height: 24),
        Text('Angel', style: AppText.serif(size: 38, color: AppColors.text, height: 1.2)),
        const SizedBox(height: 4),
        Text(s.onbTagline,
            textAlign: TextAlign.center,
            style: AppText.serif(
                size: 16, color: AppColors.lavender, style: FontStyle.italic)),
        const SizedBox(height: 24),
        Text(s.onbIntro,
            textAlign: TextAlign.center,
            style: AppText.sans(size: 16, color: AppColors.muted, height: 1.7)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: steps.map((step) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: step[2] as Color, shape: BoxShape.circle),
                    child: Center(
                        child: Text(step[1] as String,
                            style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(height: 4),
                  Text(step[0] as String,
                      style: AppText.sans(size: 12, color: AppColors.muted)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DisclaimerSlide extends StatelessWidget {
  final dynamic s;
  const _DisclaimerSlide({required this.s});

  @override
  Widget build(BuildContext context) {
    final items = [
      ['🌱', s.onbD1],
      ['🩺', s.onbD2],
      ['💫', s.onbD3],
      ['🕊', s.onbD4],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.pinkLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.pinkLight.withOpacity(0.4), width: 1.5),
          ),
          child: const Icon(Icons.favorite_border, color: AppColors.pink, size: 28),
        ),
        const SizedBox(height: 24),
        Text(s.onbDisclaimerBadge.toString().toUpperCase(),
            style: AppText.sans(
                size: 11, color: AppColors.pink, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(s.onbDisclaimerTitle,
            textAlign: TextAlign.center,
            style: AppText.serif(size: 24, color: AppColors.text, height: 1.3)),
        const SizedBox(height: 24),
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item[0], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item[1],
                        style: AppText.sans(
                            size: 14, color: AppColors.textSoft, height: 1.6)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ScaleSlide extends StatelessWidget {
  final dynamic s;
  const _ScaleSlide({required this.s});

  @override
  Widget build(BuildContext context) {
    final levels = [
      ['700–1000', s.onbScaleEnlightenment, const Color(0xFFE8D080), '✨'],
      ['500–700', s.onbScaleLove, const Color(0xFFD070C0), '💗'],
      ['200–500', s.onbScaleCourage, const Color(0xFF80B880), '🌱'],
      ['< 200', s.onbScaleBelow, const Color(0xFF9878B8), '🌫'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.onbScaleBadge.toString().toUpperCase(),
            style: AppText.sans(
                size: 11, color: const Color(0xFF70A898), letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(s.onbScaleTitle,
            textAlign: TextAlign.center,
            style: AppText.serif(size: 26, color: AppColors.text, height: 1.3)),
        const SizedBox(height: 6),
        Text(s.onbScaleSub,
            textAlign: TextAlign.center,
            style: AppText.sans(size: 14, color: AppColors.muted, height: 1.6)),
        const SizedBox(height: 20),
        ...levels.map((l) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (l[2] as Color).withOpacity(0.19),
                      shape: BoxShape.circle,
                      border: Border.all(color: (l[2] as Color).withOpacity(0.38), width: 1.5),
                    ),
                    child: Center(
                        child: Text(l[3] as String, style: const TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(width: 12),
                  Text(l[1] as String,
                      style: AppText.sans(size: 13, weight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(l[0] as String,
                      style: AppText.sans(size: 12, color: AppColors.muted)),
                ],
              ),
            )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.tealSoft.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.tealSoft.withOpacity(0.4), width: 1.5),
          ),
          child: Text(s.onbScaleNote,
              style: AppText.sans(
                  size: 13, color: const Color(0xFF3A7A6A), height: 1.7)),
        ),
      ],
    );
  }
}
