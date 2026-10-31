
import '../../../settings/domain/usecases/get_notification_settings.dart';
import 'schedule_prayer_notifications.dart';
import 'cancel_prayer_notifications.dart';
import 'schedule_azkar_notifications.dart';
import 'cancel_azkar_notifications.dart';

class InitializeNotifications {
  final GetNotificationSettings getNotificationSettings;
  final SchedulePrayerNotifications schedulePrayerNotifications;
  final CancelPrayerNotifications cancelPrayerNotifications;
  final ScheduleAzkarNotifications scheduleAzkarNotifications;
  final CancelAzkarNotifications cancelAzkarNotifications;

  InitializeNotifications({
    required this.getNotificationSettings,
    required this.schedulePrayerNotifications,
    required this.cancelPrayerNotifications,
    required this.scheduleAzkarNotifications,
    required this.cancelAzkarNotifications,
  });

  Future<void> call() async {
    final settings = await getNotificationSettings();

    if (settings.prayerNotificationsEnabled) {
      await schedulePrayerNotifications();
    } else {
      await cancelPrayerNotifications();
    }

    if (settings.azkarNotificationsEnabled) {
      await scheduleAzkarNotifications();
    } else {
      await cancelAzkarNotifications();
    }
  }
}
