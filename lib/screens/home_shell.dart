import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'check_in_flow.dart';
import 'close_the_day.dart';
import 'energy_screen.dart';
import 'insights_screen.dart';
import 'journal_screen.dart';
import 'journey_screen.dart';
import 'profile_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _transitionController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..value = 1;
    final curved = CurvedAnimation(parent: _transitionController, curve: Curves.easeOut);
    _fade = curved;
    _slide = Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(curved);
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _goToTab(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _transitionController.forward(from: 0);
  }

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
        onOpenProfile: () => _goToTab(5),
      ),
      const JournalScreen(),
      const EnergyScreen(),
      const InsightsScreen(),
      const JourneyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: IndexedStack(index: _index, children: screens),
        ),
      ),
      bottomNavigationBar: BottomNav(
        activeIndex: _index,
        onTap: _goToTab,
      ),
    );
  }
}
