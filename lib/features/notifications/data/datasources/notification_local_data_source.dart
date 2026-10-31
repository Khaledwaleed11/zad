
import 'notification_service.dart';
import '../../../../services/prayer_service.dart';

abstract class NotificationLocalDataSource {
  Future<void> schedulePrayerNotifications();

  Future<void> cancelPrayerNotifications();

  Future<void> scheduleAzkarNotifications();

  Future<void> cancelAzkarNotifications();
}

class NotificationLocalDataSourceImpl
    implements NotificationLocalDataSource {
  final PrayerService prayerService;

  NotificationLocalDataSourceImpl({
    required this.prayerService,
  });

  @override
  Future<void> schedulePrayerNotifications() async {
    await prayerService.scheduleUpcomingNotifications();
  }

  @override
  Future<void> cancelPrayerNotifications() async {
    await NotificationService.cancelPrayerNotifications();
  }

  @override
  Future<void> scheduleAzkarNotifications() async {
    await NotificationService.scheduleAzkarNotifications();
  }

  @override
  Future<void> cancelAzkarNotifications() async {
    await NotificationService.cancelAzkarNotifications();
  }
}
