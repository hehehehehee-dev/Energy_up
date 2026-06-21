import 'package:flutter/material.dart';

/// Real (rounded Material) icons replacing the emoji used throughout the app —
/// a big part of making the UI feel intentional rather than AI-generated.
///
/// Maps are keyed by the English label stored on the data objects
/// (e.g. `CheckIn.emotion` / `Emotion.label` = "Hope", `Trigger.label`).
class AppIcons {
  static const IconData _fallback = Icons.circle_outlined;

  static const Map<String, IconData> _emotion = {
    'Shame': Icons.sentiment_very_dissatisfied_rounded,
    'Guilt': Icons.cloud_rounded,
    'Apathy': Icons.cloud_queue_rounded,
    'Grief': Icons.water_drop_rounded,
    'Fear': Icons.bolt_rounded,
    'Anxiety': Icons.blur_on_rounded,
    'Desire': Icons.waves_rounded,
    'Anger': Icons.local_fire_department_rounded,
    'Frustration': Icons.flash_on_rounded,
    'Pride': Icons.emoji_events_rounded,
    'Courage': Icons.eco_rounded,
    'Hope': Icons.wb_twilight_rounded,
    'Neutral': Icons.sentiment_neutral_rounded,
    'Willingness': Icons.park_rounded,
    'Acceptance': Icons.spa_rounded,
    'Gratitude': Icons.volunteer_activism_rounded,
    'Clarity': Icons.lightbulb_rounded,
    'Reason': Icons.lightbulb_rounded,
    'Love': Icons.favorite_rounded,
    'Joy': Icons.wb_sunny_rounded,
    'Peace': Icons.self_improvement_rounded,
    'Enlightenment': Icons.auto_awesome_rounded,
    'Pure Consciousness': Icons.brightness_7_rounded,
  };

  static const Map<String, IconData> _trigger = {
    'Relationships': Icons.people_alt_rounded,
    'Work': Icons.work_rounded,
    'Health': Icons.monitor_heart_rounded,
    'Finances': Icons.savings_rounded,
    'Family': Icons.home_rounded,
    'Self & Identity': Icons.person_rounded,
    'Spirituality': Icons.auto_awesome_rounded,
    'Creativity': Icons.palette_rounded,
    'Environment': Icons.public_rounded,
    'Not sure': Icons.help_outline_rounded,
  };

  static const Map<String, IconData> _time = {
    'Morning': Icons.wb_sunny_rounded,
    'Afternoon': Icons.light_mode_rounded,
    'Evening': Icons.wb_twilight_rounded,
    'Night': Icons.nightlight_round,
  };

  static const Map<String, IconData> _level = {
    'Shame': Icons.sentiment_very_dissatisfied_rounded,
    'Guilt': Icons.cloud_rounded,
    'Apathy': Icons.cloud_queue_rounded,
    'Grief': Icons.water_drop_rounded,
    'Fear': Icons.bolt_rounded,
    'Desire': Icons.waves_rounded,
    'Anger': Icons.local_fire_department_rounded,
    'Pride': Icons.emoji_events_rounded,
    'Courage': Icons.eco_rounded,
    'Neutrality': Icons.sentiment_neutral_rounded,
    'Willingness': Icons.park_rounded,
    'Acceptance': Icons.spa_rounded,
    'Reason': Icons.lightbulb_rounded,
    'Love': Icons.favorite_rounded,
    'Joy': Icons.wb_sunny_rounded,
    'Peace': Icons.self_improvement_rounded,
    'Enlightenment': Icons.auto_awesome_rounded,
    'Pure Consciousness': Icons.brightness_7_rounded,
  };

  static IconData emotion(String label) => _emotion[label] ?? _fallback;
  static IconData trigger(String label) => _trigger[label] ?? _fallback;
  static IconData time(String key) => _time[key] ?? Icons.schedule_rounded;
  static IconData level(String name) => _level[name] ?? _fallback;
}
