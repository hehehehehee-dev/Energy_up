import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "EnergyUp" brand logo. Renders the exact PNG at [assets/logo.png];
/// if the asset is missing it falls back to a simple drawn mark so the app
/// never shows a broken image.
class BrandLogo extends StatelessWidget {
  /// Target height of the logo lockup.
  final double height;

  const BrandLogo({super.key, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _FallbackMark(height: height),
    );
  }
}

class _FallbackMark extends StatelessWidget {
  final double height;
  const _FallbackMark({required this.height});

  @override
  Widget build(BuildContext context) {
    final d = height * 0.6;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: d,
          height: d,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF6BCF46), Color(0xFF2E6EC8)],
            ),
          ),
          child: const Center(
            child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text('EnergyUp',
            style: AppText.sans(
                size: height * 0.16, weight: FontWeight.w700, color: AppColors.text)),
      ],
    );
  }
}
