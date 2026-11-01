import '../../domain/entities/notification_settings_entity.dart';

class NotificationSettingsModel {
  final bool prayerNotificationsEnabled;
  final bool azkarNotificationsEnabled;
  final bool adhanEnabled;
  final bool salawatNotificationsEnabled;

  const NotificationSettingsModel({
    required this.prayerNotificationsEnabled,
    required this.azkarNotificationsEnabled,
    required this.adhanEnabled,
    required this.salawatNotificationsEnabled,
  });

  factory NotificationSettingsModel.fromHive({
    required bool prayerNotificationsEnabled,
    required bool azkarNotificationsEnabled,
    required bool adhanEnabled,
    required bool salawatNotificationsEnabled,
  }) {
    return NotificationSettingsModel(
      prayerNotificationsEnabled: prayerNotificationsEnabled,
      azkarNotificationsEnabled: azkarNotificationsEnabled,
      adhanEnabled: adhanEnabled,
      salawatNotificationsEnabled: salawatNotificationsEnabled,
    );
  }

  NotificationSettingsEntity toEntity() {
    return NotificationSettingsEntity(
      prayerNotificationsEnabled: prayerNotificationsEnabled,
      azkarNotificationsEnabled: azkarNotificationsEnabled,
      adhanEnabled: adhanEnabled,
      salawatNotificationsEnabled: salawatNotificationsEnabled,
    );
  }
}