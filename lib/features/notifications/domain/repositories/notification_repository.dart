abstract class NotificationRepository {
  Future<void> schedulePrayerNotifications();

  Future<void> cancelPrayerNotifications();

  Future<void> scheduleAzkarNotifications();

  Future<void> cancelAzkarNotifications();

  Future<void> scheduleSalawatNotifications();

  Future<void> cancelSalawatNotifications();
}