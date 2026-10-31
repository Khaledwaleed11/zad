import '../repositories/notification_settings_repository.dart';

class SaveAdhanEnabled {
  final NotificationSettingsRepository repository;

  SaveAdhanEnabled(this.repository);

  Future<void> call(bool enabled) {
    return repository.saveAdhanEnabled(enabled);
  }
}