import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.dart';
import '../models/check_in.dart';
import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_circle.dart';
import '../widgets/gradient_button.dart';
import '../widgets/lang_toggle.dart';

class TodayScreen extends StatelessWidget {
  final VoidCallback onStartCheckIn;
  final VoidCallback onCloseTheDay;
  final VoidCallback onOpenProfile;

  const TodayScreen({
    super.key,
    required this.onStartCheckIn,
    required this.onCloseTheDay,
    required this.onOpenProfile,
  });

  static const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _monthsVi = ['Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12'];
  static const _daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _daysVi = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  String _greeting(Strings s) {
    final h = DateTime.now().hour;
    if (h < 12) return s.greetingMorning;
    if (h < 17) return s.greetingAfternoon;
    if (h < 21) return s.greetingEvening;
    return s.greetingNight;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;
    final isVi = app.lang == Lang.vi;
    final checkIns = app.todayCheckIns;
    final now = DateTime.now();
    final days = isVi ? _daysVi : _daysEn;
    final months = isVi ? _monthsVi : _monthsEn;
    final dow = now.weekday % 7; // DateTime: Mon=1..Sun=7 -> Sun=0
    final dateStr = isVi
        ? '${days[dow]}, ${now.day} ${months[now.month - 1]}'
        : '${days[dow]}, ${months[now.month - 1]} ${now.day}';

    final hasCheckIns = checkIns.isNotEmpty;
    final latest = hasCheckIns ? checkIns.last : null;
    final currentScore = latest?.score ?? 0;
    final dailyEnergy = getDailyEnergy(checkIns);
    final isAbove = currentScore >= 200;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0EDF8), AppColors.canvas],
          stops: [0, 0.4],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
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
                        Text(dateStr,
                            style: AppText.sans(
                                size: 12, color: AppColors.muted, letterSpacing: 0.7)),
                        Text('${_greeting(s)}, Minh ✦',
                            style: AppText.serif(size: 24, color: AppColors.text, height: 1.2)),
                        if (hasCheckIns)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(s.greetingSub,
                                style: AppText.sans(size: 13, color: AppColors.muted)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const LangToggle(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onOpenProfile,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.lavender2, AppColors.pinkLight],
                        ),
                      ),
                      child: const Center(
                          child: Text('🌿', style: TextStyle(fontSize: 18))),
                    ),
                  ),
                ],
              ),
            ),
            if (!hasCheckIns)
              _emptyState(context, s)
            else
              ..._content(context, s, checkIns, currentScore, dailyEnergy, isAbove, latest!),
            _gentleMoments(context, s, checkIns),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, Strings s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.lavender.withOpacity(0.12), blurRadius: 32),
        ],
      ),
      child: Column(
        children: [
          const AuraCircle(score: 0, size: AuraSize.lg),
          const SizedBox(height: 20),
          Text(s.todayEmptyTitle,
              textAlign: TextAlign.center,
              style: AppText.serif(size: 18, color: AppColors.text)),
          const SizedBox(height: 6),
          Text(s.todayEmptyBody,
              textAlign: TextAlign.center,
              style: AppText.sans(size: 14, color: AppColors.muted, height: 1.6)),
          const SizedBox(height: 20),
          GradientButton(
            colors: const [AppColors.lavender, AppColors.lavenderLight],
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            radius: 16,
            onTap: onStartCheckIn,
            shadow: [
              BoxShadow(
                  color: AppColors.lavender.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6)),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 18),
                const SizedBox(width: 8),
                Text(s.todayCheckInNow,
                    style: AppText.sans(
                        size: 15, weight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, Strings s, List<CheckIn> checkIns,
      int currentScore, int dailyEnergy, bool isAbove, CheckIn latest) {
    final currentLevel = getLevelForScore(currentScore);
    final scores = checkIns.map((c) => c.score).toList();
    final lowest = scores.reduce((a, b) => a < b ? a : b);
    final highest = scores.reduce((a, b) => a > b ? a : b);
    final sorted = [...checkIns]..sort((a, b) =>
        timeOfDayOrder.indexOf(a.timeOfDay) - timeOfDayOrder.indexOf(b.timeOfDay));

    return [
      // Current energy card
      Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.lavender.withOpacity(0.12), blurRadius: 32),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.todayCurrentEnergy.toUpperCase(),
                style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AuraCircle(score: currentScore, size: AuraSize.md),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$currentScore',
                              style: AppText.serif(
                                  size: 36, weight: FontWeight.w600, color: AppColors.text)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('— ${s.levelName(currentLevel.name)}',
                                style: AppText.sans(size: 16, color: AppColors.muted)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${s.todayCheckedInAt} ${formatTime(latest.time)}',
                          style: AppText.sans(size: 13, color: AppColors.muted)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAbove
                              ? AppColors.tealSoft.withOpacity(0.2)
                              : AppColors.lavender2.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: isAbove
                                  ? AppColors.tealSoft.withOpacity(0.5)
                                  : AppColors.lavender2.withOpacity(0.4)),
                        ),
                        child: Text(
                          isAbove ? s.todayAboveThreshold : s.todayBelowThreshold,
                          style: AppText.sans(
                              size: 11,
                              weight: FontWeight.w500,
                              color: isAbove ? AppColors.aboveText : AppColors.belowText),
                        ),
                      ),
                      if (!isAbove)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(s.todayMomentForCare,
                              style: AppText.sans(
                                  size: 12, color: AppColors.lavender, height: 1.5)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    '${checkIns.length} ${checkIns.length == 1 ? s.todayOneCheckInToday : s.todayCheckInsToday}',
                    style: AppText.sans(size: 12, color: AppColors.muted2),
                  ),
                  if (checkIns.length > 1)
                    Text(
                      '${s.todayLowest}: $lowest · ${s.todayHighest}: $highest · ${s.todayCurrent}: $currentScore',
                      style: AppText.sans(size: 12, color: AppColors.muted2),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    colors: const [AppColors.lavender, AppColors.lavenderLight],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    radius: 16,
                    onTap: onStartCheckIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 16),
                        const SizedBox(width: 6),
                        Text(s.todayCheckInAgain,
                            style: AppText.sans(
                                size: 14, weight: FontWeight.w500, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onCloseTheDay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.lavender2.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lavender2.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.nightlight_round, size: 16, color: AppColors.belowText),
                        const SizedBox(width: 6),
                        Text(s.todayCloseTheDay,
                            style: AppText.sans(
                                size: 13, weight: FontWeight.w500, color: AppColors.belowText)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Energy path timeline
      if (checkIns.length > 1)
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.todayEnergyPath.toUpperCase(),
                  style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 1.1)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var i = 0; i < sorted.length; i++) ...[
                    Text(
                      '${sorted[i].emotionEmoji} ${s.levelName(getLevelForScore(sorted[i].score).name)}',
                      style: AppText.sans(
                          size: 13,
                          weight: FontWeight.w500,
                          color: getLevelForScore(sorted[i].score).auraInner),
                    ),
                    if (i < sorted.length - 1)
                      const Icon(Icons.arrow_forward, size: 12, color: AppColors.muted3),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < sorted.length; i++)
                _timelineRow(s, sorted[i], i == sorted.length - 1),
            ],
          ),
        ),

      // Daily energy
      if (checkIns.length >= 2)
        Builder(builder: (_) {
          final dailyLevel = getLevelForScore(dailyEnergy);
          return Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [dailyLevel.auraOuter.withOpacity(0.09), Colors.white.withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dailyLevel.auraOuter.withOpacity(0.19)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.todayDailyEnergy.toUpperCase(),
                    style: AppText.sans(size: 11, color: AppColors.muted, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$dailyEnergy',
                        style: AppText.serif(size: 30, weight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(width: 8),
                    Text('— ${s.levelName(dailyLevel.name)}',
                        style: AppText.sans(size: 15, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(s.todayDailyEnergySub(checkIns.length),
                    style: AppText.sans(size: 12, color: AppColors.lavender)),
                const SizedBox(height: 3),
                Text(s.todayDailyEnergyNote,
                    style: AppText.sans(size: 12, color: AppColors.muted2, height: 1.5)),
              ],
            ),
          );
        }),

      // Insight
      Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.tealSoft.withOpacity(0.15),
            AppColors.lavender2.withOpacity(0.15),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tealSoft.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✦', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.todayInsightTitle,
                      style: AppText.sans(size: 13, weight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    checkIns.length > 1
                        ? s.todayInsightShifted
                        : isAbove
                            ? s.todayInsightAbove
                            : s.todayInsightBelow,
                    style: AppText.sans(size: 13, color: AppColors.textSoft, height: 1.7),
                  ),
                  if (checkIns.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: onCloseTheDay,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.todayReflectNow,
                                style: AppText.sans(
                                    size: 13,
                                    weight: FontWeight.w500,
                                    color: AppColors.lavender)),
                            const Icon(Icons.chevron_right, size: 14, color: AppColors.lavender),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _timelineRow(Strings s, CheckIn c, bool isLast) {
    final lv = getLevelForScore(c.score);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: lv.auraOuter.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: lv.auraOuter, width: 1.5),
                ),
                child: Center(child: Text(c.emotionEmoji, style: const TextStyle(fontSize: 10))),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.only(top: 2),
                    color: AppColors.lavender.withOpacity(0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(s.tod(c.timeOfDay),
                          style: AppText.sans(
                              size: 12, weight: FontWeight.w600, color: AppColors.lavender)),
                      const SizedBox(width: 8),
                      Text(formatTime(c.time),
                          style: AppText.sans(size: 11, color: AppColors.muted3)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('${c.score}',
                          style: AppText.serif(size: 16, weight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Text('— ${s.levelName(lv.name)}',
                          style: AppText.sans(size: 13, color: AppColors.muted)),
                    ],
                  ),
                  if (c.reflection.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '"${c.reflection.length > 60 ? '${c.reflection.substring(0, 60)}…' : c.reflection}"',
                        style: AppText.sans(
                            size: 12,
                            color: AppColors.muted,
                            height: 1.5,
                            style: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gentleMoments(BuildContext context, Strings s, List<CheckIn> checkIns) {
    final moments = [
      ['Morning', s.tod('Morning'), '🌅', s.todayMorningQ],
      ['Afternoon', s.tod('Afternoon'), '☀️', s.todayAfternoonQ],
      ['Evening', s.tod('Evening'), '🌙', s.todayEveningQ],
      ['Night', s.todayBeforeSleep, '✨', s.todayNightQ],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.todayGentleMoments,
              style: AppText.sans(size: 13, color: AppColors.muted)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: moments.map((m) {
              final done = checkIns.any((c) => c.timeOfDay == m[0]);
              return GestureDetector(
                onTap: onStartCheckIn,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.tealSoft.withOpacity(0.15)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: done
                          ? AppColors.tealSoft.withOpacity(0.4)
                          : AppColors.lavender.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(done ? '✓' : m[2], style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(m[1],
                                style: AppText.sans(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: done ? AppColors.aboveText : AppColors.text)),
                            Text(m[3],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.sans(
                                    size: 11, color: AppColors.muted, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
