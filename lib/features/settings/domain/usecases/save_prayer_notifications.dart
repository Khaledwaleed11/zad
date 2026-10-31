import '../repositories/notification_settings_repository.dart';

class SavePrayerNotifications {
  final NotificationSettingsRepository repository;

  SavePrayerNotifications(this.repository);

  Future<void> call(bool enabled) {
    return repository.savePrayerNotifications(enabled);
  }
}