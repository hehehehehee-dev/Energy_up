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

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  static const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _monthsVi = ['Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12'];
  static const _daysEn = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  static const _daysVi = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;
    final isVi = app.lang == Lang.vi;
    final todayCheckIns = app.todayCheckIns;
    final todayDate = _todayKey();

    // Group history by date
    final historyByDate = <String, List<CheckIn>>{};
    for (final c in mockHistoryCheckIns) {
      historyByDate.putIfAbsent(c.date, () => []).add(c);
    }
    final byDate = <String, List<CheckIn>>{
      if (todayCheckIns.isNotEmpty) todayDate: todayCheckIns,
      ...historyByDate,
    };
    final dates = [
      if (todayCheckIns.isNotEmpty) todayDate,
      ...historyByDate.keys.toList()..sort((a, b) => b.compareTo(a)),
    ];

    String dateLabel(String date, int index) {
      if (index == 0 && date == todayDate) return s.jsToday;
      final d = DateTime.parse('${date}T12:00:00');
      // yesterday check
      final yest = DateTime.now().subtract(const Duration(days: 1));
      final yKey =
          '${yest.year.toString().padLeft(4, '0')}-${yest.month.toString().padLeft(2, '0')}-${yest.day.toString().padLeft(2, '0')}';
      if (date == yKey) return s.jsYesterday;
      final days = isVi ? _daysVi : _daysEn;
      final months = isVi ? _monthsVi : _monthsEn;
      final dow = d.weekday % 7;
      return isVi
          ? '${days[dow]}, ${d.day} ${months[d.month - 1]}'
          : '${days[dow]}, ${months[d.month - 1]} ${d.day}';
    }

    return PaperBackground(
      tint: const Color(0xFFFEF0E6),
      blob: AppColors.goldLight,
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
                        Text(s.jsLabel.toUpperCase(),
                            style: AppText.sans(size: 11, color: AppColors.gold, letterSpacing: 1.2)),
                        Text(s.jsTitle, style: AppText.serif(size: 26, color: AppColors.text)),
                        Text(s.jsSub, style: AppText.sans(size: 14, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const LangToggle(),
                ],
              ),
            ),
            for (var i = 0; i < dates.length; i++)
              _daySection(s, dateLabel(dates[i], i), byDate[dates[i]] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _daySection(Strings s, String label, List<CheckIn> dayCheckIns) {
    if (dayCheckIns.isEmpty) return const SizedBox.shrink();
    final sorted = [...dayCheckIns]..sort((a, b) => a.time.compareTo(b.time));
    final dailyEnergy = getDailyEnergy(sorted);
    final isAbove = dailyEnergy >= 200;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.muted)),
              ),
              Text(s.jsCheckInsCount(sorted.length),
                  style: AppText.sans(size: 12, color: AppColors.muted2)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isAbove ? const Color(0xFFEAEFD8) : const Color(0xFFF7ECDB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${s.jsDaily} $dailyEnergy',
                    style: AppText.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: isAbove ? AppColors.aboveText : AppColors.belowText)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sorted.map((c) => _checkInCard(s, c)),
        ],
      ),
    );
  }

  Widget _checkInCard(Strings s, CheckIn c) {
    final level = getLevelForScore(c.score);
    final isAbove = c.score >= 200;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: level.auraOuter, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(s.tod(c.timeOfDay),
                    style: AppText.sans(size: 11, weight: FontWeight.w600, color: AppColors.lavender)),
              ),
              Text(formatTime(c.time), style: AppText.sans(size: 11, color: AppColors.muted3)),
              const Spacer(),
              Icon(AppIcons.emotion(c.emotion), size: 16, color: AppColors.muted),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    level.auraOuter.withOpacity(0.44),
                    level.auraInner.withOpacity(0.44),
                  ]),
                ),
                child: Center(
                  child: Text('${c.score}',
                      style: AppText.sans(size: 10, weight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isAbove ? const Color(0xFFEAEFD8) : const Color(0xFFF7ECDB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s.levelName(level.name),
                    style: AppText.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: isAbove ? AppColors.aboveText : AppColors.belowText)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(s.emotionLabel(c.emotion),
                  style: AppText.sans(size: 14, weight: FontWeight.w600)),
              const SizedBox(width: 6),
              const Text('·', style: TextStyle(color: AppColors.muted2)),
              const SizedBox(width: 6),
              Text('${c.score}',
                  style: AppText.serif(size: 16, weight: FontWeight.w600, color: level.auraInner)),
            ],
          ),
          if (c.triggers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: c.triggers
                  .map((tr) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5C4A0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(s.triggerLabel(tr),
                            style: AppText.sans(size: 11, color: AppColors.gold)),
                      ))
                  .toList(),
            ),
          ],
          if (c.reflection.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('"${c.reflection}"',
                style: AppText.sans(
                    size: 14, color: AppColors.textSoft, height: 1.7, style: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.spa_rounded, size: 14, color: AppColors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${s.jsPracticeLabel} ',
                      style: AppText.sans(size: 12, color: AppColors.muted)),
                  TextSpan(
                      text: s.levelPractice(level.practice),
                      style: AppText.sans(
                          size: 12, weight: FontWeight.w500, color: AppColors.lavender)),
                ])),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
