import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kDailyBriefLastShownKey = 'daily_brief_last_shown';
const kLastOpenedAtKey = 'last_opened_at';

String dailyBriefTodayString([DateTime? date]) {
  final today = date ?? DateTime.now();
  final month = today.month.toString().padLeft(2, '0');
  final day = today.day.toString().padLeft(2, '0');
  return '${today.year}-$month-$day';
}

/// Persists daily brief gate + last-opened timestamps for routing and state.
class DailyBriefGateNotifier extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> load(SharedPreferences prefs) async {
    _prefs = prefs;
    _isLoaded = true;
    notifyListeners();
  }

  bool shouldShowToday() {
    final prefs = _prefs;
    if (prefs == null) {
      return false;
    }

    final lastShown = prefs.getString(kDailyBriefLastShownKey);
    if (lastShown == null) {
      return true;
    }

    return lastShown != dailyBriefTodayString();
  }

  DateTime? readLastOpenedAt() {
    final raw = _prefs?.getString(kLastOpenedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> markShownToday() async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }

    await prefs.setString(kDailyBriefLastShownKey, dailyBriefTodayString());
    notifyListeners();
  }

  Future<void> markOpenedNow() async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }

    await prefs.setString(kLastOpenedAtKey, DateTime.now().toIso8601String());
    notifyListeners();
  }
}
