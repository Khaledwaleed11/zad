import '../api_services/prayer_api_service.dart';
import '../models/prayer_times_model.dart';

class PrayerService {
  final PrayerApiService apiService = PrayerApiService();

  Future<PrayerTimesModel> getPrayerTimes() async {
    final data = await apiService.getPrayerTimes();

    final timings = data['data']['timings'] as Map<String, dynamic>;

    return PrayerTimesModel.fromJson(timings);
  }
}
