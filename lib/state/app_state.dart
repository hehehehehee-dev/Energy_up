import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/strings.dart';
import '../models/check_in.dart';

/// Central app store — holds user data and persists it with shared_preferences.
class AppState extends ChangeNotifier {
  static const _kCheckIns = 'angel.checkIns';
  static const _kLang = 'angel.lang';
  static const _kOnboarded = 'angel.onboarded';
  static const _kDailyReflections = 'angel.dailyReflections';

  SharedPreferences? _prefs;

  Lang _lang = Lang.vi; // Vietnamese is the default; users can switch to English
  bool _onboarded = false;
  final List<CheckIn> _checkIns = [];
  // date (YYYY-MM-DD) -> end-of-day reflection text
  final Map<String, String> _dailyReflections = {};

  Lang get lang => _lang;
  Strings get s => stringsFor(_lang);
  bool get onboarded => _onboarded;

  /// All user check-ins, most recent first by date+time.
  List<CheckIn> get checkIns => List.unmodifiable(_checkIns);

  String get _today => dateKey(DateTime.now());

  /// Check-ins recorded today.
  List<CheckIn> get todayCheckIns =>
      _checkIns.where((c) => c.date == _today).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

  /// Check-ins recorded on a given `YYYY-MM-DD` date.
  List<CheckIn> checkInsOn(String date) =>
      _checkIns.where((c) => c.date == date).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

  Set<String> get _checkInDates => _checkIns.map((c) => c.date).toSet();

  /// Days checked in in a row, counting back from today. If today has no
  /// check-in yet, the streak still counts through yesterday so an
  /// in-progress streak doesn't look broken before the day ends.
  int get currentStreak {
    final dates = _checkInDates;
    if (dates.isEmpty) return 0;
    var cursor = DateTime.now();
    if (!dates.contains(dateKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (dates.contains(dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Longest streak ever reached — kept so milestones stay unlocked even
  /// after the current streak resets.
  int get longestStreak {
    final dates = _checkInDates.toList()..sort();
    if (dates.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var i = 1; i < dates.length; i++) {
      final gap = DateTime.parse(dates[i]).difference(DateTime.parse(dates[i - 1])).inDays;
      current = gap == 1 ? current + 1 : 1;
      if (current > longest) longest = current;
    }
    return longest;
  }

  Map<String, String> get dailyReflections => Map.unmodifiable(_dailyReflections);

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;

    _onboarded = prefs.getBool(_kOnboarded) ?? false;
    // Default to Vietnamese; only switch to English if the user explicitly chose it.
    _lang = (prefs.getString(_kLang) == 'en') ? Lang.en : Lang.vi;

    final raw = prefs.getString(_kCheckIns);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _checkIns
        ..clear()
        ..addAll(list.map((e) => CheckIn.fromJson(e as Map<String, dynamic>)));
    }

    final rawDaily = prefs.getString(_kDailyReflections);
    if (rawDaily != null) {
      final map = jsonDecode(rawDaily) as Map<String, dynamic>;
      _dailyReflections
        ..clear()
        ..addAll(map.map((k, v) => MapEntry(k, v as String)));
    }

    notifyListeners();
  }

  Future<void> setLang(Lang lang) async {
    if (_lang == lang) return;
    _lang = lang;
    await _prefs?.setString(_kLang, lang == Lang.vi ? 'vi' : 'en');
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    await _prefs?.setBool(_kOnboarded, true);
    notifyListeners();
  }

  Future<void> addCheckIn(CheckIn checkIn) async {
    _checkIns.add(checkIn);
    await _persistCheckIns();
    notifyListeners();
  }

  Future<void> saveDailyReflection(String reflectionText) async {
    if (reflectionText.trim().isNotEmpty) {
      _dailyReflections[_today] = reflectionText;
      await _prefs?.setString(_kDailyReflections, jsonEncode(_dailyReflections));
    }
    notifyListeners();
  }

  Future<void> _persistCheckIns() async {
    await _prefs?.setString(
      _kCheckIns,
      jsonEncode(_checkIns.map((c) => c.toJson()).toList()),
    );
  }

}
