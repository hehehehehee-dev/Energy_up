/// A single emotional energy check-in.
class CheckIn {
  final String id;
  final String date; // YYYY-MM-DD
  final String time; // HH:MM 24h
  final String timeOfDay; // Morning | Afternoon | Evening | Night
  final String emotion; // English key
  final String emotionEmoji;
  final int score;
  final List<String> triggers; // English keys
  final String reflection;

  const CheckIn({
    required this.id,
    required this.date,
    required this.time,
    required this.timeOfDay,
    required this.emotion,
    required this.emotionEmoji,
    required this.score,
    required this.triggers,
    required this.reflection,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'timeOfDay': timeOfDay,
        'emotion': emotion,
        'emotionEmoji': emotionEmoji,
        'score': score,
        'triggers': triggers,
        'reflection': reflection,
      };

  factory CheckIn.fromJson(Map<String, dynamic> j) => CheckIn(
        id: j['id'] as String,
        date: j['date'] as String,
        time: j['time'] as String,
        timeOfDay: j['timeOfDay'] as String,
        emotion: j['emotion'] as String,
        emotionEmoji: j['emotionEmoji'] as String,
        score: j['score'] as int,
        triggers: (j['triggers'] as List).map((e) => e as String).toList(),
        reflection: j['reflection'] as String,
      );
}

const List<String> timeOfDayOrder = ['Morning', 'Afternoon', 'Evening', 'Night'];

String getTimeOfDay([DateTime? date]) {
  final h = (date ?? DateTime.now()).hour;
  if (h >= 5 && h < 12) return 'Morning';
  if (h >= 12 && h < 17) return 'Afternoon';
  if (h >= 17 && h < 21) return 'Evening';
  return 'Night';
}

/// Format `HH:MM` (24h) as a 12-hour clock with AM/PM.
String formatTime(String time) {
  final parts = time.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final ampm = h >= 12 ? 'PM' : 'AM';
  final hour = h % 12 == 0 ? 12 : h % 12;
  return '$hour:${m.toString().padLeft(2, '0')} $ampm';
}

/// A gentle weighted summary of a day's check-ins.
int getDailyEnergy(List<CheckIn> checkIns) {
  if (checkIns.isEmpty) return 0;
  final avg = checkIns.fold<int>(0, (s, c) => s + c.score) / checkIns.length;
  final last = checkIns.last.score;
  return (avg * 0.55 + last * 0.45).round();
}

/// One day of aggregated history for the Energy trend chart.
class EnergyDay {
  final String date;
  final int score;
  final int checkIns;
  final int low;
  final int high;
  const EnergyDay(this.date, this.score, this.checkIns, this.low, this.high);
}

const List<EnergyDay> mockEnergyHistory = [
  EnergyDay('Jun 7', 250, 2, 250, 250),
  EnergyDay('Jun 8', 303, 3, 100, 500),
  EnergyDay('Jun 9', 215, 2, 80, 350),
  EnergyDay('Jun 10', 330, 2, 310, 350),
  EnergyDay('Jun 11', 180, 2, 110, 250),
  EnergyDay('Jun 12', 285, 2, 220, 350),
  EnergyDay('Jun 13', 208, 3, 100, 310),
];

/// Static demo history shown in the Journal / Energy screens.
const List<CheckIn> mockHistoryCheckIns = [
  CheckIn(id: 'h1a', date: '2026-06-12', time: '09:00', timeOfDay: 'Morning', emotion: 'Hope', emotionEmoji: '🌤', score: 220, triggers: ['Work'], reflection: 'Feeling hopeful about the week.'),
  CheckIn(id: 'h1b', date: '2026-06-12', time: '19:00', timeOfDay: 'Evening', emotion: 'Acceptance', emotionEmoji: '🌸', score: 350, triggers: ['Self & Identity'], reflection: 'Good conversation with my team.'),
  CheckIn(id: 'h2a', date: '2026-06-11', time: '08:00', timeOfDay: 'Morning', emotion: 'Anxiety', emotionEmoji: '😰', score: 110, triggers: ['Finances', 'Work'], reflection: 'Worried about the upcoming deadline.'),
  CheckIn(id: 'h2b', date: '2026-06-11', time: '15:00', timeOfDay: 'Afternoon', emotion: 'Neutral', emotionEmoji: '😌', score: 250, triggers: [], reflection: 'Found some calm after a walk.'),
  CheckIn(id: 'h3a', date: '2026-06-10', time: '07:30', timeOfDay: 'Morning', emotion: 'Willingness', emotionEmoji: '🌿', score: 310, triggers: ['Spirituality'], reflection: 'Morning meditation felt different today.'),
  CheckIn(id: 'h3b', date: '2026-06-10', time: '21:00', timeOfDay: 'Night', emotion: 'Acceptance', emotionEmoji: '🌸', score: 350, triggers: ['Self & Identity'], reflection: 'Something softened inside.'),
  CheckIn(id: 'h4a', date: '2026-06-09', time: '10:00', timeOfDay: 'Morning', emotion: 'Grief', emotionEmoji: '😢', score: 80, triggers: ['Relationships'], reflection: 'Missing someone.'),
  CheckIn(id: 'h4b', date: '2026-06-09', time: '18:00', timeOfDay: 'Evening', emotion: 'Acceptance', emotionEmoji: '🌸', score: 350, triggers: ['Family'], reflection: 'A long talk with my sister helped.'),
  CheckIn(id: 'h5a', date: '2026-06-08', time: '09:00', timeOfDay: 'Morning', emotion: 'Fear', emotionEmoji: '😨', score: 100, triggers: ['Work'], reflection: 'Anxious start.'),
  CheckIn(id: 'h5b', date: '2026-06-08', time: '14:00', timeOfDay: 'Afternoon', emotion: 'Willingness', emotionEmoji: '🌿', score: 310, triggers: [], reflection: 'Opened up a bit after lunch.'),
  CheckIn(id: 'h5c', date: '2026-06-08', time: '20:00', timeOfDay: 'Evening', emotion: 'Love', emotionEmoji: '💗', score: 500, triggers: ['Family'], reflection: 'Spent the afternoon with my grandmother.'),
  CheckIn(id: 'h6a', date: '2026-06-07', time: '08:00', timeOfDay: 'Morning', emotion: 'Neutral', emotionEmoji: '😌', score: 250, triggers: ['Work'], reflection: 'Quiet day. Just present.'),
  CheckIn(id: 'h6b', date: '2026-06-07', time: '20:00', timeOfDay: 'Evening', emotion: 'Neutral', emotionEmoji: '😌', score: 250, triggers: [], reflection: 'Gentle evening. Nothing dramatic.'),
];
