import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final tabs = [
      _Tab(s.navToday, Icons.wb_sunny_outlined, AppColors.lavender, const Color(0xFFF4E6D2)),
      _Tab(s.navJournal, Icons.menu_book_outlined, AppColors.pink, const Color(0xFFFBE8DB)),
      _Tab(s.navEnergy, Icons.trending_up, AppColors.teal, const Color(0xFFEAEFD8)),
      _Tab(s.navInsights, Icons.insert_chart_outlined, AppColors.gold, const Color(0xFFF5EFE0)),
      _Tab(s.navJourney, Icons.map_outlined, AppColors.lavender2, const Color(0xFFF4E6D2)),
      _Tab(s.navProfile, Icons.person_outline, AppColors.lavender, const Color(0xFFF4E6D2)),
    ];

    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppColors.lavender.withOpacity(0.12)),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final isActive = activeIndex == i;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? tab.activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon,
                        size: 20,
                        color: isActive ? tab.activeColor : AppColors.muted2),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppText.sans(
                        size: 10.5,
                        weight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? tab.activeColor : AppColors.muted2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final Color activeColor;
  final Color activeBg;
  _Tab(this.label, this.icon, this.activeColor, this.activeBg);
}
