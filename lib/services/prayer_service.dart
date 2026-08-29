import 'package:hive_flutter/hive_flutter.dart';

import '../api_services/prayer_api_service.dart';
import '../models/prayer_times_model.dart';
import '../services/notification_service.dart';

class PrayerService {
  final PrayerApiService apiService = PrayerApiService();

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

    return PrayerTimesModel.fromJson(Map<String, dynamic>.from(rawTimings));
  }

  Future<void> scheduleUpcomingNotifications() async {
    final settingsBox = await Hive.openBox('settings');

    final enabled =
        settingsBox.get('prayerNotificationsEnabled', defaultValue: true)
            as bool;

    if (!enabled) {
      await NotificationService.cancelPrayerNotifications();
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

    await NotificationService.schedulePrayerCalendar(currentMonth, nextMonth);
  }
}
