import '../entities/notification_settings_entity.dart';

abstract class NotificationSettingsRepository {
  Future<NotificationSettingsEntity> getNotificationSettings();

  Future<void> savePrayerNotifications(bool enabled);

  Future<void> saveAzkarNotifications(bool enabled);

  Future<void> saveAdhanEnabled(bool enabled);

  Future<void> saveSalawatNotifications(bool enabled);
}