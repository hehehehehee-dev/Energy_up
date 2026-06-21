import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.dart';
import '../models/check_in.dart';
import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/lang_toggle.dart';
import '../widgets/paper_background.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _periodIndex = 0; // 0 = Week, 1 = Month

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;
    final vi = s.lang == Lang.vi;
    final allCheckIns = [...mockHistoryCheckIns, ...app.todayCheckIns];

    // Get check-ins for the selected period
    final now = DateTime.now();
    final List<CheckIn> periodCheckIns;
    String periodLabel;

    if (_periodIndex == 0) {
      // This week (last 7 days)
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      periodCheckIns = allCheckIns
          .where((c) => DateTime.parse('${c.date}T00:00').isAfter(sevenDaysAgo))
          .toList();
      periodLabel = vi ? 'Tuần này' : 'This week';
    } else {
      // This month (last 30 days)
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      periodCheckIns = allCheckIns
          .where((c) => DateTime.parse('${c.date}T00:00').isAfter(thirtyDaysAgo))
          .toList();
      periodLabel = vi ? 'Tháng này' : 'This month';
    }

    // Calculate metrics
    if (periodCheckIns.isEmpty) {
      return _buildEmptyState(context, s);
    }

    final scores = periodCheckIns.map((c) => c.score).toList();
    final avgScore = (scores.reduce((a, b) => a + b) / scores.length).round();
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final avgLevel = getLevelForScore(avgScore);

    // Emotion frequency
    final emotionCounts = <String, int>{};
    for (final c in periodCheckIns) {
      emotionCounts[c.emotion] = (emotionCounts[c.emotion] ?? 0) + 1;
    }
    final topEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Trigger frequency
    final triggerCounts = <String, int>{};
    for (final c in periodCheckIns) {
      for (final t in c.triggers) {
        triggerCounts[t] = (triggerCounts[t] ?? 0) + 1;
      }
    }
    final topTriggers = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Time of day breakdown
    final timeGroups = <String, List<int>>{};
    for (final c in periodCheckIns) {
      timeGroups.putIfAbsent(c.timeOfDay, () => []).add(c.score);
    }
    final timeAvgs = timeGroups.entries
        .map((e) => MapEntry(
            e.key, (e.value.reduce((a, b) => a + b) / e.value.length).round()))
        .toList()
      ..sort((a, b) {
        const order = ['Morning', 'Afternoon', 'Evening', 'Night'];
        return order.indexOf(a.key).compareTo(order.indexOf(b.key));
      });

    // Trend direction
    final firstHalf = periodCheckIns.take((periodCheckIns.length / 2).ceil()).toList();
    final secondHalf = periodCheckIns.skip((periodCheckIns.length / 2).toInt()).toList();
    final firstAvg = (firstHalf.fold<int>(0, (s, c) => s + c.score) / firstHalf.length).round();
    final secondAvg = (secondHalf.fold<int>(0, (s, c) => s + c.score) / secondHalf.length).round();
    final trend = secondAvg > firstAvg ? 'up' : secondAvg < firstAvg ? 'down' : 'stable';
    final trendLabel = vi
        ? (trend == 'up' ? '📈 Tăng' : trend == 'down' ? '📉 Giảm' : '➡️ Ổn định')
        : (trend == 'up' ? '📈 Rising' : trend == 'down' ? '📉 Declining' : '➡️ Stable');

    return PaperBackground(
      tint: const Color(0xFFF0E8DC),
      blob: AppColors.lavenderLight,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            vi
                                ? 'GHI NHẬN & BIỂU ĐỒ'
                                : 'INSIGHTS & TRENDS',
                            style: AppText.sans(
                                size: 11, color: AppColors.lavender, letterSpacing: 1.2)),
                        Text(vi ? 'Xu hướng Năng lượng' : 'Energy Trends',
                            style: AppText.serif(size: 26, color: AppColors.text)),
                        Text(periodLabel,
                            style: AppText.sans(size: 14, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const LangToggle(),
                ],
              ),
            ),

            // Period toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.paper.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _PeriodTab(
                    label: vi ? 'Tuần' : 'Week',
                    isActive: _periodIndex == 0,
                    onTap: () => setState(() => _periodIndex = 0),
                  ),
                  _PeriodTab(
                    label: vi ? 'Tháng' : 'Month',
                    isActive: _periodIndex == 1,
                    onTap: () => setState(() => _periodIndex = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main metrics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vi ? 'TỔNG QUAN' : 'OVERVIEW',
                      style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 0.9)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.paper.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.lavender.withOpacity(0.15), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(avgScore.toString(),
                                  style: AppText.serif(
                                      size: 32, weight: FontWeight.w700, height: 1)),
                              const SizedBox(height: 4),
                              Text(s.levelName(avgLevel.name),
                                  style: AppText.sans(
                                      size: 13, weight: FontWeight.w600, color: AppColors.lavender)),
                              Text(vi ? 'Năng lượng trung bình' : 'Average energy',
                                  style: AppText.sans(size: 11, color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.paper.withOpacity(0.88),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.gold.withOpacity(0.15), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$minScore–$maxScore',
                                      style: AppText.serif(
                                          size: 18, weight: FontWeight.w700, height: 1)),
                                  const SizedBox(height: 2),
                                  Text(vi ? 'Khoảng' : 'Range',
                                      style: AppText.sans(size: 10, color: AppColors.gold)),
                                  Text(vi ? 'từ thấp đến cao' : 'low to high',
                                      style: AppText.sans(size: 10, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.paper.withOpacity(0.88),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.teal.withOpacity(0.15), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trendLabel,
                                      style: AppText.sans(
                                          size: 13, weight: FontWeight.w600, height: 1)),
                                  const SizedBox(height: 2),
                                  Text(vi ? 'Xu hướng' : 'Trend',
                                      style: AppText.sans(size: 10, color: AppColors.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Time breakdown
            if (timeAvgs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vi ? 'NĂNG LƯỢNG THEO GIỜ' : 'ENERGY BY TIME',
                        style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 0.9)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.paper.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < timeAvgs.length; i++) ...[
                            _TimeBreakdownRow(
                              label: s.tod(timeAvgs[i].key),
                              score: timeAvgs[i].value,
                              maxScore: maxScore,
                            ),
                            if (i < timeAvgs.length - 1)
                              Divider(
                                  color: AppColors.muted3.withOpacity(0.3), height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Top emotions
            if (topEmotions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vi ? 'CẢM XÚC THƯỜNG GẶP' : 'TOP EMOTIONS',
                        style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 0.9)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.paper.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < topEmotions.take(5).length; i++) ...[
                            _FrequencyRow(
                              icon: AppIcons.emotion(topEmotions[i].key),
                              label: s.emotionLabel(topEmotions[i].key),
                              count: topEmotions[i].value,
                              total: periodCheckIns.length,
                              color: AppColors.pink,
                            ),
                            if (i < topEmotions.take(5).length - 1)
                              Divider(
                                  color: AppColors.muted3.withOpacity(0.3), height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Top triggers
            if (topTriggers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vi ? 'YẾU TỐ ẢNH HƯỞNG NHIỀU NHẤT' : 'TOP TRIGGERS',
                        style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 0.9)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.paper.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < topTriggers.take(5).length; i++) ...[
                            _FrequencyRow(
                              icon: AppIcons.trigger(topTriggers[i].key),
                              label: s.triggerLabel(topTriggers[i].key),
                              count: topTriggers[i].value,
                              total: periodCheckIns.length,
                              color: AppColors.teal,
                            ),
                            if (i < topTriggers.take(5).length - 1)
                              Divider(
                                  color: AppColors.muted3.withOpacity(0.3), height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Info note
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tealSoft.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal.withOpacity(0.2)),
              ),
              child: Text(
                  vi
                      ? 'Những thống kê này dựa trên các ghi nhận của bạn. Càng ghi nhận nhiều, những xu hướng sẽ càng rõ ràng hơn.'
                      : 'These insights are based on your check-ins. The more you check in, the clearer your patterns will be.',
                  style: AppText.sans(size: 12, color: AppColors.textSoft, height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Strings s) {
    final vi = s.lang == Lang.vi;
    return PaperBackground(
      tint: const Color(0xFFF0E8DC),
      blob: AppColors.lavenderLight,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lavender.withOpacity(0.1),
                  ),
                  child: const Center(
                    child: Icon(Icons.insert_chart_outlined,
                        color: AppColors.lavender, size: 28),
                  ),
                ),
                const SizedBox(height: 16),
                Text(vi ? 'Chưa có dữ liệu' : 'No data yet',
                    style: AppText.serif(size: 20, color: AppColors.text)),
                const SizedBox(height: 8),
                Text(
                    vi
                        ? 'Hãy bắt đầu ghi nhận năng lượng để xem những xu hướng.'
                        : 'Start checking in to see your patterns.',
                    style: AppText.sans(size: 14, color: AppColors.muted, height: 1.6),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(colors: [AppColors.lavender, AppColors.lavenderLight])
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: AppText.sans(
                  size: 13,
                  weight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : AppColors.muted)),
        ),
      ),
    );
  }
}

class _TimeBreakdownRow extends StatelessWidget {
  final String label;
  final int score;
  final int maxScore;

  const _TimeBreakdownRow({
    required this.label,
    required this.score,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: AppText.sans(size: 13, weight: FontWeight.w500, color: AppColors.text)),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / maxScore,
                    minHeight: 8,
                    backgroundColor: AppColors.muted3.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(AppColors.lavender.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$score',
                  style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.text)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrequencyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int total;
  final Color color;

  const _FrequencyRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppText.sans(size: 13, weight: FontWeight.w500, color: AppColors.text)),
              Text('$count lần',
                  style: AppText.sans(size: 12, weight: FontWeight.w500, color: AppColors.lavender)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          height: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 4,
              backgroundColor: AppColors.muted3.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
