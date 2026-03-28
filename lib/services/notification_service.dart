// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/models.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// Schedule a notification for a ReminderModel
  static Future<void> schedule(ReminderModel reminder) async {
    final timeParts = reminder.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final id = reminder.id.hashCode;

    final androidDetails = AndroidNotificationDetails(
      'cardiac_reminders',
      'Health Reminders',
      channelDescription: 'Reminders for your health activities',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
        android: androidDetails, iOS: iosDetails);

    if (reminder.repeat == 'daily') {
      await _plugin.zonedSchedule(
        id,
        '🔔 Health Reminder',
        reminder.title,
        _nextInstanceOfTime(hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (reminder.repeat == 'weekly') {
      // Schedule once per selected day
      for (final day in reminder.daysOfWeek) {
        await _plugin.zonedSchedule(
          id + day, // unique id per day
          '🔔 Health Reminder',
          reminder.title,
          _nextInstanceOfDayTime(day, hour, minute),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } else {
      // One-time
      await _plugin.zonedSchedule(
        id,
        '🔔 Health Reminder',
        reminder.title,
        _nextInstanceOfTime(hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancel(String reminderId) async {
    await _plugin.cancel(reminderId.hashCode);
    // Also cancel weekly day variants
    for (int d = 1; d <= 7; d++) {
      await _plugin.cancel(reminderId.hashCode + d);
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _nextInstanceOfDayTime(
      int dayOfWeek, int hour, int minute) {
    var now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // dayOfWeek: 1=Mon, 7=Sun; DateTime.weekday: 1=Mon, 7=Sun
    while (scheduled.weekday != dayOfWeek ||
        scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
