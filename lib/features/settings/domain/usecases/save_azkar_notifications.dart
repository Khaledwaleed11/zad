import '../repositories/notification_settings_repository.dart';

class SaveAzkarNotifications {
  final NotificationSettingsRepository repository;

  SaveAzkarNotifications(this.repository);

  Future<void> call(bool enabled) {
    return repository.saveAzkarNotifications(enabled);
  }
}