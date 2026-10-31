import '../entities/notification_settings_entity.dart';
import '../repositories/notification_settings_repository.dart';

class GetNotificationSettings {
  final NotificationSettingsRepository repository;

  GetNotificationSettings(this.repository);

  Future<NotificationSettingsEntity> call() {
    return repository.getNotificationSettings();
  }
}