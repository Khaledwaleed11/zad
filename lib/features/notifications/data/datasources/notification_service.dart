import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../models/prayer_times_model.dart';
import '../../presentation/services/notification_navigation_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _azkarChannel = MethodChannel(
    'com.example.zad/azkar',
  );

  static GlobalKey<NavigatorState> get navigatorKey =>
      NotificationNavigationService.navigatorKey;

  static const int _prayerIdPrefix = 500000000;

  // Legacy Flutter notification IDs.
  // We keep them to cancel previously scheduled Azkar notifications.
  static const int _morningAzkarId = 201;
  static const int _eveningAzkarId = 202;
  static const int _sleepAzkarId = 203;

  static const AndroidNotificationDetails _prayerAndroidDetails =
      AndroidNotificationDetails(
        'zad_prayer_channel_v2',
        'Prayer Notifications',
        channelDescription: 'Prayer time notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('zad_notification'),
        enableVibration: true,
      );

  static const int _salawatIdPrefix = 301;
  static const int _salawatCount = 16;

  static const AndroidNotificationDetails _salawatAndroidDetails =
      AndroidNotificationDetails(
        'zad_salawat_channel_v1',
        'Salawat Notifications',
        channelDescription: 'Daily salawat reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('zad_salat_alanabi'),
        enableVibration: true,
        color: Color(0xFF776344),
        category: AndroidNotificationCategory.reminder,
        styleInformation: BigTextStyleInformation(
          'اللهم صلِّ وسلم على نبينا محمد ﷺ ❤️',
          summaryText: 'ZAD | زاد',
        ),
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

    // Handle taps on native Azkar notifications while the app is running.
    _azkarChannel.setMethodCallHandler((call) async {
      if (call.method == 'onAzkarNotificationTapped') {
        final payload = call.arguments as String?;

        NotificationNavigationService.onNotificationTapped(payload);
      }
    });

    // Handle a native Azkar notification that launched the app.
    final initialAzkarPayload = await _azkarChannel.invokeMethod<String>(
      'getInitialAzkarPayload',
    );

    if (initialAzkarPayload != null && initialAzkarPayload.isNotEmpty) {
      NotificationNavigationService.onNotificationTapped(initialAzkarPayload);
    }

    // Handle Flutter local notification launches (prayer and salawat).
    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      NotificationNavigationService.onNotificationTapped(
        launchDetails?.notificationResponse?.payload,
      );
    }

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<bool> _canUseExactAlarms() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) {
      return false;
    }

    final canSchedule = await androidPlugin.canScheduleExactNotifications();

    return canSchedule == true;
  }

  static AndroidScheduleMode _getScheduleMode(bool exactAvailable) {
    if (exactAvailable) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    NotificationNavigationService.onNotificationTapped(response.payload);
  }

  static Future<void> handlePendingNotification() async {
    await NotificationNavigationService.handlePendingNotification();
  }

  // ---------------------------------------------------------------------------
  // Prayer Notifications - Flutter Local Notifications
  // ---------------------------------------------------------------------------

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

    final exactAvailable = await _canUseExactAlarms();

    final scheduleMode = _getScheduleMode(exactAvailable);

    for (final prayer in prayers) {
      final scheduledDate = _buildPrayerDateTime(prayer.time, now);

      if (scheduledDate == null) {
        continue;
      }

      if (!scheduledDate.isAfter(now)) {
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
        androidScheduleMode: scheduleMode,
      );
    }
  }

  static Future<void> schedulePrayerCalendar(
    Map<String, dynamic> currentMonth,
    Map<String, dynamic> nextMonth,
  ) async {
    await cancelPrayerNotifications();

    final exactAvailable = await _canUseExactAlarms();

    final scheduleMode = _getScheduleMode(exactAvailable);

    await _scheduleCalendar(currentMonth, scheduleMode);

    await _scheduleCalendar(nextMonth, scheduleMode);
  }

  static Future<void> _scheduleCalendar(
    Map<String, dynamic> calendar,
    AndroidScheduleMode scheduleMode,
  ) async {
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
        scheduleMode: scheduleMode,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 2),
        name: 'الظهر',
        time: prayerTimes.dhuhr,
        dateString: dateString,
        scheduleMode: scheduleMode,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 3),
        name: 'العصر',
        time: prayerTimes.asr,
        dateString: dateString,
        scheduleMode: scheduleMode,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 4),
        name: 'المغرب',
        time: prayerTimes.maghrib,
        dateString: dateString,
        scheduleMode: scheduleMode,
      );

      await _schedulePrayer(
        id: _createPrayerId(dateString, 5),
        name: 'العشاء',
        time: prayerTimes.isha,
        dateString: dateString,
        scheduleMode: scheduleMode,
      );
    }
  }

  static Future<void> _schedulePrayer({
    required int id,
    required String name,
    required String time,
    required String dateString,
    required AndroidScheduleMode scheduleMode,
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
      androidScheduleMode: scheduleMode,
    );
  }

  // ---------------------------------------------------------------------------
  // Salawat Notifications - Flutter Local Notifications
  // ---------------------------------------------------------------------------

  static Future<void> scheduleSalawatNotifications() async {
    await cancelSalawatNotifications();

    final now = tz.TZDateTime.now(tz.local);
    final exactAvailable = await _canUseExactAlarms();
    final scheduleMode = _getScheduleMode(exactAvailable);

    for (int i = 0; i < _salawatCount; i++) {
      final totalMinutes = i * 90;
      final hour = totalMinutes ~/ 60;
      final minute = totalMinutes % 60;

      final scheduledDate = _nextDailyTime(now, hour, minute);

      await _notifications.zonedSchedule(
        id: _salawatIdPrefix + i,
        title: 'صلِّ على النبي ﷺ',
        body: 'اللهم صلِّ وسلم على نبينا محمد ﷺ ❤️',
        payload: 'salawat',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: _salawatAndroidDetails,
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> testSalawatNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'zad_salawat_channel_v1',
        'Salawat Notifications',
        channelDescription: 'Daily salawat reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('zad_salat_alanabi'),
        enableVibration: true,
      ),
    );

    await _notifications.show(
      id: 998,
      title: 'صلِّ على النبي ﷺ',
      body: 'اللهم صلِّ وسلم على نبينا محمد ﷺ ❤️',
      notificationDetails: details,
      payload: 'salawat',
    );
  }

  static Future<void> cancelSalawatNotifications() async {
    for (int i = 0; i < _salawatCount; i++) {
      await _notifications.cancel(id: _salawatIdPrefix + i);
    }
  }

  // ---------------------------------------------------------------------------
  // Azkar Notifications - Native Android
  // ---------------------------------------------------------------------------

  static Future<void> scheduleAzkarNotifications() async {
    // Cancel old Flutter notifications and any previous native alarms.
    await cancelAzkarNotifications();

    await _azkarChannel.invokeMethod<void>('scheduleAzkarAlarms');
  }

  static Future<void> cancelAzkarNotifications() async {
    // Remove notifications scheduled by the old Flutter implementation.
    await _notifications.cancel(id: _morningAzkarId);
    await _notifications.cancel(id: _eveningAzkarId);
    await _notifications.cancel(id: _sleepAzkarId);

    // Cancel native Android alarms.
    await _azkarChannel.invokeMethod<void>('cancelAzkarAlarms');
  }

  static Future<void> testAzkarNotification() async {
    await _azkarChannel.invokeMethod<void>('showTestAzkarNotification');
  }

  // ---------------------------------------------------------------------------
  // Date Helpers
  // ---------------------------------------------------------------------------

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

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

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
      final cleanTime = time.trim().split(' ').first;
      final timeParts = cleanTime.split(':');

      if (dateParts.length != 3 || timeParts.length < 2) {
        return null;
      }

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59 ||
          day < 1 ||
          day > 31 ||
          month < 1 ||
          month > 12) {
        return null;
      }

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

  // ---------------------------------------------------------------------------
  // Cancellation & Debug
  // ---------------------------------------------------------------------------

  static Future<void> cancelPrayerNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();

    for (final notification in pending) {
      if (notification.id >= _prayerIdPrefix &&
          notification.id < _prayerIdPrefix + 300000000) {
        await _notifications.cancel(id: notification.id);
      }
    }
  }

  static Future<void> debugPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();

    debugPrint('ZAD: Total pending = ${pending.length}');

    for (final notification in pending) {
      debugPrint(
        'ZAD: Pending ID=${notification.id}, '
        'Title=${notification.title}',
      );
    }
  }

  static Future<void> testNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'zad_test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await _notifications.show(
      id: 999,
      title: 'ZAD ✅',
      body: 'الإشعارات شغالة تمام.',
      notificationDetails: details,
      payload: 'prayer',
    );
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
