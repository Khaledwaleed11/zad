import '../../../settings/domain/repositories/notification_settings_repository.dart';

class SaveSalawatNotifications {
  final NotificationSettingsRepository repository;

  SaveSalawatNotifications(this.repository);

  Future<void> call(bool enabled) {
    return repository.saveSalawatNotifications(enabled);
  }
}