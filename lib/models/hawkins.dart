import 'package:flutter/material.dart';

/// A level on Dr. David Hawkins' Map of Consciousness (Power vs. Force).
class HawkinsLevel {
  final int score;
  final String name; // English key — localized via i18n maps
  final String description;
  final Color auraInner;
  final Color auraOuter;
  final Color auraGlow;
  final String practice; // English key — localized via i18n maps
  final String practiceDetail;

  const HawkinsLevel({
    required this.score,
    required this.name,
    required this.description,
    required this.auraInner,
    required this.auraOuter,
    required this.auraGlow,
    required this.practice,
    required this.practiceDetail,
  });
}

const List<HawkinsLevel> hawkinsLevels = [
  HawkinsLevel(
    score: 20, name: 'Shame', description: 'A tender, vulnerable place',
    auraInner: Color(0xFF6B4E8A), auraOuter: Color(0xFF9B7AB8), auraGlow: Color(0xFF8B6AAA),
    practice: 'Self-compassion breathing',
    practiceDetail:
        'Place one hand on your heart. Breathe in slowly for 4 counts, hold for 4, and exhale for 6. With each exhale, whisper "I am worthy of gentleness." Repeat 5 times.',
  ),
  HawkinsLevel(
    score: 30, name: 'Guilt', description: 'Carrying something heavy from the past',
    auraInner: Color(0xFF7A4E7A), auraOuter: Color(0xFFAA7AAA), auraGlow: Color(0xFF9A6A9A),
    practice: 'Forgiveness letter',
    practiceDetail:
        'Write a short letter to yourself acknowledging what happened, what you learned, and offering yourself forgiveness. You do not need to send it — just feel it.',
  ),
  HawkinsLevel(
    score: 50, name: 'Apathy', description: 'A quiet numbness — the body protecting itself',
    auraInner: Color(0xFF7878A8), auraOuter: Color(0xFF9898C4), auraGlow: Color(0xFF8888B8),
    practice: 'Gentle body scan',
    practiceDetail:
        'Lie down or sit comfortably. Starting at your feet, slowly notice each part of your body without judgment. When you reach your heart, place your hand there and breathe.',
  ),
  HawkinsLevel(
    score: 75, name: 'Grief', description: 'An open heart that has loved deeply',
    auraInner: Color(0xFF7888B8), auraOuter: Color(0xFF98A8CC), auraGlow: Color(0xFF8898C4),
    practice: 'Grief acknowledgment ritual',
    practiceDetail:
        'Light a candle or place your hand over your heart. Speak or write what you have lost or miss. Say aloud: "I honor what was real and meaningful to me."',
  ),
  HawkinsLevel(
    score: 100, name: 'Fear', description: 'Energy preparing you for something ahead',
    auraInner: Color(0xFF6898C0), auraOuter: Color(0xFF88B8DA), auraGlow: Color(0xFF78A8CC),
    practice: '4-7-8 breathing',
    practiceDetail:
        'Inhale quietly through your nose for 4 counts. Hold your breath for 7 counts. Exhale completely through your mouth for 8 counts. Repeat 4 cycles.',
  ),
  HawkinsLevel(
    score: 125, name: 'Desire', description: 'A signal of something that matters to you',
    auraInner: Color(0xFF9870B8), auraOuter: Color(0xFFB890CC), auraGlow: Color(0xFFA880C4),
    practice: 'Mindful wanting',
    practiceDetail:
        'Notice what you are craving without acting on it. Ask yourself: "What deeper need is beneath this desire?" Journal three words that come up.',
  ),
  HawkinsLevel(
    score: 150, name: 'Anger', description: 'Energy with a boundary trying to form',
    auraInner: Color(0xFFC07878), auraOuter: Color(0xFFD89898), auraGlow: Color(0xFFC88888),
    practice: 'Movement release',
    practiceDetail:
        'Go for a brisk 5-minute walk. As you walk, with each exhale, release the tension you are holding. Return and write one thing you can control in this situation.',
  ),
  HawkinsLevel(
    score: 175, name: 'Pride', description: 'A step toward strength, still finding its footing',
    auraInner: Color(0xFFC4A060), auraOuter: Color(0xFFD8C080), auraGlow: Color(0xFFCCB070),
    practice: 'Humility reflection',
    practiceDetail:
        'Write down three things you genuinely admire in others today. Then write one way you can learn from one of those qualities.',
  ),
  HawkinsLevel(
    score: 200, name: 'Courage', description: 'Affirming life — a meaningful threshold',
    auraInner: Color(0xFF80B880), auraOuter: Color(0xFFA0CCA0), auraGlow: Color(0xFF90C490),
    practice: 'Empowerment affirmation',
    practiceDetail:
        'Stand tall, feet shoulder-width apart. Take three deep breaths. Say aloud: "I have what it takes. I choose to face today with openness." Feel the truth in your body.',
  ),
  HawkinsLevel(
    score: 250, name: 'Neutrality', description: 'Unattached, flexible, and trusting life',
    auraInner: Color(0xFF70B0A0), auraOuter: Color(0xFF90CCBA), auraGlow: Color(0xFF80BCA8),
    practice: 'Loving-kindness meditation',
    practiceDetail:
        'Sit quietly. Breathe naturally. With each inhale, receive peace. With each exhale, send that peace to someone you care about. Continue for 5 minutes.',
  ),
  HawkinsLevel(
    score: 310, name: 'Willingness', description: 'Open, optimistic, and ready to grow',
    auraInner: Color(0xFF60A8C0), auraOuter: Color(0xFF80C4D8), auraGlow: Color(0xFF70B8CC),
    practice: 'Intention setting',
    practiceDetail:
        'Write one intention for today that aligns with who you want to become. Not a task — a way of being. For example: "I choose to be patient with myself today."',
  ),
  HawkinsLevel(
    score: 350, name: 'Acceptance', description: 'Harmonious, allowing life to unfold',
    auraInner: Color(0xFF7098C8), auraOuter: Color(0xFF90B8D8), auraGlow: Color(0xFF80A8D0),
    practice: 'Gratitude immersion',
    practiceDetail:
        'Write 10 things you are genuinely grateful for right now — from the big to the small. With each one, pause and actually feel it in your body.',
  ),
  HawkinsLevel(
    score: 400, name: 'Reason', description: 'Clear thinking, insight, and understanding',
    auraInner: Color(0xFF7870C8), auraOuter: Color(0xFF9890D8), auraGlow: Color(0xFF8880D0),
    practice: 'Contemplative journaling',
    practiceDetail:
        'Ask yourself one meaningful question: "What is the deeper truth beneath what I\'m experiencing?" Write without stopping for 10 minutes.',
  ),
  HawkinsLevel(
    score: 500, name: 'Love', description: 'Unconditional care, warmth, and service',
    auraInner: Color(0xFFC870B8), auraOuter: Color(0xFFD890CC), auraGlow: Color(0xFFD080C4),
    practice: 'Heart coherence',
    practiceDetail:
        'Focus your attention on the area of your heart. Breathe as if your breath is flowing in and out of your heart. Recall a moment of deep love. Stay in that feeling for 5 minutes.',
  ),
  HawkinsLevel(
    score: 540, name: 'Joy', description: 'Serenity, radiance, and effortless delight',
    auraInner: Color(0xFFD8A040), auraOuter: Color(0xFFECC060), auraGlow: Color(0xFFE0B050),
    practice: 'Joy anchoring',
    practiceDetail:
        'Recall a moment when you felt pure, uncaused joy. Notice where you feel it in your body. Breathe into that area. Let it expand. Know you can return here.',
  ),
  HawkinsLevel(
    score: 600, name: 'Peace', description: 'Profound stillness and inner completeness',
    auraInner: Color(0xFF80CCA8), auraOuter: Color(0xFFA0DEC0), auraGlow: Color(0xFF90D4B4),
    practice: 'Silent sitting',
    practiceDetail:
        'Find a comfortable seat. Set a gentle timer for 10 minutes. Simply be. Let thoughts arise and pass like clouds. You are the sky, not the weather.',
  ),
  HawkinsLevel(
    score: 700, name: 'Enlightenment', description: 'Transcendent awareness and unity',
    auraInner: Color(0xFFE8D080), auraOuter: Color(0xFFF4E4A0), auraGlow: Color(0xFFEED890),
    practice: 'Pure presence',
    practiceDetail:
        'Rest in open awareness. No technique needed. Simply notice the awareness itself — the space in which all experience arises. You are home.',
  ),
  HawkinsLevel(
    score: 1000, name: 'Pure Consciousness', description: 'Infinite, ineffable, beyond description',
    auraInner: Color(0xFFF5ECD8), auraOuter: Color(0xFFFDF8EC), auraGlow: Color(0xFFF8F0E0),
    practice: 'Being',
    practiceDetail: 'Simply be.',
  ),
];

HawkinsLevel getLevelForScore(int score) {
  var level = hawkinsLevels.first;
  for (final l in hawkinsLevels) {
    if (score >= l.score) {
      level = l;
    } else {
      break;
    }
  }
  return level;
}

/// Snap an arbitrary score to the nearest defined Hawkins level.
int snapToScale(int raw) {
  var closest = hawkinsLevels.first.score;
  var minDiff = (raw - closest).abs();
  for (final l in hawkinsLevels) {
    final diff = (raw - l.score).abs();
    if (diff < minDiff) {
      minDiff = diff;
      closest = l.score;
    }
  }
  return closest;
}

/// An emotion the user can pick at the start of a check-in.
class Emotion {
  final String id;
  final String label; // English key
  final String emoji;
  final int baseScore;
  final String group; // 'low' | 'high'
  const Emotion(this.id, this.label, this.emoji, this.baseScore, this.group);
}

const List<Emotion> emotions = [
  Emotion('shame', 'Shame', '😔', 20, 'low'),
  Emotion('guilt', 'Guilt', '😞', 30, 'low'),
  Emotion('apathy', 'Apathy', '😶', 50, 'low'),
  Emotion('grief', 'Grief', '😢', 75, 'low'),
  Emotion('fear', 'Fear', '😨', 100, 'low'),
  Emotion('anxiety', 'Anxiety', '😰', 110, 'low'),
  Emotion('desire', 'Desire', '🌊', 125, 'low'),
  Emotion('anger', 'Anger', '😤', 150, 'low'),
  Emotion('frustration', 'Frustration', '😣', 155, 'low'),
  Emotion('pride', 'Pride', '😤', 175, 'low'),
  Emotion('courage', 'Courage', '🌱', 200, 'high'),
  Emotion('hope', 'Hope', '🌤', 220, 'high'),
  Emotion('neutral', 'Neutral', '😌', 250, 'high'),
  Emotion('willingness', 'Willingness', '🌿', 310, 'high'),
  Emotion('acceptance', 'Acceptance', '🌸', 350, 'high'),
  Emotion('gratitude', 'Gratitude', '🙏', 375, 'high'),
  Emotion('reason', 'Clarity', '✨', 400, 'high'),
  Emotion('love', 'Love', '💗', 500, 'high'),
  Emotion('joy', 'Joy', '☀️', 540, 'high'),
  Emotion('peace', 'Peace', '🕊', 600, 'high'),
];

/// A life area that may be connected to a feeling.
class Trigger {
  final String id;
  final String label; // English key
  final String icon;
  const Trigger(this.id, this.label, this.icon);
}

const List<Trigger> triggers = [
  Trigger('relationships', 'Relationships', '👥'),
  Trigger('work', 'Work', '💼'),
  Trigger('health', 'Health', '🌿'),
  Trigger('finances', 'Finances', '💰'),
  Trigger('family', 'Family', '🏡'),
  Trigger('self', 'Self & Identity', '🪞'),
  Trigger('spirituality', 'Spirituality', '✨'),
  Trigger('creativity', 'Creativity', '🎨'),
  Trigger('environment', 'Environment', '🌍'),
  Trigger('unknown', 'Not sure', '🌫'),
];
