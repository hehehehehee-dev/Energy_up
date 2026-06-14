import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/check_in.dart';
import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_circle.dart';
import '../widgets/energy_slider.dart';
import '../widgets/gradient_button.dart';

class CloseTheDayScreen extends StatefulWidget {
  const CloseTheDayScreen({super.key});

  @override
  State<CloseTheDayScreen> createState() => _CloseTheDayScreenState();
}

class _CloseTheDayScreenState extends State<CloseTheDayScreen> {
  late int _score;
  final _controller = TextEditingController();
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final daily = getDailyEnergy(context.read<AppState>().todayCheckIns);
      _score = daily > 0 ? daily : 200;
      _init = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.s;
    final checkIns = app.todayCheckIns;
    final level = getLevelForScore(_score);
    final scores = checkIns.map((c) => c.score).toList();
    final lowest = scores.isEmpty ? 0 : scores.reduce((a, b) => a < b ? a : b);
    final highest = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8E4F4), Color(0xFFF0EDF8), AppColors.canvas],
            stops: [0, 0.4, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chevron_left, size: 16, color: AppColors.lavender),
                            Text(s.back, style: AppText.sans(size: 14, color: AppColors.lavender)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('🌙', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(s.closeTitle,
                              style: AppText.serif(size: 28, color: AppColors.text)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(s.closeSub,
                          style: AppText.sans(size: 15, color: AppColors.muted, height: 1.7)),
                      const SizedBox(height: 16),

                      // Today's journey recap
                      if (checkIns.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lavender.withOpacity(0.12)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.closeTodayJourney.toUpperCase(),
                                  style: AppText.sans(
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: AppColors.lavender,
                                      letterSpacing: 0.7)),
                              const SizedBox(height: 10),
                              ...checkIns.map((c) {
                                final lv = getLevelForScore(c.score);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(s.tod(c.timeOfDay),
                                            style: AppText.sans(
                                                size: 11, color: AppColors.muted2)),
                                      ),
                                      Text(c.emotionEmoji, style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 8),
                                      Text('${c.score}',
                                          style: AppText.sans(
                                              size: 13, weight: FontWeight.w500)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text('— ${s.levelName(lv.name)}',
                                            style: AppText.sans(
                                                size: 13, color: AppColors.muted)),
                                      ),
                                      Text(formatTime(c.time),
                                          style: AppText.sans(
                                              size: 11, color: AppColors.muted3)),
                                    ],
                                  ),
                                );
                              }),
                              if (scores.length > 1) ...[
                                const Divider(height: 16),
                                Row(
                                  children: [
                                    Text('${s.closeRange}: $lowest – $highest',
                                        style: AppText.sans(size: 12, color: AppColors.muted)),
                                    const SizedBox(width: 16),
                                    Text('${checkIns.length} ${s.todayCheckInsToday}',
                                        style: AppText.sans(size: 12, color: AppColors.muted)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Question + slider
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Text(s.closeQuestion,
                                textAlign: TextAlign.center,
                                style: AppText.serif(
                                    size: 17,
                                    color: AppColors.textSoft,
                                    height: 1.6,
                                    style: FontStyle.italic)),
                            const SizedBox(height: 16),
                            AuraCircle(score: _score, size: AuraSize.md),
                            const SizedBox(height: 16),
                            EnergySlider(
                                value: _score,
                                onChanged: (v) => setState(() => _score = v)),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: level.auraOuter.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: level.auraOuter.withOpacity(0.19)),
                              ),
                              child: Text(s.levelDescription(level.name),
                                  textAlign: TextAlign.center,
                                  style: AppText.sans(
                                      size: 13, color: AppColors.textSoft, height: 1.6)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reflection
                      Text(s.closeReflectionLabel,
                          style: AppText.sans(size: 13, color: AppColors.muted)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        maxLines: 4,
                        style: AppText.sans(size: 15, color: AppColors.text, height: 1.7),
                        decoration: InputDecoration(
                          hintText: s.closeReflectionPlaceholder,
                          hintStyle:
                              AppText.sans(size: 15, color: AppColors.muted2, height: 1.5),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: AppColors.lavender.withOpacity(0.15), width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: AppColors.lavender.withOpacity(0.15), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: AppColors.lavender, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lavender2.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lavender2.withOpacity(0.2)),
                        ),
                        child: Text(s.closeClosingNote,
                            textAlign: TextAlign.center,
                            style: AppText.sans(
                                size: 13,
                                color: AppColors.belowText,
                                height: 1.7,
                                style: FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: GradientButton(
                  colors: const [AppColors.lavender, AppColors.lavenderLight],
                  onTap: () async {
                    await context.read<AppState>().saveDailyReflection(_controller.text);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, size: 18),
                      const SizedBox(width: 8),
                      Text(s.closeSave,
                          style: AppText.sans(
                              size: 15, weight: FontWeight.w500, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
