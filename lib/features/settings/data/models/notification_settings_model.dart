import '../../domain/entities/notification_settings_entity.dart';

class NotificationSettingsModel {
  final bool prayerNotificationsEnabled;
  final bool azkarNotificationsEnabled;
  final bool adhanEnabled;

  const NotificationSettingsModel({
    required this.prayerNotificationsEnabled,
    required this.azkarNotificationsEnabled,
    required this.adhanEnabled,
  });

  factory NotificationSettingsModel.fromHive({
    required bool prayerNotificationsEnabled,
    required bool azkarNotificationsEnabled,
    required bool adhanEnabled,
  }) {
    return NotificationSettingsModel(
      prayerNotificationsEnabled: prayerNotificationsEnabled,
      azkarNotificationsEnabled: azkarNotificationsEnabled,
      adhanEnabled: adhanEnabled,
    );
  }

  NotificationSettingsEntity toEntity() {
    return NotificationSettingsEntity(
      prayerNotificationsEnabled: prayerNotificationsEnabled,
      azkarNotificationsEnabled: azkarNotificationsEnabled,
      adhanEnabled: adhanEnabled,
    );
  }
}