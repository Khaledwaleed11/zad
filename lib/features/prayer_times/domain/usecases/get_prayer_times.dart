import '../entities/prayer_times_entity.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTimes {
  final PrayerRepository repository;

  GetPrayerTimes(this.repository);

  Future<PrayerTimesEntity> call() {
    return repository.getPrayerTimes();
  }
}