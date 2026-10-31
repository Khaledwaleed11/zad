import '../entities/prayer_calendar_day_entity.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerCalendar {
  final PrayerRepository repository;

  GetPrayerCalendar(this.repository);

  Future<List<PrayerCalendarDayEntity>> call({
    required int month,
    required int year,
  }) {
    return repository.getPrayerCalendar(
      month: month,
      year: year,
    );
  }
}