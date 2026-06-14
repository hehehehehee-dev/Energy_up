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

  Lang _lang = Lang.en;
  bool _onboarded = false;
  final List<CheckIn> _checkIns = [];
  // date (YYYY-MM-DD) -> end-of-day reflection text
  final Map<String, String> _dailyReflections = {};

  Lang get lang => _lang;
  Strings get s => stringsFor(_lang);
  bool get onboarded => _onboarded;

  /// All user check-ins, most recent first by date+time.
  List<CheckIn> get checkIns => List.unmodifiable(_checkIns);

  String get _today => _dateKey(DateTime.now());

  /// Check-ins recorded today.
  List<CheckIn> get todayCheckIns =>
      _checkIns.where((c) => c.date == _today).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

  Map<String, String> get dailyReflections => Map.unmodifiable(_dailyReflections);

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;

    _onboarded = prefs.getBool(_kOnboarded) ?? false;
    _lang = (prefs.getString(_kLang) == 'vi') ? Lang.vi : Lang.en;

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

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
