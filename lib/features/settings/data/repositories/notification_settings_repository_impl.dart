import '../../domain/entities/notification_settings_entity.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../datasources/notification_settings_local_data_source.dart';

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  final NotificationSettingsLocalDataSource localDataSource;

  NotificationSettingsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<NotificationSettingsEntity> getNotificationSettings() async {
    final model = await localDataSource.getNotificationSettings();
    return model.toEntity();
  }

  @override
  Future<void> savePrayerNotifications(bool enabled) {
    return localDataSource.savePrayerNotifications(enabled);
  }

  @override
  Future<void> saveAzkarNotifications(bool enabled) {
    return localDataSource.saveAzkarNotifications(enabled);
  }

  @override
  Future<void> saveAdhanEnabled(bool enabled) {
    return localDataSource.saveAdhanEnabled(enabled);
  }
}