class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;

  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      fajr: json['Fajr']?.toString() ?? '--:--',
      sunrise: json['Sunrise']?.toString() ?? '--:--',
      dhuhr: json['Dhuhr']?.toString() ?? '--:--',
      asr: json['Asr']?.toString() ?? '--:--',
      sunset: json['Sunset']?.toString() ?? '--:--',
      maghrib: json['Maghrib']?.toString() ?? '--:--',
      isha: json['Isha']?.toString() ?? '--:--',
    );
  }
}
