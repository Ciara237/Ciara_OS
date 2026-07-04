import 'package:ciaraos/services/settings_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationTapCallback = void Function(
  String? payload,
  String? channelId,
);

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int dailyBriefId = 1000;
  static const int deepWorkNudgeId = 1001;
  static const int _opportunityIdOffset = 500000;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  NotificationTapCallback? _onNotificationTap;

  Future<void> initialize({
    NotificationTapCallback? onNotificationTap,
  }) async {
    if (_initialized) {
      return;
    }

    _onNotificationTap = onNotificationTap;
    _configureLocalTimeZone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationTap?.call(
          response.payload,
          _channelIdFromPayload(response.payload),
        );
      },
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    await _createAndroidChannels();
    _initialized = true;
  }

  Future<void> scheduleDeadlineReminders({
    required int id,
    required String title,
    required String type,
    required DateTime deadline,
  }) async {
    await cancelDeadlineReminders(id, type: type);

    const reminders = <({int days, String label})>[
      (days: 3, label: 'due in 3 days'),
      (days: 1, label: 'due tomorrow'),
      (days: 0, label: 'due today'),
    ];

    for (final reminder in reminders) {
      final triggerTime = _deadlineTriggerTime(deadline, reminder.days);
      if (!triggerTime.isAfter(DateTime.now())) {
        continue;
      }

      final notificationId = _deadlineNotificationId(id, type, reminder.days);
      final payload = type == 'opportunity'
          ? '/opportunities/$id'
          : '/tasks/$id';

      await _scheduleNotification(
        id: notificationId,
        title: title,
        body: '"$title" is ${reminder.label}',
        scheduledDate: triggerTime,
        channelId: 'deadlines',
        payload: payload,
      );
    }
  }

  Future<void> cancelDeadlineReminders(
    int id, {
    String type = 'task',
  }) async {
    for (final days in [0, 1, 3]) {
      final notificationId = _deadlineNotificationId(id, type, days);
      await _plugin.cancel(notificationId);
      await _untrackScheduledId(notificationId);
    }
  }

  Future<void> scheduleDailyBrief(TimeOfDay time) async {
    await _plugin.cancel(dailyBriefId);

    await _plugin.zonedSchedule(
      dailyBriefId,
      'Your daily brief is ready',
      "Tap to see today's mission",
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_brief',
          'Daily Brief',
          channelDescription: 'Daily executive brief reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/daily-brief',
    );
    await _trackScheduledId(dailyBriefId);
  }

  Future<void> cancelDailyBrief() async {
    await _plugin.cancel(dailyBriefId);
    await _untrackScheduledId(dailyBriefId);
  }

  Future<void> scheduleDeepWorkNudge(TimeOfDay nudgeTime) async {
    await _plugin.cancel(deepWorkNudgeId);

    await _plugin.zonedSchedule(
      deepWorkNudgeId,
      'No focus session yet today',
      'Start deep work to build your streak.',
      _nextInstanceOfTime(nudgeTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deep_work',
          'Focus Nudges',
          channelDescription: 'Reminders to start a focus session',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/|deep_work',
    );
    await _trackScheduledId(deepWorkNudgeId);
  }

  Future<void> cancelDeepWorkNudge() async {
    await _plugin.cancel(deepWorkNudgeId);
    await _untrackScheduledId(deepWorkNudgeId);
  }

  Future<void> cancelAllTrackedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(scheduledNotificationIdsPreferenceKey) ??
        const <String>[];
    for (final idValue in ids) {
      final id = int.tryParse(idValue);
      if (id != null) {
        await _plugin.cancel(id);
      }
    }
    await prefs.remove(scheduledNotificationIdsPreferenceKey);
  }

  Future<void> cancelAllDeadlineNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(scheduledNotificationIdsPreferenceKey) ??
        const <String>[];
    for (final idValue in ids) {
      final id = int.tryParse(idValue);
      if (id == null) {
        continue;
      }
      if (id == dailyBriefId || id == deepWorkNudgeId) {
        continue;
      }
      await _plugin.cancel(id);
    }
    final remaining = ids.where((idValue) {
      final id = int.tryParse(idValue);
      return id == dailyBriefId || id == deepWorkNudgeId;
    }).toList();
    await prefs.setStringList(
      scheduledNotificationIdsPreferenceKey,
      remaining,
    );
  }

  Future<void> restoreFromPreferences({
    required bool masterEnabled,
    required bool deadlineRemindersEnabled,
    required TimeOfDay dailyBriefTime,
    required TimeOfDay deepWorkTime,
    required Iterable<({int id, String title, String type, DateTime deadline})>
        deadlines,
  }) async {
    if (!masterEnabled) {
      await cancelAllTrackedNotifications();
      await cancelDailyBrief();
      await cancelDeepWorkNudge();
      return;
    }

    await scheduleDailyBrief(dailyBriefTime);
    await scheduleDeepWorkNudge(deepWorkTime);

    if (deadlineRemindersEnabled) {
      for (final item in deadlines) {
        await scheduleDeadlineReminders(
          id: item.id,
          title: item.title,
          type: item.type,
          deadline: item.deadline,
        );
      }
    } else {
      await cancelAllDeadlineNotifications();
    }
  }

  int _deadlineNotificationId(int id, String type, int days) {
    final entityKey =
        type == 'opportunity' ? _opportunityIdOffset + id : id;
    return entityKey * 10 + days;
  }

  DateTime _deadlineTriggerTime(DateTime deadline, int daysBefore) {
    if (daysBefore == 0) {
      return DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
        9,
        0,
      );
    }

    final targetDay = deadline.subtract(Duration(days: daysBefore));
    return DateTime(
      targetDay.year,
      targetDay.month,
      targetDay.day,
      9,
      0,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _toZonedDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    String? payload,
  }) async {
    final importance = channelId == 'deadlines'
        ? Importance.high
        : Importance.defaultImportance;
    final priority = channelId == 'deadlines'
        ? Priority.high
        : Priority.defaultPriority;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _toZonedDateTime(scheduledDate),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName(channelId),
          channelDescription: _channelDescription(channelId),
          importance: importance,
          priority: priority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
    await _trackScheduledId(id);
  }

  Future<void> _createAndroidChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return;
    }

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'deadlines',
        'Deadline Reminders',
        description: 'Smart reminders before task and opportunity deadlines',
        importance: Importance.high,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'daily_brief',
        'Daily Brief',
        description: 'Daily executive brief reminder',
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'deep_work',
        'Focus Nudges',
        description: 'Reminders to start a focus session',
      ),
    );
  }

  void _configureLocalTimeZone() {
    tz.initializeTimeZones();
    final offset = DateTime.now().timeZoneOffset;
    for (final name in _timeZoneCandidates(offset)) {
      try {
        tz.setLocalLocation(tz.getLocation(name));
        return;
      } catch (_) {}
    }
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  List<String> _timeZoneCandidates(Duration offset) {
    final minutes = offset.inMinutes;
    final hours = offset.inHours;
    final etcSign = hours >= 0 ? '-' : '+';

    final regional = switch (minutes) {
      0 => 'UTC',
      60 => 'Europe/Paris',
      120 => 'Europe/Helsinki',
      180 => 'Europe/Moscow',
      330 => 'Asia/Kolkata',
      480 => 'Asia/Singapore',
      540 => 'Asia/Tokyo',
      -300 => 'America/New_York',
      -360 => 'America/Chicago',
      -420 => 'America/Denver',
      -480 => 'America/Los_Angeles',
      _ => null,
    };

    return [
      ?regional,
      'Etc/GMT$etcSign${hours.abs()}',
      'UTC',
    ];
  }

  String _channelName(String channelId) {
    return switch (channelId) {
      'deadlines' => 'Deadline Reminders',
      'daily_brief' => 'Daily Brief',
      'deep_work' => 'Focus Nudges',
      _ => channelId,
    };
  }

  String _channelDescription(String channelId) {
    return switch (channelId) {
      'deadlines' =>
        'Smart reminders before task and opportunity deadlines',
      'daily_brief' => 'Daily executive brief reminder',
      'deep_work' => 'Reminders to start a focus session',
      _ => channelId,
    };
  }

  String? _channelIdFromPayload(String? payload) {
    if (payload == null) {
      return null;
    }
    if (payload.startsWith('/|deep_work')) {
      return 'deep_work';
    }
    if (payload == '/daily-brief') {
      return 'daily_brief';
    }
    if (payload.startsWith('/tasks/') ||
        payload.startsWith('/opportunities/')) {
      return 'deadlines';
    }
    if (payload == '/') {
      return 'deep_work';
    }
    return null;
  }

  Future<void> _trackScheduledId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = {
      ...?prefs
          .getStringList(scheduledNotificationIdsPreferenceKey)
          ?.map(int.parse),
      id,
    };
    await prefs.setStringList(
      scheduledNotificationIdsPreferenceKey,
      ids.map((value) => value.toString()).toList(),
    );
  }

  Future<void> _untrackScheduledId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(scheduledNotificationIdsPreferenceKey) ??
        const <String>[];
    final updated = ids.where((value) => value != id.toString()).toList();
    await prefs.setStringList(
      scheduledNotificationIdsPreferenceKey,
      updated,
    );
  }
}

String? notificationRouteFromPayload(String? payload) {
  if (payload == null || payload.isEmpty) {
    return null;
  }
  if (payload.startsWith('/|deep_work')) {
    return '/';
  }
  return payload;
}

bool isDeepWorkNotificationPayload(String? payload) {
  return payload == '/' || payload == '/|deep_work';
}
