import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.dart';
import '../models/check_in.dart';
import '../models/hawkins.dart';
import '../state/app_state.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_circle.dart';
import '../widgets/energy_slider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/paper_background.dart';

enum _Step { emotion, trigger, journal, practice }

/// The full multi-step check-in flow, pushed as a full-screen route.
class CheckInFlow extends StatefulWidget {
  const CheckInFlow({super.key});

  @override
  State<CheckInFlow> createState() => _CheckInFlowState();
}

class _CheckInFlowState extends State<CheckInFlow> {
  _Step _step = _Step.emotion;

  Emotion? _emotion;
  List<String> _triggers = [];
  int _score = 200;
  String _reflection = '';

  void _onEmotion(Emotion e) {
    setState(() {
      _emotion = e;
      _score = e.baseScore;
      _step = _Step.trigger;
    });
  }

  void _onTriggers(List<String> labels) {
    setState(() {
      _triggers = labels;
      _step = _Step.journal;
    });
  }

  Future<void> _onJournal(int score, String reflection) async {
    final now = DateTime.now();
    final checkIn = CheckIn(
      id: 'checkin-${now.millisecondsSinceEpoch}',
      date:
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      timeOfDay: getTimeOfDay(now),
      emotion: _emotion!.label,
      emotionEmoji: _emotion!.emoji,
      score: score,
      triggers: _triggers,
      reflection: reflection,
    );
    await context.read<AppState>().addCheckIn(checkIn);
    setState(() {
      _score = score;
      _reflection = reflection;
      _step = _Step.practice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.04, 0), end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        ),
        child: switch (_step) {
          _Step.emotion => _EmotionStep(
              key: const ValueKey('emotion'),
              onSelect: _onEmotion,
              onClose: () => Navigator.of(context).pop(),
            ),
          _Step.trigger => _TriggerStep(
              key: const ValueKey('trigger'),
              emotion: _emotion!,
              onSelect: _onTriggers,
              onBack: () => setState(() => _step = _Step.emotion),
            ),
          _Step.journal => _JournalStep(
              key: const ValueKey('journal'),
              emotion: _emotion!,
              triggers: _triggers,
              onSubmit: _onJournal,
              onBack: () => setState(() => _step = _Step.trigger),
            ),
          _Step.practice => _PracticeStep(
              key: const ValueKey('practice'),
              score: _score,
              emotion: _emotion!,
              reflection: _reflection,
              onDone: () => Navigator.of(context).pop(),
            ),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Emotion
// ---------------------------------------------------------------------------
class _EmotionStep extends StatefulWidget {
  final ValueChanged<Emotion> onSelect;
  final VoidCallback onClose;
  const _EmotionStep({super.key, required this.onSelect, required this.onClose});

  @override
  State<_EmotionStep> createState() => _EmotionStepState();
}

class _EmotionStepState extends State<_EmotionStep> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final low = emotions.where((e) => e.group == 'low').toList();
    final high = emotions.where((e) => e.group == 'high').toList();
    Emotion? selectedEmotion;
    for (final e in emotions) {
      if (e.id == _selected) {
        selectedEmotion = e;
        break;
      }
    }

    return PaperBackground(
      tint: const Color(0xFFFBE8DB),
      blob: AppColors.pinkLight,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.emotionStep.toString().toUpperCase(),
                          style: AppText.sans(
                              size: 11, weight: FontWeight.w700, color: AppColors.pink, letterSpacing: 2)),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.pinkLight.withOpacity(0.2),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              size: 16, color: AppColors.pink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(s.emotionTitle,
                      style: AppText.serif(size: 26, color: AppColors.text)),
                  const SizedBox(height: 4),
                  Text(s.emotionBody,
                      style:
                          AppText.sans(size: 14, color: AppColors.muted, height: 1.6)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _groupLabel(AppColors.pink, s.emotionBelowLabel),
                    const SizedBox(height: 12),
                    _grid(low, s, AppColors.pinkLight, const Color(0xFFFBE8DB)),
                    const SizedBox(height: 24),
                    _groupLabel(const Color(0xFF70A898), s.emotionAboveLabel),
                    const SizedBox(height: 12),
                    _grid(high, s, AppColors.tealSoft, const Color(0xFFEAEFD8)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: GradientButton(
                enabled: _selected != null,
                colors: _selected != null
                    ? const [Color(0xFFC57E63), Color(0xFFD89478)]
                    : const [Color(0xFFF4E8D7), Color(0xFFF4E8D7)],
                onTap: selectedEmotion == null
                    ? null
                    : () => widget.onSelect(selectedEmotion!),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedEmotion != null
                          ? s.emotionContinueWith(s.emotionLabel(selectedEmotion.label))
                          : s.emotionSelectPrompt,
                      style: AppText.sans(
                          size: 15,
                          weight: FontWeight.w500,
                          color: _selected != null ? Colors.white : AppColors.muted),
                    ),
                    if (_selected != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupLabel(Color dot, String label) => Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: AppText.sans(size: 12, color: AppColors.muted)),
        ],
      );

  Widget _grid(List<Emotion> list, Strings s, Color activeColor, Color bg) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, i) {
        final e = list[i];
        final selected = _selected == e.id;
        return GestureDetector(
          onTap: () => setState(() => _selected = e.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? activeColor : bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: selected ? activeColor : Colors.transparent, width: 1.5),
              boxShadow: selected
                  ? [BoxShadow(color: activeColor.withOpacity(0.25), blurRadius: 12)]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.emotion(e.label),
                    size: 24,
                    color: selected ? AppColors.text : AppColors.muted),
                const SizedBox(height: 6),
                Text(
                  s.emotionLabel(e.label),
                  textAlign: TextAlign.center,
                  style: AppText.sans(
                    size: 11,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.text : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Trigger
// ---------------------------------------------------------------------------
class _TriggerStep extends StatefulWidget {
  final Emotion emotion;
  final ValueChanged<List<String>> onSelect;
  final VoidCallback onBack;
  const _TriggerStep(
      {super.key,
      required this.emotion,
      required this.onSelect,
      required this.onBack});

  @override
  State<_TriggerStep> createState() => _TriggerStepState();
}

class _TriggerStepState extends State<_TriggerStep> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final selectedLabels = triggers
        .where((tr) => _selected.contains(tr.id))
        .map((tr) => tr.label)
        .toList();

    return PaperBackground(
      tint: const Color(0xFFFEF0E6),
      blob: AppColors.goldLight,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackButton(label: s.back, color: AppColors.gold, onTap: widget.onBack),
                  const SizedBox(height: 12),
                  Text(s.triggerStep.toString().toUpperCase(),
                      style: AppText.sans(
                          size: 11, weight: FontWeight.w700, color: AppColors.gold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(AppIcons.emotion(widget.emotion.label),
                          size: 24, color: AppColors.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.triggerTitle,
                            style: AppText.serif(size: 26, color: AppColors.text)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(s.triggerBody(s.emotionLabel(widget.emotion.label)),
                      style: AppText.sans(size: 14, color: AppColors.muted, height: 1.6)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: triggers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.6,
                  ),
                  itemBuilder: (context, i) {
                    final tr = triggers[i];
                    final selected = _selected.contains(tr.id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        selected ? _selected.remove(tr.id) : _selected.add(tr.id);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF5C4A0).withOpacity(0.3)
                              : AppColors.paper.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? AppColors.goldLight
                                : AppColors.goldLight.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(AppIcons.trigger(tr.label),
                                size: 22,
                                color: selected ? AppColors.gold : AppColors.muted),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.triggerLabel(tr.label),
                                style: AppText.sans(
                                  size: 14,
                                  weight:
                                      selected ? FontWeight.w600 : FontWeight.w400,
                                  color: selected
                                      ? AppColors.text
                                      : AppColors.textSoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: GradientButton(
                colors: _selected.isNotEmpty
                    ? const [Color(0xFFE0A070), Color(0xFFF5C4A0)]
                    : const [AppColors.lavender2, AppColors.lavender],
                onTap: () => widget.onSelect(selectedLabels),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selected.isNotEmpty
                          ? s.triggerContinueWith(_selected.length)
                          : s.triggerSkip,
                      style: AppText.sans(
                          size: 15, weight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Journal (score + reflection)
// ---------------------------------------------------------------------------
class _JournalStep extends StatefulWidget {
  final Emotion emotion;
  final List<String> triggers;
  final Future<void> Function(int, String) onSubmit;
  final VoidCallback onBack;
  const _JournalStep(
      {super.key,
      required this.emotion,
      required this.triggers,
      required this.onSubmit,
      required this.onBack});

  @override
  State<_JournalStep> createState() => _JournalStepState();
}

class _JournalStepState extends State<_JournalStep> {
  late int _score = widget.emotion.baseScore;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;

    return PaperBackground(
      tint: const Color(0xFFFEF0E6),
      blob: AppColors.goldLight,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BackButton(label: s.back, color: AppColors.gold, onTap: widget.onBack),
                    const SizedBox(height: 12),
                    Text(s.journalStep.toString().toUpperCase(),
                        style: AppText.sans(
                            size: 11, weight: FontWeight.w700, color: AppColors.gold, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(s.journalTitle,
                        style: AppText.serif(size: 26, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text(s.journalBody,
                        style: AppText.sans(
                            size: 14, color: AppColors.muted, height: 1.6)),
                    const SizedBox(height: 16),
                    // Score selector card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.paper.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          AuraCircle(score: _score, size: AuraSize.md),
                          const SizedBox(height: 16),
                          EnergySlider(
                            value: _score,
                            onChanged: (v) => setState(() => _score = v),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(s.journalCommonLevels,
                                style: AppText.sans(
                                    size: 12, color: AppColors.muted)),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: hawkinsLevels.map((l) {
                              final active = _score == l.score;
                              return GestureDetector(
                                onTap: () => setState(() => _score = l.score),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? l.auraOuter.withOpacity(0.31)
                                        : const Color(0xFFDCCDB8).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: active
                                            ? l.auraOuter
                                            : Colors.transparent),
                                  ),
                                  child: Text(
                                    '${l.score} · ${s.levelName(l.name)}',
                                    style: AppText.sans(
                                      size: 12,
                                      weight: active
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: active
                                          ? AppColors.text
                                          : AppColors.muted,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    if (widget.triggers.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.triggers
                            .map((tr) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5C4A0).withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFF5C4A0)
                                            .withOpacity(0.4)),
                                  ),
                                  child: Text(s.triggerLabel(tr),
                                      style: AppText.sans(
                                          size: 12, color: AppColors.gold)),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(s.journalReflection,
                        style: AppText.sans(size: 13, color: AppColors.muted)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      maxLines: 5,
                      style: AppText.sans(size: 15, color: AppColors.text, height: 1.7),
                      decoration: InputDecoration(
                        hintText: s.journalPlaceholder,
                        hintStyle:
                            AppText.sans(size: 15, color: AppColors.muted2, height: 1.5),
                        filled: true,
                        fillColor: AppColors.paper.withOpacity(0.85),
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
                          borderSide: const BorderSide(
                              color: AppColors.lavender, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: GradientButton(
                colors: const [Color(0xFFE0A070), Color(0xFFF5C4A0)],
                onTap: () => widget.onSubmit(_score, _controller.text),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.journalSave,
                        style: AppText.sans(
                            size: 15, weight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4 — Suggested practice
// ---------------------------------------------------------------------------
class _PracticeStep extends StatelessWidget {
  final int score;
  final Emotion emotion;
  final String reflection;
  final VoidCallback onDone;
  const _PracticeStep(
      {super.key,
      required this.score,
      required this.emotion,
      required this.reflection,
      required this.onDone});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final level = getLevelForScore(score);
    final isAbove = score >= 200;
    final levelName = s.levelName(level.name);
    final practiceName = s.levelPractice(level.practice);

    return PaperBackground(
      tint: Color.alphaBlend(level.auraOuter.withOpacity(0.18), AppColors.canvas),
      blob: level.auraOuter,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    Text(s.practiceSaved.toString().toUpperCase(),
                        style: AppText.sans(
                            size: 11, color: AppColors.muted, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    AuraCircle(score: score, size: AuraSize.md),
                    const SizedBox(height: 16),
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.paper.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(AppIcons.emotion(emotion.label),
                                  size: 20, color: AppColors.textSoft),
                              const SizedBox(width: 8),
                              Text(s.emotionLabel(emotion.label),
                                  style: AppText.sans(
                                      size: 15, weight: FontWeight.w600)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isAbove
                                      ? const Color(0xFFEAEFD8)
                                      : const Color(0xFFF7ECDB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('$score',
                                    style: AppText.sans(
                                        size: 14,
                                        weight: FontWeight.w700,
                                        color: isAbove
                                            ? AppColors.aboveText
                                            : AppColors.belowText)),
                              ),
                            ],
                          ),
                          if (reflection.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '"${reflection.length > 120 ? '${reflection.substring(0, 120)}…' : reflection}"',
                              style: AppText.sans(
                                  size: 14,
                                  color: AppColors.textSoft,
                                  height: 1.7,
                                  style: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(s.practiceOffering,
                          style: AppText.sans(size: 13, color: AppColors.muted)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            level.auraOuter.withOpacity(0.125),
                            level.auraInner.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: level.auraOuter.withOpacity(0.25), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: level.auraOuter.withOpacity(0.21),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                    child: Icon(Icons.spa_rounded,
                                        size: 20, color: level.auraInner)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(practiceName,
                                    style: AppText.serif(
                                        size: 18, color: AppColors.text, height: 1.3)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(level.practiceDetail,
                              style: AppText.sans(
                                  size: 15, color: AppColors.text, height: 1.8)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.paper.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppColors.lavender.withOpacity(0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.practiceReflectionLabel,
                              style: AppText.sans(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: AppColors.lavender)),
                          const SizedBox(height: 4),
                          Text(
                            isAbove
                                ? s.practiceAbove(levelName, score)
                                : s.practiceBelow(levelName, score),
                            style: AppText.sans(
                                size: 14, color: AppColors.textSoft, height: 1.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: GradientButton(
                colors: const [AppColors.lavender, AppColors.lavenderLight],
                onTap: onDone,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    Text(s.practiceBackToToday,
                        style: AppText.sans(
                            size: 15, weight: FontWeight.w500, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BackButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppText.sans(size: 14, color: color)),
        ],
      ),
    );
  }
}
