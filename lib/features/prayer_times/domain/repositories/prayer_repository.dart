import '../entities/prayer_calendar_day_entity.dart';
import '../entities/prayer_times_entity.dart';

abstract class PrayerRepository {
  Future<PrayerTimesEntity> getPrayerTimes();

  Future<List<PrayerCalendarDayEntity>> getPrayerCalendar({
    required int month,
    required int year,
  });
}