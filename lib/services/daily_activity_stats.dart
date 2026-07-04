import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-day focus time and consecutive active-day streaks.
abstract final class DailyActivityStats {
  static const _focusSecondsPrefix = 'focus_seconds_';
  static const _streakKey = 'daily_streak';
  static const _lastActiveKey = 'last_active_date';

  static Future<({int streak, String? lastActive})> streakSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      streak: prefs.getInt(_streakKey) ?? 0,
      lastActive: prefs.getString(_lastActiveKey),
    );
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static Future<int> focusSecondsFor(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_focusSecondsPrefix${_dateKey(date)}') ?? 0;
  }

  static Future<int> todayFocusSeconds() {
    return focusSecondsFor(DateTime.now());
  }

  static Future<void> addFocusSeconds(int seconds) async {
    if (seconds <= 0) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '$_focusSecondsPrefix${_dateKey(DateTime.now())}';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + seconds);
  }

  static Future<void> recordActiveDay({DateTime? date}) async {
    final activeDate = date ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(activeDate);
    final lastActive = prefs.getString(_lastActiveKey);

    if (lastActive == todayKey) {
      return;
    }

    var streak = prefs.getInt(_streakKey) ?? 0;
    if (lastActive == null) {
      streak = 1;
    } else {
      final last = DateTime.parse(lastActive);
      final lastDay = DateTime(last.year, last.month, last.day);
      final today = DateTime(activeDate.year, activeDate.month, activeDate.day);
      final gap = today.difference(lastDay).inDays;

      if (gap == 1) {
        streak += 1;
      } else if (gap > 1) {
        streak = 1;
      }
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastActiveKey, todayKey);
  }

  static Future<List<int>> focusSecondsForWeek(DateTime weekMonday) async {
    final start = DateTime(
      weekMonday.year,
      weekMonday.month,
      weekMonday.day,
    );
    return Future.wait(
      List.generate(
        7,
        (index) => focusSecondsFor(start.add(Duration(days: index))),
      ),
    );
  }

  static Future<int> focusSecondsForRange(
    DateTime start,
    DateTime end,
  ) async {
    var total = 0;
    var day = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    while (day.isBefore(endDay)) {
      total += await focusSecondsFor(day);
      day = day.add(const Duration(days: 1));
    }
    return total;
  }

  static Future<bool> isTodayLogged() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getString(_lastActiveKey);
    if (lastActive == null) {
      return false;
    }
    return lastActive == _dateKey(DateTime.now());
  }

  static Future<int> dailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getString(_lastActiveKey);
    if (lastActive == null) {
      return 0;
    }

    final last = DateTime.parse(lastActive);
    final lastDay = DateTime(last.year, last.month, last.day);
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final gap = todayDay.difference(lastDay).inDays;

    if (gap > 1) {
      return 0;
    }

    return prefs.getInt(_streakKey) ?? 0;
  }
}

/// Formats seconds as `6.4h` (one decimal) or `42m` under one hour.
String formatFocusUptime(int totalSeconds) {
  if (totalSeconds <= 0) {
    return '0h';
  }

  final hours = totalSeconds / 3600;
  if (hours >= 1) {
    return '${hours.toStringAsFixed(1)}h';
  }

  final minutes = (totalSeconds / 60).round();
  return '${minutes}m';
}
