import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/check_in.dart';
import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/lang_toggle.dart';

class _Day {
  final int day;
  final int score;
  final bool isToday;
  const _Day(this.day, this.score, this.isToday);
}

/// 21-day grid — seeded demo data so the visualization stays stable.
final List<_Day> _journeyDays = _buildDays();

List<_Day> _buildDays() {
  final rnd = Random(7);
  return List.generate(21, (i) {
    if (i == 20) return const _Day(21, 0, true); // today
    int score;
    if (i >= 14) {
      score = mockEnergyHistory[i - 14].score; // last week of history
    } else {
      score = rnd.nextInt(500) + 80;
    }
    return _Day(i + 1, score, false);
  });
}

final int _completedDays =
    _journeyDays.where((d) => d.score > 0 && !d.isToday).length;
const int _streak = 7;

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final progress = _completedDays / 21;

    final milestones = [
      [7, s.journeyFirstWeek, '🌱'],
      [14, s.journeyTwoWeeks, '🌿'],
      [21, s.journeyTwentyOne, '✨'],
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5EFE0), AppColors.canvas],
          stops: [0, 0.45],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.journeyLabel.toUpperCase(),
                            style: AppText.sans(size: 11, color: AppColors.gold, letterSpacing: 1.2)),
                        Text(s.journeyTitle, style: AppText.serif(size: 26, color: AppColors.text)),
                        Text(s.journeySub,
                            style: AppText.sans(size: 14, color: AppColors.muted, height: 1.6)),
                      ],
                    ),
                  ),
                  const LangToggle(),
                ],
              ),
            ),

            // Streak + progress cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _statTile(
                      icon: Icons.local_fire_department,
                      gradient: const [Color(0xFFF5C4A0), Color(0xFFE0A870)],
                      value: '$_streak',
                      label: s.journeyDayStreak,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statTile(
                      icon: Icons.star,
                      gradient: const [AppColors.lavender2, AppColors.lavender],
                      value: '$_completedDays/21',
                      label: s.journeyCheckins,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.journeyProgress, style: AppText.sans(size: 12, color: AppColors.muted)),
                      Text('${(progress * 100).round()}%',
                          style: AppText.sans(size: 12, weight: FontWeight.w600, color: AppColors.gold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFC8C3DC).withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFE0A870)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 21-day grid
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.journeyYour21, style: AppText.sans(size: 13, color: AppColors.muted)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: _journeyDays.map((day) {
                      final level = day.score > 0 ? getLevelForScore(day.score) : null;
                      final isAbove = day.score >= 200;
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: day.score > 0
                              ? RadialGradient(colors: [
                                  level!.auraOuter.withOpacity(0.33),
                                  level.auraInner.withOpacity(0.33),
                                ])
                              : null,
                          color: day.score > 0
                              ? null
                              : const Color(0xFFC8C3DC).withOpacity(0.15),
                          border: Border.all(
                            color: day.isToday
                                ? AppColors.lavender
                                : day.score > 0
                                    ? level!.auraOuter.withOpacity(0.25)
                                    : const Color(0xFFC8C3DC).withOpacity(0.1),
                            width: day.isToday ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${day.day}',
                                style: AppText.sans(
                                    size: 10,
                                    weight: FontWeight.w600,
                                    color: day.score > 0 ? Colors.white : AppColors.muted3)),
                            if (day.score > 0)
                              Text('✦',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: isAbove
                                          ? const Color(0xFFA0DDD1)
                                          : const Color(0xFFF4C0D0))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _legend(const [Color(0xFFA8DDD1), AppColors.lavender], s.journeyCheckedIn, false),
                      const SizedBox(width: 16),
                      _legend(null, s.journeyMissed, false),
                      const SizedBox(width: 16),
                      _legend(null, s.journeyToday, true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Milestones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.journeyMilestones, style: AppText.sans(size: 13, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  ...milestones.map((m) {
                    final dayNum = m[0] as int;
                    final reached = _completedDays >= dayNum;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: reached
                            ? const Color(0xFFF5EFE0).withOpacity(0.8)
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: reached
                              ? const Color(0xFFE0CFA8).withOpacity(0.6)
                              : const Color(0xFFC8C3DC).withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: reached ? 1 : 0.3,
                            child: Text(m[2] as String, style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m[1] as String,
                                    style: AppText.sans(
                                        size: 14,
                                        weight: FontWeight.w600,
                                        color: reached ? AppColors.text : AppColors.muted2)),
                                Text('$dayNum ${s.journeyConsecutiveCheckins}',
                                    style: AppText.sans(size: 12, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: reached
                                  ? const Color(0xFFE0CFA8)
                                  : const Color(0xFFC8C3DC).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(reached ? s.journeyDone : 'Day $dayNum',
                                style: AppText.sans(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: reached ? const Color(0xFF7A5A20) : AppColors.muted2)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required List<Color> gradient,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppText.serif(size: 24, weight: FontWeight.w600)),
              Text(label, style: AppText.sans(size: 12, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(List<Color>? gradient, String label, bool todayBorder) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient != null ? LinearGradient(colors: gradient) : null,
            color: gradient == null ? const Color(0xFFC8C3DC).withOpacity(0.2) : null,
            border: todayBorder
                ? Border.all(color: AppColors.lavender, width: 2)
                : (gradient == null
                    ? Border.all(color: const Color(0xFFC8C3DC).withOpacity(0.4))
                    : null),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.sans(size: 11, color: AppColors.muted)),
      ],
    );
  }
}
