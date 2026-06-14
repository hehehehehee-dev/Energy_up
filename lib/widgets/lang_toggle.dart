import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Small EN / VI pill toggle.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lavender.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: Lang.values.map((l) {
          final isActive = app.lang == l;
          return GestureDetector(
            onTap: () => context.read<AppState>().setLang(l),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.lavender, AppColors.lavenderLight])
                    : null,
              ),
              child: Text(
                l == Lang.en ? 'EN' : 'VI',
                style: AppText.sans(
                  size: 12,
                  weight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
