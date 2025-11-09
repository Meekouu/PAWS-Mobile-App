import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../model/vaccine_model.dart';
import '../services/vaccine_service.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone init
    tz.initializeTimeZones();
    final String timeZoneName = await tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _fln.initialize(initSettings);

    if (Platform.isAndroid) {
      final androidImpl = _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission(); // Android 13+
    }

    _initialized = true;
  }

  Future<void> clearAllScheduled() async {
    await _fln.cancelAll();
  }

  NotificationDetails _defaultDetails({AndroidNotificationChannel? channel}) {
    const androidDetails = AndroidNotificationDetails(
      'vaccine_reminders_channel',
      'Vaccine Reminders',
      channelDescription: 'Reminders for upcoming and overdue vaccinations',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    );

    return const NotificationDetails(android: androidDetails);
  }

  tz.TZDateTime _at9amLocal(DateTime base) {
    final now = tz.TZDateTime.now(tz.local);
    final dateLocal = tz.TZDateTime.from(base, tz.local);
    final scheduled = tz.TZDateTime(tz.local, dateLocal.year, dateLocal.month, dateLocal.day, 9);
    if (scheduled.isBefore(now)) {
      return now.add(const Duration(seconds: 5));
    }
    return scheduled;
  }

  Future<void> scheduleForVaccination(String petName, Vaccination v) async {
    final id = v.id.hashCode & 0x7fffffff; // stable positive id
    final title = 'Vaccine reminder for $petName';
    final body = '${v.name} due on ${v.nextDueDate.month}/${v.nextDueDate.day}/${v.nextDueDate.year}';
    final when = _at9amLocal(v.nextDueDate);
    try {
      await _fln.zonedSchedule(
        id,
        title,
        body,
        when,
        _defaultDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } on PlatformException catch (e) {
      // Android 13+ without SCHEDULE_EXACT_ALARM: fall back to inexact
      if (e.code == 'exact_alarms_not_permitted') {
        await _fln.zonedSchedule(
          id,
          title,
          body,
          when,
          _defaultDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> scheduleOverdueNow(String petName, Vaccination v) async {
    final id = (v.id.hashCode ^ 0xABCDEF).abs();
    final title = 'Overdue vaccine for $petName';
    final body = '${v.name} is overdue by ${v.daysUntilDue.abs()} day(s)';
    // Show immediately (no exact alarm permission needed)
    await _fln.show(
      id,
      title,
      body,
      _defaultDetails(),
    );
  }

  Future<void> refreshSchedules() async {
    await initialize();
    await clearAllScheduled();

    final data = await VaccineService().getAllUserPetVaccinations();
    for (final entry in data.entries) {
      final petName = entry.key;
      for (final v in entry.value) {
        // Only notify within 14 days window or overdue
        if (v.daysUntilDue < 0) {
          await scheduleOverdueNow(petName, v);
        } else if (v.daysUntilDue <= 14) {
          await scheduleForVaccination(petName, v);
        }
      }
    }
  }
}
