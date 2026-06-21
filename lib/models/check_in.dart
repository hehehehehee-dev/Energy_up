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

/// Format a [DateTime] as the `YYYY-MM-DD` key used throughout check-in data.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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

const List<EnergyDay> mockEnergyHistory = [];

/// Static demo history shown in the Journal / Energy screens.
const List<CheckIn> mockHistoryCheckIns = [];
