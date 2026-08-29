import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_times_model.dart';
import '../screens/azkar_screen.dart';
import '../screens/prayer_times_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static String? _pendingPayload;

  static const int _prayerIdPrefix = 500000000;

  static const int _morningAzkarId = 201;
  static const int _eveningAzkarId = 202;
  static const int _sleepAzkarId = 203;

  static const AndroidNotificationDetails _prayerAndroidDetails =
      AndroidNotificationDetails(
        'zad_prayer_channel',
        'Prayer Notifications',
        channelDescription: 'Prayer time notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

  static const AndroidNotificationDetails _azkarAndroidDetails =
      AndroidNotificationDetails(
        'zad_azkar_channel',
        'Azkar Notifications',
        channelDescription: 'Daily Azkar reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      _pendingPayload = launchDetails?.notificationResponse?.payload;
    }

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    if (navigatorKey.currentState == null) {
      _pendingPayload = payload;
      return;
    }

    _openFromPayload(payload);
  }

  static Future<void> handlePendingNotification() async {
    final payload = _pendingPayload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    _pendingPayload = null;

    await Future.delayed(const Duration(milliseconds: 300));

    if (navigatorKey.currentState == null) {
      _pendingPayload = payload;
      return;
    }

    _openFromPayload(payload);
  }

  static void _openFromPayload(String payload) {
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      _pendingPayload = payload;
      return;
    }

    switch (payload) {
      case 'prayer':
        navigator.push(
          MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
        );
        break;

      case 'azkar_morning':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const AzkarScreen(initialCategory: 'morning'),
          ),
        );
        break;

      case 'azkar_evening':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const AzkarScreen(initialCategory: 'evening'),
          ),
        );
        break;

      case 'azkar_sleep':
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const AzkarScreen(initialCategory: 'sleep'),
          ),
        );
        break;
    }
  }

  static Future<void> schedulePrayerNotifications(
    PrayerTimesModel prayerTimes,
  ) async {
    await cancelPrayerNotifications();

    final now = tz.TZDateTime.now(tz.local);

    final prayers = [
      _PrayerNotification(id: 101, name: 'الفجر', time: prayerTimes.fajr),
      _PrayerNotification(id: 102, name: 'الظهر', time: prayerTimes.dhuhr),
      _PrayerNotification(id: 103, name: 'العصر', time: prayerTimes.asr),
      _PrayerNotification(id: 104, name: 'المغرب', time: prayerTimes.maghrib),
      _PrayerNotification(id: 105, name: 'العشاء', time: prayerTimes.isha),
    ];

    for (final prayer in prayers) {
      final scheduledDate = _buildPrayerDateTime(prayer.time, now);

      if (scheduledDate == null || !scheduledDate.isAfter(now)) {
        continue;
      }

      await _notifications.zonedSchedule(
        id: prayer.id,
        title: 'حان وقت صلاة ${prayer.name} 🕌',
        body: 'حيّ على الصلاة',
        payload: 'prayer',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: _prayerAndroidDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> schedulePrayerCalendar(
    Map<String, dynamic> currentMonth,
    Map<String, dynamic> nextMonth,
  ) async {
    await cancelPrayerNotifications();

    await _scheduleCalendar(currentMonth);

    await _scheduleCalendar(nextMonth);
  }

  static Future<void> _scheduleCalendar(Map<String, dynamic> calendar) async {
    final data = calendar['data'];

    if (data is! List) {
      return;
    }

    for (final day in data) {
      if (day is! Map) {
        continue;
      }

      final date = day['date'];
      final timings = day['timings'];

      if (date is! Map || timings is! Map) {
        continue;
      }

      final gregorian = date['gregorian'];

      if (gregorian is! Map) {
        continue;
      }

      final dateString = gregorian['date']?.toString();

      if (dateString == null || dateString.isEmpty) {
        continue;
      }

      final prayerTimes = PrayerTimesModel.fromJson(
        Map<String, dynamic>.from(timings),
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 1),
        name: 'الفجر',
        time: prayerTimes.fajr,
        dateString: dateString,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 2),
        name: 'الظهر',
        time: prayerTimes.dhuhr,
        dateString: dateString,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 3),
        name: 'العصر',
        time: prayerTimes.asr,
        dateString: dateString,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 4),
        name: 'المغرب',
        time: prayerTimes.maghrib,
        dateString: dateString,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 5),
        name: 'العشاء',
        time: prayerTimes.isha,
        dateString: dateString,
      );
    }
  }

  static Future<void> _schedulePrayer({
    required int id,
    required String name,
    required String time,
    required String dateString,
  }) async {
    final scheduledDate = _buildDateTime(dateString, time);

    if (scheduledDate == null) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    if (!scheduledDate.isAfter(now)) {
      return;
    }

    await _notifications.zonedSchedule(
      id: id,
      title: 'حان وقت صلاة $name 🕌',
      body: 'حيّ على الصلاة',
      payload: 'prayer',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _prayerAndroidDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleAzkarNotifications() async {
    await cancelAzkarNotifications();

    final now = tz.TZDateTime.now(tz.local);

    final morning = _nextDailyTime(now, 7, 0);

    final evening = _nextDailyTime(now, 17, 0);

    final sleep = _nextDailyTime(now, 23, 0);

    const details = NotificationDetails(android: _azkarAndroidDetails);

    await _notifications.zonedSchedule(
      id: _morningAzkarId,
      title: 'أذكار الصباح 🌤️',
      body: 'حان الآن وقت أذكار الصباح',
      payload: 'azkar_morning',
      scheduledDate: morning,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _notifications.zonedSchedule(
      id: _eveningAzkarId,
      title: 'أذكار المساء 🌙',
      body: 'حان الآن وقت أذكار المساء',
      payload: 'azkar_evening',
      scheduledDate: evening,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _notifications.zonedSchedule(
      id: _sleepAzkarId,
      title: 'أذكار النوم 🌙',
      body: 'لا تنسَ أذكار النوم',
      payload: 'azkar_sleep',
      scheduledDate: sleep,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextDailyTime(tz.TZDateTime now, int hour, int minute) {
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static tz.TZDateTime? _buildPrayerDateTime(String time, tz.TZDateTime now) {
    try {
      final parts = time.trim().split(':');

      if (parts.length < 2) {
        return null;
      }

      final hour = int.parse(parts[0]);

      final minute = int.parse(parts[1]);

      return tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }

  static tz.TZDateTime? _buildDateTime(String dateString, String time) {
    try {
      final dateParts = dateString.split('-');

      final timeParts = time.trim().split(':');

      if (dateParts.length != 3 || timeParts.length < 2) {
        return null;
      }

      final day = int.parse(dateParts[0]);

      final month = int.parse(dateParts[1]);

      final year = int.parse(dateParts[2]);

      final hour = int.parse(timeParts[0]);

      final minute = int.parse(timeParts[1]);

      return tz.TZDateTime(tz.local, year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  static int _createPrayerId(String dateString, int prayerNumber) {
    final cleanDate = dateString.replaceAll('-', '');

    final date = int.tryParse(cleanDate) ?? 0;

    return _prayerIdPrefix + (date * 10) + prayerNumber;
  }

  static Future<void> cancelPrayerNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();

    for (final notification in pending) {
      if (notification.id >= _prayerIdPrefix &&
          notification.id < _prayerIdPrefix + 300000000) {
        await _notifications.cancel(id: notification.id);
      }
    }
  }

  static Future<void> cancelAzkarNotifications() async {
    await _notifications.cancel(id: _morningAzkarId);

    await _notifications.cancel(id: _eveningAzkarId);

    await _notifications.cancel(id: _sleepAzkarId);
  }
}

class _PrayerNotification {
  final int id;
  final String name;
  final String time;

  const _PrayerNotification({
    required this.id,
    required this.name,
    required this.time,
  });
}
