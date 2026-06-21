import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.dart';
import '../models/check_in.dart';
import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/energy_chart.dart';
import '../widgets/energy_funnel.dart';
import '../widgets/lang_toggle.dart';
import '../widgets/paper_background.dart';

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;
    final todayCheckIns = app.todayCheckIns;
    final allCheckIns = [...mockHistoryCheckIns, ...todayCheckIns];

    // Use actual check-ins for weekly stats, not mock history
    final allCheckInsForStats = [...mockHistoryCheckIns, ...todayCheckIns];
    final allScores = allCheckInsForStats.map((c) => c.score).toList();
    final weeklyAvg = allScores.isNotEmpty
        ? (allScores.reduce((a, b) => a + b) / allScores.length).round()
        : 0;
    final weeklyAvgLevel = getLevelForScore(weeklyAvg);

    final avgCheckIns = allScores.isNotEmpty
        ? (allCheckInsForStats.length / 7).toStringAsFixed(1)
        : '0.0';
    final avgLow = allScores.isNotEmpty ? allScores.reduce((a, b) => a < b ? a : b) : 0;
    final avgHigh = allScores.isNotEmpty ? allScores.reduce((a, b) => a > b ? a : b) : 0;

    final emotionCounts = <String, int>{};
    for (final c in allCheckIns) {
      emotionCounts[c.emotion] = (emotionCounts[c.emotion] ?? 0) + 1;
    }
    final mostCommonEmotion = _topEntry(emotionCounts);

    final timeGroups = <String, List<int>>{};
    for (final c in allCheckIns) {
      timeGroups.putIfAbsent(c.timeOfDay, () => []).add(c.score);
    }
    final timeAvgs = timeGroups.entries
        .map((e) => MapEntry(e.key, (e.value.reduce((a, b) => a + b) / e.value.length).round()))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final lowestTime = timeAvgs.isNotEmpty ? timeAvgs.first : null;

    final triggerCounts = <String, int>{};
    for (final c in allCheckIns) {
      for (final tr in c.triggers) {
        triggerCounts[tr] = (triggerCounts[tr] ?? 0) + 1;
      }
    }
    final mostCommonTrigger = _topEntry(triggerCounts);

    final currentScore = todayCheckIns.isNotEmpty ? todayCheckIns.last.score : null;
    final todayAvgScore = todayCheckIns.isNotEmpty ? getDailyEnergy(todayCheckIns) : null;

    // Chart data — build from actual check-in history, grouped by day
    final points = <EnergyPoint>[];
    if (allCheckInsForStats.isNotEmpty) {
      final checkInsByDate = <String, List<CheckIn>>{};
      for (final c in allCheckInsForStats) {
        checkInsByDate.putIfAbsent(c.date, () => []).add(c);
      }
      for (final date in checkInsByDate.keys.toList()..sort()) {
        final dailyScore = getDailyEnergy(checkInsByDate[date]!);
        points.add(EnergyPoint(date, dailyScore));
      }
    }

    return PaperBackground(
      tint: const Color(0xFFEAEFD8),
      blob: AppColors.tealSoft,
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
                        Text(s.energyLabel.toUpperCase(),
                            style: AppText.sans(size: 11, color: AppColors.teal, letterSpacing: 1.2)),
                        Text(s.energyTitle, style: AppText.serif(size: 26, color: AppColors.text)),
                        Text(s.energySub, style: AppText.sans(size: 14, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const LangToggle(),
                ],
              ),
            ),

            // Chart card — only show if there's data
            if (points.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.paper.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.energyChartTitle, style: AppText.sans(size: 12, color: AppColors.muted)),
                    Text(s.energyChartSub, style: AppText.sans(size: 11, color: AppColors.muted3)),
                    const SizedBox(height: 12),
                    EnergyChart(points: points, thresholdLabel: s.energyThreshold),
                  ],
                ),
              ),

            // Map of Consciousness funnel
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              decoration: BoxDecoration(
                color: AppColors.paper.withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.lang == Lang.vi ? 'Bản đồ Ý thức' : 'Map of Consciousness',
                      style: AppText.serif(size: 21, weight: FontWeight.w600, color: AppColors.text)),
                  Text(
                      s.lang == Lang.vi
                          ? 'Thang năng lượng rung động 20–1000'
                          : 'The vibrational scale of consciousness · 20–1000',
                      style: AppText.sans(size: 13.5, color: AppColors.muted)),
                  const SizedBox(height: 16),
                  EnergyFunnel(s: s, currentScore: currentScore, avgScore: todayAvgScore),
                ],
              ),
            ),

            // Stats grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.energyWeeklyInsights, style: AppText.sans(size: 13, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      _StatCard(value: '$weeklyAvg', sub: s.levelName(weeklyAvgLevel.name), label: s.energyWeeklyAvg, color: AppColors.teal, bg: const Color(0xFFEAEFD8)),
                      _StatCard(value: '$avgCheckIns${s.energyPerDay}', sub: s.energyGentleConsistency, label: s.energyAvgCheckins, color: AppColors.lavender, bg: const Color(0xFFF4E6D2)),
                      _StatCard(value: '$avgLow–$avgHigh', sub: s.energyLowToHigh, label: s.energyDailyRange, color: AppColors.gold, bg: const Color(0xFFF5EFE0)),
                      _StatCard(value: mostCommonEmotion == null ? '—' : s.emotionLabel(mostCommonEmotion.key), sub: s.energyTimes(mostCommonEmotion?.value ?? 0), label: s.energyCommonEmotion, color: AppColors.pink, bg: const Color(0xFFFBE8DB)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Secondary insights
            if (lowestTime != null)
              _InsightRow(
                icon: '🌙',
                label: s.energyTenderTime,
                value: '${s.tod(lowestTime.key)} · avg ${lowestTime.value}',
                sub: s.energyTenderSub,
                color: AppColors.lavender,
              ),
            if (mostCommonTrigger != null)
              _InsightRow(
                icon: '🌿',
                label: s.energyMainFactor,
                value: s.triggerLabel(mostCommonTrigger.key),
                sub: s.energyAppearedIn(mostCommonTrigger.value),
                color: AppColors.teal,
              ),

            // Today's check-ins
            if (todayCheckIns.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.paper.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.energyTodayCheckins, style: AppText.sans(size: 12, color: AppColors.muted)),
                    const SizedBox(height: 10),
                    ...todayCheckIns.map((c) {
                      final lv = getLevelForScore(c.score);
                      final isAbove = c.score >= 200;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  lv.auraOuter.withOpacity(0.4),
                                  lv.auraInner.withOpacity(0.4),
                                ]),
                              ),
                              child: Center(
                                child: Text('${c.score}',
                                    style: AppText.sans(
                                        size: 10, weight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: s.tod(c.timeOfDay),
                                    style: AppText.sans(size: 13, weight: FontWeight.w600)),
                                WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6, right: 4),
                                      child: Icon(AppIcons.emotion(c.emotion),
                                          size: 13, color: AppColors.muted),
                                    )),
                                TextSpan(
                                    text: s.emotionLabel(c.emotion),
                                    style: AppText.sans(size: 12, color: AppColors.muted)),
                              ])),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAbove ? const Color(0xFFEAEFD8) : const Color(0xFFF7ECDB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(s.levelName(lv.name),
                                  style: AppText.sans(
                                      size: 11,
                                      weight: FontWeight.w600,
                                      color: isAbove ? AppColors.aboveText : AppColors.belowText)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lavender2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lavender2.withOpacity(0.2)),
              ),
              child: Text(s.energyDisclaimer,
                  textAlign: TextAlign.center,
                  style: AppText.sans(size: 12, color: AppColors.muted, height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }

  static MapEntry<String, int>? _topEntry(Map<String, int> map) {
    if (map.isEmpty) return null;
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.first;
  }
}

class _StatCard extends StatelessWidget {
  final String value, sub, label;
  final Color color, bg;
  const _StatCard(
      {required this.value,
      required this.sub,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.125)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.serif(size: 20, weight: FontWeight.w600, height: 1.2)),
          const SizedBox(height: 2),
          Text(sub, style: AppText.sans(size: 11, weight: FontWeight.w600, color: color)),
          Text(label, style: AppText.sans(size: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String icon, label, value, sub;
  final Color color;
  const _InsightRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.sans(size: 12, color: AppColors.muted)),
                Text(value, style: AppText.sans(size: 14, weight: FontWeight.w600)),
                Text(sub,
                    style: AppText.sans(size: 11, color: color, style: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
