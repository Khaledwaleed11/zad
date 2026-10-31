import '../../domain/entities/prayer_calendar_day_entity.dart';
import 'prayer_times_model.dart';

class PrayerCalendarDayModel {
  final DateTime date;
  final PrayerTimesModel prayerTimes;

  const PrayerCalendarDayModel({
    required this.date,
    required this.prayerTimes,
  });

  factory PrayerCalendarDayModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final dateData = json['date'];
    final timingsData = json['timings'];

    if (dateData is! Map || timingsData is! Map) {
      throw const FormatException('Invalid prayer calendar data');
    }

    final gregorian = dateData['gregorian'];

    if (gregorian is! Map) {
      throw const FormatException('Gregorian date not found');
    }

    final dateString = gregorian['date']?.toString();

    if (dateString == null) {
      throw const FormatException('Invalid calendar date');
    }

    final dateParts = dateString.split('-');

    if (dateParts.length != 3) {
      throw const FormatException('Invalid date format');
    }

    final date = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
    );

    final prayerTimes = PrayerTimesModel.fromJson(
      Map<String, dynamic>.from(timingsData),
    );

    return PrayerCalendarDayModel(
      date: date,
      prayerTimes: prayerTimes,
    );
  }

  PrayerCalendarDayEntity toEntity() {
    return PrayerCalendarDayEntity(
      date: date,
      prayerTimes: prayerTimes.toEntity(),
    );
  }
}