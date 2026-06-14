import 'package:flutter_test/flutter_test.dart';

import 'package:angel/models/hawkins.dart';
import 'package:angel/models/check_in.dart';

void main() {
  test('getLevelForScore maps scores to the correct Hawkins level', () {
    expect(getLevelForScore(200).name, 'Courage');
    expect(getLevelForScore(199).name, 'Pride');
    expect(getLevelForScore(1000).name, 'Pure Consciousness');
    expect(getLevelForScore(20).name, 'Shame');
  });

  test('snapToScale snaps to the nearest defined level', () {
    expect(snapToScale(205), 200);
    expect(snapToScale(0), 20);
  });

  test('getDailyEnergy blends average and latest check-in', () {
    final checkIns = [
      const CheckIn(
        id: '1', date: '2026-06-14', time: '09:00', timeOfDay: 'Morning',
        emotion: 'Fear', emotionEmoji: '😨', score: 100, triggers: [], reflection: '',
      ),
      const CheckIn(
        id: '2', date: '2026-06-14', time: '20:00', timeOfDay: 'Evening',
        emotion: 'Courage', emotionEmoji: '🌱', score: 300, triggers: [], reflection: '',
      ),
    ];
    // avg = 200, last = 300 -> 200*0.55 + 300*0.45 = 245
    expect(getDailyEnergy(checkIns), 245);
  });
}
