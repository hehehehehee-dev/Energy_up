import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/gradient_button.dart';
import '../widgets/paper_background.dart';
import '../widgets/paper_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  static const _tints = [
    Color(0xFFF4E6D2),
    Color(0xFFFBE8DB),
    Color(0xFFEAEFD8),
  ];
  static const _blobs = [
    AppColors.tealSoft,
    AppColors.pinkLight,
    AppColors.goldLight,
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

    return Scaffold(
      body: PaperBackground(
      tint: _tints[_step],
      blob: _blobs[_step],
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            // Editorial step counter
            Text(
              '0${_step + 1} — 03',
              style: AppText.sans(
                  size: 12, weight: FontWeight.w700, color: AppColors.muted, letterSpacing: 3),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _step;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.lavender
                        : AppColors.lavender.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.58,
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
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
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
                            size: 16, weight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

/// A round icon "medallion" used in place of emoji.
class _Medallion extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _Medallion({required this.icon, required this.color, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4), width: 1.4),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  final dynamic s;
  const _WelcomeSlide({required this.s});

  @override
  Widget build(BuildContext context) {
    final steps = [
      [s.onbCheckin, Icons.spa_rounded, AppColors.teal],
      [s.onbReflect, Icons.menu_book_rounded, AppColors.pink],
      [s.onbGrow, Icons.auto_awesome_rounded, AppColors.gold],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandLogo(height: 230),
        const SizedBox(height: 10),
        Text(s.onbTagline,
            textAlign: TextAlign.center,
            style: AppText.serif(
                size: 17, color: AppColors.lavender, style: FontStyle.italic)),
        const SizedBox(height: 22),
        Text(s.onbIntro,
            textAlign: TextAlign.center,
            style: AppText.sans(size: 15.5, color: AppColors.textSoft, height: 1.7)),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: steps.map((step) {
            return Column(
              children: [
                _Medallion(icon: step[1] as IconData, color: step[2] as Color),
                const SizedBox(height: 8),
                Text(step[0] as String,
                    style: AppText.sans(
                        size: 12.5, weight: FontWeight.w600, color: AppColors.textSoft)),
              ],
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
      [Icons.eco_rounded, s.onbD1, AppColors.teal],
      [Icons.medical_services_rounded, s.onbD2, AppColors.pink],
      [Icons.auto_awesome_rounded, s.onbD3, AppColors.gold],
      [Icons.air_rounded, s.onbD4, AppColors.lavender],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Medallion(icon: Icons.favorite_rounded, color: AppColors.pink, size: 58),
        const SizedBox(height: 18),
        Text(s.onbDisclaimerBadge.toString().toUpperCase(),
            style: AppText.sans(
                size: 11, weight: FontWeight.w700, color: AppColors.pink, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(s.onbDisclaimerTitle,
            style: AppText.serif(size: 27, color: AppColors.text, height: 1.25)),
        const SizedBox(height: 22),
        ...items.map((item) => PaperCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              radius: 18,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item[0] as IconData, color: item[2] as Color, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(item[1] as String,
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
      ['700–1000', s.onbScaleEnlightenment, const Color(0xFFCBA23C), Icons.auto_awesome_rounded],
      ['500–700', s.onbScaleLove, AppColors.pink, Icons.favorite_rounded],
      ['200–500', s.onbScaleCourage, AppColors.teal, Icons.eco_rounded],
      ['< 200', s.onbScaleBelow, const Color(0xFFB08A66), Icons.blur_on_rounded],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.onbScaleBadge.toString().toUpperCase(),
            style: AppText.sans(
                size: 11, weight: FontWeight.w700, color: AppColors.teal, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(s.onbScaleTitle,
            style: AppText.serif(size: 28, color: AppColors.text, height: 1.2)),
        const SizedBox(height: 8),
        Text(s.onbScaleSub,
            style: AppText.sans(size: 14, color: AppColors.muted, height: 1.6)),
        const SizedBox(height: 20),
        ...levels.map((l) => PaperCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              radius: 18,
              accent: l[2] as Color,
              child: Row(
                children: [
                  _Medallion(icon: l[3] as IconData, color: l[2] as Color, size: 42),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l[1] as String,
                        style: AppText.sans(size: 13.5, weight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Text(l[0] as String,
                      style: AppText.sans(size: 12, weight: FontWeight.w600, color: AppColors.muted)),
                ],
              ),
            )),
        const SizedBox(height: 6),
        PaperCard(
          padding: const EdgeInsets.all(16),
          radius: 18,
          accent: AppColors.teal,
          child: Text(s.onbScaleNote,
              style: AppText.sans(
                  size: 13, color: AppColors.textSoft, height: 1.7)),
        ),
      ],
    );
  }
}
