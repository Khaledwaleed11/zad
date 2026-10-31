import 'prayer_times_entity.dart';

class PrayerCalendarDayEntity {
  final DateTime date;
  final PrayerTimesEntity prayerTimes;

  const PrayerCalendarDayEntity({
    required this.date,
    required this.prayerTimes,
  });
}