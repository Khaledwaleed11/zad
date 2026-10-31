import '../../domain/entities/prayer_calendar_day_entity.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_remote_data_source.dart';
import '../models/prayer_calendar_day_model.dart';
import '../models/prayer_times_model.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerRemoteDataSource remoteDataSource;

  PrayerRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<PrayerTimesEntity> getPrayerTimes() async {
    final response = await remoteDataSource.getPrayerTimes();

    final rawData = response['data'];

    if (rawData is! Map) {
      throw Exception('Invalid prayer times response');
    }

    final rawTimings = rawData['timings'];

    if (rawTimings is! Map) {
      throw Exception('Prayer timings not found');
    }

    final model = PrayerTimesModel.fromJson(
      Map<String, dynamic>.from(rawTimings),
    );

    return model.toEntity();
  }

  @override
  Future<List<PrayerCalendarDayEntity>> getPrayerCalendar({
    required int month,
    required int year,
  }) async {
    final response = await remoteDataSource.getPrayerCalendar(
      month: month,
      year: year,
    );

    final rawData = response['data'];

    if (rawData is! List) {
      throw Exception('Invalid prayer calendar response');
    }

    return rawData.map((day) {
      if (day is! Map) {
        throw Exception('Invalid prayer calendar day');
      }

      return PrayerCalendarDayModel.fromJson(
        Map<String, dynamic>.from(day),
      ).toEntity();
    }).toList();
  }
}