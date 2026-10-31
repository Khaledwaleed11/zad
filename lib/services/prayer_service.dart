import '../core/constants/storage_constants.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../api_services/prayer_api_service.dart';
import '../models/prayer_times_model.dart';
import '../features/notifications/data/datasources/notification_service.dart';
import '../features/adhan_voices/domain/usecases/get_selected_adhan_voice.dart';
import '../features/adhan_voices/domain/usecases/get_cached_adhan_voice_path.dart';

class PrayerService {
  final PrayerApiService apiService;
  final GetSelectedAdhanVoice getSelectedAdhanVoice;
  final GetCachedAdhanVoicePath getCachedAdhanVoicePath;

  static const MethodChannel _adhanChannel =
  MethodChannel('com.example.zad/adhan');

  PrayerService({
    required this.getSelectedAdhanVoice,
    required this.getCachedAdhanVoicePath,
    PrayerApiService? apiService,
  }) : apiService = apiService ?? PrayerApiService();

  Future<PrayerTimesModel> getPrayerTimes() async {
    final data = await apiService.getPrayerTimes();
    final rawData = data['data'];

    if (rawData is! Map) {
      throw Exception('Invalid prayer times response');
    }

    final rawTimings = rawData['timings'];

    if (rawTimings is! Map) {
      throw Exception('Prayer timings not found');
    }

    return PrayerTimesModel.fromJson(
      Map<String, dynamic>.from(rawTimings),
    );
  }

  Future<void> scheduleUpcomingNotifications() async {
    final settingsBox = await Hive.openBox(StorageConstants.settingsBox);
    final prayerNotificationsEnabled =
    settingsBox.get('prayerNotificationsEnabled', defaultValue: true)
    as bool;

    final adhanEnabled =
    settingsBox.get('adhanEnabled', defaultValue: false) as bool;

    if (!prayerNotificationsEnabled && !adhanEnabled) {
      await NotificationService.cancelPrayerNotifications();
      await _cancelAdhanAlarms();
      return;
    }

    final now = DateTime.now();

    final currentMonth = await apiService.getPrayerCalendar(
      month: now.month,
      year: now.year,
    );

    final nextMonthDate = DateTime(now.year, now.month + 1, 1);

    final nextMonth = await apiService.getPrayerCalendar(
      month: nextMonthDate.month,
      year: nextMonthDate.year,
    );

    // Keep the existing prayer notification scheduling independent.
    if (prayerNotificationsEnabled) {
      await NotificationService.schedulePrayerCalendar(
        currentMonth,
        nextMonth,
      );
    } else {
      await NotificationService.cancelPrayerNotifications();
    }

    // Schedule full Adhan playback independently.
    if (adhanEnabled) {
      await _scheduleAdhanAlarms(currentMonth, nextMonth);
    } else {
      await _cancelAdhanAlarms();
    }
  }

  Future<void> _scheduleAdhanAlarms(
      Map<String, dynamic> currentMonth,
      Map<String, dynamic> nextMonth,
      ) async {
    final voiceId = getSelectedAdhanVoice();

    if (voiceId == null || voiceId.isEmpty) {
      await _cancelAdhanAlarms();
      return;
    }

    final audioPath = await getCachedAdhanVoicePath(voiceId);

    if (audioPath == null || audioPath.isEmpty) {
      await _cancelAdhanAlarms();
      return;
    }

    final alarms = <Map<String, dynamic>>[];

    _collectMonthAlarms(currentMonth, audioPath, alarms);
    _collectMonthAlarms(nextMonth, audioPath, alarms);

    await _adhanChannel.invokeMethod<bool>(
      'scheduleAdhanAlarms',
      {'alarms': alarms},
    );
  }

  void _collectMonthAlarms(
      Map<String, dynamic> calendar,
      String audioPath,
      List<Map<String, dynamic>> alarms,
      ) {
    final days = calendar['data'];

    if (days is! List) {
      throw Exception('Invalid prayer calendar response');
    }

    const prayers = [
      ('Fajr', 'الفجر', 1),
      ('Dhuhr', 'الظهر', 2),
      ('Asr', 'العصر', 3),
      ('Maghrib', 'المغرب', 4),
      ('Isha', 'العشاء', 5),
    ];

    for (final day in days) {
      if (day is! Map) continue;

      final dateInfo = day['date'];
      final timings = day['timings'];

      if (dateInfo is! Map || timings is! Map) continue;

      final dateString = dateInfo['gregorian'] is Map
          ? dateInfo['gregorian']['date'] as String?
          : null;

      if (dateString == null) continue;

      for (final prayer in prayers) {
        final timeString = timings[prayer.$1];

        if (timeString is! String) continue;

        final prayerDateTime = _parsePrayerDateTime(
          dateString,
          timeString,
        );

        if (prayerDateTime == null ||
            !prayerDateTime.isAfter(DateTime.now())) {
          continue;
        }

        final dateParts = dateString.split('-');

        if (dateParts.length != 3) continue;

        final alarmId = int.parse(
          '${dateParts[2]}'
              '${dateParts[1].padLeft(2, '0')}'
              '${dateParts[0].padLeft(2, '0')}',
        ) * 10 + prayer.$3;

        alarms.add({
          'id': alarmId,
          'time': prayerDateTime.millisecondsSinceEpoch,
          'audioPath': audioPath,
          'prayerName': prayer.$2,
        });
      }
    }
  }

  DateTime? _parsePrayerDateTime(
      String dateString,
      String timeString,
      ) {
    try {
      final dateParts = dateString.split('-');

      if (dateParts.length != 3) return null;

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Remove timezone labels such as (EET).
      final cleanTime = timeString.trim().split(' ').first;
      final timeParts = cleanTime.split(':');

      if (timeParts.length < 2) return null;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cancelAdhanAlarms() async {
    await _adhanChannel.invokeMethod<bool>('cancelAdhanAlarms');
  }
}
