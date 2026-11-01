import '../../../settings/domain/usecases/get_notification_settings.dart';
import 'schedule_prayer_notifications.dart';
import 'cancel_prayer_notifications.dart';
import 'schedule_azkar_notifications.dart';
import 'cancel_azkar_notifications.dart';
import 'schedule_salawat_notifications.dart';
import 'cancel_salawat_notifications.dart';

class InitializeNotifications {
  final GetNotificationSettings getNotificationSettings;
  final SchedulePrayerNotifications schedulePrayerNotifications;
  final CancelPrayerNotifications cancelPrayerNotifications;
  final ScheduleAzkarNotifications scheduleAzkarNotifications;
  final CancelAzkarNotifications cancelAzkarNotifications;
  final ScheduleSalawatNotifications scheduleSalawatNotifications;
  final CancelSalawatNotifications cancelSalawatNotifications;

  InitializeNotifications({
    required this.getNotificationSettings,
    required this.schedulePrayerNotifications,
    required this.cancelPrayerNotifications,
    required this.scheduleAzkarNotifications,
    required this.cancelAzkarNotifications,
    required this.scheduleSalawatNotifications,
    required this.cancelSalawatNotifications,
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

    if (settings.salawatNotificationsEnabled) {
      await scheduleSalawatNotifications();
    } else {
      await cancelSalawatNotifications();
    }
  }
}