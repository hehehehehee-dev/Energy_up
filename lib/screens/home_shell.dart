import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'check_in_flow.dart';
import 'close_the_day.dart';
import 'energy_screen.dart';
import 'journal_screen.dart';
import 'journey_screen.dart';
import 'profile_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _startCheckIn() {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const CheckInFlow(),
    ));
  }

  void _closeTheDay() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const CloseTheDayScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        onStartCheckIn: _startCheckIn,
        onCloseTheDay: _closeTheDay,
        onOpenProfile: () => setState(() => _index = 4),
      ),
      const JournalScreen(),
      const EnergyScreen(),
      const JourneyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNav(
        activeIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
