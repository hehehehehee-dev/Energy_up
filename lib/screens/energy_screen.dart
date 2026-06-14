import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/check_in.dart';
import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/energy_chart.dart';
import '../widgets/lang_toggle.dart';

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;
    final todayCheckIns = app.todayCheckIns;
    final allCheckIns = [...mockHistoryCheckIns, ...todayCheckIns];

    final weekScores = mockEnergyHistory.map((d) => d.score).toList();
    final weeklyAvg = (weekScores.reduce((a, b) => a + b) / weekScores.length).round();
    final weeklyAvgLevel = getLevelForScore(weeklyAvg);

    final avgCheckIns =
        (mockEnergyHistory.fold<int>(0, (a, d) => a + d.checkIns) / mockEnergyHistory.length)
            .toStringAsFixed(1);
    final avgLow =
        (mockEnergyHistory.fold<int>(0, (a, d) => a + d.low) / mockEnergyHistory.length).round();
    final avgHigh =
        (mockEnergyHistory.fold<int>(0, (a, d) => a + d.high) / mockEnergyHistory.length).round();

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

    // Chart data
    final todayDaily = getDailyEnergy(todayCheckIns);
    final points = <EnergyPoint>[];
    for (var i = 0; i < mockEnergyHistory.length; i++) {
      final d = mockEnergyHistory[i];
      final isLast = i == mockEnergyHistory.length - 1;
      points.add(EnergyPoint(
          d.date, isLast && todayCheckIns.isNotEmpty ? todayDaily : d.score));
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE6F4F0), AppColors.canvas],
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

            // Chart card
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
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
                      _StatCard(value: '$weeklyAvg', sub: s.levelName(weeklyAvgLevel.name), label: s.energyWeeklyAvg, color: AppColors.teal, bg: const Color(0xFFE6F4F0)),
                      _StatCard(value: '$avgCheckIns${s.energyPerDay}', sub: s.energyGentleConsistency, label: s.energyAvgCheckins, color: AppColors.lavender, bg: const Color(0xFFE8E4F4)),
                      _StatCard(value: '$avgLow–$avgHigh', sub: s.energyLowToHigh, label: s.energyDailyRange, color: AppColors.gold, bg: const Color(0xFFF5EFE0)),
                      _StatCard(value: mostCommonEmotion == null ? '—' : s.emotionLabel(mostCommonEmotion.key), sub: s.energyTimes(mostCommonEmotion?.value ?? 0), label: s.energyCommonEmotion, color: AppColors.pink, bg: const Color(0xFFFEF0F5)),
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
                  color: Colors.white.withOpacity(0.8),
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
                                TextSpan(
                                    text: '  ${c.emotionEmoji} ${s.emotionLabel(c.emotion)}',
                                    style: AppText.sans(size: 12, color: AppColors.muted)),
                              ])),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAbove ? const Color(0xFFE6F4F0) : const Color(0xFFF0EDF8),
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
        color: Colors.white.withOpacity(0.75),
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
